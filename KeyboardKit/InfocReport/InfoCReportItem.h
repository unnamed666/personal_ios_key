//
//  InfoCReportItem.h
//  PhotoGrid
//
//  Created by deafbreeds on 2016/10/18.
//  Copyright © 2016年 CMCM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfoCReportItem : NSObject
{
 
}

-(NSInteger) eventID;
-(NSDictionary *) params;
-(void) reportWithForce:(BOOL) _forceReport;

@end
