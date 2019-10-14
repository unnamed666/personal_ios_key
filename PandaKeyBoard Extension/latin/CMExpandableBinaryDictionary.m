//
//  CMExpandableBinaryDictionary.m
//  PandaKeyboard
//
//  Created by yanzhao on 2017/6/21.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMExpandableBinaryDictionary.h"
#import "CMBinaryDictionary.h"
@class SuggestedWordInfo;

int const DICTIONARY_FORMAT_VERSION = 403;

NSString * const DICTIONARY_VERSION_KEY = @"version";
NSString * const DICTIONARY_LOCALE_KEY = @"locale";
NSString * const DICTIONARY_ID_KEY = @"dictionary";
NSString * const USES_FORGETTING_CURVE_KEY = @"USES_FORGETTING_CURVE";
NSString * const HAS_HISTORICAL_INFO_KEY = @"HAS_HISTORICAL_INFO";
NSString * const ATTRIBUTE_VALUE_TRUE = @"1";
@interface CMExpandableBinaryDictionary (){
    BOOL _dircExists;
}

@property (nonatomic, strong)dispatch_queue_t serailQueue;

@property (nonatomic,readwrite,copy) NSString *dictName;


@property (nonatomic,strong) CMBinaryDictionary * mBinaryDictionary;
@property (nonatomic,strong) NSString * mPath;
@property (nonatomic,strong) NSString * filePath;
@end

@implementation CMExpandableBinaryDictionary

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dircExists = NO;
        _mPath = [kPathDocument stringByAppendingPathComponent:@"expandableBinaryDictionary"];
        [CMDirectoryHelper createDir:_mPath];
        self.serailQueue = dispatch_queue_create([NSStringFromClass(self.class) UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}


-(void)reset:(NSString*)dictName{
    
    [self flushBinaryDictionary];
    
    self.dictName =dictName;
    self.needsToRecreate= NO;
    
    self.filePath = [_mPath stringByAppendingPathComponent:dictName];
//    _dircExists = [Common directoryHaveContent:self.filePath];
    _dircExists = [self historyFileExist:self.filePath];
}

- (BOOL)historyFileExist:(NSString*)filePath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    BOOL dir = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if(!dir)return NO;
    NSArray *arr = [fileManager contentsOfDirectoryAtPath:filePath error:nil];
    __block BOOL haveHeader = NO;
    __block BOOL haveBody = NO;
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* extension =  [obj pathExtension];
        if([extension isEqualToString:@"header"]){
            haveHeader = YES;
        }else if([extension isEqualToString:@"body"]){
            haveBody = YES;
        }
        
    }];
    return haveBody && haveHeader;

}

- (void)reloadDictionaryIfRequired{
    if(![self isReloadRequired]) return;
    
    [self asyncReloadDictionary];
    
}


- (void)asyncFlushBinaryDictionary{
    @weakify(self)
    dispatch_async(self.serailQueue, ^{
        @stronglize(self);
         [self flushBinaryDictionary];
    });
    
}


- (NSArray*) getSuggestionsWithComposedData:(CmposedData *)cmposseData ngramContext:(CMNgramContext*)cmNgramContext proximityInfoHandle:(long long)proximityInfoHandle sessionId:(int)sessionId weightForLocale:(float)weightForLocale inOutWeightOfLangModelVsSpatialModel:(float)inOutWeightOfLangModelVsSpatialModel{
    [self reloadDictionaryIfRequired];
    __block NSArray<SuggestedWordInfo*> * suggestions;
    kLog(@"getsuggestions 同步  cmposseData = %@",cmposseData);
    @weakify(self)
    dispatch_sync(self.serailQueue, ^{
        kLog(@"getsuggestions 同步1 cmNgramContext = %@",cmNgramContext);
        @stronglize(self);
        suggestions= [self.mBinaryDictionary getSuggestionsWithComposedData:cmposseData ngramContext:cmNgramContext proximityInfoHandle:proximityInfoHandle sessionId:sessionId weightForLocale:weightForLocale inOutWeightOfLangModelVsSpatialModel:inOutWeightOfLangModelVsSpatialModel];
        kLog(@"history count = %ld",(unsigned long)suggestions.count);
        if([self.mBinaryDictionary isCorruptedNative]){
            
            kLog(@"getsuggestions 异步");
            @weakify(self)
            dispatch_async(self.serailQueue, ^{
                kLog(@"getsuggestions 异步1");
                @stronglize(self);
                [self removeBinaryDictionaryLocked];
            });
        }
    });
    
    kLog(@"history  %@",suggestions);
    
    return suggestions;
}

