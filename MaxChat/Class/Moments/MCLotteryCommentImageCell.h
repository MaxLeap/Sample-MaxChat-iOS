//
//  MCLotteryCommentImageCell.h
//  MaxChat
//
//  Created by 周和生 on 16/5/11.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kLotteryCommentImageCellHeight  65

@interface MCLotteryCommentImageCell : UICollectionViewCell
@property (nonatomic, copy) dispatch_block_t removeImageBlock;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end
