//
//  CMThemeManager.h
//  PandaKeyboard
//
//  Created by 猎豹 on 2017/5/10.
//  Copyright © 2017年 猎豹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMHttpRequest.h"
#import <GLKit/GLKit.h>
#import <SceneKit/SceneKit.h>

typedef NS_ENUM(NSUInteger, CMPreviewAnimateType)  {
    CMPreviewAnimateTypeDefault = 0,
    CMPreviewAnimateTypeDropDown
};

@class CMThemeModel;

@interface CMThemeManager : NSObject

@property (nonatomic, readonly,strong)NSArray<CMThemeModel*> * DIYThemes;//diy主题数组
@property (nonatomic, readonly,strong)CMThemeModel * latestDIYTheme;//diy 主题最新的

@property (nonatomic, readonly, copy)NSString* currentThemeName;

// Image
@property (nonatomic,  strong)UIImage* letterKeyNormalBgImage;
@property (nonatomic,  strong)UIImage* letterKeyHighlightBgImage;
@property (nonatomic,  strong)UIImage* funcKeyNormalBgImage;
@property (nonatomic,  strong)UIImage* funcKeyHighlightBgImage;
@property (nonatomic,  strong)UIImage* spaceKeyNormalBgImage;
@property (nonatomic,  strong)UIImage* spaceKeyHighlightBgImage;
@property (nonatomic,  strong)UIImage* delKeyNormalBgImage;
@property (nonatomic,  strong)UIImage* delKeyHighlightBgImage;

@property (nonatomic,  strong)UIImage* returnKeyNormalImage;
@property (nonatomic,  strong)UIImage* goKeyNormalImage;
@property (nonatomic,  strong)UIImage* searchKeyNormalImage;
@property (nonatomic,  strong)UIImage* nextKeyNormalImage;
@property (nonatomic,  strong)UIImage* sendKeyNormalImage;
@property (nonatomic,  strong)UIImage* doneKeyNormalImage;
@property (nonatomic,  strong)UIImage* tabKeyNormalImage;
@property (nonatomic,  strong)UIImage* shiftKeyNormalImage;
@property (nonatomic,  strong)UIImage* shiftKeySelectImage;
@property (nonatomic,  strong)UIImage* shiftKeyLockImage;

@property (nonatomic,  strong)UIImage* preInputBgImage;
@property (nonatomic,  strong)UIImage* inputOptionBgImage;
@property (nonatomic,  strong)UIImage* inputOptionHighlightBgImage;


@property (nonatomic,  strong)UIImage* globalImage;

@property (nonatomic,  strong)UIImage* wholeBoardBgImage;
@property (nonatomic,  strong)UIImage* keyboardViewBgImage;
@property (nonatomic,  strong)UIImage* predictViewBgImage;

@property (nonatomic,  strong)UIImage* emojiImage;
@property (nonatomic,  strong)UIImage* settingImage;
@property (nonatomic,  strong)UIImage* themeImage;



@property (nonatomic, readonly, strong)UIImage* predictCellBgImage;


// Color
@property (nonatomic, readonly, strong)UIColor* wholeBoardBgColor;

@property (nonatomic, readonly, strong)UIColor* letterKeyNormalBgColor;
@property (nonatomic, readonly, strong)UIColor* letterKeyHighlightBgColor;
@property (nonatomic, readonly, strong)UIColor* funcKeyNormalBgColor;
@property (nonatomic, readonly, strong)UIColor* funcKeyHighlightBgColor;
@property (nonatomic, readonly, strong)UIColor* spaceKeyNormalBgColor;
@property (nonatomic, readonly, strong)UIColor* spaceKeyHighlightBgColor;

@property (nonatomic, readonly, strong)UIColor* preInputBgColor;
@property (nonatomic, readonly, strong)UIColor* inputOptionBgColor;
@property (nonatomic, readonly, strong)UIColor* inputOptionHighlightBgColor;

@property (nonatomic, readonly, strong)UIColor* settingViewBgColor;

@property (nonatomic, readonly, strong)UIColor* letterKeyTextColor;
@property (nonatomic, readonly, strong)UIColor* letterKeyHighlightTextColor;
@property (nonatomic, readonly, strong)UIColor* funcKeyTextColor;
@property (nonatomic, readonly, strong)UIColor* funcKeyHighlightTextColor;
@property (nonatomic, readonly, strong)UIColor* spaceKeyTextColor;
@property (nonatomic, readonly, strong)UIColor* spaceHighlightTextColor;


@property (nonatomic, readonly, strong)UIColor* preInputTextColor;
@property (nonatomic, readonly, strong)UIColor* inputOptionTextColor;
@property (nonatomic, readonly, strong)UIColor* inputOptionHighlightTextColor;
@property (nonatomic, readonly, strong)UIColor* keyHintTextColor;


