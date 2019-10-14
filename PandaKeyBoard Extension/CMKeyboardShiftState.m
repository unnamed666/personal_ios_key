//
//  CMKeyboardShiftState.m
//  PandaKeyboard
//
//  Created by yanzhao on 2017/6/13.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMKeyboardShiftState.h"
#import "CMSettingManager.h"
#import "CMKeyModel.h"
@interface CMKeyboardShiftState (){
    volatile BOOL mIsInDoubleTapShiftKey;
}
@property (nonatomic,assign) KeyboardShiftState currentShiftState;

@end

@implementation CMKeyboardShiftState

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

- (void)reset{
    _currentShiftState = 0;
    mIsInDoubleTapShiftKey = false;
}
- (void)setAutocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType{
    
    if(_autocapitalizationType != autocapitalizationType){
        _currentShiftState = 0;
    }
    
    switch (autocapitalizationType) {
        case UITextAutocapitalizationTypeAllCharacters:
            self.currentShiftState = KeyboardShiftStateShiftedLockAlpha;
            break;
        case UITextAutocapitalizationTypeNone:
            self.currentShiftState = KeyboardShiftStateAlpha;
            break;
        case UITextAutocapitalizationTypeSentences:{
            if(kCMSettingManager.autoCapitalization &&[self.delegate isSentencesEnd]){
                self.currentShiftState =  KeyboardShiftStateAutomaticShiftedAlpha;
            }else{
                self.currentShiftState = KeyboardShiftStateAlpha;
            }
        }
            break;
        case UITextAutocapitalizationTypeWords:
            if([self.delegate isWordsEnd]){
                self.currentShiftState =  KeyboardShiftStateAutomaticShiftedAlpha;
            }else{
                self.currentShiftState = KeyboardShiftStateAlpha;
            }
            break;
        default:
            break;
    }
    
    _autocapitalizationType = autocapitalizationType;
}

- (void)setCurrentShiftState:(KeyboardShiftState)currentShiftState{
    if(currentShiftState == _currentShiftState)return;
    if((currentShiftState == KeyboardShiftStateManualShiftedAlpha ||currentShiftState == KeyboardShiftStateAutomaticShiftedAlpha) &&
       (_currentShiftState == KeyboardShiftStateManualShiftedAlpha ||_currentShiftState == KeyboardShiftStateAutomaticShiftedAlpha))return;
    
    BOOL success = NO;
    switch (currentShiftState) {
        case KeyboardShiftStateAlpha:
            success =[self.delegate switchAlphabetKeyboard];
            break;
        case KeyboardShiftStateManualShiftedAlpha:
        case KeyboardShiftStateAutomaticShiftedAlpha:
            success =[self.delegate switchAlphabetShiftedKeyboard];
            break;
        case KeyboardShiftStateShiftedLockAlpha:{
            success = [self.delegate switchAlphabetShiftedLockKeyboard];
        }break;
        default:
            break;
    }
    if(success)
        _currentShiftState = currentShiftState;
}

- (void)singleTap:(CMKeyModel*)key
{
    if(key.keyType == CMKeyTypeReturn)
    {
        if(!kCMSettingManager.autoCapitalization && UITextAutocapitalizationTypeNone == self.autocapitalizationType)
        {
            self.currentShiftState =  KeyboardShiftStateAlpha;
        }
        else
        {
            self.currentShiftState =  KeyboardShiftStateAutomaticShiftedAlpha;
        }
        return;
    }
    
    if(key.keyType == CMKeyTypeShift)
    {
        if(!mIsInDoubleTapShiftKey)
        {
            mIsInDoubleTapShiftKey = true;
            [self performSelector:@selector(doubleTapShiftKey) withObject:nil afterDelay:0.3];
            switch (self.currentShiftState)
            {
                case KeyboardShiftStateAlpha:
                    self.currentShiftState = KeyboardShiftStateManualShiftedAlpha;
                    break;
                case KeyboardShiftStateManualShiftedAlpha:
                case KeyboardShiftStateAutomaticShiftedAlpha:
                case KeyboardShiftStateShiftedLockAlpha:
                    self.currentShiftState = KeyboardShiftStateAlpha;
                    break;
                default:
                    break;
            }
        }
        else
        {
            [self doubleTap:key];
        }
    }
    else
    {
        mIsInDoubleTapShiftKey = false;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doubleTapShiftKey) object:nil];
        
        switch (self.autocapitalizationType)
        {
            case UITextAutocapitalizationTypeAllCharacters:
                self.currentShiftState = KeyboardShiftStateAutomaticShiftedAlpha;
                break;
            case UITextAutocapitalizationTypeNone:
                self.currentShiftState = KeyboardShiftStateAlpha;
                break;
            case UITextAutocapitalizationTypeSentences:
                if(kCMSettingManager.autoCapitalization && [self.delegate isSentencesEnd])
                {
                    self.currentShiftState =  KeyboardShiftStateAutomaticShiftedAlpha;
                }
                else
                {
                    if(self.currentShiftState == KeyboardShiftStateManualShiftedAlpha ||
                       self.currentShiftState == KeyboardShiftStateAutomaticShiftedAlpha)
                    {
                        self.currentShiftState = KeyboardShiftStateAlpha;
                    }
                }
                break;
            case UITextAutocapitalizationTypeWords:
                if([self.delegate isWordsEnd])
                {
                    self.currentShiftState =  KeyboardShiftStateAutomaticShiftedAlpha;
                }
                else
                {
                    if(self.currentShiftState == KeyboardShiftStateManualShiftedAlpha ||
                       self.currentShiftState == KeyboardShiftStateAutomaticShiftedAlpha)
                    {
                        self.currentShiftState = KeyboardShiftStateAlpha;
                    }
                }
                break;
            default:
                break;
        }
    }
}

- (void)doubleTap:(CMKeyModel*)key
{
    if(!key)return;
    
    if(key.keyType == CMKeyTypeReturn)return;
    if(key.keyType == CMKeyTypeShift)
    {
        self.currentShiftState = KeyboardShiftStateShiftedLockAlpha;
    }
}


- (void)doubleTapShiftKey
{
    mIsInDoubleTapShiftKey = false;
}
@end
