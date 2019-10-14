// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InputModel.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface InputModelID : NSManagedObjectID {}
@end

@interface _InputModel : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) InputModelID *objectID;

@property (nonatomic, strong, nullable) NSNumber* count;

@property (atomic) int64_t countValue;
- (int64_t)countValue;
- (void)setCountValue:(int64_t)value_;

@property (nonatomic, strong, nullable) NSNumber* keyboardType;

@property (atomic) int16_t keyboardTypeValue;
- (int16_t)keyboardTypeValue;
- (void)setKeyboardTypeValue:(int16_t)value_;

@property (nonatomic, strong, nullable) NSNumber* returnType;

@property (atomic) int16_t returnTypeValue;
- (int16_t)returnTypeValue;
- (void)setReturnTypeValue:(int16_t)value_;

@end

@interface _InputModel (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSNumber*)primitiveCount;
- (void)setPrimitiveCount:(nullable NSNumber*)value;

- (int64_t)primitiveCountValue;
- (void)setPrimitiveCountValue:(int64_t)value_;

- (nullable NSNumber*)primitiveKeyboardType;
- (void)setPrimitiveKeyboardType:(nullable NSNumber*)value;

- (int16_t)primitiveKeyboardTypeValue;
- (void)setPrimitiveKeyboardTypeValue:(int16_t)value_;

- (nullable NSNumber*)primitiveReturnType;
- (void)setPrimitiveReturnType:(nullable NSNumber*)value;

- (int16_t)primitiveReturnTypeValue;
- (void)setPrimitiveReturnTypeValue:(int16_t)value_;

@end

@interface InputModelAttributes: NSObject 
+ (NSString *)count;
+ (NSString *)keyboardType;
+ (NSString *)returnType;
@end

NS_ASSUME_NONNULL_END
