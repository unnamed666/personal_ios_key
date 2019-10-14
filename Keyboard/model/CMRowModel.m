//
//  CMRowModel.m
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/9.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "CMRowModel.h"
#import "CMKeyModel.h"
#import "CMTextInputModel.h"

@interface CMRowModel ()
@property (nonatomic, readwrite, strong)NSMutableArray<CMKeyModel *>* keyArray;

@end

@implementation CMRowModel

+ (instancetype)rowModelWithArray:(NSArray<CMKeyModel *>*)keys {
    CMRowModel* model = [CMRowModel new];
    model.keyArray = [keys mutableCopy];
    return model;
}

+ (instancetype)rowModelWithDictionary:(NSDictionary *)dic
{
    CMRowModel* rowModel = [CMRowModel new];
    NSArray* infoArray = [dic objectForKey:@"character"];
    if (!infoArray || infoArray.count <= 0) {
        return nil;
    }
    NSMutableArray* array = [NSMutableArray array];
    for (NSDictionary* infoDic in infoArray) {
        CMKeyModel* keyModel = [CMKeyModel keyModelWithDictionary:infoDic];
        [array addObject:keyModel];
    }
    rowModel.keyArray = [array mutableCopy];

    return rowModel;
}

- (void)updateLayoutIdAndSpaceKey:(NSString *)layoutId layoutKey:(NSString *)layoutKey {
    if (!self.keyArray || self.keyArray.count <= 0) {
        return;
    }
    [self.keyArray enumerateObjectsUsingBlock:^(CMKeyModel * _Nonnull keyModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (keyModel.keyType == CMKeyTypeLayoutSwitch && idx == 0) {
            keyModel.layoutId = layoutId;
            keyModel.key = layoutKey;
//            *stop = YES;
        }
    }];
}

- (BOOL)isEqualToModel:(CMRowModel *)model {
    if (!model) {
        return NO;
    }
    BOOL count = self.keyArray.count == model.keyArray.count;
    BOOL inputType = [self.inputModel isEqual:model.inputModel];
    
    return count && inputType;
}


- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[CMRowModel class]]) {
        return NO;
    }
    
    return [self isEqualToModel:(CMRowModel *)object];
}



@end
