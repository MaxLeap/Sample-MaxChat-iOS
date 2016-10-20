//
//  MCTimelinePostActionCell.m
//  MaxChat
//
//  Created by 周和生 on 16/5/10.
//  Copyright © 2016年 zhouhs. All rights reserved.
//
#import "Constants.h"
#import "MCTimelinePostActionCell.h"
#import "NSDate+Extension.h"
@import MaxLeap;

@interface MCTimelinePostActionCell ()
@property (weak, nonatomic) IBOutlet UILabel *postTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *deletePostButton;

@property (weak, nonatomic) IBOutlet UIView *actionBgView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet UIView *separatorLine1;
@property (weak, nonatomic) IBOutlet UIView *separatorLine2;

@property (nonatomic, strong) MaxSocialRemoteShuoShuo *shuoshuo;
@end

@implementation MCTimelinePostActionCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.postTimeLabel.textColor = kDefaultGrayColor;
    
    self.postTimeLabel.text = @"刚刚";
    [self.actionButton setImage:ImageNamed(@"btn_timeline_comments") forState:UIControlStateNormal];
    
    [self.deletePostButton setTitle:@"删除" forState:UIControlStateNormal];
    
    self.actionBgView.backgroundColor = UIColorFromRGB(0x505050);
    self.actionBgView.layer.cornerRadius = 4;
    self.actionBgView.layer.masksToBounds = YES;
    
    [self.likeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.commentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.likeButton setTitle:@"赞" forState:UIControlStateNormal];
    self.likeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.likeButton setImage:ImageNamed(@"ic_share white") forState:UIControlStateNormal];
    self.likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8);
    
    [self.commentButton setTitle:@"评论" forState:UIControlStateNormal];
    self.commentButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.commentButton setImage:ImageNamed(@"ic_timeline_comments") forState:UIControlStateNormal];
    self.commentButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8);
    
    [self.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    self.deleteButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.deleteButton setImage:ImageNamed(@"btn_delete_normal") forState:UIControlStateNormal];
    self.deleteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8);
    
    self.separatorLine1.backgroundColor = UIColorFromRGB(0x979797);
    self.separatorLine2.backgroundColor = UIColorFromRGB(0x979797);
    
    self.actionBgView.hidden = YES;
}

- (void)hideActionPanel {
    self.actionBgView.hidden = YES;
}

- (void)updateDeleteButtonStatus {
    self.deletePostButton.hidden = ![self.shuoshuo.userId isEqualToString:MaxLeapSignedUserId];
    
    self.actionBgViewWidthConstraint.constant = 140;
    self.deleteButton.hidden = YES;
    self.separatorLine2.hidden = YES;
    
    //actionPanel上不显示deleteButton
    if (![self.shuoshuo.userId isEqualToString:MaxLeapSignedUserId]) {
        self.actionBgViewWidthConstraint.constant = 140;
        self.deleteButton.hidden = YES;
        self.separatorLine2.hidden = YES;
        
    } else {
        self.actionBgViewWidthConstraint.constant = 210;
        self.deleteButton.hidden = NO;
        self.separatorLine2.hidden = NO;
    }
}

- (void)configureCell: (MaxSocialRemoteShuoShuo *)shuoshuo {
    self.shuoshuo = shuoshuo;
    
    self.postTimeLabel.text = shuoshuo.createdAt.timeAgo;
    BOOL isLikedAlready = [[self.shuoshuo.zans valueForKeyPath:@"userId"] containsObject:MaxLeapSignedUserId];
    NSString *likeBtnText = isLikedAlready ? @"取消" : @"赞";
    [self.likeButton setTitle:likeBtnText forState:UIControlStateNormal];
    
    [self updateDeleteButtonStatus];
}

#pragma mark - Action
- (IBAction)deletePostButtonPressed:(id)sender {
    BLOCK_SAFE_ASY_RUN_MainQueue(self.deleteActionBlock);
}


//actionPanel button
- (IBAction)actionButtonPressed:(id)sender {
    [self updateDeleteButtonStatus];
    
    if (self.actionBgView.hidden) {
        self.actionBgView.hidden = NO;
        CGRect originalFrame = self.actionBgView.frame;
        CGRect initialFrame = originalFrame;
        initialFrame.origin.x = originalFrame.origin.x + originalFrame.size.width;
        initialFrame.size.width = 0;
        
        self.actionBgView.frame = initialFrame;
        [UIView animateWithDuration:0.5 animations:^{
            self.actionBgView.frame = originalFrame;
        }];
        
    } else {
        
        [self hideActionPanel];
    }
    BLOCK_SAFE_ASY_RUN_MainQueue(self.actionButtonHandler);
}

- (IBAction)likeButtonPressed:(id)sender {
    BLOCK_SAFE_ASY_RUN_MainQueue(self.likeActionBlock);
}

- (IBAction)commentButtonPressed:(id)sender {
    BLOCK_SAFE_ASY_RUN_MainQueue(self.commentActionBlock);
}

- (IBAction)deleteButtonPressed:(id)sender {
    BLOCK_SAFE_ASY_RUN_MainQueue(self.deleteActionBlock);
}

@end
