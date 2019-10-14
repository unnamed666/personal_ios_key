//
//  EncryptUtil.m
//  InfoC
//
//  Created by wei_wei on 16/4/7.
//  Copyright © 2016年 CMCM. All rights reserved.
//

#import "EncryptUtil.h"
#import <CommonCrypto/CommonCryptor.h>
#import "NSString+Base64.h"
#import "CommonKit.h"
@implementation NSString (Encrypt)

- (NSString *)AES128EncryptWithKey:(NSData *)key andIV:(NSData *)iv
{
    NSData *dataIn  = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *dataOut = [dataIn AES128EncryptWithKey:key andIV:iv];
    
    NSString *objcEncrypted = [dataOut base64EncodedStringWithOptions:0];
    DLOG(@"objcEncrypted: %@", objcEncrypted);
    return objcEncrypted;
}

@end

@implementation NSData (Encrypt)

- (NSData *)AES128EncryptWithKey:(NSData *)key andIV:(NSData *)iv
{
    CCCryptorStatus ccStatus   = kCCSuccess;
    size_t          cryptBytes = 0;
    NSMutableData  *dataOut    = [NSMutableData dataWithLength:self.length + kCCBlockSizeAES128];
    
    ccStatus = CCCrypt( kCCEncrypt,
                       kCCAlgorithmAES128,
                       kCCOptionPKCS7Padding,
                       key.bytes, kCCKeySizeAES128,
                       iv.bytes,
                       self.bytes, self.length,
                       dataOut.mutableBytes, dataOut.length,
                       &cryptBytes);
    
    if (ccStatus != kCCSuccess) {
        DLOG(@"CCCrypt status: %d", ccStatus);
    }
    dataOut.length = cryptBytes;
    
    return dataOut;
}

@end
