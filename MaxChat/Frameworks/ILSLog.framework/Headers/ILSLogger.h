//
//  ILSLogger.h
//  ILSLogger
//
//  Created by bloodmagic on 13-5-7.
//  Copyright (c) 2013年 iLegendSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef enum ILSLogLevel{
    ILSLogLevelServer = 0,
    ILSLogLevelError = 1,
    ILSLogLevelInfo = 2
} ILSLogLevel;

/***********************************************************************
 
使用方法：
 
 1，在 appDelegate 的 didFinishLaunch 中调用合适的 [[ILSLogger sharedLogger] configureXXX];
 2，在需要打印日志的地方调用 ILSLogXXX (domain是一个逻辑概念，可以用来把log分为不同的逻辑组，方便筛选。)
 
 
NSLogger 的配置：
 
 启动iMac中的 NSLogger viewer 即可看到实时 Log。
 
 bonjourName的设置：
 bonjour协议是根据name来定位局域网内部的服务器的。如果不设置，NSLogger会被禁用。
 所以约定如下：
 1，在iMac的NSLogger 查看工具中，进入设置－》Network－》Bonjour Service Name －》设为当前登录的用户帐号。（基于用户帐号一般都是不重复的）
 2，在集成的App中点击Project，选中Project（不是target）－》build setting－》Preprocessor Macros 的 Debug，Release下分别添加宏定义 LOGGER_TARGET=@\"$(USER)\"
 3，在集成的App的 appDelegate 的didFinishLaunchingWithOptions 中加入 configure 调用：
 
 3.1 使用ILSApp配置：
 #if DEBUG
 #define ILS_IS_DEBUG YES
 #else
 #define ILS_IS_DEBUG NO
 #endif
 
 [[ILSAppConfig sharedInstance] configureWithLogBonjourServerName:LOGGER_TARGET
 isDebug:ILS_IS_DEBUG
 disableADs:YES
 shareKitConfig:nil
 userDefaults:nil];
 
 3.2 如果不集成ILSApp，则：
 [[ILSLogger sharedLogger]configureWithLogLevel:ILSLogLevelInfo domainWhiteList:nil bonjourName:LOGGER_TARGET];

 **********************************************************************/

@interface ILSLogger : NSObject
@property (nonatomic, readonly) BOOL logEnabled;

+ (ILSLogger*)sharedLogger;
+ (NSString *)logFileContents;

+ (void) logWithinDomain_va: (NSString *)domain level: (ILSLogLevel) level format: (NSString *)format arguments:(va_list)argList;

// 手动设置
-(void) configureWithLogLevel:(enum ILSLogLevel) logLevel
              domainWhiteList:(NSArray*)domainWhiteList // “domain”白名单，在白名单内的日志，无论是否到达级别都会被显示
                  bonjourName:(NSString*)bonjourName;   // iMac NSLogger 的bonjour服务器名字，约定设定为当前登录用户的用户名，客户端连接时设置为：LOGGER_TARGET，如果为空则禁止 NSLogger

-(void) setNSLoggerViewerHost:(NSString*)hostNameOrIP port:(UInt32)port; // 强行设置NSLogger主机IP以及端口，可以解决bonjour找不到服务器的问题

@end

#ifdef __cplusplus
extern "C" {
#endif
    extern void ILSLogString(NSString *domain, ILSLogLevel level, NSString *format, ...) NS_FORMAT_FUNCTION(3,4);
    
    // Function APIs
    extern void ILSLogImage(NSString *title, UIImage* image);
    extern void ILSLogUIView(NSString *title, UIView* view);
    extern void ILSLogData(NSString *title, NSData* data);
    
    extern void ILSLogFlush();
#ifdef __cplusplus
};
#endif


// Macro APIs
#define ILSLogInfo(domain, ...)     ILSLogString(domain,ILSLogLevelInfo,__VA_ARGS__)
#define ILSLogError(domain, ...)    ILSLogString(domain,ILSLogLevelError,__VA_ARGS__)
#define ILSLogServer(domain, ...)   ILSLogString(domain,ILSLogLevelServer,__VA_ARGS__)

// Override assert
#if defined(DEBUG) && !defined(NDEBUG)
#undef assert
#if __DARWIN_UNIX03
#define assert(e) \
(__builtin_expect(!(e), 0) ? (ILSLogFlush(), __assert_rtn(__func__, __FILE__, __LINE__, #e)) : (void)0)
#else
#define assert(e)  \
(__builtin_expect(!(e), 0) ? (ILSLogFlush(), __assert(#e, __FILE__, __LINE__)) : (void)0)
#endif
#endif
