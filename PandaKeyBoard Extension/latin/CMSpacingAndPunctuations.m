//
//  CMSpacingAndPunctuations.m
//  Panda Keyboard
//
//  Created by yanzhao on 2017/5/10.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import "CMSpacingAndPunctuations.h"
#import "CMCommUtil.h"
#import "Constants.h"
@interface CMSpacingAndPunctuations (){
}

@property (nonatomic,assign)  unichar mSentenceSeparator;
@property (nonatomic,strong) NSSet* mSortedSymbolsPrecededBySpace;
@property (nonatomic,strong) NSSet* mSortedSymbolsFollowedBySpace;
@property (nonatomic,strong) NSSet*  mSortedSymbolsClusteringTogether;
@property (nonatomic,strong) NSSet*  mSortedWordConnectors;
@property (nonatomic,strong) NSSet*  mSortedWordSeparators;

@property (nonatomic,strong) NSSet*  mSortedSentenceTerminators;
@end

@implementation CMSpacingAndPunctuations



- (instancetype)init
{
    self = [super init];
    if (self) {
        [self reset:0];
    }
    return self;
}
- (void)reset:(CMKeyboardLanguageType)languageType{
    

            
            self.mSortedSymbolsPrecededBySpace =  [CMCommUtil tokenizationSetByNSString:@"([{&" options:NSStringEnumerationByComposedCharacterSequences];
            //    self.mSortedSymbolsFollowedBySpace = [@".,;:!?)]}&" componentsSeparatedByString:@""];
            self.mSortedSymbolsFollowedBySpace =  [CMCommUtil tokenizationSetByNSString:@".,;:!?)]}&" options:NSStringEnumerationByComposedCharacterSequences];
            
            self.mSortedWordConnectors =  [CMCommUtil tokenizationSetByNSString:@"'-" options:NSStringEnumerationByComposedCharacterSequences];
            self.mSortedWordSeparators =  [CMCommUtil tokenizationSetByNSString:@"\t \n()[]{}*&<>+=|.,;:!?/_\\" options:NSStringEnumerationByComposedCharacterSequences];
            self.mSortedSentenceTerminators =  [CMCommUtil tokenizationSetByNSString:@".?!" options:NSStringEnumerationByComposedCharacterSequences];
            self.mSentenceSeparator = 46;
            
            _mSentenceSeparatorAndSpace = [NSString stringWithFormat:@"%@%@", [NSString stringWithCharacters:&_mSentenceSeparator length:1] ,STRING_SPACE];
            _mCurrentLanguageHasSpaces = YES;


}

- (BOOL)isSentenceTerminator:(int)c{
    return [self.mSortedSentenceTerminators containsObject:@(c)];
}

- (BOOL)isWordSeparator:(int)c{
    return [self.mSortedWordSeparators containsObject:@(c)];
}


- (BOOL)isWordConnector:(int)c{
    return [self.mSortedWordConnectors containsObject:@(c)];
}


- (BOOL)isUsuallyPrecededBySpace:(int)c{
    return [self.mSortedSymbolsPrecededBySpace containsObject:@(c)];
}

- (BOOL)isUsuallyFollowedBySpace:(int)c{
    return [self.mSortedSymbolsFollowedBySpace containsObject:@(c)];
}

@end
