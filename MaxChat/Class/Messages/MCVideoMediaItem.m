//
//  MCVideoMediaItem.m
//  MaxChat
//
//  Created by 周和生 on 16/5/6.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "MCVideoMediaItem.h"
#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"
#import "UIImage+JSQMessages.h"
#import "MCMessagesModelData.h"
@import MediaPlayer;

@interface MediaContainerView: UIView
@end

@implementation MediaContainerView

@end

@interface MCVideoMediaItem ()

@property (strong, nonatomic) MediaContainerView *mediaContainerView;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayController;

@end


@implementation MCVideoMediaItem

#pragma mark - Initialization
- (void)endDisplaying {
    if (self.moviePlayController) {
        [self.moviePlayController stop];
        NSLog(@"MCVideoMediaItem endDisplaying");
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithVideoURL:(NSURL *)videoURL isReadyToPlay:(BOOL)isReadyToPlay
{
    self = [super init];
    if (self) {
        _videoURL = [videoURL copy];
        _isReadyToPlay = isReadyToPlay;
    }
    return self;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
}

#pragma mark - Setters

- (void)setVideoURL:(NSURL *)videoURL
{
    _videoURL = [videoURL copy];
}

- (void)setIsReadyToPlay:(BOOL)isReadyToPlay
{
    _isReadyToPlay = isReadyToPlay;
    [self regenerateMediaViewContents];
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    [self regenerateMediaViewContents];
}

#pragma mark - JSQMessageMediaData protocol

- (void)regenerateMediaViewContents {

    for (UIView *subview in self.mediaContainerView.subviews) {
        [subview removeFromSuperview];
    }
    
    CGSize size = [self mediaViewDisplaySize];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    imageView.backgroundColor = [UIColor blackColor];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.clipsToBounds = YES;
    
    if (_videoURL.path.length) {
        NSURL *cacheUrl = [MCMessagesModelData cacheURLForMediaURL:_videoURL.path extension:@"thumb"];
        if ([[NSFileManager defaultManager]fileExistsAtPath:cacheUrl.path]) {
            imageView.image = [UIImage imageWithContentsOfFile:cacheUrl.path];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [self generateThumbnailFromVideo];
                NSData *data = UIImagePNGRepresentation(image);
                [data writeToURL:cacheUrl atomically:YES];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.image = image;
                    });
                }
            });
        }
    }
    [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
    [self.mediaContainerView addSubview: imageView];

    
    UIImage *playIcon = [[UIImage jsq_defaultPlayImage] jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playButton setImage:playIcon forState:UIControlStateNormal];
    playButton.frame = CGRectMake(0, 0, 28, 28);
    playButton.center = CGPointMake(size.width/2, size.height/2);
    [self.mediaContainerView addSubview: playButton];
    [playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)playButtonPressed:(id)sender {
    self.moviePlayController = [[MPMoviePlayerController alloc]initWithContentURL:self.videoURL];
    CGSize size = [self mediaViewDisplaySize];
    self.moviePlayController.view.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
    [self.mediaContainerView addSubview:self.moviePlayController.view];
    [self.moviePlayController prepareToPlay];
    self.moviePlayController.shouldAutoplay = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    if (player==self.moviePlayController) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
        
        [self.moviePlayController.view removeFromSuperview];
        self.moviePlayController = nil;
    }
}

- (UIView *)mediaView
{
    if (self.mediaContainerView==nil) {
        CGSize size = [self mediaViewDisplaySize];
        self.mediaContainerView = [[MediaContainerView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    }
    [self regenerateMediaViewContents];
    return self.mediaContainerView;
}

-(UIImage*)generateThumbnailFromVideo
{
    if (self.videoURL.path.length==0) {
        return nil;
    } else {
        AVAsset *asset = [AVAsset assetWithURL: self.videoURL];
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
        
        [imageGenerator setAppliesPreferredTrackTransform:YES];
        CMTime time = CMTimeMake(1, 1);
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        return thumbnail;
    }
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    MCVideoMediaItem *videoItem = (MCVideoMediaItem *)object;
    
    return [self.videoURL isEqual:videoItem.videoURL]
    && self.isReadyToPlay == videoItem.isReadyToPlay;
}

- (NSUInteger)hash
{
    return super.hash ^ self.videoURL.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: videoURL=%@, isReadyToPlay=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.videoURL, @(self.isReadyToPlay), @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _videoURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(videoURL))];
        _isReadyToPlay = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isReadyToPlay))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.videoURL forKey:NSStringFromSelector(@selector(videoURL))];
    [aCoder encodeBool:self.isReadyToPlay forKey:NSStringFromSelector(@selector(isReadyToPlay))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    MCVideoMediaItem *copy = [[[self class] allocWithZone:zone] initWithVideoURL:self.videoURL
                                                                   isReadyToPlay:self.isReadyToPlay];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end