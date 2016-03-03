//
//  KDS_NetworkConfig.m
//  YHNetWorkDemo
//
//  Created by yehot on 15/11/17.
//  Copyright © 2015年 yehot. All rights reserved.
//

#import "KDS_NetworkConfig.h"
#import "KDS_RequestHelper.h"

@implementation KDS_NetworkConfig

+ (KDS_NetworkConfig *)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _golablUrlComponents = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setGlobalBaseUrl:(NSString *)aUrlStr {
    
    //  仅能设置一次，多次设置无效
    //  在 app luanch 时设置，防止被修改（待考虑）
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _golbalBaseURL = [aUrlStr copy];
    });
}

#pragma mark - getter

//- (NSMutableDictionary *)baseUrlComponents {
//    if (!_baseUrlComponents) {
//        _baseUrlComponents = [NSMutableDictionary dictionary];
//    }
//    return _baseUrlComponents;
//}

- (BOOL)hasGolbalDomainUrl {
    return (_golbalBaseURL.length > 0);
}

- (BOOL)hasBaseUrlComponent {
    return (_golablUrlComponents.count > 0);
}


- (void)addGlobalUrlComponentWithkey:(NSString *)key andValue:(NSString *)value {
    NSAssert(key && value, @"key or value can't set nil!");
    if (_golablUrlComponents != nil) {
        if (key != nil && value != nil) {
            [_golablUrlComponents setValue:value forKey:key];
        }
    }
}

@end
