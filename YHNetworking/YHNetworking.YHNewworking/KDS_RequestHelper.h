//
//  KDS_RequestHelper.h
//  YHNetWorkDemo
//
//  Created by yehot on 15/11/17.
//  Copyright © 2015年 yehot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDS_BaseRequest.h"

//自定义log
FOUNDATION_EXPORT void KDSNetLog(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);

/**
 *  网络库的公用方法工具类
 */
@interface KDS_RequestHelper : NSObject

/**
 *  将 dict 拼接到 url 后，以 ?key1=value1&key2=value2... 形式追加 （自动判断有无「？」）
 *
 *  @param component 全局统一追加的请求参数
 *  @param originUrl 初始url
 *
 *  @return 拼接后的url
 */
+ (NSString *)appendComponentDict:(NSDictionary *)component toOriginUrl:(NSString *)originUrl;


///字符串MD5加密
+ (NSString *)md5StringFromString:(NSString *)string;

///校验JSON格式
+ (BOOL)checkJSON:(id)json withValidator:(id)validator;

///  app 版本号
+ (NSString *)appVersionString;

@end

//  TODO:考虑是否不用这种写法
#pragma mark - KDS_BaseRequest Categoty
/**
 *  KDS_BaseRequest的私有Categoty（不对外直接暴露此Categoty）
 */
@interface KDS_BaseRequest (RequestAccessory)

//  TODO: 方法根据功能重新命名
/**
 *  hook 方法，在KDS_BaseRequest请求开始前（调用star）会被调用
 *  @remark 内部调用 requestWillStart:
 */
- (void)kds_toggleAccessoryWillStartCallBack;
/**
 *  hook 方法，在KDS_BaseRequest结束前（收到请求response）会被调用
 *  @remark 内部调用 requestWillStop:
 */
- (void)kds_toggleAccessoryWillStopCallBack;
/**
 *  hook 方法，在KDS_BaseRequest请求结束后(请求response call back 后)会被调用
 *  @remark 内部调用 requestDidStop:
 */
- (void)kds_toggleAccessoryDidStopCallBack;

@end
