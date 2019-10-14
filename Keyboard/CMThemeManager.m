//
//  CMThemeManager.m
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/10.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import "CMThemeManager.h"
#import "SSZipArchive.h"
#import "CMThemeModel.h"
#import "CMKeyboardModel.h"
#import "CMNotificationConstants.h"

#ifndef HostApp
#else
#import <pthread.h>

@interface Resources :NSObject
@property (nonatomic, assign)int referenceCount;
@end
@implementation Resources
- (instancetype)init
{
    self = [super init];
    if (self) {
        _referenceCount = 1;
    }
    return self;
}
@end

#endif


@interface CMThemeManager (){
#ifndef HostApp
#else
    CFMutableDictionaryRef _dic;//需要 copy 的主题资源的引用计数,当数值等于0的时候,移除主题资源
    pthread_mutex_t _lock;
#endif
}
@property (nonatomic, strong)NSMutableArray<CMThemeModel*>* downloadedThemes;
@property (nonatomic, strong)NSMutableArray<CMThemeModel*>* diyThemes;
//@property (nonatomic, strong)NSMutableArray * diyThemeArray;
@property (nonatomic, strong)dispatch_queue_t themeSerailQueue;

@property (nonatomic, readwrite, copy)NSString* currentThemeName;
@property (nonatomic, strong)NSMutableDictionary * themeCache;

#ifdef HostApp
@property (nonatomic, strong)NSMutableDictionary * themeNinePatchImageCache;
#endif

#ifndef HostApp
@property (nonatomic, strong)NSDictionary* currentTheme;
#else
@property (nonatomic, strong)NSMutableDictionary* currentTheme;
#endif
@property (nonatomic, strong)NSString * themePath;
@property (nonatomic, assign)BOOL diyThemeSetup;


// Font
@property (nonatomic, readwrite, strong)NSString* keyTextFontName;
@property (nonatomic, readwrite, strong)UIFont* spaceKeyFont;
@property (nonatomic, readwrite, strong)UIFont* funcKeyFont;
@property (nonatomic, readwrite, strong)UIFont* emojiKeyFont;
@property (nonatomic, readwrite, strong)UIFont* letterKeyFont;
@property (nonatomic, readwrite, strong)UIFont* letterKeyHighlightFont;
@property (nonatomic, readwrite, strong)UIFont* nonLetterKeyFont;
@property (nonatomic, readwrite, strong)UIFont* nonLetterKeyHighlightFont;
@property (nonatomic, readwrite, strong)UIFont* inputOptionCellFont;
@property (nonatomic, readwrite, strong)UIFont* inputOptionCellHighlightFont;
@property (nonatomic, readwrite, strong)UIFont* preInputFont;
@property (nonatomic, readwrite, strong)UIFont* keyHintFont;
@property (nonatomic, readwrite, strong)UIFont* predictCellTextFont;

// Sound
@property (nonatomic, readwrite, copy)NSString* defaultSoundPath;
@property (nonatomic, readwrite, copy)NSString* delSoundPath;
@property (nonatomic, readwrite, copy)NSString* spaceSoundPath;
@property (nonatomic, readwrite, copy)NSString* returnSoundPath;

@property (nonatomic, readwrite, strong)NSData* defaultSoundData;
@property (nonatomic, readwrite, strong)NSData* delSoundData;
@property (nonatomic, readwrite, strong)NSData* spaceSoundData;
@property (nonatomic, readwrite, strong)NSData* returnSoundData;


// Animate
@property (nonatomic, readwrite, copy)NSString* ribbonVertexShader;
@property (nonatomic, readwrite, copy)NSString* ribbonFragmentShader;
@property (nonatomic, readwrite, strong)GLKTextureInfo *ribbonTexture;
//@property (nonatomic, readwrite, strong)SCNMaterial* ribbonMaterial;

@property (nonatomic, readwrite, strong)GLKTextureLoader *asyncTextureLoader;
@property (nonatomic, readwrite, strong)EAGLContext *context;


@end

@implementation CMThemeManager

#pragma mark - function

- (void)dealloc{
#ifndef HostApp
#else
    CFRelease(_dic);
    pthread_mutex_destroy(&_lock);
#endif
}

- (instancetype)init {
    if (self = [super init]) {

#ifndef HostApp
#else
//        CFTimeInterval start1 = CFAbsoluteTimeGetCurrent();
        NSString* filePath = [[CMDirectoryHelper documentDir] stringByAppendingPathComponent:@"themes.dat"];
        id themes = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (themes && [themes isKindOfClass:[NSArray class]]) {
            [((NSArray*)themes) enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if([obj isKindOfClass:[CMThemeModel class]]){
                    if(((CMThemeModel*)obj).type == CMThemeModelType_Custom){
                        [self.diyThemes addObject:obj];
                    }else{
                        [self.downloadedThemes addObject:obj];
                    }
                }
            }];
        }
//        CFTimeInterval end = CFAbsoluteTimeGetCurrent();
//        kLog(@"------ 😀 %f",((end - start1)*1000));
        _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        pthread_mutex_init(&_lock, NULL);
#endif
    }
    return self;
}
- (void)resetThemeFont{
    self.keyTextFontName = nil;
    self.spaceKeyFont = nil;
    self.funcKeyFont = nil;
    self.emojiKeyFont = nil;
    self.letterKeyFont = nil;
    self.letterKeyHighlightFont = nil;
    self.nonLetterKeyFont = nil;
    self.nonLetterKeyHighlightFont = nil;
    self.inputOptionCellFont = nil;
    self.inputOptionCellHighlightFont = nil;
    self.preInputFont = nil;
    self.keyHintFont = nil;
    self.predictCellTextFont = nil;
}

-(void)resetThemeSound{
    self.defaultSoundData = nil;
    self.delSoundData = nil;
    self.returnSoundData = nil;
    self.spaceSoundData = nil;
    
    self.defaultSoundPath = nil;
    self.delSoundPath = nil;
    self.returnSoundPath = nil;
    self.spaceSoundPath = nil;
}

- (void)resetThemeCache {
    kLogTrace();
    
    [self resetRibbonAnimateCache];
    [self.themeCache removeAllObjects];//宿主 app 在 diy 主题编辑页面 收到内存警告不可以执行该语句
    
    [self resetThemeFont];
    [self resetThemeSound];
    
    self.keyboardViewControllerWidth = 0.0f;
}

- (void)cacheRibbonAnimate {
    kLogTrace();
    if ([self.currentThemeName isEqualToString:@"default"]) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        NSDictionary *options = @{GLKTextureLoaderGenerateMipmaps : @YES};
        @weakify(self)
        void (^complete)(GLKTextureInfo*, NSError*) = ^(GLKTextureInfo *texture,
                                                        NSError *error){
            @stronglize(self)
            if(error){
                // give up
                if (_ribbonTexture) {
                    GLuint name = self.ribbonTexture.name;
                    glDeleteTextures(1, &name);
                }
                self.ribbonTexture = nil;
                return;
            }
            // run our actual completion code on the main queue
            // so the glDeleteTextures call works
            dispatch_sync(dispatch_get_main_queue(), ^{
                @stronglize(self)
                // delete texture
                if (_ribbonTexture) {
                    GLuint name = self.ribbonTexture.name;
                    glDeleteTextures(1, &name);
                }
                // assign loaded texture
                self.ribbonTexture = texture;
                kLogInfo(@"[TRACE] ribbonTexture 缓存加载成功");
            });
        };

        dispatch_async(queue, ^{
            @stronglize(self)
            if (!_ribbonVertexShader) {
                NSURL *vertexShaderURL = [[NSBundle mainBundle] URLForResource:@"BlackAurora" withExtension:@"vert"];
                self.ribbonVertexShader = [[NSString alloc] initWithContentsOfURL:vertexShaderURL
                                                                       encoding:NSUTF8StringEncoding
                                                                          error:NULL];
            }
            else {
                kLogInfo(@"[TRACE] ribbonVertexShader 命中缓存");
            }
            
            if (!_ribbonFragmentShader) {
                NSURL *fragmentShaderURL = [[NSBundle mainBundle] URLForResource:@"BlackAurora" withExtension:@"frag"];
                self.ribbonFragmentShader = [[NSString alloc] initWithContentsOfURL:fragmentShaderURL
                                                                       encoding:NSUTF8StringEncoding
                                                                          error:NULL];
            }
            else {
                kLogInfo(@"[TRACE] ribbonFragmentShader 命中缓存");
            }
        });

        if (!_ribbonTexture) {
            // load texture in queue and pass in completion block
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"aurora_tex4" ofType:@"png"]; // 1
            [self.asyncTextureLoader textureWithContentsOfFile:filePath
                                                       options:options
                                                         queue:queue
                                             completionHandler:complete];
        }
        else {
            kLogInfo(@"[TRACE] ribbonTexture 命中缓存");
        }
    }
}

- (void)resetRibbonAnimateCache {
    if (![self.currentThemeName isEqualToString:@"default"]) {
        _ribbonVertexShader = nil;
        _ribbonFragmentShader = nil;
        if (_ribbonTexture) {
            GLuint name = _ribbonTexture.name;
            glDeleteTextures(1, &name);
            _ribbonTexture = nil;
        }
//        _ribbonMaterial = nil;
//        [EAGLContext setCurrentContext:nil];
//        _context = nil;
        kLogInfo(@"[TRACE] 删除缓存");
    }
    else {
        kLogInfo(@"[TRACE] 目前仍使用default主题");
    }
}

