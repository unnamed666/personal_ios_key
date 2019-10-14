//
//  DicTraverseSession.h
//  test
//
//  Created by wolf on 17/1/12.
//  Copyright © 2017年 cmcm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NativeSuggestOptions.h"
#import "OCDefines.h"
@interface CMDicTraverseSession : NSObject{
    @public
    int mInputCodePoints[MAX_WORD_LENGTH];
    
    long long mNativeDicTraverseSession;
}
@property (nonatomic,strong,readonly) NativeSuggestOptions * mNativeSuggestOptions;

- (instancetype)initWithLocale:(NSString*)locale dictionary:(long long)dictionary dictSize:(long)dictSize;
- (void)close;
@end