- (int)frequencyWithWord:(NSString*)word{
    __block int i;
    dispatch_sync(self.serailQueue, ^{
        i = [_mBinaryDictionary frequencyWithWord:word];
    });
    return i;
}

- (BOOL) isValidDictionary{
    return [_mBinaryDictionary isValidDictionary];
}
- (BOOL)isValidWord:(NSString*)word{
    __block BOOL b;
    dispatch_sync(self.serailQueue, ^{
        b = [_mBinaryDictionary isValidWord:word];
    });
    return b;
}


- (void)updateEntriesForWord:(NSString*)word ngramContext:(CMNgramContext*)ngram isValidWord:(BOOL)isValid count:(int)count timestamp:(int)time{
    dispatch_async(_serailQueue, ^{
         kLog(@"updateEntriesForWord   word = %@ , ngram = %@",word,ngram);
        [_mBinaryDictionary updateEntriesForWordWithNgramContext:ngram word:word isValidWord:isValid count:count timestamp:time];
    });
}

- (void)removeUnigramEntryDynamically:(NSString*)word{
    [self reloadDictionaryIfRequired];
    
    dispatch_async(self.serailQueue, ^{
            if(_mBinaryDictionary != nil ){
                if(![_mBinaryDictionary removeUnigramEntryNative:word]){
                    kLog(@"Can not remove unigram entry :%@",word);
                }
            }
        
        
    });
}

#pragma mark - private


- (void)flushBinaryDictionary{
    if([_mBinaryDictionary needsToRunGC:NO]){
        [_mBinaryDictionary flushWithGC];
    }else{
        [_mBinaryDictionary flush];
    }
}

- (void)dealloc
{
//    @weakify(self)
//    dispatch_sync(self.serailQueue, ^{
//        @stronglize(self);
    
    [self flushBinaryDictionary];
    [_mBinaryDictionary close];
    self.mBinaryDictionary = nil;
//    });
}

- (BOOL)isReloadRequired {
    return _mBinaryDictionary == nil || self.isNeedsToRecreate;
}

- (void)asyncReloadDictionary{

    
    @weakify(self)
    dispatch_async(self.serailQueue, ^{
        @stronglize(self);
        if(!_dircExists      || self.isNeedsToRecreate){
            [self createNewDictionaryLocked];
        }else if(_mBinaryDictionary == nil){
            [self loadBinaryDictionaryLocked];
            
            if(_mBinaryDictionary != nil && !([_mBinaryDictionary isValidDictionary]&& DICTIONARY_FORMAT_VERSION == [_mBinaryDictionary getFormatVersion])){
                [self createNewDictionaryLocked];
            }
            
        }
        self.needsToRecreate = NO;
    });
    

    
}

- (void)loadBinaryDictionaryLocked{
    [_mBinaryDictionary close];
    [self openBinaryDictionaryLocked];
    
    if([_mBinaryDictionary isValidDictionary] && 402 == [_mBinaryDictionary getFormatVersion]){
        if([_mBinaryDictionary migrateTo:DICTIONARY_FORMAT_VERSION]){
            [self removeBinaryDictionaryLocked];
        }
    }
}


- (void)createNewDictionaryLocked{
    [self removeBinaryDictionaryLocked];
    [self createOnMemoryBinaryDictionaryLocked];
    [_mBinaryDictionary flushWithGCIfHasUpdated];
}


- (void)openBinaryDictionaryLocked{
    self.mBinaryDictionary = [[CMBinaryDictionary alloc] initWithFilePath:self.filePath locale:self.locale isUpadtable:YES useFullEditDistance:YES];
    _mBinaryDictionary.dictType = self.dictType;
}

- (void)createOnMemoryBinaryDictionaryLocked{
    self.mBinaryDictionary = [[CMBinaryDictionary alloc] initWithFilePath:self.filePath locale:self.locale useFullEditDistance:YES dictType:self.dictType formatVersion:DICTIONARY_FORMAT_VERSION attributeDictionary:[self getHeaderAttributeMap]];
}

- (void)removeBinaryDictionaryLocked{
    [self closeBinaryDictionary];
    [CMDirectoryHelper deleteDirOrFile:self.filePath];
}

- (void)closeBinaryDictionary{
    [_mBinaryDictionary close];
    self.mBinaryDictionary = nil;
}

- (NSMutableDictionary*) getHeaderAttributeMap{
    NSMutableDictionary * mutableDictionary = [NSMutableDictionary new];
    [mutableDictionary setObject:self.dictName forKey:DICTIONARY_ID_KEY];
    [mutableDictionary setObject:self.locale forKey:DICTIONARY_LOCALE_KEY];
    [mutableDictionary setObject:[NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]] forKey:DICTIONARY_VERSION_KEY];
    return mutableDictionary;
}

@end
