//
//  MCTimelineTextTableViewCell.h
//  MaxChat
//
//  Created by 周和生 on 16/5/10.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCTimelineTextTableViewCell : UITableViewCell

@property (nonatomic, copy) void(^tapUserBlock)(id timelineUser);
- (void)configureCell: (MaxSocialShuoShuo *)shuoshuo;

@end
