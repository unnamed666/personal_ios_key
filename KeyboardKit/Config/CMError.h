//
//  CMError.h
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/2.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CMErrorCode) {
    CMErrorCodeSuccess						= 0, // 自定义,表示成功.
    CMErrorCodeUnknow                       = 1, // 未知错误
    CMErrorCodeUnavailable	        		= 2, // 不可用
    CMErrorCodeReservationsSuccess			= 3, // 自定义,表示成功,但是过程中有瑕疵.
    CMErrorCodeLayoutNotFound			= 4, // 自定义,表示成功,但是过程中有瑕疵.
};

@interface CMError : NSError

/**
 * 返回由Rest接口错误信息构建的错误对象.
 */
+ (CMError*)errorWithRestInfo:(NSDictionary*)restInfo;


/**
 * 返回由NSError构建的错误对象.
 */
+ (CMError*)errorWithNSError:(NSError*)error;

/**
 * 构造MPError错误。
 *
 * @param code 错误代码
 * @param errorMessage 错误信息
 *
 * 返回错误对象.
 */
+ (CMError*)errorWithCode:(CMErrorCode)code errorMessage:(NSString*)errorMessage;

@end