@property (nonatomic, readonly, strong)UIColor* tintColor;

@property (nonatomic, readonly, strong)UIColor* settingCellTintColor;
@property (nonatomic, readonly, strong)UIColor* dismissBtnTintColor;


@property (nonatomic, readonly, strong)UIColor* inputOptionShadowColor;

@property (nonatomic, readonly, strong)UIColor* predictViewBgColor;
@property (nonatomic, readonly, strong)UIColor* keyboardViewBgColor;

@property (nonatomic, readonly, strong)UIColor* predictCellBgColor;

@property (nonatomic, readonly, strong)UIColor* predictCellEmphasizeTextColor;
@property (nonatomic, readonly, strong)UIColor* predictCellEmphasizeHighlightTextColor;

@property (nonatomic, readonly, strong)UIColor* predictCellTextColor;
@property (nonatomic, readonly, strong)UIColor* predictCellHighlightTextColor;


// Font
@property (nonatomic, readonly, strong)NSString* keyTextFontName;
@property (nonatomic, readonly, strong)UIFont* spaceKeyFont;
@property (nonatomic, readonly, strong)UIFont* funcKeyFont;
@property (nonatomic, readonly, strong)UIFont* emojiKeyFont;
@property (nonatomic, readonly, strong)UIFont* letterKeyFont;
@property (nonatomic, readonly, strong)UIFont* letterKeyHighlightFont;
@property (nonatomic, readonly, strong)UIFont* nonLetterKeyFont;
@property (nonatomic, readonly, strong)UIFont* nonLetterKeyHighlightFont;
@property (nonatomic, readonly, strong)UIFont* inputOptionCellFont;
@property (nonatomic, readonly, strong)UIFont* inputOptionCellHighlightFont;
@property (nonatomic, readonly, strong)UIFont* preInputFont;
@property (nonatomic, readonly, strong)UIFont* keyHintFont;
@property (nonatomic, readonly, strong)UIFont* predictCellTextFont;

// Sound
@property (nonatomic, readonly, strong)NSData* defaultSoundData;
@property (nonatomic, readonly, strong)NSData* delSoundData;
@property (nonatomic, readonly, strong)NSData* spaceSoundData;
@property (nonatomic, readonly, strong)NSData* returnSoundData;

// Animate
@property (nonatomic, readonly, copy)NSString* ribbonVertexShader;
@property (nonatomic, readonly, copy)NSString* ribbonFragmentShader;
@property (nonatomic, readonly, strong)GLKTextureInfo *ribbonTexture;
//@property (nonatomic, readonly, strong)SCNMaterial* ribbonMaterial;
@property (nonatomic, readonly, strong)EAGLContext *context;

@property (nonatomic, readonly, copy)NSString* animateType;
@property (nonatomic, readonly, assign)BOOL animateHidekey;

@property (nonatomic, readwrite, assign)CGFloat keyboardViewControllerWidth;

#ifndef HostApp
#else
- (void)cancelChangeDiyTheme; //取消正在编辑的主题

- (void)deleteThemeModel:(CMThemeModel*)model;//删除diy主题

- (BOOL)saveDiyThemeWithCoverImage:(UIImage*)coverImage;//保存diy主题

- (void)setImage:(UIImage*)image forKeyPath:(NSString *)keyPath;
- (void)setImagePath:(NSString*)imagePath forKeyPath:(NSString *)keyPath;
- (void)setColor:(NSString*)colorStr forKeyPath:(NSString *)keyPath;
//- (void)setFont:(NSString*)fontPath  forKeyPath:(NSString *)keyPath;
- (void)setStandardDirSound:(NSString *)soundDirPath; //设置音效
- (void)setStandardDirFont:(NSString *)fontDirPath; //更新字体
//set image
- (void)letterKeyNormalBgImagePath:(NSString*)imagePath ;

- (void)letterKeyHighlightBgImagePath:(NSString*)imagePath ;

- (void)funcKeyNormalBgImagePath:(NSString*)imagePath;

- (void)funcKeyHighlightBgImagePath:(NSString*)imagePath;

- (void)spaceKeyNormalBgImagePath:(NSString*)imagePath ;

- (void)spaceKeyHighlightBgImagePath:(NSString*)imagePath;

- (void)delKeyNormalBgImagePath:(NSString*)imagePath;

- (void)delKeyHighlightBgImagePath:(NSString*)imagePath;

- (void)preInputBgImagePath:(NSString*)imagePath;

- (void)inputOptionBgImagePath:(NSString*)imagePath;

- (void)inputOptionHighlightBgImagePath:(NSString*)imagePath;


- (void)returnKeyNormalImagePath:(NSString*)imagePath;

- (void)goKeyNormalImagePath:(NSString*)imagePath;

- (void)searchKeyNormalImagePath:(NSString*)imagePath;

