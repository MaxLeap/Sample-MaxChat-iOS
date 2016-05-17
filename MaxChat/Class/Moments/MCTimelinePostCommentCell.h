//
//  MCTimelinePostCommentCell.h
//  MaxChat
//
//  Created by 周和生 on 16/5/12.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import <UIKit/UIKit.h>
@import TTTAttributedLabel;
@import MaxSocial;


@interface MCTimelinePostCommentCell : UITableViewCell
@property (nonatomic, copy) void(^tapUserBlock)(NSString *timelineUser);

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *commentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentLabelBottomConstraint;

- (void)configureCell:(MaxSocialComment *)comment;
@end
