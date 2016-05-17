//
//  MCTimelinePostImagesCell.m
//  MaxChat
//
//  Created by 周和生 on 16/5/10.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "MCTimelinePostImagesCell.h"
#import "MCPhotoBroswer.h"
#import "MCTimelinePostImagesCollectionViewCell.h"
#import "Constants.h"
@import SDWebImage;
@import MaxSocial;

@interface MCTimelinePostImagesCell () <UICollectionViewDelegate, UICollectionViewDataSource,
MCPhotoBroswerDataSource,
MCPhotoBroswerDelegate>

@property (strong, nonatomic) MCPhotoBroswer *imagePreviewView;
@property (nonatomic, strong) MaxSocialShuoShuo *shuoshuo;

@end

@implementation MCTimelinePostImagesCell
- (void)awakeFromNib {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.scrollsToTop = NO;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"MCTimelinePostImagesCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"MCTimelinePostImagesCollectionViewCell"];
}

- (void)configureCell:(MaxSocialShuoShuo *)shuoshuo {
    self.shuoshuo = shuoshuo;
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.shuoshuo.content.imageNames.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([self imageCellWidth], [self imageCellWidth]);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MCTimelinePostImagesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MCTimelinePostImagesCollectionViewCell" forIndexPath:indexPath];
    NSURL *imageUrl = [NSURL URLWithString: self.shuoshuo.content.imageNames[indexPath.row]];
    [cell.imageView sd_setImageWithURL:imageUrl
                      placeholderImage:ImageNamed(@"ic_item_detail_default")
                               options:SDWebImageRetryFailed completed:nil];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MCTimelinePostImagesCollectionViewCell *cell = (MCTimelinePostImagesCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    CGRect relativeFrame = [self frameInRootViewForCellAtIndexPath:indexPath];
    [self.imagePreviewView showImage:cell.imageView.image originPage:indexPath.row originLocation:relativeFrame];
}

#pragma mark - Action

#pragma mark MFLMImagePreviewViewDataSource
- (NSUInteger)numberOfPhotoInPhotoBroswer:(MCPhotoBroswer *)photoBroswer {
    return self.shuoshuo.content.imageNames.count;
}

- (NSURL *)imagePreviewView:(MCPhotoBroswer *)imagePreviewView imageURLAtIndex:(NSUInteger)index {
   
    return [NSURL URLWithString: self.shuoshuo.content.imageNames[index]];
}

- (UIImage *)photoBroswer:(MCPhotoBroswer *)photoBroswer thumbnieImageAtIndex:(NSUInteger)index {

    UIImage *thumbnieImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:self.shuoshuo.content.imageNames[index]];
    return thumbnieImage;
}

//#pragma mark MFLMImagePreviewDelegate
- (CGRect)finalDismissFrameAtPage:(NSUInteger)page inPhotoBroswer:(MCPhotoBroswer *)photoBroswer {
    CGRect frame = [self frameInRootViewForCellAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0]];
    return frame;
}

- (void)photoBroswer:(MCPhotoBroswer *)photoBroswer didShowPhotoAtIndex:(NSUInteger)page {
}

- (void)photoBroswer:(MCPhotoBroswer *)photoBroswer willExitPhotoAtIndex:(NSUInteger)index {
    
}

- (void)photoBroswer:(MCPhotoBroswer *)photoBroswer didDismissPhotoAtIndex:(NSUInteger)index {
    
}

#pragma mark - Getter/Setter
- (MCPhotoBroswer *)imagePreviewView {
    if (!_imagePreviewView) {
        _imagePreviewView = [MCPhotoBroswer new];
        _imagePreviewView.delegate = self;
        _imagePreviewView.dataSource = self;
    }
    
    return _imagePreviewView;
}

#pragma mark - Helper methods
- (CGFloat)imageCellWidth {
    NSUInteger imageCount = kMaxNumberOfImagesPerRow;
    CGFloat collectionViewWidth = self.bounds.size.width - 63 - kCollectionViewRightMargin;
    return collectionViewWidth / imageCount;
}

- (CGRect)frameInRootViewForCellAtIndexPath:(NSIndexPath *)indexPath {
    MCTimelinePostImagesCollectionViewCell *cell = (MCTimelinePostImagesCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    CGRect cellFrameInRootView = [cell convertRect:cell.imageView.frame toView:[UIApplication sharedApplication].keyWindow];
    return cellFrameInRootView;
}

#pragma mark - Private Methods

@end