//- (SCNMaterial *)ribbonMaterial {
//    if (!_ribbonMaterial) {
//        SCNProgram *program = [SCNProgram program];
//        program.vertexShader   = self.ribbonVertexShader;
//        program.fragmentShader = self.ribbonFragmentShader;
//
//        // Become the program delegate (to get runtime compilation errors)
////        program.delegate = self;
//
//        // Associate geometry and node data with the attributes and uniforms
//        // -----------------------------------------------------------------
//
//        // Attributes (position, normal, texture coordinate)
//        [program setSemantic:SCNGeometrySourceSemanticVertex
//                   forSymbol:@"a_position"
//                     options:nil];
//        //    [program setSemantic:SCNGeometrySourceSemanticNormal
//        //               forSymbol:@"normal"
//        //                 options:nil];
//        [program setSemantic:SCNGeometrySourceSemanticTexcoord
//                   forSymbol:@"a_texCoord"
//                     options:nil];
//
//        // Uniforms (the three different transformation matrices)
//        [program setSemantic:SCNModelViewProjectionTransform
//                   forSymbol:@"modelViewProjection"
//                     options:nil];
//
//        _ribbonMaterial = [SCNMaterial material];
//
//        _ribbonMaterial.program = program;
//        _ribbonMaterial.doubleSided = YES;
//
//        CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
//        [_ribbonMaterial handleBindingOfSymbol:@"CC_Time" usingBlock:^(unsigned int programID, unsigned int location, SCNNode * _Nullable renderedNode, SCNRenderer * _Nonnull renderer) {
//            glUniform1f(location, CFAbsoluteTimeGetCurrent() - startTime);
//        }];
//
//
//        GLKTextureInfo* texture = self.ribbonTexture;
//        [_ribbonMaterial handleBindingOfSymbol:@"u_texture0" usingBlock:^(unsigned int programID, unsigned int location, SCNNode * _Nullable renderedNode, SCNRenderer * _Nonnull renderer) {
//            if(texture) {
//                // Handle the error
//                glBindTexture(GL_TEXTURE_2D, texture.name);
//            }
//        }];
//    }
//    return _ribbonMaterial;
//}

- (void)switchTo:(NSString *)themeName {
#ifndef HostApp
//    [self resetThemeCache];
    NSString* bundlePath = [[NSBundle mainBundle] pathForResource:themeName ofType:@"plist"];
    if ([NSString stringIsEmpty:bundlePath]) {
        NSString* themePlistPath = [NSString stringWithFormat:@"%@/%@/", kCMGroupDataManager.ThemePath.path, themeName];
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:themePlistPath];
        if (exist) {
            if (![NSString stringIsEmpty:self.themePath] && ![self.themePath isEqualToString:themePlistPath]) {
                [self resetThemeCache];
            }
            self.themePath = themePlistPath;
            self.currentTheme = [[NSDictionary alloc] initWithContentsOfFile:[themePlistPath stringByAppendingPathComponent:@"theme.plist"]];
            
//            NSURL* plistUrl = [NSURL URLWithString:themePlistPath];
//            [ThemeManager setThemeWithPlistInSandbox:@"theme" path:plistUrl];
            [[CMGroupDataManager shareInstance] setCurrentThemeName:themeName];
            self.currentThemeName = themeName;

//            NSArray* directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:themePlistPath error:nil];
//            [directoryContents enumerateObjectsUsingBlock:^(NSString*  _Nonnull filePath, NSUInteger idx, BOOL * _Nonnull stop) {
//                if ([filePath hasSuffix:@".plist"]) {
//                    NSURL* plistUrl = [NSURL URLWithString:themePlistPath];
//                    [ThemeManager setThemeWithPlistInSandbox:filePath path:plistUrl];
//                    [[CMGroupDataManager shareInstance] setCurrentThemeName:themeName];
//                    *stop = YES;
//                }
//            }];
        }
        else {
            
            self.themePath = [[NSBundle mainBundle] pathForResource:@"default" ofType:@"bundle"];
            self.currentTheme = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"default" ofType:@"plist"]];
            kLogError(@"%@.plist not existed", themeName);
//            [ThemeManager setThemeWithPlistInMainBundle:@"default"];
            [[CMGroupDataManager shareInstance] setCurrentThemeName:@"default"];
            self.currentThemeName = themeName;
        }
    }
    else {
        if (![NSString stringIsEmpty:self.currentThemeName] && ![self.currentThemeName isEqualToString:themeName]) {
            [self resetThemeCache];
        }
        self.themePath = [[NSBundle mainBundle] pathForResource:themeName ofType:@"bundle"];;
        self.currentTheme = [[NSDictionary alloc] initWithContentsOfFile:bundlePath];
        
//        [ThemeManager setThemeWithPlistInMainBundle:themeName];

        [[CMGroupDataManager shareInstance] setCurrentThemeName:themeName];
        self.currentThemeName = themeName;
    }
    
#else
    self.diyThemeSetup = NO;
    
    NSString* bundlePath = [[NSBundle mainBundle] pathForResource:themeName ofType:@"plist"];
    if ([NSString stringIsEmpty:bundlePath]) {
        NSString* themePlistPath = [NSString stringWithFormat:@"%@/%@/", kCMGroupDataManager.ThemePath.path, themeName];
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:themePlistPath];
        if (exist) {
            if (![NSString stringIsEmpty:self.themePath] && ![self.themePath isEqualToString:themePlistPath]) {
                [self resetThemeCache];
            }
            self.themePath = themePlistPath;
            self.currentTheme = [[NSMutableDictionary alloc] initWithContentsOfFile:[themePlistPath stringByAppendingPathComponent:@"theme.plist"]];
            self.currentThemeName = themeName;

        }else {
            
            self.themePath = [[NSBundle mainBundle] pathForResource:@"diyTheme" ofType:@"bundle"];
            self.currentTheme = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"diyTheme" ofType:@"plist"]];
            kLogError(@"%@.plist not existed", themeName);
            self.currentThemeName = themeName;
        }
    }
    else {
        if (![NSString stringIsEmpty:self.currentThemeName] && ![self.currentThemeName isEqualToString:themeName]) {
            [self resetThemeCache];
        }
        self.themePath = [[NSBundle mainBundle] pathForResource:themeName ofType:@"bundle"];;
        self.currentTheme = [[NSMutableDictionary alloc] initWithContentsOfFile:bundlePath];
        
        self.currentThemeName = themeName;
    }
    // 创建 diy 主题目录
    [self createDiyThemeDirectory];
    
        pthread_mutex_lock(&_lock);
        if (CFDictionaryGetCount(_dic) > 0) {
                    CFMutableDictionaryRef holder = _dic;
                    _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
                    dispatch_async(queue, ^{
                        CFRelease(holder); // hold and release in specified queue
                    });
        }else{
            [self setupDicContentWithKey:@"imageAttr"];
            [self setupDicContentWithKey:@"viewAttr"];
            [self setupDicContentWithKey:@"sound"];
            
        }
        pthread_mutex_unlock(&_lock);



#endif
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ThemeUpdateNotification" object:nil];
    
}
#ifndef HostApp
#else
- (void)setupDicContentWithKey:(NSString*)key{
    NSDictionary *dic = [self.currentTheme objectForKey:key];
    if(dic){
        [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            id value = nil;
            if([obj isKindOfClass:[NSString class]] && ![NSString stringIsEmpty:obj]){
                value = obj;
            }else if ([obj isKindOfClass:[NSDictionary class]]){
                NSString * fontName = [obj objectForKey:@"fontName"];
                if(![NSString stringIsEmpty:fontName]){
                    value = fontName;
                }
            }
            if(value){
                Resources * resources = CFDictionaryGetValue(_dic, (__bridge const void *)(value));
                if(!resources){
                    Resources * resources = [[Resources alloc] init];
                    CFDictionarySetValue(_dic, (__bridge const void *)(value), (__bridge const void *)(resources));
                }else{
                    resources.referenceCount+=1;
                }
            }
            
            
        }];
    }
}
#endif

