// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InputModel.m instead.

#import "_InputModel.h"

@implementation InputModelID
@end

@implementation _InputModel

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"InputModel" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"InputModel";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"InputModel" inManagedObjectContext:moc_];
}

- (InputModelID*)objectID {
	return (InputModelID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"keyboardTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"keyboardType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"returnTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"returnType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic count;

- (int64_t)countValue {
	NSNumber *result = [self count];
	return [result longLongValue];
}

- (void)setCountValue:(int64_t)value_ {
	[self setCount:@(value_)];
}

- (int64_t)primitiveCountValue {
	NSNumber *result = [self primitiveCount];
	return [result longLongValue];
}

- (void)setPrimitiveCountValue:(int64_t)value_ {
	[self setPrimitiveCount:@(value_)];
}

@dynamic keyboardType;

- (int16_t)keyboardTypeValue {
	NSNumber *result = [self keyboardType];
	return [result shortValue];
}

- (void)setKeyboardTypeValue:(int16_t)value_ {
	[self setKeyboardType:@(value_)];
}

- (int16_t)primitiveKeyboardTypeValue {
	NSNumber *result = [self primitiveKeyboardType];
	return [result shortValue];
}

- (void)setPrimitiveKeyboardTypeValue:(int16_t)value_ {
	[self setPrimitiveKeyboardType:@(value_)];
}

@dynamic returnType;

- (int16_t)returnTypeValue {
	NSNumber *result = [self returnType];
	return [result shortValue];
}

- (void)setReturnTypeValue:(int16_t)value_ {
	[self setReturnType:@(value_)];
}

- (int16_t)primitiveReturnTypeValue {
	NSNumber *result = [self primitiveReturnType];
	return [result shortValue];
}

- (void)setPrimitiveReturnTypeValue:(int16_t)value_ {
	[self setPrimitiveReturnType:@(value_)];
}

@end

@implementation InputModelAttributes 
+ (NSString *)count {
	return @"count";
}
+ (NSString *)keyboardType {
	return @"keyboardType";
}
+ (NSString *)returnType {
	return @"returnType";
}
@end

