//
//  MFLMImagePreviewView.m
//  LikedMe
//
//  Created by Jun Xia on 15/10/17.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MCPhotoBroswer.h"
#import "MCVisibleProcessImageView.h"

#define kAnimationDuration 0.25

@interface MCPhotoBroswer () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *fakeImageView;
@property (nonatomic, assign, readwrite) NSUInteger page;
@property (nonatomic, strong) MCVisibleProcessImageView *imageView0;
@property (nonatomic, strong) MCVisibleProcessImageView *imageView1;
@property (nonatomic, assign) NSUInteger imageView0Index;
@property (nonatomic, assign) NSUInteger imageView1Index;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, assign) float previousScale;
@end

@implementation MCPhotoBroswer

#pragma mark - init Method
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    self.page = NSNotFound;
    [self.scrollView addSubview:self.imageView0];
    [self.scrollView addSubview:self.imageView1];
    [self addSubview:self.scrollView];
    [self addGestureRecognizer:self.tapGesture];
    
    [self addGestureRecognizer:self.pinchGesture];
    
    return self;
}

#pragma mark- View Life Cycle

#pragma mark- Override Parent Methods
- (void)layoutSubviews {
    self.scrollView.frame = CGRectMake(0, 0, ScreenRect.size.width, ScreenRect.size.height);
    NSUInteger numberOfImages = [self.dataSource numberOfPhotoInPhotoBroswer:self];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * numberOfImages, ScreenRect.size.height);
    self.scrollView.contentOffset = CGPointMake(self.page * self.scrollView.frame.size.width, 0);
}

#pragma mark- SubViews Configuration

#pragma mark- Actions
- (void)handTapGesture:(UITapGestureRecognizer *)tapGesture {
    CGRect finalFrame = [self.delegate finalDismissFrameAtPage:self.page inPhotoBroswer:self];
    [self dismissImageToFinalLocation:finalFrame];
}

-(void)handleLongPressGesture:(UIPinchGestureRecognizer *)sender {
    //当手指离开屏幕时,将lastscale设置为1.0
    if([sender state] == UIGestureRecognizerStateEnded) {
        self.previousScale = 1.0;
        return;
    }
    
    MCVisibleProcessImageView *previewImageView = (self.page % 2 == 0) ? self.imageView0 : self.imageView1;
    CGFloat scale = 1.0 - (self.previousScale - [(UIPinchGestureRecognizer*)sender scale]);
    CGAffineTransform currentTransform = previewImageView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    
    [previewImageView setTransform:newTransform];
    self.previousScale = [sender scale];
    
}

#pragma mark- Public Methods
- (void)showImage:(UIImage *)image originPage:(NSUInteger)page originLocation:(CGRect)originImageLocation {
    self.backgroundColor = UIColorFromRGBWithAlpha(0x000000, 0.0);
    self.page = page;
    
    [self.scrollView removeFromSuperview];
    UIWindow *keywindow = [UIApplication sharedApplication].keyWindow;
    UIView *frontView = [[keywindow subviews] lastObject];
    self.frame = frontView.bounds;
    [frontView addSubview:self];
    [self layoutIfNeeded];
    
    [self.fakeImageView setImage:image];
    self.fakeImageView.frame = originImageLocation;
    [self addSubview:self.fakeImageView];
    
    [self.delegate photoBroswer:self didShowPhotoAtIndex:page];
    
    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect finalFrame = CGRectMake(0, 0, ScreenRect.size.width, ScreenRect.size.height);
        self.fakeImageView.frame = CGRectInset(finalFrame, 2, 2);
        self.backgroundColor = UIColorFromRGBWithAlpha(0x000000, 1.0);
    } completion:^(BOOL finished) {
        [self addSubview:self.scrollView];
        
        CGRect firstViewFrame = CGRectMake(ScreenRect.size.width * page, 0, ScreenRect.size.width, ScreenRect.size.height);
        firstViewFrame = CGRectInset(firstViewFrame, 2, 2);
        
        if ([self.dataSource respondsToSelector:@selector(imagePreviewView:imageURLAtIndex:)]) {
            NSURL *firstViewImageURL = [self.dataSource imagePreviewView:self imageURLAtIndex:page];
            if (self.page % 2 == 0) {
                self.imageView0.frame = firstViewFrame;
                UIImage *placeImage = ImageNamed(@"ic_item_detail_default");
                [self.imageView0 setImageWithURL:firstViewImageURL withPlaceHolderImage:placeImage];
            } else {
                self.imageView1.frame = firstViewFrame;
                UIImage *placeImage = ImageNamed(@"ic_item_detail_default");
                [self.imageView1 setImageWithURL:firstViewImageURL withPlaceHolderImage:placeImage];
            }
            
        } else if ([self.dataSource respondsToSelector:@selector(photoBroswer:thumbnieImageAtIndex:)]) {
            UIImage *image = [self.dataSource photoBroswer:self thumbnieImageAtIndex:page];
            if (image) {
                if (self.page % 2 == 0) {
                    self.imageView0.frame = firstViewFrame;
                    self.imageView0.image = image;
                    
                } else {
                    self.imageView1.frame = firstViewFrame;
                    self.imageView1.image = image;
                }
            }
            
        }
        
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width * self.page, 0)];
        [self reloadData];
        
        [self.fakeImageView removeFromSuperview];
    }];
}