- (NSURLSessionDownloadTask *)downloadTheme:(CMThemeModel *)model
                              progressBlock:(CMProgressBlock)progressBlock
                              completeBlock:(CMDownloadCompleteBlock)completeBlock {
    __block CMThemeModel* theModel = model;
    NSURLSessionDownloadTask* task = [CMRequestFactory downloadRequestWithURL:model.downloadUrlString progressBlock:progressBlock completeBlock:^(NSURLResponse *response, NSURL *filePath, CMError *error) {
        if (!error) {
            dispatch_async(self.themeSerailQueue, ^{
                NSString* oldPath = filePath.path;
                NSFileManager* fileMgr = [NSFileManager defaultManager];
                NSRange range = [oldPath rangeOfString:@"/" options:NSBackwardsSearch];
                NSString* newPath = [[oldPath substringToIndex:NSMaxRange(range)] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", theModel.themeName]];
                NSError* localError = nil;
                [fileMgr moveItemAtPath:oldPath toPath:newPath error:&localError];
                if (localError) {
                    if (completeBlock) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completeBlock(response, filePath, [CMError errorWithNSError:localError]);
                        });
                    }
                }
                else {
                    [SSZipArchive unzipFileAtPath:newPath toDestination:[[CMGroupDataManager shareInstance].ThemePath.path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/", theModel.themeName]] progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
                        //
                    } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
                        if (!error && succeeded) {
                            theModel.localPathString = [[CMGroupDataManager shareInstance].ThemePath.path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/", theModel.themeName]];
                            __block NSInteger index = -1;
                            [self.downloadedThemes enumerateObjectsUsingBlock:^(CMThemeModel*  _Nonnull themeModel, NSUInteger idx, BOOL * _Nonnull stop) {
                                if ([themeModel.themeId isEqualToString:theModel.themeId]) {
                                    index = idx;
                                    *stop = YES;
                                }
                            }];
                            if (index >= 0) {
                                [self.downloadedThemes replaceObjectAtIndex:index withObject:theModel];
                            }
                            else {
                                [self.downloadedThemes addObject:theModel];
                            }
                            BOOL succeed = [self archive];
                            BOOL delete = [[NSFileManager defaultManager] removeItemAtPath:newPath error:&error];
                            
                            if (!succeed || !delete) {
                                if (completeBlock) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        completeBlock(response, filePath, [CMError errorWithCode:CMErrorCodeUnknow errorMessage:[NSString stringWithFormat:@"本地序列化失败(%d)或删除zip文件失败(%d)", succeed, delete]]);
                                    });
                                }
                            }
                            else {
                                if (completeBlock) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        completeBlock(response, filePath, nil);
                                    });
                                }
                            }
                        }
                        else {
                            if (completeBlock) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completeBlock(response, filePath, [CMError errorWithNSError:error]);
                                });
                            }
                        }
                    }];
                }
            });
        }
        else {
            if (completeBlock) {
                completeBlock(response, filePath, error);
            }
        }
    }];
    return task;
}

- (BOOL)archive {
    NSMutableArray *arr = nil;
    if (_downloadedThemes && _downloadedThemes.count > 0){
        arr = [[NSMutableArray alloc] initWithArray:_downloadedThemes];
    }
    if(_diyThemes && _diyThemes.count>0){
        if(arr){
            [arr addObjectsFromArray:_diyThemes];
        }else{
            arr = [[NSMutableArray alloc] initWithArray:_diyThemes];
        }
    }else if(!arr){
        arr = [NSMutableArray array];
    }
    

    NSString* filePath = [[CMDirectoryHelper documentDir] stringByAppendingPathComponent:@"themes.dat"];
    return [NSKeyedArchiver archiveRootObject:arr toFile:filePath];
}

- (NSString *)cachedThemeVersion:(CMThemeModel *)themeModel {
    __block NSString* result = nil;
    [self.downloadedThemes enumerateObjectsUsingBlock:^(CMThemeModel*  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([themeModel.themeId isEqualToString:model.themeId]) {
            result = model.themeVersion;
            *stop = YES;
        }
    }];
    return result;
}

- (NSString *)cachedThemeName:(CMThemeModel *)themeModel {
    __block NSString* result = nil;
    [self.downloadedThemes enumerateObjectsUsingBlock:^(CMThemeModel*  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([themeModel.themeId isEqualToString:model.themeId]) {
            result = model.themeName;
            *stop = YES;
        }
    }];
    return result;
}

- (NSString *)cachedThemeLocalPath:(CMThemeModel *)themeModel {
    __block NSString* result = nil;
    [self.downloadedThemes enumerateObjectsUsingBlock:^(CMThemeModel*  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([themeModel.themeId isEqualToString:model.themeId]) {
            result = model.localPathString;
            *stop = YES;
        }
    }];
    return result;
}

- (CMThemeModel *)cachedThemeModelById:(NSString *)themeId {
    __block CMThemeModel* result = nil;
    [self.downloadedThemes enumerateObjectsUsingBlock:^(CMThemeModel*  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([model.themeId isEqualToString:themeId]) {
            result = model;
            *stop = YES;
        }
    }];
    return result;
}

- (void)deleteThemeModel:(CMThemeModel*)model{
    NSString* themePlistPath = [NSString stringWithFormat:@"%@/%@/", kCMGroupDataManager.ThemePath.path, model.themeId];
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:themePlistPath];
    if (exist){
        [[NSFileManager defaultManager] removeItemAtPath:themePlistPath error:nil];
        [self.diyThemes removeObject:model];
        [self archive];
    }
    
}
- (void)cancelChangeDiyTheme{
    if(_diyThemeSetup)return;
    [[NSFileManager defaultManager] removeItemAtPath:self.themePath error:nil];
    self.diyThemeSetup= NO;
}

- (void)createDiyThemeDirectory{
    if(_diyThemeSetup)return;
    NSString * themeDirectory;
    NSString *fileName ;
    long long dateNum = [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000] longLongValue];
    if ([self.themePath rangeOfString:@"diyTheme.bundle"].location != NSNotFound){
        fileName = [NSString stringWithFormat:@"DIY_%lld",(long long)dateNum];
    }else{
        if ([self.themePath.lastPathComponent hasPrefix:@"DIY_"]) {
            NSString *string = [self.themePath.lastPathComponent substringFromIndex:4];
            if ([string containsString:@"_"]) {
                // 格式为DIY_THEMEID_时间戳
                fileName = [NSString stringWithFormat:@"DIY_%@_%lld", string, (long long)dateNum];
            }else{
                fileName = [NSString stringWithFormat:@"DIY_%lld", (long long)dateNum];
            }
        }else{
            fileName = [NSString stringWithFormat:@"DIY_%@_%lld", self.themePath.lastPathComponent, (long long)dateNum];
        }
    }
    themeDirectory = [kPathTemp stringByAppendingString:fileName];

    NSError * error;
    [[NSFileManager defaultManager] copyItemAtPath:self.themePath toPath:themeDirectory error:&error];
    if(error){
        NSLog(@"%@ copy toPath %@ error!",self.themePath,themeDirectory);
    }
    self.themePath = themeDirectory;
    self.currentThemeName = fileName;
    self.diyThemeSetup= YES;
}

#ifdef HostApp
- (BOOL)saveDiyThemeWithCoverImage:(UIImage*)coverImage{
    if(!_diyThemeSetup)return NO;
    CMThemeModel * themeModel;//将修改的theme 模型放到数组最后的位置
    for (themeModel in _diyThemes) {
        if ([themeModel.themeId isEqualToString:self.currentThemeName]){
            [_diyThemes removeObject:themeModel];
            if(_diyThemes.count == 0){
                [_diyThemes addObject:themeModel];
            }else{
                [_diyThemes insertObject:themeModel atIndex:0];
            }
            break;
        }
    }
    //保存缓存中的图片
    NSDictionary * dic = [self.currentTheme valueForKey:@"imageAttr"];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if([obj isKindOfClass:[NSString class]]){
            if([((NSString*)obj) hasSuffix:@"png"]){
                id object = [self.themeCache objectForKey:obj];
                if ([UIImage isNinePatchImageByName:obj]) {
                    object = [self.themeNinePatchImageCache objectForKey:obj];
                }
                if([object isKindOfClass:[UIImage class]]){
                    [UIImagePNGRepresentation(object)  writeToFile:[self.themePath stringByAppendingPathComponent:obj] atomically:YES];
                }
            }
        }
    }];
    
    NSString * coverPath = [self.themePath stringByAppendingPathComponent:@"cover.jpg"];
    if(coverImage){
        [[NSFileManager defaultManager] removeItemAtPath:coverPath error:nil];
        [UIImageJPEGRepresentation(coverImage,0.1) writeToFile:coverPath atomically:YES];
    }
    
    if(!themeModel){
        NSString * path = kCMGroupDataManager.ThemePath.path;
        NSString * dirName = [self.themePath lastPathComponent];
        NSString * themePath = [path stringByAppendingPathComponent:dirName];
        themeModel = [[CMThemeModel alloc] initWithCustomThemeId:self.currentThemeName coverImagePath:[themePath stringByAppendingPathComponent:@"cover.jpg"] localPath:themePath];
        if(self.diyThemes.count == 0){
            [self.diyThemes addObject:themeModel];
        }else{
            [self.diyThemes insertObject:themeModel atIndex:0];
        }
        [self archive];
    }else{
        [[NSFileManager defaultManager] removeItemAtPath:themeModel.localPathString error:nil];
    }
    [self.currentTheme writeToFile:[self.themePath stringByAppendingPathComponent:@"theme.plist"] atomically:YES];
    
    NSError * error;
    [[NSFileManager defaultManager] moveItemAtPath:self.themePath toPath:themeModel.localPathString error:&error];
    if(error){
        NSLog(@"%@",error);
    }
    return YES;
}
#endif

#pragma mark - setter/getter
- (NSArray<CMThemeModel*>*)DIYThemes{
    return _diyThemes;
}

- (CMThemeModel *)latestDIYTheme{
    return [_diyThemes firstObject];
}

- (NSMutableArray<CMThemeModel*> *)downloadedThemes{
    if(!_downloadedThemes){
        _downloadedThemes = [NSMutableArray new];
    }
    return _downloadedThemes;
}

- (NSMutableArray<CMThemeModel*> *)diyThemes{
    if(!_diyThemes){
        _diyThemes = [NSMutableArray new];
    }
    return _diyThemes;
}

- (dispatch_queue_t)themeSerailQueue {
    if (!_themeSerailQueue) {
        _themeSerailQueue = dispatch_queue_create("theme_manager_serial_queue", DISPATCH_QUEUE_SERIAL);
    }
    return _themeSerailQueue;
}

- (NSMutableDictionary *)themeCache{
    if(!_themeCache){
        _themeCache = [[NSMutableDictionary alloc] init];
//        _themeCache.countLimit = 50;
//        _themeCache.delegate = self;
    }
    return _themeCache;
}

