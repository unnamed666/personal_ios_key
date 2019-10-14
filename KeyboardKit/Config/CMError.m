//
//  CMError.m
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/2.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "CMError.h"
#import "CMLogger.h"

@implementation CMError

- (NSString*)description
{
    NSString* s = [self.userInfo objectForKey:@"error_msg"];
    if (s.length > 0) {
        return s;
    }
    else {
        return [super description];
    }
}

+ (CMError*)errorWithRestInfo:(NSDictionary*)restInfo {
    
    NSNumber* errorCode = [restInfo objectForKey:@"error_code"];
    kLogInfo(@"%d=%@", [errorCode intValue], [restInfo objectForKey:@"error_msg"]);
    CMError* error = [CMError errorWithDomain:@"MP" code:[errorCode intValue] userInfo:restInfo];
    return error;
}

+ (CMError*)errorWithNSError:(NSError*)error {
    if (!error) {
        return nil;
    }
    CMError* myError = [CMError errorWithDomain:error.domain code:error.code userInfo:error.userInfo];
    kLogInfo(@"code=%ld", (long)myError.code);
    return myError;
}

+ (CMError*)errorWithCode:(CMErrorCode)code errorMessage:(NSString*)errorMessage {
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    [userInfo setObject:[NSString stringWithFormat:@"%ld", (long)code] forKey:@"error_code"];
    if (errorMessage) {
        [userInfo setObject:errorMessage forKey:@"error_msg"];
    }
    
    CMError* error = [CMError errorWithDomain:@"cheetah mobile" code:code userInfo:userInfo];
    return error;
    
}

- (id)initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict {
    if (self = [super initWithDomain:domain code:code userInfo:dict]) {
    }
    return self;
}

@end
