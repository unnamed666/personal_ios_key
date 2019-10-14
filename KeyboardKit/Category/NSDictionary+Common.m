//
//  NSDictionary.m
//  Meng800
//
//  Created by 猎豹 on 14/7/19.
//

#import "NSDictionary+Common.h"
#import "CMLogger.h"

@implementation NSDictionary (Common)

- (BOOL)boolValueForKey:(NSString *)key {
    return [self boolValueForKey:key defaultValue:NO];
}

- (BOOL)boolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    return ([self objectForKey:key] == [NSNull null] || [self objectForKey:key] == nil) ? defaultValue
    : [[self objectForKey:key] boolValue];
}

- (int)intValueForKey:(NSString *)key {
    return [self intValueForKey:key defaultValue:0];
}

- (int)intValueForKey:(NSString *)key defaultValue:(int)defaultValue {
    return ([self objectForKey:key] == [NSNull null] || [self objectForKey:key] == nil)
    ? defaultValue : [[self objectForKey:key] intValue];
}

- (NSInteger)integerValueForKey:(NSString *)key
{
    return [self integerValueForKey:key defaultValue:0];
}

- (NSInteger)integerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue
{
    return ([self objectForKey:key] == [NSNull null] || [self objectForKey:key] == nil)
    ? defaultValue : [[self objectForKey:key] integerValue];
}

- (NSDictionary *)dictionaryValueForKey:(NSString *)key {
    NSObject *obj = [self objectForKey:key];
    if (obj && [obj isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)obj;
    }
    return [NSDictionary dictionary];
}

- (NSArray *)arrayValueForKey:(NSString *)key {
    NSObject *obj = [self objectForKey:key];
    if (obj && [obj isKindOfClass:[NSArray class]]) {
        return (NSArray *)obj;
    }
    return [NSArray array];
}

- (time_t)timeValueForKey:(NSString *)key {
    return [self timeValueForKey:key defaultValue:0];
}

- (time_t)timeValueForKey:(NSString *)key defaultValue:(time_t)defaultValue {
    id timeObject = [self objectForKey:key];
    if ([timeObject isKindOfClass:[NSNumber class]]) {
        NSNumber *n = (NSNumber *)timeObject;
        CFNumberType numberType = CFNumberGetType((CFNumberRef)n);
        NSTimeInterval t;
        if (numberType == kCFNumberLongLongType) {
            t = [n longLongValue] / 1000;
        }
        else {
            t = [n longValue];
        }
        return t;
    }
    else if ([timeObject isKindOfClass:[NSString class]]) {
        NSString *stringTime = timeObject;
        if (stringTime.length == 13) {
            long long llt = [stringTime longLongValue];
            NSTimeInterval t = llt / 1000;
            return t;
        }
        else if (stringTime.length == 10) {
            long long lt = [stringTime longLongValue];
            NSTimeInterval t = lt;
            return t;
        }
        else {
            if (!stringTime || (id)stringTime == [NSNull null]) {
                stringTime = @"";
            }
            struct tm created;
            time_t now;
            time(&now);
            
            if (stringTime) {
                if (strptime([stringTime UTF8String], "%a %b %d %H:%M:%S %z %Y", &created) == NULL) {
                    strptime([stringTime UTF8String], "%a, %d %b %Y %H:%M:%S %z", &created);
                }
                return mktime(&created);
            }
        }
    }
    return defaultValue;
}

- (long long)longLongValueForKey:(NSString *)key {
    return [self longLongValueForKey:key defaultValue:0];
}

- (long long)longLongValueForKey:(NSString *)key defaultValue:(long long)defaultValue {
    return ([self objectForKey:key] == [NSNull null] || [self objectForKey:key] == nil)
    ? defaultValue : [[self objectForKey:key] longLongValue];
}

- (double)doubleValueForKey:(NSString *)key {
    return [self doubleValueForKey:key defaultValue:0];
}

- (double)doubleValueForKey:(NSString *)key defaultValue:(double)defaultValue {
    if ([self objectForKey:key] == [NSNull null]) {
        return defaultValue;
    }
    if ([[self objectForKey:key] isKindOfClass:[NSString class]]) {
        
        NSString *stringValue = [self objectForKey:key];
        return [[stringValue stringByReplacingOccurrencesOfString:@"," withString:@""] doubleValue];
    } else if ([[self objectForKey:key] isKindOfClass:[NSNumber class]]) {
        return [[self objectForKey:key] doubleValue];
    }
    
    return defaultValue;
}

- (float)floatValueForKey:(NSString *)key
{
    return [self floatValueForKey:key defaultValue:0];
}

- (float)floatValueForKey:(NSString *)key defaultValue:(float)defaultValue
{
    return ([self objectForKey:key] == [NSNull null] || [self objectForKey:key] == nil)
    ? defaultValue : [[self objectForKey:key] floatValue];
}

- (NSString *)stringValueForKey:(NSString *)key {
    return [self stringValueForKey:key defaultValue:nil];
}

- (NSString *)stringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    if ([self objectForKey:key] == nil || [self objectForKey:key] == [NSNull null]) {
        return defaultValue;
    }
    id result = [self objectForKey:key];
    if ([result isKindOfClass:[NSNumber class]]) {
        return [result stringValue];
    }
    return result;
}

- (NSData *) toJsonData{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                        error:&error];
    if(error){
        kLogInfo(@"Got an error: %@", error);
    }
    return jsonData;
}

- (NSString*) toJSonString{
    
    NSString *jsonString = nil;
;
    NSData *jsonData = [self toJsonData];
    if (! jsonData) {
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

@end
