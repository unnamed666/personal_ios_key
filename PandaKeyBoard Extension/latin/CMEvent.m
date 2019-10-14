//
//  CMEvent.m
//  Panda Keyboard
//
//  Created by yanzhao on 2017/3/11.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import "CMEvent.h"
#import "CMKeyModel.h"
#import "CMStringUtils.h"
#import "Character.h"
@interface CMEvent ()
//@property (nonatomic,strong) NSMutableArray<CMEvent*> * freeEvent;

@end

@implementation CMEvent
static NSMutableArray<CMEvent*> * freeEvent;
static NSObject * freeEventSync;

+(instancetype)obtainEvent{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        freeEvent = [[NSMutableArray alloc] init];
        freeEventSync = [NSObject new];
    });
    CMEvent *event = nil;
    
//    NSLog(@"%@",freeEvent);
    @synchronized (freeEventSync) {
        event =  [freeEvent lastObject];
        [freeEvent removeObject:event];
    }

    if(!event)
        event = [[CMEvent alloc] init];
    
//    NSLog(@"%@",event);
    return event;
}

+ (instancetype)obtainEventByCMKeyModel:(CMKeyModel *)keyModel {
    CMEvent* event = [CMEvent obtainEvent];
    event.key = keyModel;
    return event;
}


+ (instancetype)obtainEventByLetter:(NSString *)letter {
    CMEvent* event = [CMEvent obtainEvent];
    event.key = [[CMKeyModel alloc] init];
    event.key.key = letter;
    event.key.mCode = [Character codePointAt:letter index:0];
    event.key.keyType = CMKeyTypeLetter;
    event.code = CMEventCodeInput;
    return event;
}

-(void)recycle{
    self.key = nil;
    self.code = 0;
    self.origin = CGPointZero;
    self.object = nil;
    @synchronized (freeEventSync){
        [freeEvent addObject:self];
    }
}

@end
