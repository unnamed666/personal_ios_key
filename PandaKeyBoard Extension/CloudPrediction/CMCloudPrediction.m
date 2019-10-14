//
//  CMCloudPrediction.m
//  PandaKeyboard
//
//  Created by yanzhao on 2017/7/5.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMCloudPrediction.h"
#import "CMCloudPredictionConfigManager.h"
#import "CMSettingManager.h"
#import "CMCommUtil.h"
#import "CMAppConfig.h"
#import <SocketRocket/SocketRocket.h>
#import "CMRSA.h"
#import <CommonCrypto/CommonCryptor.h>

#import "NSDictionary+Common.h"

#import "CMOReachability.h"
#import "CloudPredictionReport.h"
#import "SuggestedWordInfo.h"
#import "CMCloudConfig.h"

@import Security;

@interface CMCloudPrediction ()<SRWebSocketDelegate>{
    volatile NSUInteger  currentId;
    int reConnectCount;
}

@property (nonatomic, strong)dispatch_queue_t serailQueue;

@property (nonatomic,strong) SRWebSocket *webSocket;
@property (nonatomic,strong) NSString *secKey;

@property (nonatomic,strong) NSString *rsaPublicKey;
@property (nonatomic,strong) NSMutableDictionary <NSString*,CloudPredictionReport*>* reportDic;

@property (nonatomic, strong)CMCloudPredictionConfigManager* cloudManager;

@end

@implementation CMCloudPrediction

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rsaPublicKey = @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAw5eW8RGYz5MGtREhnjKtCiXtdamdIf/8Y7dTmd4lRolC7nxMLhKW9ZA62AEwQMlfdXtS7fk5sJPN9ZaGcXH+D80eGaAOOrgIe97gTRJVFT33BwDi2PoBlpzQgh/mS05/wCg2Q25vYJEnXSNP+WlZNT6dh3LEfs5ktaf9LgVza10JaM3pQcyDES9QAx6AZ97NM/L4CBTduPzpK5pXGaHSHOHH9OYfmdVYSzdN4e/hvuO7esVBJWs/zetMFhTl87cc+keF+bDZqaPpXOaLgtxHrIuSlZma7QULsCFpq21iV68MjM+4fr+svu6ItS7Fn/nIhBhcjku+fYR8QaJyaFU2vwIDAQAB";
//        mIv = {0xD1, 0xD9, 0x9C, 0xA9, 0xB7, 0xEC, 0x07, 0x08, 0xC8, 0x3E, 0xCC, 0xA4, 0xB6, 0x35, 0xDB, 0xF1};
         _reportDic = [[NSMutableDictionary alloc] init];
        reConnectCount =0;
    }
    return self;
}

- (void)dealloc {
    kLogTrace();
}

#pragma mark -  set get

