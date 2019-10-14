//
//  CMCommUtil.m
//  Panda Keyboard
//
//  Created by yanzhao on 2017/3/13.
//  Copyright © 2017年 Cheetah Mobile. All rights reserved.
//

#import "CMCommUtil.h"

#import "CMKeyboardManager.h"
#import "Character.h"

@implementation CMCommUtil


+ (UIImage *) makeNinePatchImage:(UIImage *)image
{
    //Clear the black 9patch regions
    CGRect imageRect = CGRectMake(0.0, 0.0, image.size.width-2, image.size.height-2);
    CGSize size = image.size;
    size.height = size.height-4;
    size.width = size.width-4;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [image drawInRect:imageRect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, CGRectMake(0, 0, image.size.width, 2));
    CGContextClearRect(context, CGRectMake(0, 0, 2, image.size.height));
    //    CGContextClearRect(context, CGRectMake(image.size.width-1, 0, image.size.width, 1));
    //    CGContextClearRect(context, CGRectMake(0, image.size.height-1, 1, image.size.height));
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIEdgeInsets insets;
    
    //hard coded for now, could easily read the black regions if necessary
    insets.left = insets.right = image.size.width / 2 - 1;
    insets.top = insets.bottom = image.size.height / 2 - 1;
    
    UIImage *nineImage = [image resizableImageWithCapInsets:insets
                                               resizingMode:UIImageResizingModeStretch];
    
    return nineImage;
    
}

+ (NSMutableSet *)tokenizationSetByNSString:(NSString*)str options:(NSStringEnumerationOptions)opts{
    NSMutableSet *splitArray = [NSMutableSet set];
    NSRange range = NSMakeRange(0, [str length]);
    [str enumerateSubstringsInRange:range options:opts usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        unichar c;
        [substring getCharacters:&c];
        [splitArray addObject:@(c)];
    }];
    
    return splitArray;
}

+ (NSMutableArray *)tokenizationStringByNSString:(NSString*)str options:(NSStringEnumerationOptions)opts{
    NSMutableArray *splitArray = [NSMutableArray array];
    NSRange range = NSMakeRange(0, [str length]);
    [str enumerateSubstringsInRange:range options:opts usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        [splitArray addObject:substring];
    }];
    
    return splitArray;
}

+ (NSString*)keyboardLanguageTypeToLang:(int)languageType{
    switch (languageType) {
        case CMKeyboardLanguageTypeSpanish:
            return @"es";
            break;
        case CMKeyboardLanguageTypeEnglishUnitedState:
            return @"en";
            break;
        case CMKeyboardLanguageTypeIndonesian:
            return @"id";
            break;
        case CMKeyboardLanguageTypeAzerbaijani:
            return @"az";
            break;
        case CMKeyboardLanguageTypeCatalan:
            return @"ca";
            break;
        case CMKeyboardLanguageTypeCzech:
            return @"cs";
            break;
        case CMKeyboardLanguageTypeDanish:
            return @"da";
            break;
        case CMKeyboardLanguageTypeGerman:
            return @"de";
            break;
        case CMKeyboardLanguageTypeEstonian:
            return @"et";
            break;
        case CMKeyboardLanguageTypeFinnish:
            return @"fi";
            break;
        case CMKeyboardLanguageTypeFrench:
            return @"fr";
            break;
        case CMKeyboardLanguageTypeCroatian:
            return @"hr";
            break;
        case CMKeyboardLanguageTypeHungarian:
            return @"hu";
            break;
        case CMKeyboardLanguageTypePortuguese:
            return @"pt";
            break;
        case CMKeyboardLanguageTypeMalay:
            return @"ms";
            break;
        case CMKeyboardLanguageTypeFilipino:
            return @"tl";
            break;
        case CMKeyboardLanguageTypeTurkish:
            return @"tr";
            break;
        case CMKeyboardLanguageTypeItalian:
            return @"it";
            break;
        case CMKeyboardLanguageTypePolish:
            return @"pl";
            break;
        case CMKeyboardLanguageTypeRomanian:
            return @"ro";
            break;
        case CMKeyboardLanguageTypeDutch:
            return @"nl";
            break;
        case CMKeyboardLanguageTypeSlovak:
            return @"sk";
            break;
        case CMKeyboardLanguageTypeLatvian:
            return @"lv";
            break;
        case CMKeyboardLanguageTypeNorwegianBokmal:
            return @"nb";
            break;
        case CMKeyboardLanguageTypeSwedish:
            return @"sv";
            break;
        case CMKeyboardLanguageTypeRussian:
            return @"ru";
            break;
        case CMKeyboardLanguageTypeBelarusian:
            return @"be";
            break;
        case CMKeyboardLanguageTypeBulgarian:
            return @"bg";
            break;
        case CMKeyboardLanguageTypeMacedonian:
            return @"mk";
            break;
        case CMKeyboardLanguageTypeSerbian:
            return @"sr";
            break;
        case CMKeyboardLanguageTypeUkrainian:
            return @"uk";
            break;
        case CMKeyboardLanguageTypeArabic:
            return @"ar";
            break;
        default:
            break;
    }
    return nil;
}

