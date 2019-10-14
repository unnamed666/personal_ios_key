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

@interface CMInappController : CMBaseViewController

@property (nonatomic, strong) SKProduct* monthProductInfo;
@property (nonatomic, strong) SKProduct* yearProductInfo;
@property (nonatomic, strong) NSString* const yearID;
@property (nonatomic, strong) NSString* const monthID;
@end

NS_ASSUME_NONNULL_END