- (dispatch_queue_t)serailQueue{
    if(!_serailQueue){
        _serailQueue = dispatch_queue_create([NSStringFromClass(self.class) UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    return _serailQueue;
}

- (CMCloudPredictionConfigManager *)cloudManager {
    if (!_cloudManager) {
        _cloudManager = [CMCloudPredictionConfigManager new];
    }
    return _cloudManager;
}


- (NSString *)secKey{
    if(!_secKey){
        _secKey = [[NSUUID UUID].UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    return _secKey;
}

#pragma mark -  public
- (void)swichLanguage{
    NSString * language = [CMCommUtil keyboardLanguageTypeToLocaleString:kCMSettingManager.languageType];
    BOOL support = [self.cloudManager isSupportLan:language];
    if(!support){
        [self closeWebSocket];
    }
}
- (void)connectPredictionService{
    [self connetServiceWithForce:NO];
}

- (void)forceconnectPredictionService{
    [self connetServiceWithForce:YES];
}


- (BOOL)isClosed{
    if(!_webSocket || _webSocket.readyState == SR_CLOSED || _webSocket.readyState == SR_CLOSING ){
        return YES;
    }
    return NO;
}

- (void)connect{
    
    if([self isClosed]){
        NSString * webSocketAddress = self.cloudManager.webSocketAddress;
        if(webSocketAddress.length < 8) return;
//        webSocketAddress = @"10.60.118.170:6985";
        NSString * urlStr = [NSString stringWithFormat:@"ws://%@/echo",webSocketAddress];
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
        self.webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
        _webSocket.delegate = self;
        [_webSocket open];
        currentId = 0;
        
    }else{
        kLog(@"链接着呢");
    }
    
}

- (void)clickCloudPredictionIndex:(int)index upack:(NSString*)upack{
     CloudPredictionReport * report =  _reportDic[upack];
    report.selectIndex = (short)index;
    [report endDuration];
}

- (void)cloudReport{
    NSMutableArray *report = [[NSMutableArray alloc] initWithCapacity:_reportDic.count];
    [_reportDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, CloudPredictionReport * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj endDuration];
        [report addObject:[obj toDictionary]];
    }];
    [_reportDic removeAllObjects];
    if(report.count<1)return;
    NSDictionary* dic=@{@"report":report};
    [self send:dic];
    
}
- (void)updateSendId{
    currentId++;
}

- (NSUInteger)sendWord:(NSString*)word{
    if([CMOReachability status] == kNavNetWorkUnknow) return 0;

    NSMutableArray *report = [[NSMutableArray alloc] initWithCapacity:_reportDic.count];
    [_reportDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, CloudPredictionReport * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj endDuration];
        [report addObject:[obj toDictionary]];
    }];
    

    if(word.length<=0)return 0;

    if([self isClosed]){
        [self connectPredictionService];
        return 0;
    }
    
    [_reportDic removeAllObjects];
    NSDictionary * data = @{@"word":word,
                            @"st":[NSString stringWithFormat:@"%lu",(unsigned long)currentId]};
    
    NSDictionary * dic = @{@"act":@"2",
                           @"data":data,
                           @"report":report};
    kLog(@"%@",[dic toJSonString]);
#if DEBUG && defined(CLOUD_MOC)
    [self mocSend:dic];
#else
    [self send:dic];
#endif
    return currentId;
//    NSString * str = [NSString stringWithFormat:@"{\"act\":\"2\"}"];
}

- (void)send:(NSDictionary*)dic{
    if(_webSocket.readyState == SR_OPEN){
        [_webSocket send: [self AESEncode:[dic toJsonData]]];
    }
}

#if DEBUG && defined(CLOUD_MOC)
- (void)mocSend:(NSDictionary*)dic{
    NSString* jsonStr = [NSString stringWithFormat:@"{\"code\":0,\"data\":[\"you\"],\"st\":\"13\",\"upack\":\"SeqID=123106570065166336\"}"];
    [self webSocket:_webSocket didReceiveJsonString:jsonStr];
}
#endif

#pragma mark -  SRWebSocketDelegate

// message will either be an NSString if the server is using text
// or NSData if the server is using binary.
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
//    kLog(@"收到数据了，注意 message 是 id 类型的，学过C语言的都知道，id 是 (void *)  void* 就厉害了，二进制数据都可以指着，不详细解释 void* 了");
    @try {
        
        NSData * data = [self AESDecode:message];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSArray * predictionArr = jsonDict[@"data"];
        int code = [jsonDict[@"code"] intValue];
        int st = [jsonDict[@"st"] intValue];
        NSString* upack = jsonDict[@"upack"];
        
        kLog(@"%@",jsonDict);
        
        if([predictionArr isKindOfClass:[NSNull class]])return;
        
        if(code!=0  || upack.length<1 || predictionArr.count<1)return;//数据不对
        CloudPredictionReport * report = [[CloudPredictionReport alloc] initWithUpack:upack predictionType:REPORT_PREDICTION_TYPE_WORD];
        [_reportDic setObject:report forKey:upack];
        if(st < currentId) return;
        SuggestedWordInfo * suggestWord;
        if([self.delegate isComposingWord]){
            suggestWord = [[SuggestedWordInfo alloc] initWithCloudWord:predictionArr[0] upack:upack score:0 kindAndFlags:KIND_CLOUD_CORRECTION];
        }else{
            suggestWord = [[SuggestedWordInfo alloc] initWithCloudWord:predictionArr[0] upack:upack score:0 kindAndFlags:KIND_CLOUD_PREDICTION];
        }
        [self.delegate onGetCloudPredictionWord:suggestWord];
        [report beginDuration];
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

#if DEBUG && defined(CLOUD_MOC)
- (void)webSocket:(SRWebSocket *)webSocket didReceiveJsonString:(NSString *)jsonStr{
    //    kLog(@"收到数据了，注意 message 是 id 类型的，学过C语言的都知道，id 是 (void *)  void* 就厉害了，二进制数据都可以指着，不详细解释 void* 了");
    @try {
        NSError *jsonError;
        NSData *objectData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
        NSArray * predictionArr = jsonDict[@"data"];
        int code = [jsonDict[@"code"] intValue];
        int st = [jsonDict[@"st"] intValue];
        NSString* upack = jsonDict[@"upack"];
        
        kLog(@"%@",jsonDict);
        
        if([predictionArr isKindOfClass:[NSNull class]])return;
        
        if(code!=0  || upack.length<1 || predictionArr.count<1)return;//数据不对
        CloudPredictionReport * report = [[CloudPredictionReport alloc] initWithUpack:upack predictionType:REPORT_PREDICTION_TYPE_WORD];
        [_reportDic setObject:report forKey:upack];
        //        if(st < currentId) return;
        SuggestedWordInfo * suggestWord;
        if([self.delegate isComposingWord]){
            suggestWord = [[SuggestedWordInfo alloc] initWithCloudWord:predictionArr[0] upack:upack score:0 kindAndFlags:KIND_CLOUD_CORRECTION];
        }else{
            suggestWord = [[SuggestedWordInfo alloc] initWithCloudWord:predictionArr[0] upack:upack score:0 kindAndFlags:KIND_CLOUD_PREDICTION];
        }
        [self.delegate cludSuggestWord:suggestWord];
        [report beginDuration];
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}
#endif

- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
//    kLog(@"连接成功，可以立刻登录你公司后台的服务器了，还有开启心跳");
    [webSocket send:[self publicParam]];
    reConnectCount = 0;
    
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    
    if([CMOReachability status] == kNavNetWorkUnknow) return;
    
    reConnectCount ++;
    if(1 == reConnectCount){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(pow(2, reConnectCount) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.webSocket = nil;
            [self connectPredictionService];
        });
    }else if(2 == reConnectCount){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(pow(2, reConnectCount) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.webSocket = nil;
            [self forceconnectPredictionService];
        });
    }
    
//    NSLog(@"连接失败，这里可以实现掉线自动重连，要注意以下几点");
//    NSLog(@"1.判断当前网络环境，如果断网了就不要连了，等待网络到来，在发起重连");
//    NSLog(@"2.判断调用层是否需要连接，例如用户都没在聊天界面，连接上去浪费流量");
//    NSLog(@"3.连接次数限制，如果连接失败了，重试10次左右就可以了，不然就死循环了。 或者每隔1，2，4，8，10，10秒重连...f(x) = f(x-1) * 2, (x=5)");
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    
    kLog(@"连接断开，清空socket对象，清空该清空的东西，还有关闭心跳！");
    self.webSocket = nil;
    
}
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    kLog(@"%s",__func__);
}


