//
//  KDS_RequestHelper.m
//  YHNetWorkDemo
//
//  Created by yehot on 15/11/17.
//  Copyright © 2015年 yehot. All rights reserved.
//

#import "KDS_RequestHelper.h"
#import <CommonCrypto/CommonDigest.h>

void KDSNetLog(NSString *format, ...) {
#ifdef DEBUG
    va_list args;
    va_start(args, format);
    NSLogv(format, args);
    va_end(args);
#endif
}

@implementation KDS_RequestHelper

+ (NSString *)appendComponentDict:(NSDictionary *)component toOriginUrl:(NSString *)originUrl {
    
    NSString *finalStr = originUrl;
    NSString *paramerStr = [self stringConvertFromParameterDictionary:component];
    if (paramerStr.length > 0) {
        if ([originUrl rangeOfString:@"?"].location != NSNotFound) {// url 里已有「？」，直接追加到后边
            finalStr = [finalStr stringByAppendingString:paramerStr];
        } else {
            finalStr = [finalStr stringByAppendingFormat:@"?%@", [paramerStr substringFromIndex:1]];
        }
        return finalStr;
    } else {
        return originUrl;
    }
}

/**
 *  将 key value 拼接成 &key=value 形式字符串（随后拼接入url作为参数）
 */
+ (NSString *)stringConvertFromParameterDictionary:(NSDictionary *)paramDict {
    NSMutableString *paramStr = [[NSMutableString alloc] initWithString:@""];
    if (paramDict.count > 0) {
        for (NSString * key in paramDict.allKeys) {
            NSString *value = paramDict[key];
            value = [NSString stringWithFormat:@"%@", value];
            value = [self encodeUrlSting:value];
            [paramStr appendFormat:@"&%@=%@", key, value];
        }
    }
    return paramStr;
}

/**
 *  处理参数中的特殊字符
 */
+ (NSString *)encodeUrlSting:(NSString *)aStr {
    //different library use slightly different escaped and unescaped set.
    //below is copied from AFNetworking but still escaped [] as AF leave them for Rails array parameter which we don't use.
    //https://github.com/AFNetworking/AFNetworking/pull/555
    NSString *resultStr = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)aStr, CFSTR("."), CFSTR(":/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8);
    return resultStr;
}

+ (NSString *)md5StringFromString:(NSString *)string {
    
    if (string == nil || string.length == 0) {
        return nil;
    }
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++) {
        [outputString appendFormat:@"%02x", outputBuffer[count]];
    }
    return outputString;
}

+ (BOOL)checkJSON:(id)json withValidator:(id)validatorJson {
    if ([json isKindOfClass:[NSDictionary class]] && [validatorJson isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = json;
        NSDictionary *validatorDict = validatorJson;
        BOOL result = YES;
        NSEnumerator *enumer = [validatorDict keyEnumerator];
        NSString *key;
        while ((key = [enumer nextObject]) != nil) {
            id value = dict[key];
            id format = validatorDict[key];
            if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]) {
                result = [self checkJSON:value withValidator:format];
                if (!result) {
                    break;
                }
            } else {
                if (![value isKindOfClass:format] && ![value isKindOfClass:[NSNull class]]) {
                    result = NO;
                    break;
                }
            }
        }
        
//        [validatorDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
//            
//            
//        }];
        
        return result;
    } else if ([json isKindOfClass:[NSArray class]] && [validatorJson isKindOfClass:[NSArray class]]) {
        NSArray *array = json;
        NSDictionary *validator = validatorJson[0];
        for (id item in array) {
            BOOL result = [self checkJSON:item withValidator:validator];
            if (!result) {
                return NO;
            }
        }
        return YES;
    } else if ([json isKindOfClass:validatorJson]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)appVersionString {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

@end

@implementation KDS_BaseRequest (RequestAccessory)

- (void)kds_toggleAccessoryWillStartCallBack {
    if ([self.accessoryDelegate respondsToSelector:@selector(requestWillStart:)]) {
        [self.accessoryDelegate requestWillStart:self];
    }
}

- (void)kds_toggleAccessoryWillStopCallBack {
    if ([self.accessoryDelegate respondsToSelector:@selector(requestWillStop:)]) {
        [self.accessoryDelegate requestWillStop:self];
    }
}

- (void)kds_toggleAccessoryDidStopCallBack {
    if ([self.accessoryDelegate respondsToSelector:@selector(requestDidStop:)]) {
        [self.accessoryDelegate requestDidStop:self];
    }
}


@end

