//
//  KDS_NetworkAgent.m
//  YHNetWorkDemo
//
//  Created by yehot on 15/11/17.
//  Copyright © 2015年 yehot. All rights reserved.
//

#import "KDS_NetworkAgent.h"
#import "AFNetworking.h"
#import "KDS_RequestHelper.h"
#import "KDS_NetworkConfig.h"

static NSInteger const maxConcurrentOperationCount_ = 4; ///< 默认最大并发请求数

@interface KDS_NetworkAgent ()

@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;   ///< 请求管理器
@property (strong, nonatomic) NSMutableDictionary *requestsRecorder;    ///< 请求的记录池

@end

@implementation KDS_NetworkAgent

+ (KDS_NetworkAgent *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)addRequest:(KDS_BaseRequest *)request {
    
    //请求头
    NSDictionary *headerDict = [request requestHeaderValueDictionary];
    if (nil != headerDict) { //设置了请求头
        for (id key in headerDict.allKeys) {
            id value = headerDict[key];
            BOOL keyValue = [value isKindOfClass:[NSString class]] && [key isKindOfClass:[NSString class]];
            if (keyValue) {
                [self.manager.requestSerializer setValue:(NSString *)value forKey:(NSString *)key];
            } else {    //key、value 必须是字符串类型
                KDSNetLog(@"Error, class of key/value in headerFieldValueDictionary should be NSString.");
            }
        }
    }
    
    //超时时间
    self.manager.requestSerializer.timeoutInterval = request.requestTimeoutInterval;
    
    if (request.requestSerializerType == KDSRequestSerializerTypeHttp) {
        self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    else if (request.requestSerializerType == KDSRequestSerializerTypeJSON) {
        self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    if (nil != request.buildCustomURLRequest) { //自定义Request
        [self startCustomRequest:request];
    }
    else {    //KDS_BaseRequest
        [self startKDS_BaseRequest:request];
    }
}

- (void)cancelRequest:(KDS_BaseRequest *)request {
    [request.operation cancel];
    [self removeOperation:request.operation];
    [request clearBlock];
}

- (void)cancelAllRequest {
    //  使用 拷贝 来处理，而非直接操作原对象
    NSDictionary *copyRecord = [self.requestsRecorder copy];
    for (NSString *key in copyRecord) {
        KDS_BaseRequest *request = copyRecord[key];
        [request stop];
    }
}

#pragma mark -

/**
 *  发起 KDS_BaseRequest 请求
 */
- (void)startKDS_BaseRequest:(KDS_BaseRequest *)request {    
    NSString *urlStr = [self buildURLFromRequest:request];
    id parameters    = request.requestArgument; //请求参数
    
    switch (request.requestMethod) {
        case KDSRequestMethodGet:
        {
            [self getRequest:request withUrlStr:urlStr parameters:parameters];
        }
            break;
            
        case KDSRequestMethodPost:
        {
            [self postRequest:request withUrlStr:urlStr parameters:parameters];
        }
            break;
            
        case KDSRequestMethodPut:
        {
            [self putRequest:request withUrlStr:urlStr parameters:parameters];
        }
            break;
            
        case KDSRequestMethodHead:
        {
            [self headRequest:request withUrlStr:urlStr parameters:parameters];
        }
            break;
            
        case KDSRequestMethodPatch:
        {
            [self patchRequest:request withUrlStr:urlStr parameters:parameters];
        }
            break;
            
        case KDSRequestMethodDelete:
        {
            [self deleteRequest:request withUrlStr:urlStr parameters:parameters];
        }
            break;
            
        default:
        {
            KDSNetLog(@"Error, unsupport method type !");
        }
            break;
    }
    KDSNetLog(@"Add request: %@", NSStringFromClass([request class]));
    [self recorderDictionaryAddRequest:request];
}

/**
 *  发起自定义请求
 */
- (void)startCustomRequest:(KDS_BaseRequest *)request {
    
    NSURLRequest *customRequest = request.buildCustomURLRequest;
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:customRequest];
    operation.responseSerializer = self.manager.responseSerializer;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [self handleRequestResultWithOperation:operation];
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        [self handleRequestResultWithOperation:operation];
    }];
    request.operation = operation;
    [self.manager.operationQueue addOperation:operation];
}

/**
 *  处理请求的结果，通过block、delegate返回
 */