/*
+ (NSString*)keyboardLanguageTypeToCountry:(int)languageType{
    switch (languageType) {
        case CMKeyboardLanguageTypeSpanish:
            return nil;
            break;
        case CMKeyboardLanguageTypeEnglishUnitedState:
            return @"us";
            break;
            
        default:
            break;
    }
    return nil;
}
 */

+ (NSString*)keyboardLanguageTypeToLocaleString:(int)languageType{
    switch (languageType) {
        case CMKeyboardLanguageTypeSpanish:
            return @"es";
            break;
        case CMKeyboardLanguageTypeEnglishUnitedState:
            return @"en_us";
            break;
        case CMKeyboardLanguageTypeIndonesian:
            return @"id";
            break;
        case CMKeyboardLanguageTypeAzerbaijani:
            return @"az";
            break;
        case CMKeyboardLanguageTypeCatalan:
            return @"ca";
            break;
        case CMKeyboardLanguageTypeCzech:
            return @"cs";
            break;
        case CMKeyboardLanguageTypeDanish:
            return @"da";
            break;
        case CMKeyboardLanguageTypeGerman:
            return @"de";
            break;
        case CMKeyboardLanguageTypeEstonian:
            return @"et";
            break;
        case CMKeyboardLanguageTypeFinnish:
            return @"fi";
            break;
        case CMKeyboardLanguageTypeFrench:
            return @"fr";
            break;
        case CMKeyboardLanguageTypeCroatian:
            return @"hr";
            break;
        case CMKeyboardLanguageTypeHungarian:
            return @"hu";
            break;
        case CMKeyboardLanguageTypePortuguese:
            return @"pt";
            break;
        case CMKeyboardLanguageTypeMalay:
            return @"ms";
            break;
        case CMKeyboardLanguageTypeFilipino:
            return @"tl";
            break;
        case CMKeyboardLanguageTypeTurkish:
            return @"tr";
            break;
        case CMKeyboardLanguageTypeItalian:
            return @"it";
            break;
        case CMKeyboardLanguageTypePolish:
            return @"pl";
            break;
        case CMKeyboardLanguageTypeRomanian:
            return @"ro";
            break;
        case CMKeyboardLanguageTypeDutch:
            return @"nl";
            break;
        case CMKeyboardLanguageTypeSlovak:
            return @"sk";
            break;
        case CMKeyboardLanguageTypeLatvian:
            return @"lv";
            break;
        case CMKeyboardLanguageTypeNorwegianBokmal:
            return @"nb";
            break;
        case CMKeyboardLanguageTypeSwedish:
            return @"sv";
            break;
        case CMKeyboardLanguageTypeRussian:
            return @"ru";
            break;
        case CMKeyboardLanguageTypeBelarusian:
            return @"be";
            break;
        case CMKeyboardLanguageTypeUkrainian:
            return @"uk";
            break;
        case CMKeyboardLanguageTypeBulgarian:
            return @"bg";
            break;
        case CMKeyboardLanguageTypeSerbian:
            return @"sr";
            break;
        case CMKeyboardLanguageTypeMacedonian:
            return @"mk";
            break;
        case CMKeyboardLanguageTypeArabic:
            return @"ar";
            break;
        default:
            break;
    }
    return nil;
}

