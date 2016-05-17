//
//  MCTimelinePostLikesCell.m
//  MaxChat
//
//  Created by 周和生 on 16/5/12.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "MCTimelinePostLikesCell.h"
#import "Constants.h"
@import TTTAttributedLabel;


@interface MCTimelinePostLikesCell () <TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *likeIconImageView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *userNamesLabel;

@end

@implementation MCTimelinePostLikesCell

- (void)awakeFromNib {
    self.bgView.backgroundColor = UIColorFromRGB(0xEEEEEC);
    self.likeIconImageView.image = ImageNamed(@"ic_share_ blue");
    
    self.userNamesLabel.linkAttributes = @{NSForegroundColorAttributeName : UIColorFromRGB(0x0076FF), NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone), NSFontAttributeName : [UIFont systemFontOfSize:14]};
    self.userNamesLabel.inactiveLinkAttributes = self.userNamesLabel.linkAttributes;
    self.userNamesLabel.delegate = self;
}

- (void)configureCell:(MaxSocialRemoteShuoShuo *)shuoshuo {
    
    NSMutableAttributedString *namesAttrStr = [[NSMutableAttributedString alloc] init];
    [shuoshuo.zans enumerateObjectsUsingBlock:^(MaxSocialComment *like, NSUInteger idx, BOOL * _Nonnull stop) {
        NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:SAFE_STRING(like.userId) attributes:self.userNamesLabel.linkAttributes];
        [namesAttrStr appendAttributedString:nameStr];
        
        if (idx < shuoshuo.zans.count - 1) {
            [namesAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:@", " attributes:self.userNamesLabel.linkAttributes]];
        }
    }];
    self.userNamesLabel.attributedText = namesAttrStr;
    
    //add links
    NSMutableString *str = [[NSMutableString alloc] init];
    [shuoshuo.zans enumerateObjectsUsingBlock:^(MaxSocialComment *like, NSUInteger idx, BOOL * _Nonnull stop) {
        if (like.userId.length > 0) {
            NSRange currentNameStrRange = NSMakeRange(str.length, like.userId.length);
            [self.userNamesLabel addLinkToURL:[NSURL URLWithString:like.userId] withRange:currentNameStrRange];
            
            [str appendString:SAFE_STRING(like.userId)];
            if (idx < shuoshuo.zans.count - 1) {
                [str appendString:@", "];
            }
        }
    }];
}

#pragma mark - TTTttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    NSString *timelineUserMemId = url.absoluteString;
    BLOCK_SAFE_ASY_RUN_MainQueue(self.tapUserBlock, timelineUserMemId);
}

@end
