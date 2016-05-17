//
//  KDS_OneRequest.h
//  YHNetWorkDemo
//
//  Created by yehot on 15/11/20.
//  Copyright © 2015年 yehot. All rights reserved.
//

#import "KDS_BaseCacheRequest.h"

//  带缓存的请求
@interface KDS_OneRequest : KDS_BaseCacheRequest

@property (copy, nonatomic) AFDownloadProgressBlock downloadProgressBlock;

@end
