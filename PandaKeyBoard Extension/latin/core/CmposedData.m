//
//  CmposedData.m
//  test
//
//  Created by yanzhao on 2017/3/23.
//  Copyright © 2017年 cmcm. All rights reserved.
//

#import "CmposedData.h"
#import "InputPointers.h"
#import "Constants.h"

#import "Character.h"
@implementation CmposedData
- (instancetype)initWithInputPointers:(InputPointers*)inputPointers isBatchMode:(BOOL)isBatchMode typeWord:(NSString*)typeWord
{
    self = [super init];
    if (self) {
        self.inputPointers = inputPointers;
        self.isBatchMode = isBatchMode;
        self.typeWord = typeWord;
    }
    return self;
}

- (void)setInputPointers:(InputPointers *)inputPointers {
    _inputPointers = inputPointers;
    self.isBatchMode = YES;
}

- (int)copyCodePointsExceptTrailingSingleQuotesAndReturnCodePointCount:(int[])destination destinationLen:(int)len{
    //TODO: 字符长度 多语言状态下，是否和java的String获取长度不同？
    int lastIndex = (int) self.typeWord.length - [self getTrailingSingleQuotesCount:self.typeWord];
    if(lastIndex<=0)return 0;
    
    if(lastIndex > len)return -1;
    unichar buffer[lastIndex];
    NSString *str = [self.typeWord lowercaseString];
    [str getCharacters:buffer range:NSMakeRange(0, lastIndex)];
    for (int i =0 ; i<lastIndex; i++) {
        *(destination+i) = buffer[i];
    }
    return lastIndex;
}

//unichar CODE_SINGLE_QUOTE = '\'';
- (int)getTrailingSingleQuotesCount:(NSString*)str{
    int lastIndex = (int)str.length-1;
    int i = lastIndex;
    while (i>=0 && [Character codePointAt:str index:i] == CODE_SINGLE_QUOTE) {
        --i;
    }
    return lastIndex - i;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ inputPointers = %@", self.typeWord ,self.inputPointers];
}

@end