- (void)handleRequestResultWithOperation:(AFHTTPRequestOperation *)operation {
    
    NSString *key = [self keyFromOperation:operation];
    KDS_BaseRequest *request = self.requestsRecorder[key];
    KDSNetLog(@"请求完成： %@", NSStringFromClass([request class]));
    
    if (request) {
        BOOL succeed = [self checkResult:request];
        if (succeed) {
            [request kds_toggleAccessoryWillStopCallBack];
            //如果是KDS_BaseCacheRequest，这里一定会写入缓存
            [request requestCompleteFilter];
            if ([request.delegate respondsToSelector:@selector(request:didFinishWithObject:)]) {
                [request.delegate request:request didFinishWithObject:request.responseJSONObject];
            }
            if (request.successBlock) {
                request.successBlock(request, request.responseJSONObject);
            }
            [request kds_toggleAccessoryDidStopCallBack];
        }
        
    } else {
        KDSNetLog(@"%@请求失败, status code = %zd ", NSStringFromClass([request class]), request.responseCode );
        [request kds_toggleAccessoryWillStopCallBack];
        [request requestCompleteFilter];
        if ([request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
            [request.delegate request:request didFailWithError:request.operation.error];
        }
        if (request.failureBlock) {
            request.failureBlock(request, request.operation.error);
        }
        [request kds_toggleAccessoryDidStopCallBack];
    }
    [self removeOperation:operation];
    [request clearBlock];
}

#pragma mark 处理具体种类的请求

/**
 *  处理 GET 请求
 */
- (void)getRequest:(KDS_BaseRequest *)request withUrlStr:(NSString *)urlStr parameters:(id)parameters {
    if (request.resumableDownloadPath.length > 0) {  // 设置了断点续传路径
        [self resumeGetRequest:request withUrlStr:urlStr parameters:parameters];
    } else {    // common get
        [self commonGetRequest:request withUrlStr:urlStr parameters:parameters];
    }
}

/**
 *  断点续传 GET 请求
 */
- (void)resumeGetRequest:(KDS_BaseRequest *)request withUrlStr:(NSString *)urlStr parameters:(id)parameters {
    //断点续传AFN只能使用拼接式的url发起get请求
    NSString *resumeUrl = [KDS_RequestHelper appendComponentDict:parameters toOriginUrl:urlStr];
    NSURLRequest *resumeRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:resumeUrl]];
    AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:resumeRequest targetPath:request.resumableDownloadPath shouldResume:YES];
    [operation setProgressiveDownloadProgressBlock:request.resumableDownloadProgressBlock]; //进度回调
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [self handleRequestResultWithOperation:operation];
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        [self handleRequestResultWithOperation:operation];
    }];
    request.operation = operation;
    [_manager.operationQueue addOperation:operation];
}

/**
 *  普通 GET 请求
 */
- (void)commonGetRequest:(KDS_BaseRequest *)request withUrlStr:(NSString *)urlStr parameters:(id)parameters {
    request.operation = [self.manager GET:urlStr parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [self handleRequestResultWithOperation:operation];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleRequestResultWithOperation:operation];
    }];
}

/**
 *  处理 POST 请求
 */
- (void)postRequest:(KDS_BaseRequest *)request withUrlStr:(NSString *)urlStr parameters:(id)parameters {
    if (request.constructionBodyBlock != nil) {   // 带富文本
        request.operation = [_manager POST:urlStr parameters:parameters constructingBodyWithBlock:request.constructionBodyBlock success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            [self handleRequestResultWithOperation:operation];
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            [self handleRequestResultWithOperation:operation];
        }];
    } else {    // common post
        [self commonPostRequest:request withUrlStr:urlStr parameters:parameters];
    }
}

/**
 *  带富文本 POST 请求
 */
- (void)PostRequest:(KDS_BaseRequest *)request withUrlStr:(NSString *)urlStr parameters:(id)parameters {
    if (request.constructionBodyBlock != nil) {   // 带富文本
        
    } else {    // common post
        [self commonPostRequest:request withUrlStr:urlStr parameters:parameters];
    }
    
}


/**
 *  普通 POST 请求
 */
- (void)commonPostRequest:(KDS_BaseRequest *)request withUrlStr:(NSString *)urlStr parameters:(id)parameters {
    request.operation = [self.manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [self handleRequestResultWithOperation:operation];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleRequestResultWithOperation:operation];
    }];
}

