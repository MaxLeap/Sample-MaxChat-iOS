//
//  MCTimelinePostsListViewController.h
//  MaxChat
//
//  Created by 周和生 on 16/5/10.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface MCTimelinePostsListViewController : UIViewController

// isSquare YES：表示广场，NO：其他
@property (nonatomic, assign) BOOL isSquare;
// isCycle YES：朋友圈 NO：timelineUser的发帖
@property (nonatomic, assign) BOOL isCycle;
// timelineUser未设置，则使用MaxLeapSignedUserId
@property (nonatomic, strong) NSString *timelineUser;

- (void)triggerPullToRefresh;
- (void)hideCommentToolBarView;
@end