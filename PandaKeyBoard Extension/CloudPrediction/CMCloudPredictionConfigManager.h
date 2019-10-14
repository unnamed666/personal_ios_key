//
//  CMCloudPredictionConfigManager.h
//  PandaKeyboard
//
//  Created by yanzhao on 2017/7/4.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompletionBlock)(NSString* webSocketAddress);

@interface CMCloudPredictionConfigManager : NSObject
@property (nonatomic,readonly) NSString* webSocketAddress;

- (void)resetWithLanguage:(NSString*)language  isForce:(BOOL) isForce completionBlock:(CompletionBlock)block;
- (BOOL)isSupportLan:(NSString*)lang;
@end

