//
//  KDS_NetworkConfig.h
//  YHNetWorkDemo
//
//  Created by yehot on 15/11/17.
//  Copyright © 2015年 yehot. All rights reserved.
//

#import <Foundation/Foundation.h>

//@protocol KDSUrlComponentProtocol <NSObject>
//@required
//@property (strong, nonatomic, readonly) NSDictionary *urlComponents;
//
////- (NSString *)appendComponentToURL:(NSString *)originUrl withRequest:()
//- (NSString *)appendComponent:(NSDictionary *)component toOriginUrl:(NSString *)originUrl;
//
//@end

/**
 *  配置全局的请求参数，如域名、参数、缓存
 */
@interface KDS_NetworkConfig : NSObject

+ (KDS_NetworkConfig *)sharedInstance;

/**
 *  配置整个工程请求 统一的 域名：    eg: http:www.519.com/
 *  @code
     [KDS_NetworkConfig sharedInstance].baseUrl = @"http:www.519.com/";
    @endcode
 *  @warning 可在KDS_BaseRequest.m 子类中为 overwrite baseUrl 方法，手动为该请求单独指定。
 */
@property (copy, readonly, nonatomic) NSString *golbalBaseURL;

///**
// *  NSArray<KDSUrlFilterProtocol>
// *  @Remark   Array里是 <KDSUrlComponentProtocol> 的对象
// */
//@property (strong, readonly, nonatomic) NSArray *baseURLComponents;

@property (strong, readonly, nonatomic) NSMutableDictionary *golablUrlComponents;

/**
 *  是否设置了 baseUrl
 */
@property (assign, readonly, nonatomic) BOOL hasGolbalDomainUrl;
/**
 *   是否设置了baseUrlComponents
 */
@property (assign, readonly, nonatomic) BOOL hasBaseUrlComponent;

- (void)setGlobalBaseUrl:(NSString *)aUrlStr;
- (void)addGlobalUrlComponentWithkey:(NSString *)key andValue:(NSString *)value;




//TODO:  状态条上的 活动指示器。自动 转动 和 隐藏。封装到 base rqquest 中
//[[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];


@end
