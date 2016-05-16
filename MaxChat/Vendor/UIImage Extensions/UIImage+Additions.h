//
//  UIImage+Additions.h
//  VideoDownloader
//
//  Created by Jin Sun on 13-1-15.
//  Copyright (c) 2013年 Jin Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(UIImage_Additions)

+ (UIImage *)pngImageInBundleNamed:(NSString *)imageName;
- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;
- (UIImage *)fixOrientation;


- (UIImage *)croppedImage:(CGRect)bounds;
+ (UIImage *)ipMaskedImage:(UIImage *)image color:(UIColor *)color;
- (UIImage *)imageScaleAspectToMaxSize:(CGFloat)newSize;
+ (UIImage *)imageWithColor:(UIColor *)color;


+ (CGSize)getImageSize:(UIImage *)image;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
