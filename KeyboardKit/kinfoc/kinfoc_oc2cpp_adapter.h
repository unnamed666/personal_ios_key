//
//  kinfoc_oc2cpp_adapter.h
//  KEWL
//
//  Created by Jin Ye on 4/22/16.
//  Copyright © 2016 CMCM. All rights reserved.
//
#import <UIKit/UIKit.h>
@interface KInfocOc2CppFunc : NSObject

+ (NSData*) buildReportDataForProduct:(NSInteger) prodId
    byPublicSection: (NSData*) pPublicSection
    andDataSection: (NSData*) pDataSection;

+ (NSData*) getPublicSectionBinary: (NSString*) strPublicDataString;
+ (NSData*) getDataSectionBinary: (NSString*) strDataString forTable:(NSString*) strTableName;

+ (NSMutableData*) buildReportDataHeader:(NSData*) pPublicSection;
+ (BOOL) addReportData:(NSData*) pDataSection toDataObj:(NSMutableData*) dataObj;
+ (NSData*) finishBuildBatchReportDataForProduct:(NSInteger) prodId withDataObj:(NSMutableData*) pDataObj;

@end
