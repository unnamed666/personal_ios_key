//
//  kinfoc_public_section_mgr.h
//  KEWL
//
//  Created by Jin Ye on 5/5/16.
//  Copyright © 2016 CMCM. All rights reserved.
//

@interface KInfocPublicSectionMgr : NSObject
{
@private
    NSString* m_publicSection;
    NSData* m_publicSectionData;
}

- (void) rebuildPublicSection;
- (NSData*) getPublicSectionData;

@end
