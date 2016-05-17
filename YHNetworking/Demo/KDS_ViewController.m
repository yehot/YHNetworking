//
//  KDS_ViewController.m
//  YHNetWorkDemo
//
//  Created by yehot on 15/11/17.
//  Copyright © 2015年 yehot. All rights reserved.
//

#import "KDS_ViewController.h"
#import "KDS_OneRequest.h"
#import "KDS_TwoRequest.h"

@interface KDS_ViewController () <KDSRequestDelegate>

@end

@implementation KDS_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self testBlockRequest];
    
//    [self testDelegateRequest];
    
}

- (void)testBlockRequest {
    KDS_OneRequest *request = [[KDS_OneRequest alloc] init];
    
    // 断点续传使用
    request.downloadProgressBlock =  ^(AFDownloadRequestOperation *operation, NSInteger Readbytes, long long totalReadBytes, long long totalExpectedBytes, long long totalBytesReadForFile, long long totalBytesExpextedToReadForFile) {
        //下载进度的回调
        
    };
    
    //  先取出缓存供页面使用 (如果有)
    NSDictionary *cacheData = [request cachedObject];
    NSLog(@"%@", cacheData);    // view 使用
    
    // 模拟网络数据5秒后到
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [request startWithSuccessBlock:^(KDS_BaseRequest *request, id responseObject) {
            NSLog(@"%@",responseObject);
        } failureBlock:^(KDS_BaseRequest *request, NSError *error) {
            NSLog(@"%@",error);
        }];
    });
}

- (void)testDelegateRequest {
    KDS_OneRequest *request = [[KDS_OneRequest alloc] init];
    request.delegate = self;
    [request start];
}

#pragma mark -

- (void)request:(KDS_BaseRequest *)request didFinishWithObject:(id)responseObject {
     NSLog(@"%@",responseObject);
}

- (void)request:(KDS_BaseRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
}


@end