/**
 *  处理 put 请求
 */
- (void)putRequest:(KDS_BaseRequest *)request withUrlStr:(NSString *)urlStr parameters:(id)parameters {
    request.operation = [self.manager PUT:urlStr parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [self handleRequestResultWithOperation:operation];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleRequestResultWithOperation:operation];
    }];
}

/**
 *  处理 head 请求
 */
- (void)headRequest:(KDS_BaseRequest *)request withUrlStr:(NSString *)urlStr parameters:(id)parameters {
    request.operation = [self.manager HEAD:urlStr parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation) {
        [self handleRequestResultWithOperation:operation];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleRequestResultWithOperation:operation];
    }];
}

/**
 *  处理 patch 请求
 */
- (void)patchRequest:(KDS_BaseRequest *)request withUrlStr:(NSString *)urlStr parameters:(id)parameters {
    request.operation = [self.manager PATCH:urlStr parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [self handleRequestResultWithOperation:operation];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleRequestResultWithOperation:operation];
    }];
}

/**
 *  处理 delete 请求
 */
- (void)deleteRequest:(KDS_BaseRequest *)request withUrlStr:(NSString *)urlStr parameters:(id)parameters {
    request.operation = [self.manager DELETE:urlStr parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [self handleRequestResultWithOperation:operation];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [self handleRequestResultWithOperation:operation];
    }];
}

#pragma mark - private

//验证状态码，校验json
- (BOOL)checkResult:(KDS_BaseRequest *)request {
    BOOL result = request.operation.response.statusCode;
    if (!result) {
        return result;
    }
    id validator = [request jsonValidator];
    if (validator != nil) {
        id json = [request responseJSONObject];
        result = [KDS_RequestHelper checkJSON:json withValidator:validator];
    }
    return result;
}

/**
 *  将请求记录到 dictionary
 *  @warning  key: operation 、value: request
 */
- (void)recorderDictionaryAddRequest:(KDS_BaseRequest *)request {
    if (request.operation != nil) {
        NSString *key = [self keyFromOperation:request.operation];
        @synchronized(self) {
            self.requestsRecorder[key] = request;
        }
    }
}


/**
 *  从记录池移除指定 请求
 */
- (void)removeOperation:(AFHTTPRequestOperation *)operation {
    NSString *key = [self keyFromOperation:operation];
    @synchronized(self) {
        [self.requestsRecorder removeObjectForKey:key];
    }
    KDSNetLog(@"请求池剩余请求个数:%zd", self.requestsRecorder.count);
}


/**
 *  将 hash 化的 operation 转为字符串
 *
 *  @return hash key string
 */
- (NSString *)keyFromOperation:(AFHTTPRequestOperation *)operation {
    NSString *key = [NSString stringWithFormat:@"%lu",(unsigned long)[operation hash]];
    return key;
}

/**
 *  将 url 拼接完整，加入 baseUrl 和 全局参数
 */
- (NSString *)buildURLFromRequest:(KDS_BaseRequest *)request {
    NSString *detailUrl = [request requestURL];
    if ([detailUrl hasPrefix:@"http"]) {   //子类设置了完整的url
        return detailUrl;
    }
    KDS_NetworkConfig *config = [KDS_NetworkConfig sharedInstance];
    
    if (config.hasBaseUrlComponent) {   // 设置了全局统一参数
        NSDictionary *component = config.golablUrlComponents;
        detailUrl = [KDS_RequestHelper appendComponentDict:component toOriginUrl:detailUrl];
    }
    
    NSString *baseUrl;
    if (request.baseURL.length > 0) {  //请求单独指定了baselUrl
        baseUrl = request.baseURL;
    } else {        // 使用默认的全局baseDomainUrl
        baseUrl = config.golbalBaseURL;
    }
    // 拼接成完整的 url
    NSString *fullUrl = [NSString stringWithFormat:@"%@%@", baseUrl, detailUrl];
    return fullUrl;
}

#pragma mark - getter

- (AFHTTPRequestOperationManager *)manager {
    if (!_manager) {
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount_;
    }
    return _manager;
}

- (NSMutableDictionary *)requestsRecorder {
    if (!_requestsRecorder) {
        _requestsRecorder = [NSMutableDictionary dictionary];
    }
    return _requestsRecorder;
}


@end
