//
//  KDS_NetworkAgent.h
//  YHNetWorkDemo
//
//  Created by yehot on 15/11/17.
//  Copyright © 2015年 yehot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDS_BaseRequest.h"

/**
 *  网络请求管理类（此类管理网络请求的发起，不直接调用此类）
 *  内部封装AFN
 */
@interface KDS_NetworkAgent : NSObject

+ (KDS_NetworkAgent *)sharedInstance;   ///< NetworkAgent单例

/**
 *  添加一个网络请求对象(并发起请求)
 */
- (void)addRequest:(KDS_BaseRequest *)request;

/**
 *  取消指定的网络请求
 */
- (void)cancelRequest:(KDS_BaseRequest *)request;

/**
 *  取消当前所有的网络请求
 */
- (void)cancelAllRequest;

@end
