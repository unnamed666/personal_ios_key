//
//  CMGiphyImage.h
//  iMessage
//
//  Created by yanzhao on 2017/9/25.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface CMGiphyImage : NSObject
/** URL for animated GIF*/
@property (readonly, strong, nonatomic) NSURL * url;
/** width for animated GIF*/
@property (readonly, nonatomic) CGFloat width;
/** height for animated GIF*/
@property (readonly, nonatomic) CGFloat height;

- (instancetype) initWithDictionary:(NSDictionary *) dictionary;
@end
