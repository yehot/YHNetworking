//
//  KDS_BaseRequest.h
//  YHNetWorkDemo
//
//  Created by yehot on 15/11/17.
//  Copyright © 2015年 yehot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFDownloadRequestOperation/AFDownloadRequestOperation.h>

//请求类型
typedef NS_ENUM (NSInteger, KDSRequestMethod) {
    KDSRequestMethodGet = 0,
    KDSRequestMethodPost,
    KDSRequestMethodHead,
    KDSRequestMethodPut,
    KDSRequestMethodDelete,
    KDSRequestMethodPatch
};

//请求序列化类型
typedef NS_ENUM(NSInteger, KDSRequestSerializerType) {
    KDSRequestSerializerTypeHttp = 0,
    KDSRequestSerializerTypeJSON
};

@class KDS_BaseRequest;

@protocol KDSRequestDelegate <NSObject>
@optional
/**
 *  请求成功回调
 */
- (void)request:(KDS_BaseRequest *)request didFinishWithObject:(id)responseObject;

/**
 *  请求失败回调
 */
- (void)request:(KDS_BaseRequest *)request didFailWithError:(NSError *)error;

@end

///     hook delegate
@protocol KDSRequestAccessoryDelegate <NSObject>

@optional

- (void)requestWillStart:(KDS_BaseRequest *)request;
- (void)requestWillStop:(KDS_BaseRequest *)request;
- (void)requestDidStop:(KDS_BaseRequest *)request;

@end


typedef void(^SuccessBlock)(KDS_BaseRequest *request, id responseObject);
typedef void(^FailureBlock)(KDS_BaseRequest *request, NSError *error);


@interface KDS_BaseRequest : NSObject

//TODO: 没必要直接访问、操作 operation 对象
//TODO:  这些 属性，基本没必要暴露出来（尽量简化接口）
@property (strong, nonatomic) AFHTTPRequestOperation *operation;    ///<请求operation对象
@property (copy, readonly, nonatomic) SuccessBlock successBlock;      ///<block call back
@property (copy, readonly, nonatomic) FailureBlock failureBlock;      ///<block call back
@property (strong, readonly, nonatomic) NSString *responseString;   ///<返回string数据
@property (strong, readonly, nonatomic) id responseJSONObject;  ///<返回的JSON格式数据

#pragma mark response

@property (strong, readonly, nonatomic) NSDictionary *responseHeaders;   ///<响应头

@property (assign, readonly, nonatomic) NSInteger responseCode; ///<响应状态码

@property (assign, nonatomic) NSInteger tag;    ///<请求的tag值

/**
 *  请求回调的delegate ,使用 delegate作为请求回调时使用
 */
@property (weak, nonatomic) id<KDSRequestDelegate> delegate;

/**
 *  hook delegate
 */
@property (weak, nonatomic) id<KDSRequestAccessoryDelegate> accessoryDelegate;

#pragma mark - use delegate
/**
 *  开始请求
 */
- (void)start;

/**
 *  结束请求
 */
- (void)stop;

/**
 *  请求是否正在执行中 （下载用）
 */
- (BOOL)isExecuting;

#pragma mark - use block
/**
 *  设置block回调，并发起请求
 */
- (void)startWithSuccessBlock:(SuccessBlock)success failureBlock:(FailureBlock)failure;

/**
 *  设置block回调
 *  @warning 需调用 start 发起请求
 */
- (void)setRequestSuccessBlock:(SuccessBlock)success failureBlock:(FailureBlock)failure;


//TODO: 无需手动调用
/**
 *  将请求的 block 置为 nil （to break circle call in block）
 */
- (void)clearBlock;

#pragma mark - subClass overwrite
#pragma mark 以下方法由子类重载，覆盖默认值 (也可作为getter方法使用)

/**
 *  请求单独指定 baseURL。如果此方法重写后，返回值不为nil，则认为此 请求对象不使用 全局默认的 统一域名（即 NetworkConfig 中的 baseDomainURL）
 */
- (NSString *)baseURL;

/**
 *  请求的url （如果设置了 baseDomainURL， 则为 baseDomainURL + requestURL）
 */
- (NSString *)requestURL;

/**
 *  请求的参数列表
 */
- (id)requestArgument;

/**
 *  请求类型 （default = GET）
 */
- (KDSRequestMethod)requestMethod;

/**
 *  请求超时时间 （default = 60s）
 */
- (NSTimeInterval)requestTimeoutInterval;

/**
 *  请求的序列化类型 (default = KDSRequestSerializerTypeHttp)
 */
- (KDSRequestSerializerType)requestSerializerType;

/**
 *  添加HTTP头参数 （optional） eg:cookie
 */
- (NSDictionary *)requestHeaderValueDictionary;

//TODO: 处理 cookie 单独抽成方法 ??


//TODO: 可以先不暴露这些方法
//  TODO: filter 是干嘛的？？ 重命名
/**
 *  请求成功时会调用 （可以缓存请求数据）
 */
- (void)requestCompleteFilter;

/**
 *  请求失败时会被调用 （可以做retry处理）
 */
- (void)requestFailedFilter;

#pragma mark 自定义request
/**
 *  使用完全自定义的 NSURLRequest
 *  @warning 若这个方法返回非nil对象，会忽略requestUrl, requestArgument, requestMethod, requestSerializerType
 */
- (NSURLRequest *)buildCustomURLRequest;

/// 用于检查JSON是否合法的对象(子类定义JSON格式)
- (id)jsonValidator;

#pragma mark - 断点续传

typedef void(^AFConstructingBlock)(id<AFMultipartFormData> formData);

/**
 *  下载进度的回调
 *
 *  @param operation                       请求operation
 *  @param Readbytes                       本次下载
 *  @param totalReadBytes                  当前已下载
 *  @param totalExpectedBytes              总预期大小
 *  @param totalBytesReadForFile           当前文件大小
 *  @param totalBytesExpextedToReadForFile 文件预计总大小
 */
typedef void(^AFDownloadProgressBlock)(AFDownloadRequestOperation *operation, NSInteger Readbytes, long long totalReadBytes, long long totalExpectedBytes, long long totalBytesReadForFile, long long totalBytesExpextedToReadForFile);

/// 当POST的内容带有文件等富文本时使用
- (AFConstructingBlock)constructionBodyBlock;

//指定下载的本地路径，断点续传路径
- (NSString *)resumableDownloadPath;

// 当需要断点续传时，获得下载进度的回调：
//子类添加一个     @property (copy, nonatomic) AFDownloadProgressBlock downloadProgressBlock;
//重写 - (AFDownloadProgressBlock)resumableDownloadProgressBlock {return self.downloadProgressBlock;}
//使用时 request.downloadProgressBlock =  ^()xxx {}
- (AFDownloadProgressBlock)resumableDownloadProgressBlock;


@end
