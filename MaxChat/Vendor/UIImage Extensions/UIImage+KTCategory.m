//
//  UIImageAdditions.m
//
//  Created by Kirby Turner on 2/7/10.
//  Updated by Linc YIM on 5/13/13.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import "UIImage+KTCategory.h"

@implementation UIImage (KTCategory)

- (UIImage *)imageScaleAspectToMaxSize:(CGFloat)newSize {
   CGSize size = [self size];
   CGFloat ratio;
   if (size.width > size.height) {
      ratio = newSize / size.width;
   } else {
      ratio = newSize / size.height;
   }
   
   CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
    CGSize resize = rect.size;
    resize.width *= [UIScreen mainScreen].scale;
    resize.height *= [UIScreen mainScreen].scale;
    rect.size = resize;
   UIGraphicsBeginImageContext(rect.size);
   [self drawInRect:rect];
   UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
   return scaledImage;
}


- (UIImage *)imageScaleAndCropToMaxSize:(CGSize)newSize {
   CGFloat largestSize = (newSize.width > newSize.height) ? newSize.width : newSize.height;
   CGSize imageSize = [self size];
   
   // Scale the image while mainting the aspect and making sure the 
   // the scaled image is not smaller then the given new size. In
   // other words we calculate the aspect ratio using the largest
   // dimension from the new size and the small dimension from the
   // actual size.
   CGFloat ratio;
   if (imageSize.width > imageSize.height) {
      ratio = largestSize / imageSize.height;
   } else {
      ratio = largestSize / imageSize.width;
   }
   
   CGRect rect = CGRectMake(0.0, 0.0, ratio * imageSize.width, ratio * imageSize.height);
    CGSize size = rect.size;
    size.width *= [UIScreen mainScreen].scale;
    size.height *= [UIScreen mainScreen].scale;
    rect.size = size;
    UIGraphicsBeginImageContext(size);
   [self drawInRect:rect];
   UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
   
   // Crop the image to the requested new size maintaining
   // the inner most parts of the image.
   CGFloat offsetX = 0;
   CGFloat offsetY = 0;
   imageSize = [scaledImage size];
   if (imageSize.width < imageSize.height) {
      offsetY = (imageSize.height / 2) - (imageSize.width / 2);
   } else {
      offsetX = (imageSize.width / 2) - (imageSize.height / 2);
   }
   
   CGRect cropRect = CGRectMake(offsetX, offsetY,
                                imageSize.width - (offsetX * 2),
                                imageSize.height - (offsetY * 2));
   
   CGImageRef croppedImageRef = CGImageCreateWithImageInRect([scaledImage CGImage], cropRect);
   UIImage *newImage = [UIImage imageWithCGImage:croppedImageRef];
   CGImageRelease(croppedImageRef);
   return newImage;
}


- (UIImage *)imageScaleAndCropToConstrainedSize:(CGSize)newSize {
    CGSize imageSize = [self size];
    // Scale the image while mainting the aspect and making sure the
    // the scaled image is not smaller then the given new size. In
    // other words we calculate the aspect ratio using the largest
    // dimension from the new size and the small dimension from the
    // actual size.
    CGFloat ratio;
    if (newSize.width / imageSize.width >
        newSize.height / imageSize.height) {
        ratio = newSize.width / imageSize.width;
    } else {
        ratio = newSize.height / imageSize.height;
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, ratio * imageSize.width, ratio * imageSize.height);
    CGSize size = rect.size;
    size.width *= [UIScreen mainScreen].scale;
    size.height *= [UIScreen mainScreen].scale;
    rect.size = size;
    newSize.width *= [UIScreen mainScreen].scale;
    newSize.height *= [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContext(size);
    [self drawInRect:rect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Crop the image to the requested new size maintaining
    // the inner most parts of the image.
    CGFloat offsetX = 0;
    CGFloat offsetY = 0;
    imageSize = [scaledImage size];
    if (imageSize.height > newSize.height) {
        offsetY = (imageSize.height / 2) - (newSize.height / 2);
    } else {
        offsetX = (imageSize.width / 2) - (newSize.width / 2);
    }
    
    CGRect cropRect = CGRectMake(offsetX, offsetY,
                                 newSize.width,
                                 newSize.height);
    
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect([scaledImage CGImage], cropRect);
    UIImage *newImage = [UIImage imageWithCGImage:croppedImageRef];
    CGImageRelease(croppedImageRef);
    
    return newImage;
}
@end
