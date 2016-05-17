//
//  MFLMCustomImageView.m
//  LikedMe
//
//  Created by Jun Xia on 15/10/17.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MCVisibleProcessImageView.h"
#import "Constants.h"
@import SDWebImage;

@interface MCVisibleProcessImageView ()
@property (nonatomic, strong) MFLMProgressIndicator * progressIndicator;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) BOOL didSetupConstraints;
@end

@implementation MCVisibleProcessImageView

#pragma mark - init Method
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    self.backgroundColor = UIColorFromRGB(0xf2f2f2);
    [self addSubview:self.imageView];
    
    return self;
}

#pragma mark- View Life Cycle
#pragma mark- Override Parent Methods
- (void)layoutSubviews {
    self.imageView.frame = self.bounds;
    self.progressIndicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

#pragma mark- SubViews Configuration

#pragma mark- Actions

#pragma mark- Public Methods

- (void)setImageWithURL:(NSURL *)imageURL withPlaceHolderImage:(UIImage *)placeHolderImage {
    [self.progressIndicator setProgress:0];
    [self addSubview:self.progressIndicator];
    
    [self.imageView sd_setImageWithPreviousCachedImageWithURL:imageURL
                                          andPlaceholderImage:placeHolderImage
                                                      options:SDWebImageRetryFailed
                                                     progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                         [self.progressIndicator setProgress:receivedSize * 1.0 / expectedSize];
                                                     } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                         [self.progressIndicator removeFromSuperview];
                                                         if (cacheType == SDImageCacheTypeNone && !placeHolderImage && image) {
                                                             [UIView transitionWithView:self.imageView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                                                 self.imageView.image = image;
                                                             } completion:nil];
                                                         }
                                                     }];
}

- (void)cancelCurrentImageLoad {
    [self.imageView sd_cancelCurrentImageLoad];
    [self.progressIndicator removeFromSuperview];
}

#pragma mark- Private Methods

#pragma mark- Delegate，DataSource, Callback Method

#pragma mark- Getter Setter
- (MFLMProgressIndicator *)progressIndicator {
    if (!_progressIndicator) {
        _progressIndicator = [[MFLMProgressIndicator alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
        _progressIndicator.layer.cornerRadius = 75 / 2.0f;
    }
    
    return _progressIndicator;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];;
        _imageView.userInteractionEnabled = YES;
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _imageView;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (UIImage *)image {
    return self.imageView.image;
}

#pragma mark- Helper Method

@end



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

@interface MFLMProgressIndicator ()
@property (nonatomic, strong) CAShapeLayer *cricleLayer;
@end

@implementation MFLMProgressIndicator

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    self.backgroundColor = UIColorFromRGBWithAlpha(0x000000, 0.12);
    self.layer.cornerRadius = frame.size.width / 2.0f;
    self.layer.masksToBounds = YES;
    [self.layer insertSublayer:self.cricleLayer atIndex:0];
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.layer.cornerRadius = frame.size.width / 2.0f;
}

- (CAShapeLayer *)cricleLayer {
    if (!_cricleLayer) {
        _cricleLayer = [CAShapeLayer layer];
        float x = (CGRectGetMaxX(self.frame) - CGRectGetMinX(self.frame)) / 2;
        float y = (CGRectGetMaxY(self.frame) - CGRectGetMinY(self.frame)) / 2;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x, y)
                                                            radius:self.frame.size.width * 0.6 / 2
                                                        startAngle:-M_PI_2
                                                          endAngle:-M_PI_2
                                                         clockwise:YES];
        _cricleLayer.path = path.CGPath;
        _cricleLayer.strokeColor = UIColorFromRGBWithAlpha(0xffffff, 1.0).CGColor;
        _cricleLayer.lineCap = @"round";
        _cricleLayer.fillColor = [UIColor clearColor].CGColor;
        _cricleLayer.lineWidth = 7;
    }
    
    return _cricleLayer;
}

- (void)setProgress:(float)progress {
    _progress = progress;
    float x = (CGRectGetMaxX(self.frame) - CGRectGetMinX(self.frame)) / 2;
    float y = (CGRectGetMaxY(self.frame) - CGRectGetMinY(self.frame)) / 2;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x,y)
                                                        radius:self.frame.size.width * 0.6 / 2
                                                    startAngle:-M_PI_2
                                                      endAngle:-M_PI_2 + M_PI * 2 * progress
                                                     clockwise:YES];
    _cricleLayer.path = path.CGPath;
}

@end