#ifdef HostApp
- (NSMutableDictionary *)themeNinePatchImageCache
{
    if (!_themeNinePatchImageCache) {
        _themeNinePatchImageCache = [[NSMutableDictionary alloc] init];
    }
    return _themeNinePatchImageCache;
}

#endif

#pragma mark - 主题
#ifndef HostApp
#else
-(void)setStandardDirSound:(NSString *)soundDirPath{
    
    NSString *defaultPath =  soundDirPath? [soundDirPath.lastPathComponent  stringByAppendingPathComponent:@"default.wav"] : @"";
    NSString *deletePath  =  soundDirPath? [soundDirPath.lastPathComponent stringByAppendingPathComponent:@"delete.wav"] : @"";
    NSString *enterPath   =  soundDirPath? [soundDirPath.lastPathComponent stringByAppendingPathComponent:@"enter.wav"] : @"";
    NSString *spacePath   =  soundDirPath? [soundDirPath.lastPathComponent stringByAppendingPathComponent:@"space.wav"] : @"";
    
    [self.currentTheme setValue:defaultPath forKeyPath:@"sound.default"];
    [self.currentTheme setValue:deletePath forKeyPath:@"sound.delete"];
    [self.currentTheme setValue:enterPath forKeyPath:@"sound.returntype"];
    [self.currentTheme setValue:spacePath forKeyPath:@"sound.space"];
    
    [self resetThemeSound];

//    [self setObject:nil objPath:defaultPath toDir:@"sounds" forKeyPath:@"sound.default"];
//
//    [self setObject:nil objPath:deletePath toDir:@"sounds" forKeyPath:@"sound.delete"];
//
//    [self setObject:nil objPath:enterPath toDir:@"sounds" forKeyPath:@"sound.returntype"];
//
//    [self setObject:nil objPath:spacePath toDir:@"sounds" forKeyPath:@"sound.space"];
    
}

-(void)setStandardDirFont:(NSString *)fontDirPath{
    NSString *defaultPath =  fontDirPath? fontDirPath.lastPathComponent  : @"";
    [self.currentTheme setValue:defaultPath forKeyPath:@"viewAttr.keyTextFontName"];
    [self resetThemeFont];
}

- (void)setFont:(NSString*)fontPath  forKeyPath:(NSString *)keyPath{
    [self setObject:nil objPath:fontPath toDir:@"fonts" forKeyPath:keyPath];
    [self resetThemeFont];
}

- (void)setColor:(NSString*)colorStr forKeyPath:(NSString *)keyPath{
    NSString* value = [self.currentTheme valueForKeyPath:keyPath];
    if([NSString stringIsEmpty:colorStr]) {
        if(![NSString stringIsEmpty:value]){
            [self removeLocalResources:value];
        }
        [self.currentTheme setValue:@"" forKeyPath:keyPath];
        return;
    }
    
    UIColor *color = [UIColor colorWithHexString:colorStr];
    [self.currentTheme setValue:colorStr forKeyPath:keyPath];
    [self addLocalResources:color path:nil forKey:colorStr];
}

- (void)removeLocalResources:(NSString*)value{
    pthread_mutex_lock(&_lock);
    if(CFDictionaryContainsKey(_dic,(__bridge const void *)(value))){
        Resources *resource = CFDictionaryGetValue(_dic, (__bridge const void *)(value));
        if(resource.referenceCount<=1){
            resource.referenceCount = 0;
            [self.themeCache removeObjectForKey:value];
            [[NSFileManager defaultManager] removeItemAtPath:[self.themePath stringByAppendingPathComponent:value] error:nil];
        }else{
            resource.referenceCount -=1;
        }
    }
    pthread_mutex_unlock(&_lock);
}
- (void)addLocalResources:(id)obj path:(NSString*)path forKey:(id)key{
    pthread_mutex_lock(&_lock);
//    if(CFDictionaryContainsKey(_dic,(__bridge const void *)(key))){
    Resources *resource = CFDictionaryGetValue(_dic, (__bridge const void *)(key));
    if(resource && resource.referenceCount > 0){
        resource.referenceCount +=1;
    }else{
        if(!resource){
            Resources * resources = [[Resources alloc] init];
            CFDictionarySetValue(_dic, (__bridge const void *)(key), (__bridge const void *)(resources));
        }else{
            resource.referenceCount = 1;
        }
        
        if(obj){
            if ([obj isKindOfClass:[UIImage class]] && [UIImage isNinePatchImageByName:key]) {
                [self.themeNinePatchImageCache setObject:obj forKey:key];
                UIImage *image = [SWNinePatchImageFactory createResizableNinePatchImage:obj];
                [self.themeCache setObject:image forKey:key];
            }else{
                [self.themeCache setObject:obj forKey:key];
            }
        }
        if(path){
            NSError *error;
            
            if ([[NSFileManager defaultManager] copyItemAtPath:path toPath:[self.themePath stringByAppendingPathComponent:key] error:&error]) {
                
            }else{
                
            }
           
        }
    }
    pthread_mutex_unlock(&_lock);
}

- (void)setObject:(id)obj objPath:(NSString*)objPath toDir:(NSString*)dir forKeyPath:(NSString *)keyPath{
    NSString* value = [self.currentTheme valueForKeyPath:keyPath];

    BOOL objPathNull  = [NSString stringIsEmpty:objPath];
    if(objPathNull && obj==nil) {
        if(![NSString stringIsEmpty:value]){
            [self removeLocalResources:value];
        }
        [self.currentTheme setValue:@"" forKeyPath:keyPath];
        return;
    }
    
    // 删除当前 key 所对应的资源
    if(![NSString stringIsEmpty:value]){
        [self removeLocalResources:value];
    }
    //创建目录
    NSString *fontDir = [self.themePath stringByAppendingPathComponent:dir];
    if(![[NSFileManager defaultManager] fileExistsAtPath:fontDir]){
        [[NSFileManager defaultManager] createDirectoryAtPath:fontDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
   
    //设置主题 plist 文件的 value 值
    if(!objPathNull){
        NSString * objName = [objPath lastPathComponent];
        value = [dir stringByAppendingPathComponent:objName];
        [self.currentTheme setValue:value forKeyPath:keyPath];
    }else{
        //如果设置的为图片, key 所对应的值为 null, 还没有图片路径,那就默认图片名为 key
        value = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@%@%@.png",  [keyPath lastPathComponent], kNativeScale == 3.0f ? @"3x" : @"2x", [obj isKindOfClass:[UIImage class]] && [obj isNinePatchImageByContent] ? @".9" : @""]];
        [self.currentTheme setValue:value forKeyPath:keyPath];
    }
    
    //将图片资源 copy 到 diy 主题目录
    [self addLocalResources:obj path:objPath forKey:value];
}

- (void)setImagePath:(NSString*)imagePath forKeyPath:(NSString *)keyPath {
    //读取图片到 cache
    UIImage * image = nil;
    if(![NSString stringIsEmpty:imagePath]) {
        image = [UIImage imageWithContentsOfFile:imagePath];
        if(!image)return;
        if([UIImage isNinePatchImageByName:imagePath]) {
            image = [SWNinePatchImageFactory createResizableImage:image];
        }
    }
    if(!image)return;
    [self setObject:image objPath:imagePath toDir:@"images" forKeyPath:keyPath];
}

- (void)setImage:(UIImage*)image forKeyPath:(NSString *)keyPath{
//    if(!image)return;
    [self setObject:image objPath:nil toDir:@"images" forKeyPath:keyPath];
}
#endif

- (UIImage *)imageFromKey:(NSString*)key{
  
    NSString* value =  [self.currentTheme valueForKeyPath:key];
    if([NSString stringIsEmpty:value]) return nil;
    
    UIImage *image = [self.themeCache objectForKey:value];
    if(image)   return image;
    image = [UIImage imageWithContentsOfFile:[self.themePath stringByAppendingPathComponent:value]];
    if(!image){
        image = [UIImage imageNamed:value];//iPad iOS 9.3.5 (13G36) 3ba82e06eff120602b7d2bc9823c390014a6e742 默认主题资源读取失败
    }
    if(!image)return nil;
    
    if([UIImage isNinePatchImageByName:value]){
        //
        NSUInteger cgImageWidth = CGImageGetWidth(image.CGImage);
        NSUInteger cgImageHight = CGImageGetHeight(image.CGImage);
        CGFloat top= 0,left =0,bottom=0, right=0;
        if([self.currentThemeName isEqualToString:@"default"]){
            if([value hasPrefix:@"dt_btn_keyboard_key_spacebar"]){
                top = bottom = 0;
            }else{
                top = bottom = round(cgImageHight/2/image.scale);
            }
            left = right = round(cgImageWidth/2/image.scale);
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(top,left,bottom, right) resizingMode:UIImageResizingModeStretch];
            
        }else if([self.currentThemeName isEqualToString:@"purple_hologram"]){
            if([value hasPrefix:@"ph_keyboard_key_feedback_background"]){
                top =  5;
                bottom =  cgImageHight - 6;
                left = right = round(cgImageWidth/2/image.scale);

            }else{
                top = bottom = round(cgImageHight/4*3/image.scale);
                left = right = round(cgImageWidth/2/image.scale);
            }
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(top,left,bottom, right) resizingMode:UIImageResizingModeStretch];
            
        }else{
            image = [SWNinePatchImageFactory createResizableNinePatchImage:image];
        }
    }else{
        if ([key isEqualToString:@"imageAttr.inputOptionViewBackgroundImage"] || [key isEqualToString:@"imageAttr.spaceKeyBackgroundImage"]) {
            image = [SWNinePatchImageFactory createResizableImage:image];
        }
    }
    
    [self.themeCache setObject:image forKey:value];

    return image;
}

