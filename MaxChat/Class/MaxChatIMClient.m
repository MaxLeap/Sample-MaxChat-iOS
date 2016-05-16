//
//  MaxChatIMClient.m
//  MaxChat
//
//  Created by 周和生 on 16/5/4.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "MaxChatIMClient.h"
#import "MCMessagesViewController.h"
#import "MCMessagesModelData.h"


@implementation MLIMFriendInfo(isEqual)
- (BOOL)isEqual:(id)obj {
    if ([obj isKindOfClass:[MLIMFriendInfo class]]) {
        return [self.uid isEqualToString:[obj uid]];
    } else {
        return NO;
    }
}
@end

@implementation MLIMGroup(isEqual)
- (BOOL)isEqual:(id)obj {
    if ([obj isKindOfClass:[MLIMGroup class]]) {
        return [self.groupId isEqualToString:[obj groupId]];
    } else {
        return NO;
    }
}
@end

@interface MaxChatIMClient() <MLIMClientDelegate>

@property (nonatomic, strong) MCMessagesViewController *currentMessagesViewController;
@property (nonatomic, strong) MCMessagesModelData *currentMessagesData;
@property (nonatomic, strong) id currentMessagesReceiver;

@end

@implementation MaxChatIMClient

+ (MaxChatIMClient*)sharedInstance
{
    static MaxChatIMClient* sharedInstance = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        // 客户端配置
        MLIMClientConfiguration *configuration = [MLIMClientConfiguration defaultConfiguration];
        
        // 必选配置
        configuration.appId = MAXLEAP_APPID;
        configuration.clientKey = MAXLEAP_CLIENTKEY;
        
        // 断线重连设置
        configuration.autoReconnect = YES;
        configuration.reconnectAttempts = 3; // 重连次数
        configuration.reconnectWait = 3; // 断线后重连等待时间
        
        // 可选配置，如果不配置 installationId，将不会收到离线消息推送
        configuration.installationId = [MLInstallation currentInstallation].installationId;
        self.client = [MLIMClient clientWithConfiguration:configuration];
        self.client.delegate = self;
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(maxLeapDidLogin:) name:kMaxLeapDidLoginNofitification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(maxLeapDidLogout:) name:kMaxLeapDidLogoutNofitification object:nil];
    }
    
    return self;
}

- (void)maxLeapDidLogin:(id)sender {
    [self loginWithCurrentuserCompletion:nil];
}

- (void)maxLeapDidLogout:(id)sender {
    self.recentChats = nil;
    [self.client logoutWithCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"MaxChatIMClient logout");
    }];
}

- (void)loginWithCurrentuserCompletion:(MLIMBooleanResultBlock)completion {
    MLUser *currentUser = [MLUser currentUser];
    if (currentUser) {
        if ([MLAnonymousUtils isLinkedWithUser:currentUser]) {
            // 匿名登录
            if (completion) {
                completion(NO, nil);
            }
            
        } else {
            // 常规登录
            [self.client loginWithUserId:currentUser.username
                              completion:^(BOOL succeeded, NSError * _Nullable error) {
                                  if (succeeded) {
                                      NSLog(@"MaxChatIMClient login SUCCESS");
                                  } else {
                                      NSLog(@"MaxChatIMClient login ERROR %@", error);
                                  }
                                  
                                  [self.client.currentUser fetchAttributesWithCompletion:^(NSDictionary * _Nullable attrs, NSError * _Nullable error) {
                                      if (!error) {
                                          NSLog(@"IMClient attributes %@", attrs);
                                          NSMutableDictionary *attribute = [NSMutableDictionary dictionaryWithDictionary:attrs];
                                          attribute[@"iconUrl"] = [[MLUser currentUser] objectForKey:@"iconUrl"];
                                          attribute[@"mobilePhone"] = [[MLUser currentUser] objectForKey:@"mobilePhone"];
                                          attribute[@"nickName"] = [[MLUser currentUser] objectForKey:@"nickName"];
                                          attribute[@"email"] = [[MLUser currentUser] objectForKey:@"email"];
                                          [self.client.currentUser updateAttributes:attribute
                                                                         completion:^(BOOL success, NSError * _Nullable error) {
                                                                             NSLog(@"IM currentUser updateAttributes success %ld error %@", (long)success, error);
                                                                             if (completion) {
                                                                                 completion(succeeded, error);
                                                                             }
                                                                         }];
                                      }
                                  }];
                              }];
        }
    } else {
        if (completion) {
            completion(NO, nil);
        }
    }
}

- (void)updateRecentChats:(id)chat {
    if (self.recentChats==nil) {
        self.recentChats = [NSMutableArray array];
    }
    
    [self.recentChats enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual:chat]) {
            [self.recentChats removeObjectIdenticalTo:obj];
            *stop = YES;
        }
    }];
    
    [self.recentChats insertObject:chat atIndex:0];
    [[NSNotificationCenter defaultCenter]postNotificationName:kRecentChatsUpdatedNotification object:nil];
}


