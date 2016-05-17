//
//  MaxChatIMClient.h
//  MaxChat
//
//  Created by 周和生 on 16/5/4.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MaxIMLib;

@interface MaxChatIMClient : NSObject

+ (MaxChatIMClient*)sharedInstance;

@property (nonatomic, strong) MLIMClient *client;

// 最近聊天： MLIMFriendInfo or MLIMGroup
@property (nonatomic, strong) NSMutableArray *recentChats;

- (void)loginWithCurrentuserCompletion:(MLIMBooleanResultBlock)completion;

- (void)pushMessagesControllerForFriend:(MLIMFriendInfo *)aFriend withNavigator:(UINavigationController *)navigator;
- (void)pushMessagesControllerForGroup:(MLIMGroup *)aGroup withNavigator:(UINavigationController *)navigator;
@end