- (UIColor *)colorFromKey:(NSString*)key defaultColor:(UIColor *)defColor{
    UIColor *color = [self colorFromKey:key];
    if(color == [UIColor clearColor]){
        return defColor;
    }
    return color;
}

- (UIColor *)colorFromKey:(NSString*)key{
    
    NSString* value =  [self.currentTheme valueForKeyPath:key];
    if(!value) return [UIColor clearColor];
    
    UIColor * color = [self.themeCache objectForKey:value];
    if(color)return color;
    
    color = [UIColor colorWithHexString:value];
    [self.themeCache setObject:color forKey:value];
    return color;
}

#pragma mark - image set
#ifndef HostApp
#else
- (void)letterKeyNormalBgImagePath:(NSString*)imagePath {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.letterKeyBackgroundImage"];
}

- (void)letterKeyHighlightBgImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.letterKeyHighlightBackgroundImage"];
}

- (void)funcKeyNormalBgImagePath:(NSString*)imagePath  {
   [self setImagePath:imagePath forKeyPath:@"imageAttr.functionalletterKeyBackgroundImage"];
}

- (void)funcKeyHighlightBgImagePath:(NSString*)imagePath  {
   [self setImagePath:imagePath forKeyPath:@"imageAttr.functionalletterKeyHighlightBackgroundImage"];
}

- (void)spaceKeyNormalBgImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.spaceKeyBackgroundImage"];
}

- (void)spaceKeyHighlightBgImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.spaceKeyHighlightBackgroundImage"];
}

- (void)delKeyNormalBgImagePath:(NSString*)imagePath  {
   [self setImagePath:imagePath forKeyPath:@"imageAttr.delKeyBackgroundImage"];
}

- (void)delKeyHighlightBgImagePath:(NSString*)imagePath  {
   [self setImagePath:imagePath forKeyPath:@"imageAttr.delKeyHighlightBackgroundImage"];
}

- (void)preInputBgImagePath:(NSString*)imagePath  {
   [self setImagePath:imagePath forKeyPath:@"imageAttr.preInputViewBackgroundImage"];
}

- (void)inputOptionBgImagePath:(NSString*)imagePath  {
   [self setImagePath:imagePath forKeyPath:@"imageAttr.inputOptionViewBackgroundImage"];
}

- (void)inputOptionHighlightBgImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.inputOptionCellHighlightBackgroundImage"];
}


- (void)returnKeyNormalImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.sym_keyboard_return"];
}

- (void)goKeyNormalImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.sym_keyboard_go"];
}

- (void)searchKeyNormalImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.sym_keyboard_search"];
}

- (void)nextKeyNormalImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.sym_keyboard_next"];
}

- (void)sendKeyNormalImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.sym_keyboard_send"];
}

- (void)doneKeyNormalImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.sym_keyboard_done"];
}

- (void)tabKeyNormalImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.sym_keyboard_tab"];
}

- (void)shiftKeyNormalImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.shiftKeyNormalBackgroundImage"];
}

- (void)shiftKeySelectImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.shiftKeySelectedBackgroundImage"];
}

- (void)shiftKeyLockImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.shiftKeyLockedBackgroundImage"];
}

- (void)globalImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.switchBtnBackgroundImage"];
}

- (void)wholeBoardBgImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.backgroundImage"];
}

- (void)keyboardViewBgImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.keyboardBackgroundImage"];
}

- (void)predictViewBgImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.predictViewBackgroundImage"];
}

- (void)emojiImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.sym_keyboard_smiley"];
}

- (void)settingImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.sym_keyboard_settings"];
}

- (void)themeImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.btn_keyboard_skin"];
}

- (void)predictCellBgImagePath:(NSString*)imagePath  {
    [self setImagePath:imagePath forKeyPath:@"imageAttr.predictCellBackgroundImage"];
}


-(void)setLetterKeyNormalBgImage:(UIImage *)letterKeyNormalBgImage{
    UIImage* image = letterKeyNormalBgImage;
    if (![image isNinePatchImageByContent]) {
        CGFloat width = image.size.width;
        CGFloat height = image.size.height;
        CGFloat top=height/2 - 1, left =width/2 - 1, bottom=height/2 + 1, right=width/2 + 1;
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
    }
    [self setImage:image forKeyPath:@"imageAttr.letterKeyBackgroundImage"];
}

-(void)setLetterKeyHighlightBgImage:(UIImage *)letterKeyHighlightBgImage{
    UIImage* image = letterKeyHighlightBgImage;
    if (![image isNinePatchImageByContent]) {
        CGFloat width = image.size.width;
        CGFloat height = image.size.height;
        CGFloat top=height/2 - 1, left =width/2 - 1, bottom=height/2 + 1, right=width/2 + 1;
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
    }
    [self setImage:image forKeyPath:@"imageAttr.letterKeyHighlightBackgroundImage"];
}

-(void)setFuncKeyNormalBgImage:(UIImage *)funcKeyNormalBgImage{
    UIImage* image = funcKeyNormalBgImage;
    if (![image isNinePatchImageByContent]) {
        CGFloat width = image.size.width;
        CGFloat height = image.size.height;
        CGFloat top=height/2 - 1, left =width/2 - 1, bottom=height/2 + 1, right=width/2 + 1;
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
    }
    [self setImage:image forKeyPath:@"imageAttr.functionalletterKeyBackgroundImage"];
}

-(void)setFuncKeyHighlightBgImage:(UIImage *)funcKeyHighlightBgImage{
    UIImage* image = funcKeyHighlightBgImage;
    if (![image isNinePatchImageByContent]) {
        CGFloat width = image.size.width;
        CGFloat height = image.size.height;
        CGFloat top=height/2 - 1, left =width/2 - 1, bottom=height/2 + 1, right=width/2 + 1;
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
    }
    [self setImage:image forKeyPath:@"imageAttr.functionalletterKeyHighlightBackgroundImage"];
}

-(void)setSpaceKeyNormalBgImage:(UIImage *)spaceKeyNormalBgImage{
    UIImage* image = spaceKeyNormalBgImage;
    if (![image isNinePatchImageByContent]) {
        CGFloat width = image.size.width;
        CGFloat height = image.size.height;
        CGFloat top=height/2 - 1, left =width/2 - 1, bottom=height/2 + 1, right=width/2 + 1;
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
    }
    [self setImage:image forKeyPath:@"imageAttr.spaceKeyBackgroundImage"];
}

-(void)setSpaceKeyHighlightBgImage:(UIImage *)spaceKeyHighlightBgImage{
    UIImage* image = spaceKeyHighlightBgImage;
    if (![image isNinePatchImageByContent]) {
        CGFloat width = image.size.width;
        CGFloat height = image.size.height;
        CGFloat top=height/2 - 1, left =width/2 - 1, bottom=height/2 + 1, right=width/2 + 1;
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
    }
    [self setImage:image forKeyPath:@"imageAttr.spaceKeyHighlightBackgroundImage"];
}

-(void)setDelKeyNormalBgImage:(UIImage *)delKeyNormalBgImage{
    [self setImage:delKeyNormalBgImage forKeyPath:@"imageAttr.delKeyBackgroundImage"];
}

-(void)setDelKeyHighlightBgImage:(UIImage *)delKeyHighlightBgImage{
    [self setImage:delKeyHighlightBgImage forKeyPath:@"imageAttr.delKeyHighlightBackgroundImage"];
}

-(void)setPreInputBgImage:(UIImage *)preInputBgImage{
    [self setImage:preInputBgImage forKeyPath:@"imageAttr.preInputViewBackgroundImage"];
}

-(void)setInputOptionBgImage:(UIImage *)inputOptionBgImage{
    UIImage* image = inputOptionBgImage;
    if (![image isNinePatchImageByContent]) {
        CGFloat width = image.size.width;
        CGFloat height = image.size.height;
        CGFloat top=height/2 - 1, left =width/2 - 1, bottom=height/2 + 1, right=width/2 + 1;
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
    }
    [self setImage:image forKeyPath:@"imageAttr.inputOptionViewBackgroundImage"];
}


-(void)setInputOptionHighlightBgImage:(UIImage *)inputOptionHighlightBgImage{
    [self setImage:inputOptionHighlightBgImage forKeyPath:@"imageAttr.inputOptionCellHighlightBackgroundImage"];
}

-(void)setReturnKeyNormalImage:(UIImage *)returnKeyNormalImage{
    [self setImage:returnKeyNormalImage forKeyPath:@"imageAttr.sym_keyboard_return"];
}

-(void)setGoKeyNormalImage:(UIImage *)goKeyNormalImage{
    [self setImage:goKeyNormalImage forKeyPath:@"imageAttr.sym_keyboard_go"];
}

-(void)setSearchKeyNormalImage:(UIImage *)searchKeyNormalImage{
    [self setImage:searchKeyNormalImage forKeyPath:@"imageAttr.sym_keyboard_search"];
}

- (void)setNextKeyNormalImage:(UIImage *)nextKeyNormalImage{
    [self setImage:nextKeyNormalImage forKeyPath:@"imageAttr.sym_keyboard_next"];
}