- (void)nextKeyNormalImagePath:(NSString*)imagePath;

- (void)sendKeyNormalImagePath:(NSString*)imagePath;

- (void)doneKeyNormalImagePath:(NSString*)imagePath;

- (void)tabKeyNormalImagePath:(NSString*)imagePath;

- (void)shiftKeyNormalImagePath:(NSString*)imagePath;

- (void)shiftKeySelectImagePath:(NSString*)imagePath ;

- (void)shiftKeyLockImagePath:(NSString*)imagePath;

- (void)globalImagePath:(NSString*)imagePath;

- (void)wholeBoardBgImagePath:(NSString*)imagePath;

- (void)keyboardViewBgImagePath:(NSString*)imagePath;

- (void)predictViewBgImagePath:(NSString*)imagePath;

- (void)emojiImagePath:(NSString*)imagePath;

- (void)settingImagePath:(NSString*)imagePath;

- (void)themeImagePath:(NSString*)imagePath;

- (void)predictCellBgImagePath:(NSString*)imagePath ;

// get image path
- (NSString *)letterKeyNormalBgImagePath;
- (NSString *)letterKeyHighlightBgImagePath;
- (NSString *)funcKeyNormalBgImagePath;
- (NSString *)funcKeyHighlightBgImagePath;
- (NSString *)spaceKeyNormalBgImagePath;
- (NSString *)spaceKeyHighlightBgImagePath;
- (NSString *)preInputBgImagePath;
- (NSString *)inputOptionBgImagePath;
- (NSString *)inputOptionHighlightBgImagePath;

//set color

- (void)wholeBoardBgColorHexString:(NSString*)hexStr ;

- (void)letterKeyNormalBgColorHexString:(NSString*)hexStr;

- (void)letterKeyHighlightBgColorHexString:(NSString*)hexStr;

- (void)funcKeyNormalBgColorHexString:(NSString*)hexStr;

- (void)funcKeyHighlightBgColorHexString:(NSString*)hexStr;

- (void)spaceKeyNormalBgColorHexString:(NSString*)hexStr;

- (void)spaceKeyHighlightBgColorHexString:(NSString*)hexStr;

- (void)preInputBgColorHexString:(NSString*)hexStr;

- (void)inputOptionBgColorHexString:(NSString*)hexStr;

- (void)inputOptionHighlightBgColorHexString:(NSString*)hexStr;

- (void)settingViewBgColorHexString:(NSString*)hexStr;

- (void)letterKeyTextColorHexString:(NSString*)hexStr;

- (void)letterKeyHighlightTextColorHexString:(NSString*)hexStr;

- (void)funcKeyTextColorHexString:(NSString*)hexStr;

- (void)funcKeyHighlightTextColorHexString:(NSString*)hexStr;

- (void)spaceKeyTextColorHexString:(NSString*)hexStr ;
- (void)spaceHighlightTextColorHexString:(NSString*)hexStr;

- (void)preInputTextColorHexString:(NSString*)hexStr;

- (void)inputOptionTextColorHexString:(NSString*)hexStr;

- (void)inputOptionHighlightTextColorHexString:(NSString*)hexStr ;

- (void)keyHintTextColorHexString:(NSString*)hexStr;

- (void)tintColorHexString:(NSString*)hexStr ;

- (void)settingCellTintColorHexString:(NSString*)hexStr;

- (void)dismissBtnTintColorHexString:(NSString*)hexStr;

- (void)inputOptionShadowColorHexString:(NSString*)hexStr;

- (void)predictViewBgColorHexString:(NSString*)hexStr;

- (void)keyboardViewBgColorHexString:(NSString*)hexStr ;

- (void)predictCellBgColorHexString:(NSString*)hexStr;

- (void)predictCellTextColorHexString:(NSString*)hexStr;

- (void)predictCellHighlightTextColorHexString:(NSString*)hexStr;

- (void)predictCellEmphasizeTextColorHexString:(NSString*)hexStr;

- (void)predictCellEmphasizeHighlightTextColorHexString:(NSString*)hexStr;


#endif


- (void)switchTo:(NSString*)themeName;

- (NSURLSessionDownloadTask *)downloadTheme:(CMThemeModel *)model
        progressBlock:(CMProgressBlock)progressBlock
        completeBlock:(CMDownloadCompleteBlock)completeBlock;

//- (NSString *)cachedThemeVersion:(CMThemeModel *)themeModel;
//
- (NSString *)cachedThemeName:(CMThemeModel *)themeModel;
//
//- (NSString *)cachedThemeLocalPath:(CMThemeModel *)themeModel;

- (CMThemeModel *)cachedThemeModelById:(NSString *)themeId;

- (void)resetThemeCache;

- (void)cacheRibbonAnimate;

- (void)resetRibbonAnimateCache;

@end
