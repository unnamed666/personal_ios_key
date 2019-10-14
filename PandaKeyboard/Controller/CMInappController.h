//
//  InappController.h
//  PandaKeyboard
//
//  Created by yu dandan on 2019/3/14.
//  Copyright © 2019 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMBaseViewController.h"
#import "StoreKit/StoreKit.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString* const kYearID;
extern NSString* const kMonthID;
@interface CMInappController : CMBaseViewController
@property (nonatomic, strong) SKProduct* monthProductInfo;
@property (nonatomic, strong) SKProduct* yearProductInfo;

@end

NS_ASSUME_NONNULL_END
