//
//  KDS_OneRequest.m
//  YHNetWorkDemo
//
//  Created by yehot on 15/11/20.
//  Copyright © 2015年 yehot. All rights reserved.
//

#import "KDS_OneRequest.h"

@implementation KDS_OneRequest

#define URL_GET @"http://bea.wufazhuce.com/OneForWeb/one/getHp_N"

- (NSString *)requestURL {
    return URL_GET;
}

- (id)requestArgument {
    return @{
             @"strDate" : @"2015-11-21",
             @"strRow"  : @"1"
             };
}

//  设置缓存有效期
- (NSInteger)cacheTimeInSeconds {
    return 10;
}

- (AFDownloadProgressBlock)resumableDownloadProgressBlock {
    return self.downloadProgressBlock;
}

@end