- (void)setSendKeyNormalImage:(UIImage *)sendKeyNormalImage{
    [self setImage:sendKeyNormalImage forKeyPath:@"imageAttr.sym_keyboard_send"];
}

-(void)setDoneKeyNormalImage:(UIImage *)doneKeyNormalImage{
    
    [self setImage:doneKeyNormalImage forKeyPath:@"imageAttr.sym_keyboard_done"];
}

-(void)setTabKeyNormalImage:(UIImage *)tabKeyNormalImage{
    [self setImage:tabKeyNormalImage forKeyPath:@"imageAttr.sym_keyboard_tab"];
}

- (void)setShiftKeyNormalImage:(UIImage *)shiftKeyNormalImage{
    [self setImage:shiftKeyNormalImage forKeyPath:@"imageAttr.shiftKeyNormalBackgroundImage"];
}

-(void)setShiftKeySelectImage:(UIImage *)shiftKeySelectImage{
    [self setImage:shiftKeySelectImage forKeyPath:@"imageAttr.shiftKeySelectedBackgroundImage"];
}

- (void)setShiftKeyLockImage:(UIImage *)shiftKeyLockImage{
    [self setImage:shiftKeyLockImage forKeyPath:@"imageAttr.shiftKeyLockedBackgroundImage"];
}

- (void)setGlobalImage:(UIImage *)globalImage{
    [self setImage:globalImage forKeyPath:@"imageAttr.switchBtnBackgroundImage"];
}

-(void)setWholeBoardBgImage:(UIImage *)wholeBoardBgImage{
    [self setImage:wholeBoardBgImage forKeyPath:@"imageAttr.backgroundImage"];
    
}

- (void)setKeyboardViewBgImage:(UIImage *)keyboardViewBgImage{
    [self setImage:keyboardViewBgImage forKeyPath:@"imageAttr.keyboardBackgroundImage"];
}

- (void)setPredictViewBgImage:(UIImage *)predictViewBgImage{
    [self setImage:predictViewBgImage forKeyPath:@"imageAttr.predictViewBackgroundImage"];
}
- (void)setEmojiImage:(UIImage *)emojiImage{
    [self setImage:emojiImage forKeyPath:@"imageAttr.sym_keyboard_smiley"];
}

- (void)setSettingImage:(UIImage *)settingImage{
    [self setImage:settingImage forKeyPath:@"imageAttr.sym_keyboard_settings"];
}
- (void)setThemeImage:(UIImage *)themeImage{
    [self setImage:themeImage forKeyPath:@"imageAttr.btn_keyboard_skin"];
}

- (void)setPredictCellBgImage:(UIImage *)predictCellBgImage {
    [self setImage:predictCellBgImage forKeyPath:@"imageAttr.predictCellBackgroundImage"];
}

#endif

#pragma mark - image get



- (UIImage *)letterKeyNormalBgImage {
    return [self imageFromKey:@"imageAttr.letterKeyBackgroundImage"];
}

- (UIImage *)letterKeyHighlightBgImage {
    return [self imageFromKey:@"imageAttr.letterKeyHighlightBackgroundImage"];
}

- (UIImage *)funcKeyNormalBgImage {
    return [self imageFromKey:@"imageAttr.functionalletterKeyBackgroundImage"];
}

- (UIImage *)funcKeyHighlightBgImage {
    return [self imageFromKey:@"imageAttr.functionalletterKeyBackgroundImage"];
//    return [self imageFromKey:@"imageAttr.functionalletterKeyHighlightBackgroundImage"];
}

- (UIImage *)spaceKeyNormalBgImage {
    return [self imageFromKey:@"imageAttr.spaceKeyBackgroundImage"];
}

- (UIImage *)spaceKeyHighlightBgImage {
    return [self imageFromKey:@"imageAttr.spaceKeyHighlightBackgroundImage"];
}

- (UIImage *)delKeyNormalBgImage {
    return [self imageFromKey:@"imageAttr.delKeyBackgroundImage"];
}

- (UIImage *)delKeyHighlightBgImage {
    return [self imageFromKey:@"imageAttr.delKeyHighlightBackgroundImage"];
}

- (UIImage *)preInputBgImage {
    return [self imageFromKey:@"imageAttr.preInputViewBackgroundImage"];
}

- (UIImage *)inputOptionBgImage {
    return [self imageFromKey:@"imageAttr.inputOptionViewBackgroundImage"];
}

- (UIImage *)inputOptionHighlightBgImage {
    return [self imageFromKey:@"imageAttr.inputOptionCellHighlightBackgroundImage"];
}


- (UIImage *)returnKeyNormalImage {
    return [self imageFromKey:@"imageAttr.sym_keyboard_return"];
}

- (UIImage *)goKeyNormalImage {
    return [self imageFromKey:@"imageAttr.sym_keyboard_go"];
}

- (UIImage *)searchKeyNormalImage {
    return [self imageFromKey:@"imageAttr.sym_keyboard_search"];
}

- (UIImage *)nextKeyNormalImage {
    return [self imageFromKey:@"imageAttr.sym_keyboard_next"];
}

- (UIImage *)sendKeyNormalImage {
    return [self imageFromKey:@"imageAttr.sym_keyboard_send"];
}

- (UIImage *)doneKeyNormalImage {
    return [self imageFromKey:@"imageAttr.sym_keyboard_done"];
}

- (UIImage *)tabKeyNormalImage {
    return [self imageFromKey:@"imageAttr.sym_keyboard_tab"];
}

- (UIImage *)shiftKeyNormalImage {
    return [self imageFromKey:@"imageAttr.shiftKeyNormalBackgroundImage"];
}

- (UIImage *)shiftKeySelectImage {
    return [self imageFromKey:@"imageAttr.shiftKeySelectedBackgroundImage"];
}

- (UIImage *)shiftKeyLockImage {
    return [self imageFromKey:@"imageAttr.shiftKeyLockedBackgroundImage"];
}

- (UIImage *)globalImage {
    return [self imageFromKey:@"imageAttr.switchBtnBackgroundImage"];
}

- (UIImage *)wholeBoardBgImage {
    return [self imageFromKey:@"imageAttr.backgroundImage"];
}

- (UIImage *)keyboardViewBgImage {
    return [self imageFromKey:@"imageAttr.keyboardBackgroundImage"];
}

- (UIImage *)predictViewBgImage {
    return [self imageFromKey:@"imageAttr.predictViewBackgroundImage"];
}

- (UIImage *)emojiImage {
    return [self imageFromKey:@"imageAttr.sym_keyboard_smiley"];
}

- (UIImage *)settingImage {
    return [self imageFromKey:@"imageAttr.sym_keyboard_settings"];
}

- (UIImage *)themeImage {
    return [self imageFromKey:@"imageAttr.btn_keyboard_skin"];
}

- (UIImage *)predictCellBgImage {
    return [self imageFromKey:@"imageAttr.predictCellBackgroundImage"];
}

#pragma mark - image path
#ifndef HostApp
#else
- (NSString *)letterKeyNormalBgImagePath
{
    return [self imagePath:@"imageAttr.letterKeyBackgroundImage"];
}

- (NSString *)letterKeyHighlightBgImagePath
{
    return [self imagePath:@"imageAttr.letterKeyHighlightBackgroundImage"];
}

- (NSString *)funcKeyNormalBgImagePath
{
    return [self imagePath:@"imageAttr.functionalletterKeyBackgroundImage"];
}

- (NSString *)funcKeyHighlightBgImagePath
{
    return [self imagePath:@"imageAttr.functionalletterKeyHighlightBackgroundImage"];
}

- (NSString *)spaceKeyNormalBgImagePath
{
    return [self imagePath:@"imageAttr.spaceKeyBackgroundImage"];
}

- (NSString *)spaceKeyHighlightBgImagePath
{
    return [self imagePath:@"imageAttr.spaceKeyHighlightBackgroundImage"];
}

- (NSString *)preInputBgImagePath
{
    return [self imagePath:@"imageAttr.preInputViewBackgroundImage"];
}

- (NSString *)inputOptionBgImagePath
{
    return [self imagePath:@"imageAttr.inputOptionViewBackgroundImage"];
}

- (NSString *)inputOptionHighlightBgImagePath
{
    return [self imagePath:@"imageAttr.inputOptionCellHighlightBackgroundImage"];
}

- (NSString *)imagePath:(NSString *)key
{
    NSString *imagePath = [self.themePath stringByAppendingPathComponent:[self.currentTheme valueForKeyPath:key]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        return imagePath;
    }
    return nil;
}
#endif

#pragma mark - color set
#ifndef HostApp
#else
- (void)wholeBoardBgColorHexString:(NSString*)hexStr {
    [self setColor:hexStr forKeyPath:@"imageAttr.backgroundColor"];
}

- (void)letterKeyNormalBgColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"imageAttr.letterKeyBackgroundColor"];
}

- (void)letterKeyHighlightBgColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"imageAttr.letterKeyHighlightBackgroundColor"];
}

- (void)funcKeyNormalBgColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"imageAttr.functionalletterKeyBackgroundColor"];
}

- (void)funcKeyHighlightBgColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"imageAttr.functionalletterKeyHighlightBackgroundColor"];
}

- (void)spaceKeyNormalBgColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"imageAttr.spaceKeyBackgroundColor"];
}

- (void)spaceKeyHighlightBgColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"imageAttr.spaceKeyHighlightBackgroundColor"];
}

