//
//  CMPageCollectionViewFlowLayout.h
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/6/6.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMPageCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign)CGFloat offset;
@property (nonatomic, assign)BOOL useVelocity;

@end