+ (NSString *)keyboardLanguageTypeToLanguageString:(int)languageType
{
    NSString *languageStr = nil;
    switch (languageType) {
        case CMKeyboardLanguageTypeEnglishUnitedState:
            languageStr = @"English";
            break;
        case CMKeyboardLanguageTypeSpanish:
            languageStr = @"Spanish";
            break;
        case CMKeyboardLanguageTypeIndonesian:
            languageStr = @"Indonesian";
            break;
        case CMKeyboardLanguageTypeAzerbaijani:
            languageStr = @"Azerbaijani";
            break;
        case CMKeyboardLanguageTypeCatalan:
            languageStr = @"Catalan";
            break;
        case CMKeyboardLanguageTypeCzech:
            languageStr = @"Czech";
            break;
        case CMKeyboardLanguageTypeDanish:
            languageStr = @"Danish";
            break;
        case CMKeyboardLanguageTypeGerman:
            languageStr = @"German";
            break;
        case CMKeyboardLanguageTypeEstonian:
            languageStr = @"Estonian";
            break;
        case CMKeyboardLanguageTypeFinnish:
            languageStr = @"Finnish";
            break;
        case CMKeyboardLanguageTypeFrench:
            languageStr = @"French";
            break;
        case CMKeyboardLanguageTypeCroatian:
            languageStr = @"Croatian";
            break;
        case CMKeyboardLanguageTypeHungarian:
            languageStr = @"Hungarian";
            break;
        case CMKeyboardLanguageTypePortuguese:
            languageStr = @"Portuguese";
            break;
        case CMKeyboardLanguageTypeMalay:
            languageStr = @"Malay";
            break;
        case CMKeyboardLanguageTypeFilipino:
            languageStr = @"Filipino";
            break;
        case CMKeyboardLanguageTypeTurkish:
            languageStr = @"Turkish";
            break;
        case CMKeyboardLanguageTypeItalian:
            languageStr = @"Italian";
            break;
        case CMKeyboardLanguageTypePolish:
            languageStr = @"Polish";
            break;
        case CMKeyboardLanguageTypeRomanian:
            languageStr = @"Romanian";
            break;
        case CMKeyboardLanguageTypeDutch:
            languageStr = @"Dutch";
            break;
        case CMKeyboardLanguageTypeSlovak:
            languageStr = @"Slovak";
            break;
        case CMKeyboardLanguageTypeLatvian:
            languageStr = @"Latvian";
            break;
        case CMKeyboardLanguageTypeNorwegianBokmal:
            languageStr = @"Norwegian Bokmal";
            break;
        case CMKeyboardLanguageTypeSwedish:
            languageStr = @"Swedish";
            break;
        case CMKeyboardLanguageTypeRussian:
            languageStr = @"Russian";
            break;
        case CMKeyboardLanguageTypeBelarusian:
            languageStr = @"Belarusian";
            break;
        case CMKeyboardLanguageTypeUkrainian:
            languageStr = @"Ukrainian";
            break;
        case CMKeyboardLanguageTypeSerbian:
            languageStr = @"Serbian";
            break;
        case CMKeyboardLanguageTypeBulgarian:
            languageStr = @"Bulgarian";
            break;
        case CMKeyboardLanguageTypeMacedonian:
            languageStr = @"Macedonian";
            break;
        case CMKeyboardLanguageTypeArabic:
            languageStr = @"Arabic";
            break;
        default:
            break;
    }
    return languageStr;
}