- (void)dismissImageToFinalLocation:(CGRect)finalImageLocation {
    [self.delegate photoBroswer:self willExitPhotoAtIndex:self.page];
    
    MCVisibleProcessImageView *previewImageView = (self.page % 2 == 0) ? self.imageView0 : self.imageView1;
    self.fakeImageView.image = previewImageView.image;
    CGRect initFrame = CGRectMake(0, 0, ScreenRect.size.width, ScreenRect.size.height);
    self.fakeImageView.frame = CGRectInset(initFrame, 2, 2);
    [self addSubview:self.fakeImageView];
    
    [self.scrollView removeFromSuperview];
    
    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.fakeImageView.frame = finalImageLocation;
        self.backgroundColor = UIColorFromRGBWithAlpha(0x000000, 0.0);
    } completion:^(BOOL finished) {
        [self.fakeImageView removeFromSuperview];
        [self removeFromSuperview];
        [self.delegate photoBroswer:self didDismissPhotoAtIndex:self.page];
    }];
}

#pragma mark- Private Methods
- (void)reloadData {
    NSUInteger numberOfImages = [self.dataSource numberOfPhotoInPhotoBroswer:self];
    float currenPosition = self.scrollView.contentOffset.x;
    int currentPage = roundf(currenPosition / self.scrollView.frame.size.width);
    float currentPagePosition = currentPage * self.scrollView.frame.size.width;
    BOOL view1Active = (currentPage % 2 == 0);//view1 - imageView0
    MCVisibleProcessImageView *nextView = view1Active ? self.imageView1 : self.imageView0;
    
    int nextpage = currenPosition < currentPagePosition ? currentPage - 1 : currentPage + 1;
    if (nextpage >= 0 && nextpage < numberOfImages) {
        if((view1Active && nextpage == self.imageView0Index) || (!view1Active && nextpage == self.imageView1Index)) {
            return;
        }
        
        nextView.frame = CGRectMake(nextpage * self.scrollView.frame.size.width, 0, ScreenRect.size.width, ScreenRect.size.height);
        nextView.frame = CGRectInset(nextView.frame, 2, 2);
        
        if ([self.dataSource respondsToSelector:@selector(imagePreviewView:imageURLAtIndex:)]) {
            NSURL *oneImageUrl = [self.dataSource imagePreviewView:self imageURLAtIndex:nextpage];
            UIImage *placeImage = ImageNamed(@"ic_item_detail_default");
            [nextView setImageWithURL:oneImageUrl withPlaceHolderImage:placeImage];
            
        } else if ([self.dataSource respondsToSelector:@selector(photoBroswer:thumbnieImageAtIndex:)]) {
            UIImage *image = [self.dataSource photoBroswer:self thumbnieImageAtIndex:nextpage];
            if (image) {
                nextView.image = image;
            }
        }
    }
    
    if(view1Active) {
        self.imageView0Index = nextpage;
    } else {
        self.imageView1Index = nextpage;
    }
}

#pragma mark- Delegate，DataSource, Callback Method

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.imageView0 setTransform:CGAffineTransformIdentity];
    [self.imageView1 setTransform:CGAffineTransformIdentity];
    
    NSUInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    if (page != self.page) {
        [self.delegate photoBroswer:self didDismissPhotoAtIndex:self.page];
        self.page = page;
        [self.delegate photoBroswer:self didShowPhotoAtIndex:self.page];
    }
    [self reloadData];
}

#pragma mark- Getter Setter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        _scrollView.backgroundColor = [UIColor clearColor];
    }
    
    return _scrollView;
}

- (MCVisibleProcessImageView *)imageView0 {
    if (!_imageView0) {
        _imageView0 = [MCVisibleProcessImageView new];
        _imageView0.backgroundColor = [UIColor clearColor];
    }
    
    return _imageView0;
}

- (MCVisibleProcessImageView *)imageView1 {
    if (!_imageView1) {
        _imageView1 = [MCVisibleProcessImageView new];
        _imageView1.backgroundColor = [UIColor clearColor];
    }
    
    return _imageView1;
}

- (UIImageView *)fakeImageView {
    if (!_fakeImageView) {
        _fakeImageView = [UIImageView new];
        _fakeImageView.layer.cornerRadius = 2;
        _fakeImageView.layer.masksToBounds = YES;
        _fakeImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _fakeImageView;
}

- (void)setDataSource:(id<MCPhotoBroswerDataSource>)dataSource {
    _dataSource = dataSource;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handTapGesture:)];
    }
    
    return _tapGesture;
}

- (UIPinchGestureRecognizer *)pinchGesture {
    if (!_pinchGesture) {
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    }
    return _pinchGesture;
}

#pragma mark- Helper Method

#pragma mark Temporary Area

@end
