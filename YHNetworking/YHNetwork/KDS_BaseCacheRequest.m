//
//  KDS_BaseCacheRequest.m
//  YHNetWorkDemo
//
//  Created by yehot on 15/11/20.
//  Copyright © 2015年 yehot. All rights reserved.
//

#import "KDS_BaseCacheRequest.h"
#import "KDS_NetworkConfig.h"
#import "KDS_RequestHelper.h"

@interface KDS_BaseCacheRequest () {
    BOOL dataIsFromCache_;
}

@property (strong, nonatomic) id cacheJsonObject;

@end

@implementation KDS_BaseCacheRequest

#pragma mark - Super

- (void)start {
    
    // check if ignoreCache
    if (self.ignoreCache) {
        [super start];
        return;
    }
    
    // check cache time
    if (self.cacheTimeInSeconds < 0) {
        [super start];
        return;
    }
    
    // check cache version
//    long long cacheVersionFileContent = [self versionOfCacheFileContet];
//    if (cacheVersionFileContent != [self versionOfCache]) {
//        return;
//    }
    if ([self isCacheVersionExpired]) {
        [super start];
        return;
    }
    
    // check if cache path existance
    NSString *path = [self filePathOfCache];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        [super start];
        return;
    }
    
    // check cache expired
    int seconds = [self durationOfCacheFile:path];
    if (seconds < 0 || seconds > [self cacheTimeInSeconds]) {
        [super start];
        return;
    }
    
    // load cache
    self.cacheJsonObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (self.cacheJsonObject == nil) {
        [super start];
        return;
    }
    
    dataIsFromCache_ = YES;
    [self requestCompleteFilter];
    KDS_BaseCacheRequest *strongSelf = self;
    if ([strongSelf.delegate respondsToSelector:@selector(request:didFinishWithObject:)]) {
        [strongSelf.delegate request:strongSelf didFinishWithObject:strongSelf.responseJSONObject];
    }
    if (strongSelf.successBlock) {
        strongSelf.successBlock(strongSelf, strongSelf.responseJSONObject);
    }
    [strongSelf clearBlock];
}

//不使用缓存
- (void)startWithOutChche {
    [super start];
}

#pragma mark super

//  拦截父类方法，返回缓存
- (id)responseJSONObject {
    if (_cacheJsonObject) {
        return _cacheJsonObject;
    } else {
        return [super responseJSONObject];
    }
}

// 将返回的数据缓存
- (void)requestCompleteFilter {
    [super requestCompleteFilter];
    [self saveToCacheFileWithResponseJSON:[super responseJSONObject]];
}

// 手动将其他请求的JsonResponse写入该请求的缓存
- (void)saveToCacheFileWithResponseJSON:(id)responseJSONObject {
    if ([self cacheTimeInSeconds] > 0 && ![self isDataFromCache]) {
        NSDictionary *json = responseJSONObject;
        if (json != nil) {
            [NSKeyedArchiver archiveRootObject:json toFile:[self filePathOfCache]];
            [NSKeyedArchiver archiveRootObject:@([self versionOfCache]) toFile:[self filePathOfTheCacheVersion]];
        }
    }
    
}

#pragma mark -

///缓存已存在的时间
- (int)durationOfCacheFile:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    NSDictionary *attributes = [manager attributesOfItemAtPath:path error:&error];
    if (!attributes) {
        KDSNetLog(@"Error get attributes for file at %@; error: %@", path, error);
        return -1;
    }
    //缓存文件上次被修改的时间 与 此刻 的时间差
    int seconds = -[[attributes fileModificationDate] timeIntervalSinceNow];
    return seconds;
}

///缓存文件的路径
- (NSString *)filePathOfCache {
    NSString *cacheFile = [self fileNameOfCache];
    NSString *path = [self basePathOfCache];
    path = [path stringByAppendingPathComponent:cacheFile];
    return path;
}

///获取缓存版本号？？
- (long long)versionOfCacheFileContet {
    NSString *path = [self filePathOfTheCacheVersion];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path isDirectory:nil]) {
        NSNumber *version = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        return [version longLongValue];
    } else {
        return 0;
    }
}

///缓存文件路径
- (NSString *)filePathOfTheCacheVersion {
    NSString *cacheVersionFileName = [NSString stringWithFormat:@"%@.version", [self fileNameOfCache]];
    NSString *path = [self basePathOfCache];
    path = [path stringByAppendingPathComponent:cacheVersionFileName];
    return path;
}

///缓存base路径
- (NSString *)basePathOfCache {
    NSString *pathOfLibrary = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [pathOfLibrary stringByAppendingString:@"LazyRequestCache"];
    //    TODO: filter
    [self checkDirectoryOfPath:path];
    return path;
}

///检查文件是否存在，如果不存在自动生成一个
- (void)checkDirectoryOfPath:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![manager fileExistsAtPath:path isDirectory:&isDir]) {
        [self creatBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error;
            [manager removeItemAtPath:path error:&error];
            [self creatBaseDirectoryAtPath:path];
        }
    }
}

///缓存不做iCloud备份
- (void)addDoNotBackupAttribute:(NSString *)path {
    NSURL *url =[NSURL fileURLWithPath:path];
    NSError *error;
    [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (error) {
        KDSNetLog(@"error to set do not backup attribute, error : %@", error);
    }
}

///生成缓存base文件夹
- (void)creatBaseDirectoryAtPath:(NSString *)path {
    __autoreleasing NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        KDSNetLog(@"creat cache directory failed, error = %@", error);
    } else {
        [self addDoNotBackupAttribute:path];
    }
}

///缓存文件名
- (NSString *)fileNameOfCache {
    NSString *requestUrl = [self requestURL];
    NSString *baseUrl = [KDS_NetworkConfig sharedInstance].golbalBaseURL;
    id argument = [self cacheFileNameFilterForRequestArgument:[self requestArgument]];
    NSString *requestInfo = [NSString stringWithFormat:@"Method:%ld Host:%@ Url:%@ Argument:%@ AppVersion:%@ Sensitive:%@", (long)[self requestMethod], baseUrl, requestUrl, argument, [KDS_RequestHelper appVersionString], [self cacheSensitiveData]];
    NSString *cacheFileName = [KDS_RequestHelper md5StringFromString:requestInfo];
    return cacheFileName;
}

- (id)cachedObject {
    if (!_cacheJsonObject) {
        NSString *path = [self filePathOfCache];
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:path]) {
            _cacheJsonObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        }
    }
    return _cacheJsonObject;
}

- (BOOL)isDataFromCache {
    return dataIsFromCache_;
}

- (BOOL)isCacheVersionExpired {
    long long cacheVersion = [self versionOfCacheFileContet];
    if (cacheVersion != [self versionOfCache]) {
        return YES;
    } else {
        return NO;
    }
}



- (id)cacheFileNameFilterForRequestArgument:(id)argument {
    return argument;
}

#pragma mark - SubClass overwrite

//供子类重载
- (NSInteger)cacheTimeInSeconds {
    return -1;
}

- (long long)versionOfCache {
    return 0;
}

- (id)cacheSensitiveData {
    return nil;
}

@end