- (void)preInputBgColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"imageAttr.preInputViewBackgroundColor"];
}

- (void)inputOptionBgColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"imageAttr.inputOptionViewBackgroundColor"];
}

- (void)inputOptionHighlightBgColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"imageAttr.inputOptionCellHighlightBackgroundColor"];
}

- (void)settingViewBgColorHexString:(NSString*)hexStr {
   [self setColor:hexStr forKeyPath:@"imageAttr.settingViewBackgroundColor"];
}

- (void)letterKeyTextColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"viewAttr.keyTextColor"];
}

- (void)letterKeyHighlightTextColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"viewAttr.keyHighlightTextColor"];
}

- (void)funcKeyTextColorHexString:(NSString*)hexStr {
    UIColor *color = [UIColor colorWithHexString:hexStr];
    self.shiftKeyNormalImage = [self.shiftKeyNormalImage imageWithTintColor:color];
    self.shiftKeyLockImage = [self.shiftKeyLockImage imageWithTintColor:color];
    self.shiftKeySelectImage = [self.shiftKeySelectImage imageWithTintColor:color];
    self.delKeyNormalBgImage = [self.delKeyNormalBgImage imageWithTintColor:color];
    self.returnKeyNormalImage = [self.returnKeyNormalImage imageWithTintColor:color];
    self.goKeyNormalImage = [self.goKeyNormalImage imageWithTintColor:color];
    self.searchKeyNormalImage = [self.searchKeyNormalImage imageWithTintColor:color];
    self.goKeyNormalImage = [self.goKeyNormalImage imageWithTintColor:color];
    self.nextKeyNormalImage = [self.nextKeyNormalImage imageWithTintColor:color];
    self.doneKeyNormalImage = [self.doneKeyNormalImage imageWithTintColor:color];
    self.sendKeyNormalImage = [self.sendKeyNormalImage imageWithTintColor:color];
    self.tabKeyNormalImage = [self.tabKeyNormalImage imageWithTintColor:color];
    self.globalImage = [self.globalImage imageWithTintColor:color];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShiftKeyTapped object:@{@"shiftKeyState":@(CMShiftKeyStateNormal)}];
    return [self setColor:hexStr forKeyPath:@"viewAttr.functionalTextColor"];
}

- (void)funcKeyHighlightTextColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"viewAttr.functionalHighlightTextColor"];
}

- (void)spaceKeyTextColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"viewAttr.spaceTextColor"];
}

- (void)spaceHighlightTextColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"viewAttr.spaceKeyHighlightTextColor"];
}

- (void)preInputTextColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"viewAttr.preInputTextColor"];
}

- (void)inputOptionTextColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"viewAttr.inputOptionCellTextColor"];
}

- (void)inputOptionHighlightTextColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"viewAttr.inputOptionCellHighlightTextColor"];
}

- (void)keyHintTextColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"viewAttr.keyHintLetterColor"];
}

- (void)tintColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"imageAttr.iconTintColor"];
}

- (void)settingCellTintColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"imageAttr.settingCellTintColor"];
}

- (void)dismissBtnTintColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"imageAttr.dismissButtonTintColor"];
}

- (void)inputOptionShadowColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"viewAttr.inputOptionCellShadowColor"];
}

- (void)predictViewBgColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"imageAttr.predictViewBackgroundColor"];
}

- (void)keyboardViewBgColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"imageAttr.keyboardBackgroundColor"];
}

- (void)predictCellBgColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"imageAttr.predictCellBackgroundColor"];
}

- (void)predictCellTextColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"viewAttr.colorSuggest"];
}

- (void)predictCellHighlightTextColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"viewAttr.predictCellHighlightTextColor"];
}

- (void)predictCellEmphasizeTextColorHexString:(NSString*)hexStr {
    return [self setColor:hexStr forKeyPath:@"viewAttr.colorAutoCotrrct"];
}

- (void)predictCellEmphasizeHighlightTextColorHexString:(NSString*)hexStr{
    return [self setColor:hexStr forKeyPath:@"viewAttr.predictCellEmphasizeHighlightTextColor"];
}

#endif

#pragma mark - color get
// Color
- (UIColor *)wholeBoardBgColor {
    return [self colorFromKey:@"imageAttr.backgroundColor"];
}

- (UIColor *)letterKeyNormalBgColor {
    return [self colorFromKey:@"imageAttr.letterKeyBackgroundColor"];
}

- (UIColor *)letterKeyHighlightBgColor {
    return [self colorFromKey:@"imageAttr.letterKeyHighlightBackgroundColor"];
}

- (UIColor *)funcKeyNormalBgColor {
    return [self colorFromKey:@"imageAttr.functionalletterKeyBackgroundColor"];
}

- (UIColor *)funcKeyHighlightBgColor {
    return [self colorFromKey:@"imageAttr.functionalletterKeyHighlightBackgroundColor"];
}

- (UIColor *)spaceKeyNormalBgColor {
    return [self colorFromKey:@"imageAttr.spaceKeyBackgroundColor"];
}

- (UIColor *)spaceKeyHighlightBgColor {
    return [self colorFromKey:@"imageAttr.spaceKeyHighlightBackgroundColor"];
}

- (UIColor *)preInputBgColor {
    return [self colorFromKey:@"imageAttr.preInputViewBackgroundColor"];
}

- (UIColor *)inputOptionBgColor {
    return [self colorFromKey:@"imageAttr.inputOptionViewBackgroundColor"];
}

- (UIColor *)inputOptionHighlightBgColor {
    return [self colorFromKey:@"imageAttr.inputOptionCellHighlightBackgroundColor"];
}

- (UIColor *)settingViewBgColor {
    UIColor *color = [self colorFromKey:@"imageAttr.settingViewBackgroundColor"];
    if (color != [UIColor clearColor]) {
        return [color colorWithAlphaComponent:0.85f];
    }else{
        return [UIColor clearColor];
    }
}

- (UIColor *)letterKeyTextColor {
    return [self colorFromKey:@"viewAttr.keyTextColor"];
}

- (UIColor *)letterKeyHighlightTextColor {
    return [self colorFromKey:@"viewAttr.keyHighlightTextColor"];
}

- (UIColor *)funcKeyTextColor {
    return [self colorFromKey:@"viewAttr.functionalTextColor"];
}

- (UIColor *)funcKeyHighlightTextColor {
    return [self colorFromKey:@"viewAttr.functionalHighlightTextColor"];
}

- (UIColor *)spaceKeyTextColor {
    return [self colorFromKey:@"viewAttr.spaceTextColor"];
}

- (UIColor *)spaceHighlightTextColor {
    return [self colorFromKey:@"viewAttr.spaceKeyHighlightTextColor"];
}

- (UIColor *)preInputTextColor {
    return [self colorFromKey:@"viewAttr.preInputTextColor"];
}

- (UIColor *)inputOptionTextColor {
    return [self colorFromKey:@"viewAttr.inputOptionCellTextColor"];
}

- (UIColor *)inputOptionHighlightTextColor {
    return [self colorFromKey:@"viewAttr.inputOptionCellHighlightTextColor"];
}

- (UIColor *)keyHintTextColor {
    return [self colorFromKey:@"viewAttr.keyHintLetterColor" defaultColor:[UIColor colorWithHexString:@"74f7fd"]];
}

- (UIColor *)tintColor {
    return [self colorFromKey:@"imageAttr.iconTintColor"];
}

- (UIColor *)settingCellTintColor {
    return [self colorFromKey:@"imageAttr.settingCellTintColor" defaultColor:self.tintColor ? self.tintColor : [UIColor whiteColor]];
}

- (UIColor *)dismissBtnTintColor {
    return [self colorFromKey:@"imageAttr.dismissButtonTintColor" defaultColor:[UIColor whiteColor]];
}

- (UIColor *)inputOptionShadowColor {
    return [self colorFromKey:@"viewAttr.inputOptionCellShadowColor" defaultColor:rgb(136, 138, 142)];
}

- (UIColor *)predictViewBgColor {
    return [self colorFromKey:@"imageAttr.predictViewBackgroundColor"];
}

- (UIColor *)keyboardViewBgColor {
    return [self colorFromKey:@"imageAttr.keyboardBackgroundColor"];
}

- (UIColor *)predictCellBgColor {
    return [self colorFromKey:@"imageAttr.predictCellBackgroundColor"];
}

- (UIColor *)predictCellTextColor {
    return [self colorFromKey:@"viewAttr.colorSuggest"];
}

- (UIColor *)predictCellHighlightTextColor {
    return [self colorFromKey:@"viewAttr.predictCellHighlightTextColor" defaultColor:[UIColor colorWithHexString:@"#F78AE0"]];
}

- (UIColor *)predictCellEmphasizeTextColor {
    return [self colorFromKey:@"viewAttr.colorAutoCotrrct" defaultColor:[UIColor whiteColor]];
}

- (UIColor *)predictCellEmphasizeHighlightTextColor {
    return [self colorFromKey:@"viewAttr.predictCellEmphasizeHighlightTextColor" defaultColor:[UIColor colorWithHexString:@"#F78AE0"]];
}

#pragma mark - Font


