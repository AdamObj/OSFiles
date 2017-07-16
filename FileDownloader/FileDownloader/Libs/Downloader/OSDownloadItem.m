//
//  OSDownloadItem.m
//  DownloaderManager
//
//  Created by Ossey on 2017/6/4.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "OSDownloadItem.h"


@interface OSDownloadItem ()

/** 恢复下载时所在文件的字节数 */
@property (nonatomic, assign) ino64_t resumedFileSizeInBytes;
/** 下载的url */
@property (nonatomic, copy) NSString *urlPath;
/** 下载会话对象 NSURLSessionDownloadTask */
@property (nonatomic, strong) NSURLSessionTask *sessionTask;
/** 下载时发送的错误信息栈 */
@property (nonatomic, strong) NSArray<NSString *> *errorMessagesStack;
/** 最后的HTTP状态码 */
@property (nonatomic, assign) NSInteger lastHttpStatusCode;
/** 最终文件存储的本地路径 */
@property (nonatomic, strong) NSURL *finalLocalFileURL;
/** 文件的类型 */
@property (nonatomic, copy) NSString *MIMEType;
/** 流 */
@property (nonatomic, strong) NSOutputStream *outputStream;

@property (nonatomic, strong) OSDownloadProgress *progressObj;

@end

@implementation OSDownloadItem

////////////////////////////////////////////////////////////////////////
#pragma mark - initialize
////////////////////////////////////////////////////////////////////////

@synthesize
cancellationHandler = _cancellationHandler,
pausingHandler = _pausingHandler,
resumingHandler = _resumingHandler;

- (instancetype)initWithURL:(NSString *)urlPath
            sessionDataTask:(NSURLSessionDataTask *)sessionDownloadTask {
    if (self = [super init]) {
        self.urlPath = urlPath;
        self.sessionTask = sessionDownloadTask;
        self.resumedFileSizeInBytes = 0;
        self.lastHttpStatusCode = 0;
        
        NSProgress *progress = [[NSProgress alloc] initWithParent:[NSProgress currentProgress] userInfo:nil];
        progress.kind = NSProgressKindFile;
        [progress setUserInfoObject:NSProgressFileOperationKindKey forKey:NSProgressFileOperationKindDownloading];
        [progress setUserInfoObject:urlPath forKey:@"urlPath"];
        progress.cancellable = YES;
        progress.pausable = YES;
        progress.totalUnitCount = NSURLSessionTransferSizeUnknown;
        progress.completedUnitCount = 0;
        
        self.progressObj = [[OSDownloadProgress alloc] initWithDownloadProgress:0
                                                               expectedFileSize:0
                                                               receivedFileSize:0
                                                         estimatedRemainingTime:0
                                                            bytesPerSecondSpeed:0
                                                                 nativeProgress:progress];
        
    }
    return self;
}

- (void)pause {
    [self.progressObj.nativeProgress pause];
}

- (void)cancel {
    [self.progressObj.nativeProgress cancel];
}

- (void)resume {
    if ([self.progressObj.nativeProgress respondsToSelector:@selector(resume)]) {
        [self.progressObj.nativeProgress resume];
    } else {
        if (self.resumingHandler) {
            self.resumingHandler();
        }
    }
}




- (void)dealloc {
    
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (void)setCancellationHandler:(void (^)(void))cancellationHandler {
    _cancellationHandler = cancellationHandler;
    [self.progressObj.nativeProgress setCancellationHandler:cancellationHandler];
}

- (void (^)(void))cancellationHandler {
    return self.progressObj.nativeProgress.cancellationHandler;
}

- (void)setPausingHandler:(void (^)(void))pausingHandler {
    _pausingHandler = pausingHandler;
    [self.progressObj.nativeProgress setPausingHandler:pausingHandler];
}

- (void (^)(void))pausingHandler {
    return self.progressObj.nativeProgress.pausingHandler;
}

- (void)setResumingHandler:(void (^)(void))resumingHandler {
    _resumingHandler = resumingHandler;
    if ([self.progressObj.nativeProgress respondsToSelector:@selector(setResumingHandler:)]) {
        [self.progressObj.nativeProgress setResumingHandler:resumingHandler];
    }
}

- (void (^)(void))resumingHandler {
    return self.progressObj.nativeProgress.resumingHandler;
}

- (void)setProgressHandler:(void (^)(NSProgress * _Nonnull))progressHandler {
    _progressHandler = progressHandler;
    self.progressObj.progressHandler = progressHandler;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - description
////////////////////////////////////////////////////////////////////////



- (NSString *)description {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.urlPath forKey:@"urlPath"];
    [dict setObject:self.progressObj.description forKey:@"progressObj"];
    if (self.sessionTask) {
        [dict setObject:[NSString stringWithFormat:@"sessionTask identifier:%ld", self.sessionTask.taskIdentifier] forKey:@"taskIdentifier"];
    }
    if (self.MIMEType) {
        [dict setObject:self.MIMEType forKey:@"MIMEType"];
    }
    NSString *description = [NSString stringWithFormat:@"%@", dict];
    
    return description;
}

@end