- (void)pushMessagesControllerForFriend:(MLIMFriendInfo *)aFriend withNavigator:(UINavigationController *)navigator {
    self.currentMessagesReceiver = aFriend;
    self.currentMessagesData = [[MCMessagesModelData alloc] initWithFriend:aFriend];
    
    self.currentMessagesViewController = [MCMessagesViewController messagesViewController];
    self.currentMessagesViewController.hidesBottomBarWhenPushed = YES;
    
    self.currentMessagesViewController.title = aFriend.uid;
    
    self.currentMessagesViewController.messageModel = self.currentMessagesData;
    self.currentMessagesData.messagesController = self.currentMessagesViewController;
    
    [navigator pushViewController:self.currentMessagesViewController animated:YES];
    [self updateRecentChats:aFriend];
}

- (void)pushMessagesControllerForGroup:(MLIMGroup *)aGroup withNavigator:(UINavigationController *)navigator {
    self.currentMessagesReceiver = aGroup;
    self.currentMessagesData = [[MCMessagesModelData alloc] initWithGroup:aGroup];
    
    self.currentMessagesViewController = [MCMessagesViewController messagesViewController];
    self.currentMessagesViewController.hidesBottomBarWhenPushed = YES;
    
    self.currentMessagesViewController.title = aGroup.name;
    
    self.currentMessagesViewController.messageModel = self.currentMessagesData;
    self.currentMessagesData.messagesController = self.currentMessagesViewController;
    
    [navigator pushViewController:self.currentMessagesViewController animated:YES];
    [self updateRecentChats:aGroup];
}



#pragma mark - MLIMClientDelegate

/**
 *  Called when connection broken.
 *
 *  @param client The client object that disconnect.
 */
- (void)clientDidDisconnect:(MLIMClient *)client {
    NSLog(@"clientDidDisconnect %@", client);
}

/**
 *  Called when client reconnect.
 *
 *  @param client The client object that attempts to reconnect.
 */
- (void)clientAttemptReconnect:(MLIMClient *)client {
    NSLog(@"clientAttemptReconnect %@", client);
}

/**
 *  Called when user login success.
 *
 *  @param client The client object that login success.
 */
- (void)clientDidLogin:(MLIMClient *)client {
    NSLog(@"clientDidLogin %@", client);
}

/**
 *  Called when user logout.
 *
 *  @param client The client object that logout.
 */
- (void)clientDidLogout:(MLIMClient *)client {
    NSLog(@"clientDidLogout %@", client);
}

/**
 *  Called when receive a message from friend or message send to friend by your other clients.
 *
 *  @param client  The client that received message.
 *  @param message The message received.
 *  @param aFriend The message sender.
 */
- (void)client:(MLIMClient *)client didReceiveMessage:(MLIMMessage *)message fromFriend:(MLIMFriendInfo *)aFriend {
    [self updateRecentChats:aFriend];
    
    if ([self.currentMessagesReceiver isKindOfClass:[MLIMFriendInfo class]]) {
        MLIMFriendInfo *currentFriend = (MLIMFriendInfo *)self.currentMessagesReceiver;
        if ([currentFriend.uid isEqualToString:aFriend.uid]) {
            [self.currentMessagesData receiveMessage:message];
            [self.currentMessagesViewController finishReceivingMessageAnimated:YES];
        }
    }
}

/**
 *  Called when receive a message from group or message send to group by your other clients.
 *
 *  @param client  The client that received message.
 *  @param message The message received
 *  @param group   The group that message belongs to.
 */
- (void)client:(MLIMClient *)client didReceiveMessage:(MLIMMessage *)message fromGroup:(MLIMGroup *)group {
    [self updateRecentChats:group];
    
    if ([self.currentMessagesReceiver isKindOfClass:[MLIMGroup class]]) {
        MLIMGroup *currentGroup = (MLIMGroup *)self.currentMessagesReceiver;
        if ([currentGroup.groupId isEqualToString:group.groupId]) {
            [self.currentMessagesData receiveMessage:message];
            [self.currentMessagesViewController finishReceivingMessageAnimated:YES];
        }
    }
}

/**
 *  Called when receive a message from room or message send to room by your other clients.
 *
 *  @param client  The client that received message.
 *  @param message The message received.
 *  @param room    The room that message belongs to.
 */
- (void)client:(MLIMClient *)client didReceiveMessage:(MLIMMessage *)message fromRoom:(MLIMRoom *)room {
    
}

/**
 *  Called when receive a message from system.
 *
 *  @param client  The client that received message
 *  @param message The message received
 */
- (void)client:(MLIMClient *)client didReceiveSystemMessage:(MLIMMessage *)message {
    NSLog(@"MLIMClient didReceiveSystemMessage %@", message);
}

/**
 *  Called when a friend online.
 *
 *  @param client  The client
 *  @param aFriend The friend online.
 */
- (void)client:(MLIMClient *)client friendDidOnline:(MLIMFriendInfo *)aFriend {
    NSLog(@"friendDidOnline %@", aFriend);
}

/**
 *  Called when a friend offline
 *
 *  @param client  The client
 *  @param aFriend The friend offline.
 */
- (void)client:(MLIMClient *)client friendDidOffline:(MLIMFriendInfo *)aFriend {
    NSLog(@"friendDidOffline %@", aFriend);
}

@end
