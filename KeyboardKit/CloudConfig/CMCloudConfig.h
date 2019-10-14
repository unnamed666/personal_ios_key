//
//  CMCloudConfig.h
//  PandaKeyboard
//
//  Created by 张璐 on 2017/6/23.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

// 魔方数据有刷新的通知
extern NSString* const kCloudConfigRefreshNotify;

@interface CMCloudConfig : NSObject
@property (nonatomic, readonly, strong) NSDictionary *cloudDataDic;

/**
 * 初始化云端配置
 * @param productId 魔方分配的ID
 * @param pkg 包名
 * @param channelId 渠道
 * @param language APP语言
 */
- (void)initCloudConfig:(NSString*)productId pkg:(NSString*)pkg channelId:(NSString*)channelId language:(NSString*)language;

// 更新本地缓存的云控配置，因为container app和extension各有一个实例去拉取云控，会出现实例中云控数据不一致的问题，所以在每次取云控数据前先更新一次本地缓存
- (void)loadCloudConfig;

/**
 * 强制拉取数据
 * @param language 根据APP语言拉取数据
 */
- (void)pullCloudConfigDataWithLanguage:(NSString*)language;

/**
 * 获取数据，若存在同名的section，取优先级高的（值越低优先级越高）
 * @param funcType 根据后台划分的func_type来区分数据投放，云端数据目前是2
 * @param section 数据节点
 */
- (NSString*)getSectionKeyValue:(NSNumber*)funcType section:(NSString*)section;

/**
 * 获取同名的section下的所有KeyValue集合
 * @param funcType 根据后台划分的func_type来区分数据投放，云端数据目前是2
 * @param section 数据节点
 */
- (NSArray*)getAllSectionData:(NSNumber*)funcType section:(NSString*)section;

/// 获取云端所有数据
- (NSString*)getAllCloudData;

/**
 * 返回section中的key_value字段里的数据
 * @param funcType 根据后台划分的func_type来区分数据投放，云端数据目前是2
 * @param section 数据节点
 */
- (NSDictionary*)getFieldInKeyValue:(NSNumber*)funcType section:(NSString*)section;


// 更新本地缓存的云控配置，因为container app和extension各有一个实例去拉取云控，会出现实例中云控数据不一致的问题，所以在每次取云控数据前先更新一次本地缓存
- (void)updateLocalCloudConfig;

/**
 * 获取数据，若存在同名的section，取优先级高的（priority值越低优先级越高）
 * @param function 根据后台划分的func_type来区分数据投放，云端数据目前是2
 * @param section 数据节点
 */
- (NSString*)getCloudData:(int)function section:(NSString*)section;

/**
 * 返回同名section下的key_value列表
 * @param function 根据后台划分的func_type来区分数据投放，云端数据目前是2
 * @param section 数据节点
 */
- (NSArray*)getCloudDatas:(int)function section:(NSString*)section;

/**
 * 返回section中的key_value数据下的字段里的数据（获取优先级最高的字段数据）
 * @param function 根据后台划分的func_type来区分数据投放，云端数据目前是2
 * @param section 数据节点
 * @param key 字段名
 * @param defValue 默认数据
 */
- (NSString*)getCloudStringValue:(int)function section:(NSString*)section key:(NSString*)key defValue:(NSString*)defValue;

/**
 * 返回section中的key_value数据下的字段里的数据（获取优先级最高的字段数据）
 * @param function 根据后台划分的func_type来区分数据投放，云端数据目前是2
 * @param section 数据节点
 * @param key 字段名
 * @param defValue 默认数据
 */
- (int)getCloudIntValue:(int)function section:(NSString*)section key:(NSString*)key defValue:(int)defValue;

/**
 * 返回section中的key_value数据下的字段里的数据（获取优先级最高的字段数据）
 * @param function 根据后台划分的func_type来区分数据投放，云端数据目前是2
 * @param section 数据节点
 * @param key 字段名
 * @param defValue 默认数据
 */
- (long)getCloudLongValue:(int)function section:(NSString*)section key:(NSString*)key defValue:(long)defValue;

/**
 * 返回section中的key_value数据下的字段里的数据（获取优先级最高的字段数据）
 * @param function 根据后台划分的func_type来区分数据投放，云端数据目前是2
 * @param section 数据节点
 * @param key 字段名
 * @param defValue 默认数据
 */
- (BOOL)getCloudBoolValue:(int)function section:(NSString*)section key:(NSString*)key defValue:(BOOL)defValue;

/**
 * 返回section中的key_value数据下的字段里的数据（获取优先级最高的字段数据）
 * @param function 根据后台划分的func_type来区分数据投放，云端数据目前是2
 * @param section 数据节点
 * @param key 字段名
 * @param defValue 默认数据
 */
- (double)getCloudDoubleValue:(int)function section:(NSString*)section key:(NSString*)key defValue:(double)defValue;

@end
