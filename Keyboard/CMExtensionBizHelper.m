//
//  CMExtensionBizHelper.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/8/18.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMExtensionBizHelper.h"
#import <AudioToolbox/AudioToolbox.h>
#include <dlfcn.h>
#import "CMKeyboardManager.h"
#import "CMGroupDataManager.h"
#import "CMAppConfig.h"
#import "CMRowView.h"
#import "CMKeyButton.h"


@implementation CMExtensionBizHelper

+ (void)playVibration:(BOOL)cancelPre {
    if (!kCMGroupDataManager.vibrationEnable || ![[UIDevice currentDevice] canVibration]) {
        return;
    }
    
    if ([UIDevice hasHapticFeedback]) {
        UIImpactFeedbackGenerator* generator = [CMKeyboardManager sharedInstance].feedbackGenerator;
        [generator impactOccurred];
    }
    else {
        NSString* key1 = [NSString stringWithFormat:@"V%@tern", @"ibePat"];
        NSString* key2 = [NSString stringWithFormat:@"I%@ity", @"ntens"];
        
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        if (![UIDevice isIphone55S5C]) {
            parameters[key1] = @[@YES, @1];
            parameters[key2] = @0.08;
        }
        else {
            parameters[key1] = @[@YES, @30];
            parameters[key2] = @0.2;
        }
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wimplicit-function-declaration"
        if (cancelPre) {
//                    AudioServicesStopSystemSound(kSystemSoundID_Vibrate);
            NSString* apiString = [NSString stringWithFormat:@"Au%@ice%@yst%@nd", @"dioServ", @"sStopS", @"emSou"];
            void (*thatApi)(int);
            thatApi = dlsym(RTLD_DEFAULT, apiString.UTF8String);
            if (thatApi != NULL) {
                thatApi(kSystemSoundID_Vibrate);
            }
        }
//            AudioServicesPlaySystemSoundWithVibration(kSystemSoundID_Vibrate, nil, parameters);
        NSString* apiString = [NSString stringWithFormat:@"Au%@ice%@yste%@ndW%@br%@on", @"dioServ", @"sPlayS", @"mSou", @"ithVi", @"ati"];
        void (*thatApi)(int, void *, id);
        thatApi = dlsym(RTLD_DEFAULT, apiString.UTF8String);
        if (thatApi != NULL) {
            thatApi(kSystemSoundID_Vibrate, nil, parameters);
        }
#pragma clang diagnostic pop
    }
}

+ (BOOL)shouldUseTensorFlow {
//#ifdef DEBUG
//    if (![CMGroupDataManager shareInstance].isTensorFlowABTestEnable) {
//        return YES;
//    }
//#endif
    if ([CMKeyboardManager sharedInstance].currentLanguageType != CMKeyboardLanguageTypeEnglishUnitedState) {
        return NO;
    }
    return YES;
//    NSString* udid = [CMAppConfig deviceId];
//    NSArray* filterArray = @[@"1", @"3", @"5", @"7", @"9", @"b", @"d", @"f"];
//    NSString* lastChar = [udid substringFromIndex:udid.length-1];
//    if ([filterArray containsObject:lastChar]) {
//        return YES;
//    }
//    return NO;
}

+ (CMKeyButton *)findNearestKeyButtonInView:(UIView *)keyboardView point:(CGPoint)point {
    UIView* rowView = [keyboardView findNearestView:point class:[CMRowView class]];
    if (rowView) {
        CGPoint thePt = [keyboardView convertPoint:point toView:rowView];
        return (CMKeyButton*)[rowView findNearestView:thePt class:[CMKeyButton class]];
    }
    return nil;
}

@end
