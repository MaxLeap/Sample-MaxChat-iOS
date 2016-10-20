//
//  MCTimelineTextTableViewCell.m
//  MaxChat
//
//  Created by 周和生 on 16/5/10.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "MCTimelineTextTableViewCell.h"
#import "Constants.h"
@import TTTAttributedLabel;
@import SDWebImage;



#define kUserNameLinkTag   @"timeline_Username"

@interface MCTimelineTextTableViewCell () <TTTAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentTextLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTextLabelBottomConstraint;


@property (nonatomic, strong) MaxSocialShuoShuo *shuoshuo;

@end

@implementation MCTimelineTextTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.iconImageView.layer.cornerRadius = self.iconImageView.bounds.size.width / 2;
    self.iconImageView.layer.masksToBounds = YES;
    self.commentTextLabel.textColor = [UIColor darkTextColor];
    
    self.iconImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedUserIcon:)];
    [self.iconImageView addGestureRecognizer:tap];
    
    self.authorNameLabel.linkAttributes = @{NSForegroundColorAttributeName : UIColorFromRGB(0x0076FF), NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone), NSFontAttributeName : [UIFont systemFontOfSize:14]};
    self.authorNameLabel.delegate = self;
    self.authorNameLabel.inactiveLinkAttributes = self.authorNameLabel.linkAttributes;
}

- (void)configureCell:(MaxSocialShuoShuo *)shuoshuo {
    self.shuoshuo = shuoshuo;
    
    self.commentTextLabel.text = (shuoshuo.content.text.length>0) ?shuoshuo.content.text: @" ";
    self.authorNameLabel.text = shuoshuo.userId ?: @" ";
    
    // author url
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:@""]
                          placeholderImage:ImageNamed(@"ic_timeline_userhead")
                                   options:SDWebImageRetryFailed];
    
    self.authorNameLabel.attributedText = [[NSAttributedString alloc] initWithString:self.authorNameLabel.text
                                                                          attributes:self.authorNameLabel.linkAttributes];
    NSRange userNameRange = [shuoshuo.userId rangeOfString:shuoshuo.userId];
    [self.authorNameLabel addLinkToURL:[NSURL URLWithString:kUserNameLinkTag] withRange:userNameRange];
    
    self.contentTextLabelBottomConstraint.constant = shuoshuo.content.imageURLs.count == 0 ? 0 : 8;
}

#pragma mark - Action
- (void)tappedUserIcon:(id)sender {
    BLOCK_SAFE_ASY_RUN_MainQueue(self.tapUserBlock, self.shuoshuo.userId);
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if ([url.absoluteString isEqualToString:kUserNameLinkTag]) {
        BLOCK_SAFE_ASY_RUN_MainQueue(self.tapUserBlock, self.shuoshuo.userId);
    }
}

@end
