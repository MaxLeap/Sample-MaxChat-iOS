//
//  MCLotteryCommentImageCell.m
//  MaxChat
//
//  Created by 周和生 on 16/5/11.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "MCLotteryCommentImageCell.h"
#import "Constants.h"


@implementation MCLotteryCommentImageCell

- (IBAction)deleteButtonPressed:(id)sender {
    BLOCK_SAFE_ASY_RUN_MainQueue(self.removeImageBlock);
}

@end