- (NSString *)keyTextFontName {
    if (!_keyTextFontName) {
        NSString * value = [self.currentTheme valueForKeyPath:@"viewAttr.keyTextFontName"];
        _keyTextFontName = [[value lastPathComponent] stringByDeletingPathExtension];
        if (!_keyTextFontName || _keyTextFontName.length == 0) {
            _keyTextFontName = [UIFont systemFontOfSize:11.0f].fontName;
        }else{
            if (![CMBizHelper isFontRegistered:_keyTextFontName]) {
//                [CMBizHelper registerFont:[self.themePath stringByAppendingPathComponent:value]];
                [CMBizHelper registerFont:[kCMGroupDataManager.ThemeFontPath.path  stringByAppendingPathComponent:value]];
                if (![CMBizHelper isFontRegistered:_keyTextFontName]){
                     _keyTextFontName = [UIFont systemFontOfSize:11.0f].fontName;
                }
            }
        }
    }
    return _keyTextFontName;
}

- (UIFont *)spaceKeyFont {
    if (!_spaceKeyFont) {
        _spaceKeyFont = [UIFont fontWithName:self.keyTextFontName size:18.0f];
    }
    return _spaceKeyFont;
}

- (UIFont *)funcKeyFont {
    if (!_funcKeyFont) {
        _funcKeyFont = [UIFont fontWithName:self.keyTextFontName size:15.0f];
    }
    return _funcKeyFont;
}

- (UIFont *)emojiKeyFont {
    if (!_emojiKeyFont) {
        _emojiKeyFont = [UIFont systemFontOfSize:28.0f];
    }
    return _emojiKeyFont;
}

- (UIFont *)letterKeyFont {
    if (!_letterKeyFont) {
        _letterKeyFont = [UIFont fontWithName:self.keyTextFontName size:22.0f];
    }
    return _letterKeyFont;
}

- (UIFont *)letterKeyHighlightFont {
    if (!_letterKeyHighlightFont) {
        _letterKeyHighlightFont = [UIFont fontWithName:self.keyTextFontName size:20.0f];
    }
    return _letterKeyHighlightFont;
}

- (UIFont *)nonLetterKeyFont {
    if (!_nonLetterKeyFont) {
        _nonLetterKeyFont = [UIFont systemFontOfSize:22.0f];
    }
    return _nonLetterKeyFont;
}

- (UIFont *)nonLetterKeyHighlightFont {
    if (!_nonLetterKeyHighlightFont) {
        _nonLetterKeyHighlightFont = [UIFont systemFontOfSize:20.0f];
    }
    return _nonLetterKeyHighlightFont;
}

- (UIFont *)inputOptionCellFont {
    if (!_inputOptionCellFont) {
        _inputOptionCellFont = [UIFont systemFontOfSize:22.0f];
    }
    return _inputOptionCellFont;
}

- (UIFont *)inputOptionCellHighlightFont {
    if (!_inputOptionCellHighlightFont) {
        _inputOptionCellHighlightFont = [UIFont systemFontOfSize:24.0f];
    }
    return _inputOptionCellHighlightFont;
}

- (UIFont *)preInputFont {
    if (!_preInputFont) {
        _preInputFont = [UIFont fontWithName:self.keyTextFontName size:28.0f];
    }
    return _preInputFont;
}

- (UIFont *)keyHintFont {
    if (!_keyHintFont) {
        _keyHintFont = [UIFont systemFontOfSize:9.0f];
    }
    return _keyHintFont;
}

- (UIFont *)predictCellTextFont {
    if (!_predictCellTextFont) {
        _predictCellTextFont = [UIFont systemFontOfSize:16.0f];
    }
    return _predictCellTextFont;
}

#pragma mark - Sound
- (NSString *)defaultSoundPath {
    if (!_defaultSoundPath) {
        NSString* soundName = @"dt_sound_default";
        NSDictionary* dic = [self.currentTheme valueForKeyPath:@"sound"];
        if (dic) {
            soundName = [dic stringValueForKey:@"default" defaultValue:@"dt_sound_default"];
        }
        NSString* soundFilePath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"wav"];
        if ([NSString stringIsEmpty:soundFilePath]) {
//            soundFilePath = [NSString stringWithFormat:@"%@/%@/%@", kCMGroupDataManager.ThemePath.path, [CMGroupDataManager shareInstance].currentThemeName, soundName];
            soundFilePath = [[CMGroupDataManager shareInstance].ThemeSoundPath.path stringByAppendingPathComponent:soundName];
//            soundFilePath = [self.themePath stringByAppendingPathComponent:soundName];
            BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:soundFilePath];
            if (exist) {
                _defaultSoundPath = soundFilePath;
            }
        }
        else {
            _defaultSoundPath = soundFilePath;
        }
    }
    return _defaultSoundPath;
}

- (NSString *)delSoundPath {
    if (!_delSoundPath) {
        NSString* soundName = @"dt_sound_delete";
        NSDictionary* dic = [self.currentTheme valueForKeyPath:@"sound"];
        if (dic) {
            soundName = [dic stringValueForKey:@"delete" defaultValue:@"dt_sound_delete"];
        }
        NSString* soundFilePath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"wav"];
        if ([NSString stringIsEmpty:soundFilePath]) {
//            soundFilePath = [self.themePath stringByAppendingPathComponent:soundName];
            soundFilePath = [[CMGroupDataManager shareInstance].ThemeSoundPath.path stringByAppendingPathComponent:soundName];

            BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:soundFilePath];
            if (exist) {
                _delSoundPath = soundFilePath;
            }
        }
        else {
            _delSoundPath = soundFilePath;
        }
    }
    return _delSoundPath;
}

- (NSString *)spaceSoundPath {
    if (!_spaceSoundPath) {
        NSString* soundName = @"dt_sound_space";
        NSDictionary* dic = [self.currentTheme valueForKeyPath:@"sound"];
        if (dic) {
            soundName = [dic stringValueForKey:@"space" defaultValue:@"dt_sound_space"];
        }
        NSString* soundFilePath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"wav"];
        if ([NSString stringIsEmpty:soundFilePath]) {
//            soundFilePath = [self.themePath stringByAppendingPathComponent:soundName];
            soundFilePath = [[CMGroupDataManager shareInstance].ThemeSoundPath.path stringByAppendingPathComponent:soundName];

            BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:soundFilePath];
            if (exist) {
                _spaceSoundPath = soundFilePath;
            }
        }
        else {
            _spaceSoundPath = soundFilePath;
        }
    }
    return _spaceSoundPath;
}

- (NSString *)returnSoundPath {
    if (!_returnSoundPath) {
        NSString* soundName = @"dt_sound_enter";
        NSDictionary* dic = [self.currentTheme valueForKeyPath:@"sound"];
        if (dic) {
            soundName = [dic stringValueForKey:@"returntype" defaultValue:@"dt_sound_enter"];
        }
        NSString* soundFilePath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"wav"];
        if ([NSString stringIsEmpty:soundFilePath]) {
//            soundFilePath = [self.themePath stringByAppendingPathComponent:soundName];
            soundFilePath = [[CMGroupDataManager shareInstance].ThemeSoundPath.path stringByAppendingPathComponent:soundName];

            BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:soundFilePath];
            if (exist) {
                _returnSoundPath = soundFilePath;
            }
        }
        else {
            _returnSoundPath = soundFilePath;
        }
    }
    return _returnSoundPath;
}

- (NSData *)defaultSoundData {
    if (!_defaultSoundData) {
        kLog(@"%@",_defaultSoundData);
        _defaultSoundData = [[NSData alloc] initWithContentsOfFile:self.defaultSoundPath];
    }
    return _defaultSoundData;
}

- (NSData *)delSoundData {
    if (!_delSoundData) {
        _delSoundData = [[NSData alloc] initWithContentsOfFile:self.delSoundPath];
    }
    return _delSoundData;
}

- (NSData *)spaceSoundData {
    if (!_spaceSoundData) {
        _spaceSoundData = [[NSData alloc] initWithContentsOfFile:self.spaceSoundPath];
    }
    return _spaceSoundData;
}

- (NSData *)returnSoundData {
    if (!_returnSoundData) {
        _returnSoundData = [[NSData alloc] initWithContentsOfFile:self.returnSoundPath];
    }
    return _returnSoundData;
}


#pragma mark - animate

//- (GLKTextureInfo *)ribbonTexture {
//    if (!_ribbonTexture) {
//        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"aurora_tex4" ofType:@"png"]; // 1
//        NSError *textureLoadingError = nil;
//        _ribbonTexture = [GLKTextureLoader textureWithContentsOfFile:filePath options:@{GLKTextureLoaderGenerateMipmaps : @YES, GLKTextureLoaderOriginBottomLeft : @(1)} error:&textureLoadingError];
//        if (textureLoadingError) {
//            _ribbonTexture = nil;
//        }
//        if (_ribbonTexture) {
//            glBindTexture(_ribbonTexture.target, _ribbonTexture.name);
//        }
//    }
//    return _ribbonTexture;
//}

- (EAGLContext *)context {
    if (!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (_context) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [EAGLContext setCurrentContext:_context];
            });
        }
    }
    return _context;
}

- (GLKTextureLoader *)asyncTextureLoader {
    if (!_asyncTextureLoader) {
        _asyncTextureLoader = [[GLKTextureLoader alloc] initWithSharegroup:self.context.sharegroup];
    }
    return _asyncTextureLoader;
}

- (NSString *)animateType{
    return [self.currentTheme valueForKeyPath:@"animate.type"];
}

- (BOOL)animateHidekey{
    return [[self.currentTheme valueForKeyPath:@"animate.hidekey"] boolValue];
}

@end
