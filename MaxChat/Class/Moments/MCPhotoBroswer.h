//
//  MFLMImagePreviewView.h
//  LikedMe
//
//  Created by Jun Xia on 15/10/17.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCPhotoBroswer;

@protocol MCPhotoBroswerDataSource <NSObject>
- (NSUInteger)numberOfPhotoInPhotoBroswer:(MCPhotoBroswer *)photoBroswer;
- (UIImage *)photoBroswer:(MCPhotoBroswer *)photoBroswer thumbnieImageAtIndex:(NSUInteger)index;

@optional
- (NSURL *)imagePreviewView:(MCPhotoBroswer *)imagePreviewView imageURLAtIndex:(NSUInteger)index;
@end

@protocol MCPhotoBroswerDelegate <NSObject>
- (CGRect)finalDismissFrameAtPage:(NSUInteger)page inPhotoBroswer:(MCPhotoBroswer *)photoBroswer;
- (void)photoBroswer:(MCPhotoBroswer *)photoBroswer didShowPhotoAtIndex:(NSUInteger)index;
- (void)photoBroswer:(MCPhotoBroswer *)photoBroswer didDismissPhotoAtIndex:(NSUInteger)index;
- (void)photoBroswer:(MCPhotoBroswer *)photoBroswer willExitPhotoAtIndex:(NSUInteger)index;
@end

@interface MCPhotoBroswer : UIView
@property (nonatomic, strong) id<MCPhotoBroswerDataSource> dataSource;
@property (nonatomic, strong) id<MCPhotoBroswerDelegate> delegate;
@property (nonatomic, assign, readonly) NSUInteger page;

- (void)showImage:(UIImage *)image originPage:(NSUInteger)page originLocation:(CGRect)originImageLocation;
@end
