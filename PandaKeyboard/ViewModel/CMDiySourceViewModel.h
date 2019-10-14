//
//  CMSourceViewModel.h
//  PandaKeyboard
//
//  Created by duwenyan on 2017/11/1.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CMDiySourceFetchStatus) {
    CMDiySourceFetchNone,
    CMDiySourceFetchNew,
    CMDiySourceFetchMore,
};

typedef NS_ENUM(NSUInteger, CMDiySourceType) {
    CMDiySourceTypeBackground,
    CMDiySourceTypeButton,
    CMDiySourceTypeSounds,
    CMDiySourceTypeFonts
};

@class CMDiySourceModel;

typedef void(^CMLoadDataComplete)(CMError *errorMsg, BOOL hasMore);

@interface CMDiySourceViewModel : NSObject

@property (nonatomic, assign) CMDiySourceType diySourceType;
@property (nonatomic, assign) CMDiySourceFetchStatus fetchStatus;

- (instancetype)initWithPlist:(NSString *)plistName;

- (NSInteger)numberOfItems;

- (CMDiySourceModel *)sourceModelAtIndexPath:(NSIndexPath *)indexPath;

- (CMDiySourceModel *)sourceModelAtIndex:(NSInteger)row;

- (void)fetchNetDiySourcesFirstPageWithBlock:(CMLoadDataComplete)block;

- (void)fetchNetDiySourcesNextPageWithBlock:(CMLoadDataComplete)block;

- (void)loadLocalSourcesWithBlock:(CMLoadDataComplete)block;

- (void)cancelTask;

@end
