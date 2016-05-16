//
//  ChattingViewController.h
//  MaxChat
//
//  Created by 周和生 on 16/5/3.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCRecentChatsViewController : UIViewController

@end


@interface MCChatCell : UITableViewCell
- (void)configWithChat:(id)chat;
@end