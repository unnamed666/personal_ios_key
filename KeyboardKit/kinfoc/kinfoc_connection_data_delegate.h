//
//  kinfoc_connection_data_delegate.h
//  KEWL
//
//  Created by Jin Ye on 4/23/16.
//  Copyright © 2016 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "kinfoc_httpposter.h"

@interface KInfocConDataDelegate : NSObject <NSURLConnectionDataDelegate>
{
    @private
    id<HttpPostResult> m_ResultListener;
    NSMutableData* m_ReturnData;
}

- (id) initWithResultListener:(id<HttpPostResult>) resultListener;

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
