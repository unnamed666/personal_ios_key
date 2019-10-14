//
//  kinfoc_control.h
//  KEWL
//
//  Created by Jin Ye on 4/26/16.
//  Copyright © 2016 CMCM. All rights reserved.
//

typedef enum _emKInfoPriority {
    Unknow          = -1,
    High,           // 0
    Normal,         // 1
    Basic_infoc,    // 2
    Basic_special,  // 3
    End             // 4
} emKInfoPriority;


@interface KInfoControl : NSObject
{
@private
    void* m_pKCtrlDatReader;
    bool m_bInited;
}

- (bool) isInited;
- (NSInteger) getProductID;
- (NSInteger) getValidityDays;
- (NSInteger) getProbability:(NSString*) strTableName;
- (NSInteger) getUserProbability:(NSString*) strTableName;
- (NSString*) getServerUrl:(emKInfoPriority) nPriority;

@end
