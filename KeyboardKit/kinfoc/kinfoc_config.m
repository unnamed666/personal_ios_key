//
//  kinfoc_config.m
//  KEWL
//
//  Created by Jin Ye on 4/23/16.
//  Copyright © 2016 CMCM. All rights reserved.
//

#import "kinfoc_config.h"

@implementation KInfocConfig

+ (NSString*) getPublicTableName
{
    return @"cheetahkeyboard_public";
}

+ (NSString*) getDefaultServerUrl
{
    return @"https://helpcheetahkeyboard1.ksmobile.com/c/";
}

+ (BOOL) didUserAllowedUploadInfo
{
    // TODO
    return YES;
}

@end
