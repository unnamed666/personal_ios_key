//
//  CMEmojiKeyboardViewModel.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/5/18.
//  Copyright © 2017年 姚宗超. All rights reserved.
//

#import "CMEmojiKeyboardViewModel.h"
#import "CMEmojiSectionModel.h"
#import "NSDictionary+Common.h"
#import "CMKeyModel.h"
#import "CMSettingManager.h"

@implementation CMEmojiKeyboardViewModel

- (id)copyWithZone:(NSZone *)zone {
    CMEmojiKeyboardViewModel* model = [[[self class] allocWithZone:zone] init];
    model.emojiArray = [_emojiArray copy];
    model.layoutKeyModel = _layoutKeyModel;
    model.deleteKeyModel = _deleteKeyModel;
    model.returnKeyModel = _returnKeyModel;
    return model;
}

- (void)dealloc {
    kLogTrace();
}

- (instancetype)initWithPlist:(NSString *)filePath {
    if (self = [super init]) {
        NSMutableArray* sectionArray = [NSMutableArray array];
        
        CMEmojiSectionModel* recentlySection = [CMEmojiSectionModel new];
        NSMutableArray* recently = [NSMutableArray array];
        for (NSString *emoji in kCMSettingManager.recentlyEmoji) {
            CMKeyModel *keyModel = [[CMKeyModel alloc] initEmojiWithKey:emoji];
            [recently addObject:keyModel];
        }
        recentlySection.emojiArray = [recently copy];
        recentlySection.sectionName = @"recently";
        recentlySection.sectionNormalIconName = @"emoji_icon_recent";
        recentlySection.sectionHighlightIconName = @"emoji_icon_recent_highlight";
        [sectionArray addObject:recentlySection];
        
        NSDictionary* plistInfo = [NSDictionary dictionaryWithContentsOfFile:filePath];
        
        CMEmojiSectionModel* peopleSection = [CMEmojiSectionModel new];
        NSMutableArray* people = [NSMutableArray array];
        for (NSString* emoji in [plistInfo arrayValueForKey:@"people"]) {
            CMKeyModel* keyModel = [[CMKeyModel alloc] initEmojiWithKey:emoji];
            [people addObject:keyModel];
        }
        peopleSection.emojiArray = [people copy];
        peopleSection.sectionName = @"people";
        peopleSection.sectionNormalIconName = @"emoji_icon_people";
        peopleSection.sectionHighlightIconName = @"emoji_icon_people_highlight";

        [sectionArray addObject:peopleSection];
        
        CMEmojiSectionModel* natureSection = [CMEmojiSectionModel new];
        NSMutableArray* nature = [NSMutableArray array];
        for (NSString* emoji in [plistInfo arrayValueForKey:@"nature"]) {
            CMKeyModel* keyModel = [[CMKeyModel alloc] initEmojiWithKey:emoji];
            [nature addObject:keyModel];
        }
        natureSection.emojiArray = [nature copy];
        natureSection.sectionName = @"nature";
        natureSection.sectionNormalIconName = @"emoji_icon_nature";
        natureSection.sectionHighlightIconName = @"emoji_icon_nature_highlight";
        [sectionArray addObject:natureSection];

        CMEmojiSectionModel* symbolsSection = [CMEmojiSectionModel new];
        NSMutableArray* symbols = [NSMutableArray array];
        for (NSString* emoji in [plistInfo arrayValueForKey:@"objects&symbols"]) {
            CMKeyModel* keyModel = [[CMKeyModel alloc] initEmojiWithKey:emoji];
            [symbols addObject:keyModel];
        }
        symbolsSection.emojiArray = [symbols copy];
        symbolsSection.sectionName = @"symbols";
        symbolsSection.sectionNormalIconName = @"emoji_icon_symbols";
        symbolsSection.sectionHighlightIconName = @"emoji_icon_symbols_highlight";
        [sectionArray addObject:symbolsSection];

        CMEmojiSectionModel* foodSection = [CMEmojiSectionModel new];
        NSMutableArray* drinks = [NSMutableArray array];
        for (NSString* emoji in [plistInfo arrayValueForKey:@"food&drinks"]) {
            CMKeyModel* keyModel = [[CMKeyModel alloc] initEmojiWithKey:emoji];
            [drinks addObject:keyModel];
        }
        foodSection.emojiArray = [drinks copy];
        foodSection.sectionName = @"drinks";
        foodSection.sectionNormalIconName = @"emoji_icon_drink";
        foodSection.sectionHighlightIconName = @"emoji_icon_drink_highlight";
        [sectionArray addObject:foodSection];

        CMEmojiSectionModel* activitySection = [CMEmojiSectionModel new];
        NSMutableArray* activity = [NSMutableArray array];
        for (NSString* emoji in [plistInfo arrayValueForKey:@"activity"]) {
            CMKeyModel* keyModel = [[CMKeyModel alloc] initEmojiWithKey:emoji];
            [activity addObject:keyModel];
        }
        activitySection.emojiArray = [activity copy];
        activitySection.sectionName = @"activity";
        activitySection.sectionNormalIconName = @"emoji_icon_activity";
        activitySection.sectionHighlightIconName = @"emoji_icon_activity_highlight";
        [sectionArray addObject:activitySection];

        if (IOS9_OR_LATER) {
            CMEmojiSectionModel* flagSection = [CMEmojiSectionModel new];
            NSMutableArray* flags = [NSMutableArray array];
            for (NSString* emoji in [plistInfo arrayValueForKey:@"flags"]) {
                CMKeyModel* keyModel = [[CMKeyModel alloc] initEmojiWithKey:emoji];
                [flags addObject:keyModel];
            }
            flagSection.emojiArray = [flags copy];
            flagSection.sectionName = @"flags";
            flagSection.sectionNormalIconName = @"emoji_icon_flags";
            flagSection.sectionHighlightIconName = @"emoji_icon_flags_highlight";
            [sectionArray addObject:flagSection];
        }

        CMEmojiSectionModel* objectsSection = [CMEmojiSectionModel new];
        NSMutableArray* objects = [NSMutableArray array];
        for (NSString* emoji in [plistInfo arrayValueForKey:@"objects"]) {
            CMKeyModel* keyModel = [[CMKeyModel alloc] initEmojiWithKey:emoji];
            [objects addObject:keyModel];
        }
        objectsSection.emojiArray = [objects copy];
        objectsSection.sectionName = @"objects";
        objectsSection.sectionNormalIconName = @"emoji_icon_objects";
        objectsSection.sectionHighlightIconName = @"emoji_icon_objects_highlight";
        [sectionArray addObject:objectsSection];

        CMEmojiSectionModel* travelSection = [CMEmojiSectionModel new];
        NSMutableArray* places = [NSMutableArray array];
        for (NSString* emoji in [plistInfo arrayValueForKey:@"travel&places"]) {
            CMKeyModel* keyModel = [[CMKeyModel alloc] initEmojiWithKey:emoji];
            [places addObject:keyModel];
        }
        travelSection.emojiArray = [places copy];
        travelSection.sectionName = @"places";
        travelSection.sectionNormalIconName = @"emoji_icon_places";
        travelSection.sectionHighlightIconName = @"emoji_icon_places_highlight";
        [sectionArray addObject:travelSection];
        
        _emojiArray = [sectionArray copy];

//        CMEmojiSectionModel* faceActivitySection = [CMEmojiSectionModel new];
//        faceActivitySection.sectionModel = [[plistInfo dictionaryValueForKey:@"faceDict"] arrayValueForKey:@"activity"];
//        [sectionArray addObject:faceActivitySection];
//
//        CMEmojiSectionModel* facePeopleSection = [CMEmojiSectionModel new];
//        facePeopleSection.sectionModel = [[plistInfo dictionaryValueForKey:@"faceDict"] arrayValueForKey:@"people"];
//        [sectionArray addObject:facePeopleSection];
    }
    return self;
}

+ (instancetype)viewModelWithPlist:(NSString *)filePath {
    CMEmojiKeyboardViewModel* viewModel = [[CMEmojiKeyboardViewModel alloc] initWithPlist:filePath];
    return viewModel;
}

@end
