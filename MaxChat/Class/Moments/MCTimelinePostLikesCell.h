//
//  MCTimelinePostLikesCell.h
//  MaxChat
//
//  Created by 周和生 on 16/5/12.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaxSocialRemoteShuoShuo.h"

@interface MCTimelinePostLikesCell : UITableViewCell
@property (nonatomic, copy) void(^tapUserBlock)(NSString *timelineUser);

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *likesLabelBottomConstraint;

- (void)configureCell:(MaxSocialRemoteShuoShuo *)shuoshuo;
@end