+ (NSString *)keyboardLanguageTypeToLocaleLanguageStr:(int)languageType
{
    NSString *languageStr = nil;
    switch (languageType) {
        case CMKeyboardLanguageTypeEnglishUnitedState:
            languageStr = @"English";
            break;
        case CMKeyboardLanguageTypeSpanish:
            languageStr = @"Español";
            break;
        case CMKeyboardLanguageTypeIndonesian:
            languageStr = @"Indonesia";
            break;
        case CMKeyboardLanguageTypeAzerbaijani:
            languageStr = @"Azərbaycan";
            break;
        case CMKeyboardLanguageTypeCatalan:
            languageStr = @"Català";
            break;
        case CMKeyboardLanguageTypeCzech:
            languageStr = @"Čeština";
            break;
        case CMKeyboardLanguageTypeDanish:
            languageStr = @"Dansk";
            break;
        case CMKeyboardLanguageTypeGerman:
            languageStr = @"Deutsch";
            break;
        case CMKeyboardLanguageTypeEstonian:
            languageStr = @"Eesti";
            break;
        case CMKeyboardLanguageTypeFinnish:
            languageStr = @"Suomi";
            break;
        case CMKeyboardLanguageTypeFrench:
            languageStr = @"Français";
            break;
        case CMKeyboardLanguageTypeCroatian:
            languageStr = @"Hrvatski";
            break;
        case CMKeyboardLanguageTypeHungarian:
            languageStr = @"Magyar";
            break;
        case CMKeyboardLanguageTypePortuguese:
            languageStr = @"Português";
            break;
        case CMKeyboardLanguageTypeMalay:
            languageStr = @"Melayu";
            break;
        case CMKeyboardLanguageTypeFilipino:
            languageStr = @"Tagalog";
            break;
        case CMKeyboardLanguageTypeTurkish:
            languageStr = @"Türkçe";
            break;
        case CMKeyboardLanguageTypeItalian:
            languageStr = @"Italiano";
            break;
        case CMKeyboardLanguageTypePolish:
            languageStr = @"Polski";
            break;
        case CMKeyboardLanguageTypeRomanian:
            languageStr = @"Română";
            break;
        case CMKeyboardLanguageTypeDutch:
            languageStr = @"Nederlands";
            break;
        case CMKeyboardLanguageTypeSlovak:
            languageStr = @"Slovenčina";
            break;
        case CMKeyboardLanguageTypeLatvian:
            languageStr = @"Latviešu";
            break;
        case CMKeyboardLanguageTypeNorwegianBokmal:
            languageStr = @"Norsk bokmål";
            break;
        case CMKeyboardLanguageTypeSwedish:
            languageStr = @"Svenska";
            break;
        case CMKeyboardLanguageTypeRussian:
            languageStr = @"русский";
            break;
        case CMKeyboardLanguageTypeBelarusian:
            languageStr = @"Беларуская";
            break;
        case CMKeyboardLanguageTypeUkrainian:
            languageStr = @"Українська";
            break;
        case CMKeyboardLanguageTypeBulgarian:
            languageStr = @"български";
            break;
        case CMKeyboardLanguageTypeSerbian:
            languageStr = @"Српски";
            break;
        case CMKeyboardLanguageTypeMacedonian:
            languageStr = @"Македонски";
            break;
        case CMKeyboardLanguageTypeArabic:
            languageStr = @"العربية";
            break;
        default:
            break;
    }
    return languageStr;
}

+ (BOOL)isLetterPartOfScriptWithcodePoint:(int)codePoint languageType:(int)languageType{
    return codePoint <= 0x2AF && [Character isLetter:codePoint];
//    return YES;
}

+ (long)evaluate:(float)fraction startColor:(CGColorRef)startColor endColor:(CGColorRef)endColor
{
    const CGFloat *startColorCom = CGColorGetComponents(startColor);
    long startR = (long)(startColorCom[0] * 255.0f);
    long startG = (long)(startColorCom[1] * 255.0f);
    long startB = (long)(startColorCom[2] * 255.0f);

    const CGFloat *endColorCom = CGColorGetComponents(endColor);
    long endR = (long)(endColorCom[0] * 255.0f);
    long endG = (long)(endColorCom[1] * 255.0f);
    long endB = (long)(endColorCom[2] * 255.0f);
    
    return (long) ((startR + (long) (fraction * (endR - startR))) << 16)
    | (long) ((startG + (long) (fraction * (endG - startG))) << 8)
    | (long) ((startB + (long) (fraction * (endB - startB))));
}

@end
