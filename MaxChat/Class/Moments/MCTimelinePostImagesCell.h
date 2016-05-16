//
//  MCTimelinePostImagesCell.h
//  MaxChat
//
//  Created by 周和生 on 16/5/10.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMaxNumberOfImagesPerRow   3
#define kCollectionViewRightMargin 60
#define kCollectionViewLeftMargin  63

@interface MCTimelinePostImagesCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
- (void)configureCell:(MaxSocialShuoShuo *)shuoshuo;

@end
