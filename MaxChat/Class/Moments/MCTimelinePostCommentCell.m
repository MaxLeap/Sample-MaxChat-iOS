//
//  MCTimelinePostCommentCell.m
//  MaxChat
//
//  Created by 周和生 on 16/5/12.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "MCTimelinePostCommentCell.h"
#import "Constants.h"
@import MaxSocial;

#define kTappedUsernameTag @"tappedUser"

@interface MCTimelinePostCommentCell () <TTTAttributedLabelDelegate>
@property (nonatomic, strong) MaxSocialComment *comment;
@end

@implementation MCTimelinePostCommentCell

- (void)awakeFromNib {
    // Initialization code
    self.bgView.backgroundColor = UIColorFromRGB(0xEEEEEC);
    
    self.commentLabel.linkAttributes = @{NSForegroundColorAttributeName : UIColorFromRGB(0x0076FF), NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone), NSFontAttributeName : [UIFont systemFontOfSize:14]};
    self.commentLabel.delegate = self;
    self.commentLabel.inactiveLinkAttributes = self.commentLabel.linkAttributes;
}

- (void)configureCell:(MaxSocialComment *)comment {
    self.comment = comment;

    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:SAFE_STRING(comment.userId) attributes:self.commentLabel.linkAttributes];
    NSString *commentFormatStr = [NSString stringWithFormat:@": %@", comment.content];
    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:commentFormatStr attributes:@{NSForegroundColorAttributeName : kDefaultTextColor, NSFontAttributeName : [UIFont systemFontOfSize:14]}]];
    
    self.commentLabel.attributedText = attrStr;
    if (comment.userId.length) {
        [self.commentLabel addLinkToURL:[NSURL URLWithString:kTappedUsernameTag] withRange:NSMakeRange(0, comment.userId.length)];
    }
}

#pragma mark - TTTttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if ([url.absoluteString isEqualToString:kTappedUsernameTag]) {
        BLOCK_SAFE_ASY_RUN_MainQueue(self.tapUserBlock, self.comment.userId);
    }
}

@end
