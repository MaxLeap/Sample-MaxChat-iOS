//
//  MCTimelinePostActionCell.h
//  MaxChat
//
//  Created by 周和生 on 16/5/10.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaxSocialRemoteShuoShuo.h"

@interface MCTimelinePostActionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@property (nonatomic, copy) dispatch_block_t actionButtonHandler;
@property (nonatomic, copy) dispatch_block_t likeActionBlock;
@property (nonatomic, copy) dispatch_block_t commentActionBlock;
@property (nonatomic, copy) dispatch_block_t deleteActionBlock;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionBgViewWidthConstraint;

- (void)configureCell: (MaxSocialRemoteShuoShuo *)shuoshuo;
- (void)hideActionPanel;
@end