#pragma mark - private 

- (void)closeWebSocket{
    if(![self isClosed]){
        [_webSocket close];
    }
    self.webSocket = nil;
}

- (void)connetServiceWithForce:(BOOL)isForce{
#if DEBUG && defined(CLOUD_MOC)
#else
    BOOL cloudPredictionEnble = [kCMKeyboardManager.cloundConfig getCloudBoolValue:3 section:@"ex_cloud_prediction" key:@"enable" defValue:NO];
//    BOOL cloudPredictionEnble = YES;

    if(!cloudPredictionEnble){
        [self closeWebSocket];
        return;
    }
#endif
    
    dispatch_async(self.serailQueue, ^{
        [self.cloudManager resetWithLanguage:[CMCommUtil keyboardLanguageTypeToLocaleString:kCMSettingManager.languageType] isForce:isForce completionBlock:^(NSString *webSocketAddress) {
            kLog(@"webSocketAddress = %@",webSocketAddress);
            if(webSocketAddress){
                [self connect];
            }
        }];
    });
}

- (NSData*)AESEncode:(NSData*)data{
    
    
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [self.secKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1] = {0xD1, 0xD9, 0x9C, 0xA9, 0xB7, 0xEC, 0x07, 0x08, 0xC8, 0x3E, 0xCC, 0xA4, 0xB6, 0x35, 0xDB, 0xF1,0};
    
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCKeySizeAES256,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;

    
}

- (NSData*)AESDecode:(NSData*)data{
    
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [self.secKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1] = {0xD1, 0xD9, 0x9C, 0xA9, 0xB7, 0xEC, 0x07, 0x08, 0xC8, 0x3E, 0xCC, 0xA4, 0xB6, 0x35, 0xDB, 0xF1,0};

    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCKeySizeAES256,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}


- (NSData*) publicParam{
//    NSDictionary * dic = @{@"uid":[CMAppConfig deviceId],
//                           @"av":[CMAppConfig sharedInstance].appVersion,
//                           @"ch":@"",
//                           @"al":[CMCommUtil keyboardLanguageTypeToLocaleString:kCMSettingManager.languageType],
//                           @"mcc":[CMAppConfig mobileCountryCode],
//                           @"pt":@"1",
//                           @"act":@"1",
//                           @"sec":self.secKey};
    NSString * ret = [NSString stringWithFormat:@"{\"uid\":\"%@\",\"av\":\"%@\",\"ch\":\"ios.keyboard\",\"al\":\"%@\",\"mcc\":\"%@\",\"pt\":\"1\",\"act\":\"1\",\"sec\":\"%@\"}",[CMAppConfig deviceId],[CMAppConfig appVersion],[CMCommUtil keyboardLanguageTypeToLocaleString:kCMSettingManager.languageType],[CMAppConfig mobileCountryCode],self.secKey];
    kLog(@"len = %ld , publicParam = %@  ",(unsigned long)ret.length,ret);
    return [CMRSA encryptString:ret publicKey:self.rsaPublicKey];

}






@end
