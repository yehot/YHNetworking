//
//  KDS_BaseCacheRequest.h
//  YHNetWorkDemo
//
//  Created by yehot on 15/11/20.
//  Copyright © 2015年 yehot. All rights reserved.
//

#import "KDS_BaseRequest.h"

/**
 *  带缓存功能的请求对象 （需要缓存功能的请求 要继承此类）
 */
@interface KDS_BaseCacheRequest : KDS_BaseRequest

///忽略缓存 （默认启用缓存）
@property (assign, nonatomic) BOOL ignoreCache;

///当前缓存的对象
- (id)cachedObject;

///是否当前的数据是从缓存获得
- (BOOL)isDataFromCache;

///缓存是否过期
- (BOOL)isCacheVersionExpired;

///强制更新缓存
- (void)startWithOutChche;

/// 手动将其他请求的JsonResponse写入该请求的缓存
//- (void)saveToCacheFileWithResponseJSON:(id)responseJSONObject;

- (id)cacheFileNameFilterForRequestArgument:(id)argument;

#pragma mark - SubClass overwrite
/**
 *  设定缓存有效期 (默认立即过期)
 *
 *  @return 有效时间（秒）
 */
- (NSInteger)cacheTimeInSeconds;    //TODO:设置缓存时间目前无效。缓存清理问题

///缓存版本号 （default = 0）
- (long long)versionOfCache;

///缓存敏感数据 (default = nil)
- (id)cacheSensitiveData;

@end
