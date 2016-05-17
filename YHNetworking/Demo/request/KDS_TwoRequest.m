//
//  KDS_TwoRequest.m
//  YHNetWorkDemo
//
//  Created by yehot on 15/11/23.
//  Copyright © 2015年 yehot. All rights reserved.
//

#import "KDS_TwoRequest.h"

@implementation KDS_TwoRequest

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

@end
