//
//  CMOReachability.m
//  osvideo
//
//  Created by wolf on 16/7/7.
//  Copyright © 2016年 cmcm. All rights reserved.
//

#import "CMOReachability.h"

#import "CMNotificationConstants.h"
#import "Reachability.h"


kNavNetWorkStatus          gReachStatus=kNavNetWorkUnknow;
@interface CMOReachability ()
{
    BOOL started;
}
@property (nonatomic) Reachability *internetReachability;
@end

@implementation CMOReachability

+ (instancetype)shareInstance
{
    static CMOReachability  *s_client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!s_client) {
            s_client = [[[self class] alloc] init];
        }
    });
    
    return s_client;
}

+(void)start{
    [[CMOReachability shareInstance] __start];
}
+(void)stop{
    [[CMOReachability shareInstance] __stop];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        started = NO;
//        [self __start];
    }
    return self;
}
- (void)__start{
    if(started)return;
    started = YES;
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
}

- (void)dealloc
{
    [self __stop];
}
- (void)__stop{
    if(!started)return;
    started = NO;
    
    if(_internetReachability) [self.internetReachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}
- (void)updateInterfaceWithReachability:(Reachability *)reachability{
    if (reachability == self.internetReachability){
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        switch (netStatus)
        {
            case NotReachable:        {
                gReachStatus = kNavNetWorkNotReachable;
                break;
            }
                
            case ReachableViaWWAN:        {
                gReachStatus = kNavNetWorkWWAN;
                break;
            }
            case ReachableViaWiFi:        {
                gReachStatus = kNavNetWorkWIFI;
                break;
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName: kGlobalNotificationNetWorkChanged object: nil];
    }
}

+(kNavNetWorkStatus)status{
    [CMOReachability shareInstance];
    return gReachStatus;
}

@end
