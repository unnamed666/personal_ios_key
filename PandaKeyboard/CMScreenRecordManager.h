//
//  CMScreenRecordManager.h
//  PandaKeyboard
//
//  Created by 刘建东 on 2017/10/18.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

//个性化的需求，通过channle去控制,后续添加
typedef NS_ENUM(NSInteger,ScreenRecordChannle){
    ScreenRecordChannleByVideo, // 截图: view-image-video-gif
    ScreenRecordChannleByImage, // 截图: view-image-gif
};

typedef void (^CMScreenRecordFinishBlock) (NSURL * _Nullable gifPath);

@interface CMScreenRecordManager : NSObject

/** 当前是否正在录制视频 **/
@property (nonatomic, readonly) BOOL isRecording;


#pragma mark - method

+ (instancetype _Nullable )sharedInstance;
/*
 1.targetView: 想要截图的view
 2.chanel : 生成gif的方式
 */
-(void)startScreenRecord:(UIView *_Nullable)targetView channel:(ScreenRecordChannle)chanel;
-(void)cancleScreenRecord;
-(void)stopScreenRecord:(CMScreenRecordFinishBlock _Nullable)completeBlock;


@end
