//
//  CMCloudPredictionConfigManager.m
//  PandaKeyboard
//
//  Created by yanzhao on 2017/7/4.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMCloudPredictionConfigManager.h"
#import "CMKeyboardRequestFactory.h"
#import "CMSettingManager.h"
#import "NSString+Common.h"

@interface CMCloudPredictionConfigManager(){
}
@property (nonatomic, strong)NSString* language;
@property (nonatomic, strong)NSURLSessionDataTask * task;
@property (nonatomic, assign)   BOOL  isRequesting;
@end

@implementation CMCloudPredictionConfigManager

- (void)dealloc {
    kLogTrace();
    if (self.task) {
        [self.task cancel];
        self.task = nil;
    }
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.isRequesting = NO;
    
    return self;
}

- (NSString *)webSocketAddress{
    NSUserDefaults * standard = [NSUserDefaults standardUserDefaults];
    return [standard objectForKey:kGlobalUserDefaultsCloudPredictionAddres];
}

- (void)resetWithLanguage:(NSString*)language  isForce:(BOOL) isForce completionBlock:(CompletionBlock)block{
    self.language = language;
    if(!isForce){
        NSUserDefaults * standard = [NSUserDefaults standardUserDefaults];
        NSInteger requestTime =  [standard integerForKey:kGlobalUserDefaultsCloudPredictionConfigServerRequstTime];
        BOOL cachTiemout =  ([[NSDate date] timeIntervalSince1970] -requestTime )>2400;//60*40
        if(!cachTiemout){
            if(block){
                if(![self isSupportLan:self.language]){
                    block(nil);
                }else{
                    block(self.webSocketAddress);
                }
                block = nil;
            }
            return;
        }
    }
    [self request:0 completionBlock:block];
}

- (BOOL)isSupportLan:(NSString*)lang{
    NSArray * supportLanArr =  kCMSettingManager.cloudSupportLan;
    NSString * lan = [lang componentsSeparatedByString:@"_"][0];
    NSUInteger index =  [supportLanArr indexOfObject:lan];
    return index<200;
}

- (void)request:(int)number completionBlock:(CompletionBlock)block{
    
    if (self.isRequesting) return;
    
    self.isRequesting = YES;
    
    if (self.task) {
        [self.task cancel];
    }
    self.task = [CMRequestFactory cloudPredictionConfigRequestWithLanguage:self.language completeBlock:^(NSURLSessionDataTask *task, id dicOrArray, CMError *errorMsg) {
        
        self.isRequesting = NO;
        
        if (errorMsg) {
            kLog(@"[CLOUDLOG]第%d次请求(云预测 配置服务器)失败，错误信息(%@)", number, errorMsg);
            if (errorMsg.code != -1) {
                int recount = number +1;
                if(recount < 3){
                    //                [self performSelector:@selector(request:) withObject:@(recount) afterDelay:recount];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(pow(2, recount) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self request:recount completionBlock:block];
                    });
                }
            }
            else {
                NSUserDefaults * standard = [NSUserDefaults standardUserDefaults];
                [standard setInteger:[[NSDate date] timeIntervalSince1970] forKey:kGlobalUserDefaultsCloudPredictionConfigServerRequstTime];
            }
        }
        else {
            kLogInfo(@"[CLOUDLOG]%@", dicOrArray);
            @try {
                void (^temBlock)() = ^(){
                    
                    NSUserDefaults * standard = [NSUserDefaults standardUserDefaults];
                    [standard removeObjectForKey:kGlobalUserDefaultsCloudPredictionAddres];
                    if(block){
                        block(nil);
                    }
                };
                if(![dicOrArray isKindOfClass:[NSDictionary class]]){
                    temBlock();
                    return ;
                }
                if([[dicOrArray objectForKey:@"code"] intValue] != 0){
                    temBlock();
                    return ;
                }
                
                NSArray *dataArray = dicOrArray[@"data"];
                NSDictionary * datadic = [dataArray firstObject];
                NSArray<NSString*> *lan = datadic[@"lan"];
                NSString *addres = datadic[@"addres"];
                NSArray * components = [addres componentsSeparatedByString:@":"];
                if(components.count != 2){
                    temBlock();
                    return ;
                }
                if(![components[0] isIPAddress]){
                    temBlock();
                    return ;
                }
                
                NSMutableArray* lanNew = [NSMutableArray new];
                [lan enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if(obj.length>0){
                        NSArray<NSString*> * components = [obj componentsSeparatedByString:@"_"];
                        [lanNew addObject:[components[0] lowercaseString]];
                    }
                }];
                
                kCMSettingManager.cloudSupportLan = lanNew;
                
                if(![self isSupportLan:self.language]){
                    temBlock();
                    return ;
                }
                
                
                NSUserDefaults * standard = [NSUserDefaults standardUserDefaults];
                [standard setInteger:[[NSDate date] timeIntervalSince1970] forKey:kGlobalUserDefaultsCloudPredictionConfigServerRequstTime];
                [standard setObject:addres forKey:kGlobalUserDefaultsCloudPredictionAddres];
                if(block){
                    block(addres);
                }
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        }
    }];
    [self.task resume];
}
@end
