//
//  KDS_BaseRequest.m
//  YHNetWorkDemo
//
//  Created by yehot on 15/11/17.
//  Copyright © 2015年 yehot. All rights reserved.
//

#import "KDS_BaseRequest.h"
#import "KDS_NetworkAgent.h"
#import "KDS_RequestHelper.h"

//请求默认超时时间
static NSTimeInterval const kDefaultTimeOutInteval_ = 60;

@implementation KDS_BaseRequest

#pragma mark main

- (void)start{
    [self kds_toggleAccessoryWillStartCallBack];
    [[KDS_NetworkAgent sharedInstance] addRequest:self];

}

- (void)stop {
    [self kds_toggleAccessoryWillStopCallBack];
    [[KDS_NetworkAgent sharedInstance] cancelRequest:self];
    [self kds_toggleAccessoryDidStopCallBack];
}

- (BOOL)isExecuting {
    return self.operation.isExecuting;
}

#pragma mark block call back

- (void)startWithSuccessBlock:(SuccessBlock)success failureBlock:(FailureBlock)failure {
    [self setRequestSuccessBlock:success failureBlock:failure];
    [self start];
}

- (void)setRequestSuccessBlock:(SuccessBlock)success failureBlock:(FailureBlock)failure {
    self.successBlock = success;
    self.failureBlock = failure;
}

- (void)clearBlock {
    self.successBlock = nil;
    self.failureBlock = nil;
}

#pragma mark - subClass overwrite

- (NSString *)baseURL {
    return @"";
}

#pragma mark 以下方法供子类重载，覆盖默认值

- (NSString *)requestURL {
    return @"";
}

- (id)requestArgument {
    return nil;
}

- (KDSRequestMethod)requestMethod {
    return KDSRequestMethodGet;
}

- (NSTimeInterval)requestTimeoutInterval {
    return kDefaultTimeOutInteval_;
}

- (KDSRequestSerializerType)requestSerializerType {
    return KDSRequestSerializerTypeHttp;
}

- (NSDictionary *)requestHeaderValueDictionary {
    return nil;
}

- (void)requestCompleteFilter {
    //子类可选重载
}

- (void)requestFailedFilter {
    //子类可选重载
}

- (NSURLRequest *)buildCustomURLRequest {
    return nil;
}

- (id)jsonValidator {
    return nil;
}

#pragma mark - getter

- (id)responseJSONObject {
    return self.operation.responseObject;
}

- (NSString *)responseString {
    return self.operation.responseString;
}

- (NSInteger)responseCode {
    return self.operation.response.statusCode;
}

- (NSDictionary *)responseHeaders {
    return self.operation.response.allHeaderFields;
}


#pragma mark - setter

- (void)setSuccessBlock:(SuccessBlock)successBlock {
    if (!_successBlock) {
        _successBlock = successBlock;
    }
}

- (void)setFailureBlock:(FailureBlock)failureBlock {
    _failureBlock = failureBlock;
}

- (AFConstructingBlock)constructionBodyBlock {
    return nil;
}

- (NSString *)resumableDownloadPath {
    return nil;
}

- (AFDownloadProgressBlock)resumableDownloadProgressBlock {
    return nil;
}

@end
