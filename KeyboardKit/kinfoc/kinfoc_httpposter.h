//
//  kinfoc_httpposter.h
//  KEWL
//
//  Created by Jin Ye on 4/23/16.
//  Copyright © 2016 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HttpPostResult <NSObject>

- (void) onSuccess;
- (void) onFail;

@end

@interface KInfocHttpPoster : NSObject
{
    @private
    NSOperationQueue* m_OpQueueForPoster;
}

- (void) postData: (NSData*) pData
    toUrl: (NSString*) strUrl
    andResultCall:(id<HttpPostResult>) resultListener;

@end
