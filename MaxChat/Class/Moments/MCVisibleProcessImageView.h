//
//  MFLMCustomImageView.h
//  LikedMe
//
//  Created by Jun Xia on 15/10/17.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCVisibleProcessImageView : UIView
@property (nonatomic, strong) UIImage *image;
- (void)setImageWithURL:(NSURL *)imageURL withPlaceHolderImage:(UIImage *)placeHolderImage;
- (void)cancelCurrentImageLoad;
@end

@interface MFLMProgressIndicator : UIView
@property (nonatomic, assign) float progress;
@end