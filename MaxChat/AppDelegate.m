//
//  AppDelegate.m
//  MaxChat
//
//  Created by 周和生 on 16/5/3.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "AppDelegate.h"
#import "MCContactsViewController.h"
#import "MCSettingsViewController.h"
#import "MCPersonalViewController.h"
#import "MCRecentChatsViewController.h"
#import "MCMomentsViewController.h"
#import "Constants.h"

#import "WeiboSDK.h"
#import "WXApi.h"
#import "MaxChatIMClient.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "UIImage+Additions.h"

@import MLWeChatUtils;
@import MLWeiboUtils;
@import MLQQUtils;

#define MAXLEAP_APPID           @"572826d0a5ff7f00019a437d"
#define MAXLEAP_CLIENTKEY       @"RjJGZXVCaWJSemFOaEFvYmJCUG41dw"

// 注意要在info.plist中的URL Types中设置
#define WECHAT_APPID            @"wx41b6f4bde79513c8"
#define WECHAT_SECRET           @"d4624c36b6795d1d99dcf0547af5443d"
#define WEIBO_APPKEY            @"2328234403"
#define WEIBO_REDIRECTURL       @"https://api.weibo.com/oauth2/default.html"
#define QQ_APPID                @"222222"


@interface AppDelegate () <WXApiDelegate, WeiboSDKDelegate, TencentSessionDelegate>
@property (nonatomic, strong) UITabBarController *tabBarController;

@end

@implementation AppDelegate

#pragma mark TencentLoginDelegate TencentSessionDelegate

// 以下三个方法保持空实现就可以，MLQQUtils 会置换这三个方法，但是会调用这里的实现

- (void)tencentDidLogin {
    
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    
}

- (void)tencentDidNotNetWork {
    
}

#pragma mark - WeiboSDKDelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    NSLog(@"didReceiveWeiboRequest %@", request);
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        [MLWeiboUtils handleAuthorizeResponse:(WBAuthorizeResponse *)response];
    }
}

#pragma mark WXApiDelegate

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        [MLWeChatUtils handleAuthorizeResponse:(SendAuthResp *)resp];
    } else {
        // 处理其他请求的响应
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    if ([url.absoluteString hasPrefix:@"tencent"]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    if ([url.absoluteString hasPrefix:@"wb"]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    if ([url.absoluteString hasPrefix:@"wx"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([url.absoluteString hasPrefix:@"tencent"]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    if ([url.absoluteString hasPrefix:@"wb"]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    if ([url.absoluteString hasPrefix:@"wx"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    if ([url.absoluteString hasPrefix:@"tencent"]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    if ([url.absoluteString hasPrefix:@"wb"]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    if ([url.absoluteString hasPrefix:@"wx"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    return YES;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    MCMomentsViewController *momentsViewContoller = [[MCMomentsViewController alloc]init];
    UINavigationController *momentsNavigationController = [[UINavigationController alloc]initWithRootViewController:momentsViewContoller];
    momentsNavigationController.tabBarItem = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"朋友圈", nil)
                                                                          image:ImageNamed(@"btn_shop_normal")
                                                                  selectedImage:nil];
    
    MCPersonalViewController *personalViewContoller = [[MCPersonalViewController alloc]init];
    UINavigationController *personalNavigationController = [[UINavigationController alloc]initWithRootViewController:personalViewContoller];
    personalNavigationController.tabBarItem = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"个人信息", nil)
                                                                           image:ImageNamed(@"btn_member_normal")
                                                                   selectedImage:nil];
    
    MCRecentChatsViewController *chattingViewController = [[MCRecentChatsViewController alloc]init];
    UINavigationController *chattingNavigationController = [[UINavigationController alloc]initWithRootViewController:chattingViewController];
    chattingNavigationController.tabBarItem = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"最近聊天", nil)
                                                                           image:ImageNamed(@"btn_support_normal")
                                                                   selectedImage:nil];
    
    MCContactsViewController *contactsViewContoller = [[MCContactsViewController alloc]init];
    UINavigationController *contactsNavigationController = [[UINavigationController alloc]initWithRootViewController:contactsViewContoller];
    contactsNavigationController.tabBarItem = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"联系人", nil)
                                                                           image:ImageNamed(@"btn_forum_normal")
                                                                   selectedImage:nil];
    
    MCSettingsViewController *settingsViewController = [[MCSettingsViewController alloc]init];
    UINavigationController *settingsNavigationController = [[UINavigationController alloc]initWithRootViewController:settingsViewController];
    settingsNavigationController.tabBarItem = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"设置", nil)
                                                                           image:ImageNamed(@"btn_more_normal-1")
                                                                   selectedImage:nil];
    
    self.tabBarController = [[UITabBarController alloc]init];
    self.tabBarController.viewControllers = @[personalNavigationController, contactsNavigationController, chattingNavigationController, momentsNavigationController,settingsNavigationController];
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    [MaxLeap setApplicationId:MAXLEAP_APPID clientKey:MAXLEAP_CLIENTKEY site:MLSiteCN];
    
    [MLWeChatUtils initializeWeChatWithAppId:WECHAT_APPID appSecret:WECHAT_SECRET wxDelegate:self];
    [MLWeiboUtils initializeWeiboWithAppKey:WEIBO_APPKEY redirectURI:WEIBO_REDIRECTURL];
    [MLQQUtils initializeQQWithAppId:QQ_APPID qqDelegate:self];

    [self configureGlobalAppearance];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateChats:) name:kRecentChatsUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(maxLeapDidLogout:) name:kMaxLeapDidLogoutNofitification object:nil];
    [MaxChatIMClient sharedInstance];
    
    return YES;
}
- (void)maxLeapDidLogout:(id)sender {
    self.tabBarController.tabBar.items[2].badgeValue = nil;
}


- (void)updateChats:(id)sender {
    self.tabBarController.tabBar.items[2].badgeValue = [MaxChatIMClient sharedInstance].recentChats.count ? [NSString stringWithFormat:@"%ld", (long)[MaxChatIMClient sharedInstance].recentChats.count] :nil;
}

- (void)configureGlobalAppearance {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [UITabBarItem.appearance setTitleTextAttributes:@{NSForegroundColorAttributeName : kTextColor,
                                                      NSFontAttributeName : [UIFont systemFontOfSize:10]}
                                           forState:UIControlStateNormal];
    [UITabBarItem.appearance setTitleTextAttributes:@{NSForegroundColorAttributeName : kNavigationBGColor,
                                                      NSFontAttributeName : [UIFont systemFontOfSize:10]}
                                           forState:UIControlStateSelected];
    
    UIImage *barLineImage = [UIImage imageWithColor:[UIColor clearColor]];
    UIImage *barBGImage = [UIImage imageWithColor:kNavigationBGColor];
    [[UINavigationBar appearance] setBackgroundImage:barBGImage forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:barLineImage];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                           NSFontAttributeName : [UIFont systemFontOfSize:17]}];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                           NSFontAttributeName : [UIFont systemFontOfSize:17]}
                                                forState:UIControlStateNormal];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITableViewHeaderFooterView appearance] setTintColor:kSeparatorLineColor];
    
    [[UITabBar appearance] setTintColor:kNavigationBGColor];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
