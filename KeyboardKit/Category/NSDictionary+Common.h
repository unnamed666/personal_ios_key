//
//  NSDictionary.h
//  Meng800
//
//  Created by 猎豹 on 14/7/19.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Common)
- (BOOL)boolValueForKey:(NSString *)key;
- (BOOL)boolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue;
- (int)intValueForKey:(NSString *)key;
- (int)intValueForKey:(NSString *)key defaultValue:(int)defaultValue;

- (NSInteger)integerValueForKey:(NSString *)key;
- (NSInteger)integerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue;

- (time_t)timeValueForKey:(NSString *)key;
- (time_t)timeValueForKey:(NSString *)key defaultValue:(time_t)defaultValue;
- (long long)longLongValueForKey:(NSString *)key;
- (long long)longLongValueForKey:(NSString *)key defaultValue:(long long)defaultValue;
- (NSString *)stringValueForKey:(NSString *)key;
- (NSString *)stringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue;
- (NSDictionary *)dictionaryValueForKey:(NSString *)key;
- (NSArray *)arrayValueForKey:(NSString *)key;
- (double)doubleValueForKey:(NSString *)key;
- (double)doubleValueForKey:(NSString *)key defaultValue:(double)defaultValue;
- (float)floatValueForKey:(NSString *)key;
- (float)floatValueForKey:(NSString *)key defaultValue:(float)defaultValue;

- (NSString*) toJSonString;
- (NSData *) toJsonData;

@end
