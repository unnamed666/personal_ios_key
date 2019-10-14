//
//  CMGiphyImage.m
//  iMessage
//
//  Created by yanzhao on 2017/9/25.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import "CMGiphyImage.h"
@interface CMGiphyImage ()<NSCoding>
@property (strong, readwrite, nonatomic) NSURL * url;
@property (readwrite, nonatomic) CGFloat width;
@property (readwrite, nonatomic) CGFloat height;
@end
@implementation CMGiphyImage

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _url = [aDecoder decodeObjectForKey:@"url"];
        _width = [aDecoder decodeInt32ForKey:@"width"];
        _height = [aDecoder decodeInt32ForKey:@"height"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeInt32:(int)_width forKey:@"width"];
    [aCoder encodeInt32:(int)_height forKey:@"height"];
}

- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.url = [NSURL URLWithString:dictionary[@"url"]];
    self.width = [dictionary[@"width"] floatValue];
    self.height = [dictionary[@"height"] floatValue];
    
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"url = %@,width = %f,height = %f",_url,_width,_height];
}
@end
