//
//  FileLogger.h
//  ILSLog
//
//  Created by 周和生 on 14/8/1.
//  Copyright (c) 2014年 iLegendSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FLog(fmt, ...) [[FileLogger sharedInstance] log:fmt, ##__VA_ARGS__]

@interface FileLogger : NSObject

+ (FileLogger *)sharedInstance;
- (void)logString:(NSString *)format, ...;
- (void)log_va:(NSString *)format arguments:(va_list)argList;
- (void)logMessage: (NSString *)message;

- (NSString *)logFileContents;
@end

