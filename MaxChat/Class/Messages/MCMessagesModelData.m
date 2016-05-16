
#import "MCMessagesModelData.h"
#import "MCVideoMediaItem.h"
#import "MCAudioMediaItem.h"
#import "MaxChatIMClient.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@interface MCMessagesModelData ()
@property (nonatomic, strong) NSArray<NSString *> *members;
@property (nonatomic, strong) MLIMGroup *group;
@end


@implementation NSString (_AESCrypt)

-(NSString*)sha256
{
    const char* str = [self UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

- (NSString *)md5 {
    const char* str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

@end

@implementation MCMessagesModelData

- (id)initWithGroup:(MLIMGroup*)aGroup {
    self = [super init];
    if (self) {
        NSLog(@"MCMessagesModelData for group %@", aGroup);
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
        
        self.group = aGroup;
        self.members = aGroup.members;
        
        [self updateMyAvatar];
        [self updatefriendsAvatar];
        [self loadMessages];;
    }
    return self;
}

- (id)initWithFriend:(MLIMFriendInfo*)aFriend
{
    self = [super init];
    if (self) {
        NSLog(@"MCMessagesModelData for friend %@", aFriend);
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
        
        self.members = @[aFriend.uid];
        [self updateMyAvatar];
        [self updatefriendsAvatar];
        [self loadMessages];
    }
    
    return self;
}

- (void)updatefriendsAvatar {
    for (NSString *friendID in self.members) {
        JSQMessagesAvatarImage *friendImage = [JSQMessagesAvatarImageFactory avatarImageWithUserInitials:friendID.uppercaseString
                                                                                         backgroundColor:[UIColor colorWithWhite:0.65f alpha:1.0f]
                                                                                               textColor:[UIColor colorWithWhite:0.40f alpha:1.0f]
                                                                                                    font:[UIFont systemFontOfSize:14.0f]
                                                                                                diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        self.avatars[friendID] = friendImage;
        
        // 获得好友 attributes 及 iconUrl，设置好友头像
        MLIMUser *imUser = [MLIMUser userWithId:friendID];
        [imUser fetchAttributesWithCompletion:^(NSDictionary * _Nullable attrs, NSError * _Nullable error) {
            NSString *iconUrl = attrs[@"iconUrl"];
            if (iconUrl) {
                [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:iconUrl]
                                                               options:kNilOptions
                                                              progress:nil
                                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                                 if (image) {
                                                                     self.avatars[friendID] = [JSQMessagesAvatarImageFactory avatarImageWithImage:image
                                                                                                                                         diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                                                                 }
                                                             }];
            }
        }];
    }
}

- (void)updateMyAvatar {
    // 默认头像
    JSQMessagesAvatarImage *myImage = [JSQMessagesAvatarImageFactory avatarImageWithUserInitials:@"我"
                                                                                 backgroundColor:[UIColor colorWithWhite:0.85f alpha:1.0f]
                                                                                       textColor:[UIColor colorWithWhite:0.60f alpha:1.0f]
                                                                                            font:[UIFont systemFontOfSize:14.0f]
                                                                                        diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    self.avatars = [[NSMutableDictionary alloc]initWithDictionary:@{ IMCurrentUserID : myImage }];
    
    // 根据iconUrl设置头像
    if (IMCurrentUser.attributes[@"iconUrl"]) {
        [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:IMCurrentUser.attributes[@"iconUrl"]]
                                                       options:kNilOptions
                                                      progress:nil
                                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                         if (image) {
                                                             self.avatars[IMCurrentUserID] = [JSQMessagesAvatarImageFactory avatarImageWithImage:image
                                                                                                                                        diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                                                         }
                                                     }];
    }
}

- (void)loadMessages
{
    self.messages = [[NSMutableArray alloc] init];
    
    NSTimeInterval ts = [[NSDate date] timeIntervalSince1970];
    if (self.group==nil && self.members.count==1) {
        
        [IMCurrentUser getLatestChatsWithFriend:self.members.firstObject
                                beforeTimestamp:ts
                                          limit:10
                                          block:^(NSArray<MLIMMessage *> * _Nullable messages, NSError * _Nullable error) {
                                              if (!error) {
                                                  NSLog(@"lastest history messages: %ld", (long)messages.count);
                                                  [messages enumerateObjectsUsingBlock:^(MLIMMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                      [self receiveMessage:obj];
                                                  }];
                                                  
                                                  [self.messagesController finishReceivingMessageAnimated:NO];
                                              }
                                          }];
    } else {
        
        [self.group getLatestMessagesBefore:ts
                                      limit:10
                                 completion:^(NSArray<MLIMMessage *> * _Nullable messages, NSError * _Nullable error) {
                                     if (!error) {
                                         NSLog(@"lastest history messages: %ld", (long)messages.count);
                                         [messages enumerateObjectsUsingBlock:^(MLIMMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                             [self receiveMessage:obj];
                                         }];
                                         
                                         [self.messagesController finishReceivingMessageAnimated:NO];
                                     }
                                 }];
        
    }
    
}

+ (NSURL *)cacheURLForMediaURL: (NSString *)attachmentUrl extension:(NSString * )extension {
    NSURL *cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory: NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *saveUrl = [NSURL fileURLWithPath:extension.length?[attachmentUrl.md5 stringByAppendingPathExtension:extension]:attachmentUrl.md5
                              relativeToURL:cacheUrl];
    
    return saveUrl;
}

- (void)receiveMessage:(MLIMMessage *)obj {
    if (obj.mediaType==MLIMMediaTypeVideo) {
        MCVideoMediaItem *videoMediaItem = [[MCVideoMediaItem alloc] initWithVideoURL:nil isReadyToPlay:NO];
        videoMediaItem.appliesMediaViewMaskAsOutgoing = [obj.sender.userId isEqualToString:IMCurrentUserID];
        JSQMessage *mediaMessage = [[JSQMessage alloc]initWithSenderId:obj.sender.userId
                                                     senderDisplayName:obj.sender.userId
                                                                  date:[NSDate dateWithTimeIntervalSince1970:obj.sendTimestamp]
                                                                 media:videoMediaItem];
        [self.messages addObject:mediaMessage];
        
        NSURL *videoURL = [NSURL URLWithString:obj.attachmentUrl];
        NSURL *cacheURL = [MCMessagesModelData cacheURLForMediaURL:obj.attachmentUrl extension:@"mp4"];
        
        if (![[NSFileManager defaultManager]fileExistsAtPath:cacheURL.path]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [NSData dataWithContentsOfURL:videoURL];
                if (data) {
                    [data writeToURL:cacheURL atomically:YES];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        videoMediaItem.videoURL = cacheURL;
                        videoMediaItem.isReadyToPlay = YES;
                        [self.messagesController finishReceivingMessageAnimated:NO];
                    });
                }
            });
        } else {
            videoMediaItem.videoURL = cacheURL;
            videoMediaItem.isReadyToPlay = YES;
        }
        
    } else if (obj.mediaType==MLIMMediaTypeAudio){
        MCAudioMediaItem *audioMediaItem = [[MCAudioMediaItem alloc] init];
        audioMediaItem.appliesMediaViewMaskAsOutgoing = [obj.sender.userId isEqualToString:IMCurrentUserID];
        JSQMessage *mediaMessage = [[JSQMessage alloc]initWithSenderId:obj.sender.userId
                                                     senderDisplayName:obj.sender.userId
                                                                  date:[NSDate dateWithTimeIntervalSince1970:obj.sendTimestamp]
                                                                 media:audioMediaItem];
        [self.messages addObject:mediaMessage];
        
        NSURL *audioURL = [NSURL URLWithString:obj.attachmentUrl];
        NSURL *cacheURL = [MCMessagesModelData cacheURLForMediaURL:obj.attachmentUrl extension:nil];
        
        if (![[NSFileManager defaultManager]fileExistsAtPath:cacheURL.path]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [NSData dataWithContentsOfURL:audioURL];
                if (data) {
                    [data writeToURL:cacheURL atomically:YES];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [audioMediaItem setAudioDataWithUrl:cacheURL];
                        [self.messagesController finishReceivingMessageAnimated:NO];
                    });
                }
            });
        } else {
            [audioMediaItem setAudioDataWithUrl:cacheURL];
        }
        
    } else if (obj.mediaType==MLIMMediaTypeImage) {
        JSQPhotoMediaItem *photoMediaItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
        photoMediaItem.appliesMediaViewMaskAsOutgoing = [obj.sender.userId isEqualToString:IMCurrentUserID];
        
        JSQMessage *mediaMessage = [[JSQMessage alloc]initWithSenderId:obj.sender.userId
                                                     senderDisplayName:obj.sender.userId
                                                                  date:[NSDate dateWithTimeIntervalSince1970:obj.sendTimestamp]
                                                                 media:photoMediaItem];
        [self.messages addObject:mediaMessage];
        
        NSURL *photoURL = [NSURL URLWithString:obj.attachmentUrl];
        [[SDWebImageManager sharedManager]downloadImageWithURL:photoURL
                                                       options:kNilOptions
                                                      progress:nil
                                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                         if (image) {
                                                             photoMediaItem.image = image;
                                                             [self.messagesController finishReceivingMessageAnimated:NO];
                                                         }
                                                     }];
        
    } else if (obj.mediaType==MLIMMediaTypeText) {
        [self.messages addObject: [[JSQMessage alloc] initWithSenderId:obj.sender.userId
                                                     senderDisplayName:obj.sender.userId
                                                                  date:[NSDate dateWithTimeIntervalSince1970:obj.sendTimestamp]
                                                                  text:obj.text]
         ];
    }
}


- (void)sendMessage:(JSQMessage *)message {
    [self.messages addObject:message];
    
    MLIMMessage *msg = nil;
    
    if (message.isMediaMessage) {
        
        id<JSQMessageMediaData> media = message.media;
        if ([media isKindOfClass:[JSQPhotoMediaItem class]]) {
            NSLog(@"will send JSQPhotoMediaItem");
            JSQPhotoMediaItem *photoMedia = (JSQPhotoMediaItem *)media;
            msg = [MLIMMessage messageWithImage:photoMedia.image];
            [MLAnalytics trackEvent:@"发送图片"];
        } else if ([media isKindOfClass:[MCVideoMediaItem class]]) {
            NSLog(@"will send MCVideoMediaItem");
            MCVideoMediaItem *videoItem = (MCVideoMediaItem *)media;
            msg = [MLIMMessage messageWithVideoFileAtPath:videoItem.videoURL.path];
            [MLAnalytics trackEvent:@"发送视频"];
        } else if ([media isKindOfClass:[MCAudioMediaItem class]]) {
            NSLog(@"will send MCAudioMediaItem");
            MCAudioMediaItem *audioItem = (MCAudioMediaItem *)media;
            msg = [MLIMMessage messageWithAudioFileAtPath:audioItem.audioURL.path];
            [MLAnalytics trackEvent:@"发送音频"];
        } else if ([media isKindOfClass:[JSQLocationMediaItem class]]) {
            NSLog(@"will send JSQLocationMediaItem, not implemented");
            [MLAnalytics trackEvent:@"发送位置"];
        }
        
        
    } else if (message.text) {
        msg = [MLIMMessage messageWithText:message.text];
        [MLAnalytics trackEvent:@"发送文字信息"];
    }
    
    if (msg) {
        if (self.group==nil && self.members.count==1) {
            [IMCurrentClient sendMessage:msg
                                toFriend:self.members.firstObject
                              completion:^(BOOL succeeded, NSError * _Nullable error) {
                                  if (succeeded) {
                                  } else {
                                      NSLog(@"发送失败 %@", error);
                                  }
                              }];
        } else {
            [IMCurrentClient sendMessage:msg
                                 toGroup:self.group.groupId
                              completion:^(BOOL succeeded, NSError * _Nullable error) {
                                  if (succeeded) {
                                  } else {
                                      NSLog(@"发送失败 %@", error);
                                  }
                              }];
        }
    }
}

+ (JSQMessage *)createVideoMediaMessageWithURL:(NSURL *)mediaURL {
    MCVideoMediaItem *videoItem = [[MCVideoMediaItem alloc] initWithVideoURL:mediaURL
                                                               isReadyToPlay:YES];
    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:IMCurrentUserID
                                                   displayName:IMCurrentUserID
                                                         media:videoItem];
    return videoMessage;
}

+ (JSQMessage *)createAudioMediaMessageWithURL:(NSURL *)mediaURL {
    MCAudioMediaItem *audioItem = [[MCAudioMediaItem alloc] init];
    [audioItem setAudioDataWithUrl:mediaURL];
    JSQMessage *audioMessage = [JSQMessage messageWithSenderId:IMCurrentUserID
                                                   displayName:IMCurrentUserID
                                                         media:audioItem];
    return audioMessage;
}

+ (JSQMessage *)createPhotoMediaMessageWithImage:(UIImage *)image {
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:IMCurrentUserID
                                                   displayName:IMCurrentUserID
                                                         media:photoItem];
    return photoMessage;
}


+ (JSQMessage *)createPhotoMediaMessage
{
    UIImage *image = arc4random()%2 ? [UIImage imageNamed:@"goldengate"] : [UIImage imageNamed:@"bg_414"];
    ILSLogImage(@"send image", image);
    
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:IMCurrentUserID
                                                   displayName:IMCurrentUserID
                                                         media:photoItem];
    return photoMessage;
}

+ (JSQMessage *)createAudioMediaMessage
{
    MCAudioMediaItem *audioItem = [[MCAudioMediaItem alloc] init];
    [audioItem setAudioDataWithUrl:[[NSBundle mainBundle] URLForResource:@"messages_sample" withExtension:@"m4a"]];
    JSQMessage *audioMessage = [JSQMessage messageWithSenderId:IMCurrentUserID
                                                   displayName:IMCurrentUserID
                                                         media:audioItem];
    return audioMessage;
}

+ (JSQMessage *)createLocationMediaMessageCompletion:(JSQLocationMediaItemCompletionBlock)completion
{
    CLLocation *ferryBuildingInSF = [[CLLocation alloc] initWithLatitude:37.795313 longitude:-122.393757];
    
    JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
    [locationItem setLocation:ferryBuildingInSF withCompletionHandler:completion];
    
    JSQMessage *locationMessage = [JSQMessage messageWithSenderId:IMCurrentUserID
                                                      displayName:IMCurrentUserID
                                                            media:locationItem];
    return locationMessage;
}

+ (JSQMessage *)createVideoMediaMessage
{
    NSURL *videoURL = [[NSBundle mainBundle]URLForResource:@"movie_sample" withExtension:@"mp4"];
    MCVideoMediaItem *videoItem = [[MCVideoMediaItem alloc] initWithVideoURL:videoURL
                                                               isReadyToPlay:YES];
    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:IMCurrentUserID
                                                   displayName:IMCurrentUserID
                                                         media:videoItem];
    return videoMessage;
}

#pragma mark - video utility
// use AVAssetExportSession to crop and transform video
+ (void)cropVideo:(AVAsset *)asset toUrl:(NSURL *)outputURL renderSize:(CGSize)renderSize start:(NSTimeInterval)start duration:(NSTimeInterval)duration presetName:(NSString *)presetName completion:(void(^)())completion {
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize = renderSize;
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(start, 600), CMTimeMakeWithSeconds(duration, 600));
    AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
    
    CGSize clipSize = clipVideoTrack.naturalSize;
    CGAffineTransform finalTransform = CGAffineTransformMakeScale(renderSize.width/clipSize.width, renderSize.height/clipSize.height);
    
    [transformer setTransform:finalTransform atTime:kCMTimeZero];
    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
    videoComposition.instructions = [NSArray arrayWithObject: instruction];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset
                                                                      presetName:presetName] ;
    exporter.videoComposition = videoComposition;
    exporter.outputURL = outputURL;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(start, 600), CMTimeMakeWithSeconds(duration, 600));
    
    [exporter exportAsynchronouslyWithCompletionHandler:^(void){
        if (exporter.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"exporter success");
        } else {
            NSLog(@"exporter error: %@", [exporter error]);
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
}

+ (void)cropVideo:(AVAsset *)asset toUrl:(NSURL *)outputURL renderSizeScale:(CGSize)renderSizeScale start:(NSTimeInterval)start duration:(NSTimeInterval)duration presetName:(NSString *)presetName completion:(void(^)())completion {
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(start, 600), CMTimeMakeWithSeconds(duration, 600));
    AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
    
    CGSize clipSize = clipVideoTrack.naturalSize;
    videoComposition.renderSize = CGSizeMake(clipSize.width*renderSizeScale.width, clipSize.height*renderSizeScale.height);
    CGAffineTransform finalTransform = CGAffineTransformMakeScale(renderSizeScale.width, renderSizeScale.height);
    
    [transformer setTransform:finalTransform atTime:kCMTimeZero];
    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
    videoComposition.instructions = [NSArray arrayWithObject: instruction];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset
                                                                      presetName:presetName] ;
    exporter.videoComposition = videoComposition;
    exporter.outputURL = outputURL;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(start, 600), CMTimeMakeWithSeconds(duration, 600));
    
    [exporter exportAsynchronouslyWithCompletionHandler:^(void){
        if (exporter.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"exporter success");
        } else {
            NSLog(@"exporter error: %@", [exporter error]);
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
}

+ (BOOL) isVideoPortrait:(AVAsset *)asset {
    BOOL isPortrait = FALSE;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks    count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        CGAffineTransform t = videoTrack.preferredTransform;
        // Portrait
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)
        {
            isPortrait = YES;
        }
        // PortraitUpsideDown
        if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)  {
            
            isPortrait = YES;
        }
        // LandscapeRight
        if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)
        {
            isPortrait = FALSE;
        }
        // LandscapeLeft
        if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0)
        {
            isPortrait = FALSE;
        }
    }
    return isPortrait;
}


+ (void)cropVideo:(AVAsset *)asset toUrl:(NSURL *)outputURL toSquareWithSide:(CGFloat)sideLength start:(NSTimeInterval)start duration:(NSTimeInterval)duration presetName:(NSString *)presetName completion:(void(^)())completion {
    
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    
    /* asset */
    
    AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] lastObject];
    
    /* sizes/scales/offsets */
    
    CGSize originalSize = assetVideoTrack.naturalSize;
    
    CGFloat scale;
    
    if (originalSize.width < originalSize.height) {
        scale = sideLength / originalSize.width;
    } else {
        scale = sideLength / originalSize.height;
    }
    
    CGSize scaledSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    
    CGPoint topLeft = CGPointMake(sideLength * .5 - scaledSize.width * .5, sideLength  * .5 - scaledSize.height * .5);
    
    /* Layer instruction */
    
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:assetVideoTrack];
    
    CGAffineTransform orientationTransform = assetVideoTrack.preferredTransform;
    
    /* fix the orientation transform */
    
    if (orientationTransform.tx == originalSize.width || orientationTransform.tx == originalSize.height) {
        orientationTransform.tx = sideLength;
    }
    
    if (orientationTransform.ty == originalSize.width || orientationTransform.ty == originalSize.height) {
        orientationTransform.ty = sideLength;
    }
    
    /* -- */
    
    CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformMakeScale(scale, scale),  CGAffineTransformMakeTranslation(topLeft.x, topLeft.y)), orientationTransform);
    
    [layerInstruction setTransform:transform atTime:kCMTimeZero];
    
    /* Instruction */
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    instruction.layerInstructions = @[layerInstruction];
    instruction.timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(start, 600), CMTimeMakeWithSeconds(duration, 600));
    
    /* Video composition */
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    
    videoComposition.renderSize = CGSizeMake(sideLength, sideLength);
    videoComposition.renderScale = 1.0;
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    videoComposition.instructions = @[instruction];
    
    /* Export */
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:presetName];
    
    exporter.videoComposition = videoComposition;
    exporter.outputURL = outputURL;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(start, 600), CMTimeMakeWithSeconds(duration, 600));
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (exporter.status == AVAssetExportSessionStatusCompleted) {
                NSLog(@"exporter success");
            } else {
                NSLog(@"exporter error: %@", [exporter error]);
            }
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }
        });
    }];
    
}

+ (void)cropVideo:(AVAsset *)asset toUrl:(NSURL *)outputURL toSquareWithScale:(CGFloat)scale start:(NSTimeInterval)start duration:(NSTimeInterval)duration presetName:(NSString *)presetName completion:(void(^)())completion {
    
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    
    /* asset */
    
    AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] lastObject];
    
    /* sizes/scales/offsets */
    
    CGSize originalSize = assetVideoTrack.naturalSize;
    
    CGFloat sideLength;
    
    if (originalSize.width < originalSize.height) {
        sideLength =  scale * originalSize.width;
    } else {
        sideLength =  scale * originalSize.height;
    }
    
    CGSize scaledSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    
    CGPoint topLeft = CGPointMake(sideLength * .5 - scaledSize.width * .5, sideLength  * .5 - scaledSize.height * .5);
    
    /* Layer instruction */
    
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:assetVideoTrack];
    
    CGAffineTransform orientationTransform = assetVideoTrack.preferredTransform;
    
    /* fix the orientation transform */
    
    if (orientationTransform.tx == originalSize.width || orientationTransform.tx == originalSize.height) {
        orientationTransform.tx = sideLength;
    }
    
    if (orientationTransform.ty == originalSize.width || orientationTransform.ty == originalSize.height) {
        orientationTransform.ty = sideLength;
    }
    
    /* -- */
    
    CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformMakeScale(scale, scale),  CGAffineTransformMakeTranslation(topLeft.x, topLeft.y)), orientationTransform);
    
    [layerInstruction setTransform:transform atTime:kCMTimeZero];
    
    /* Instruction */
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    instruction.layerInstructions = @[layerInstruction];
    instruction.timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(start, 600), CMTimeMakeWithSeconds(duration, 600));
    
    /* Video composition */
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    
    videoComposition.renderSize = CGSizeMake(sideLength, sideLength);
    videoComposition.renderScale = 1.0;
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    videoComposition.instructions = @[instruction];
    
    /* Export */
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:presetName];
    
    exporter.videoComposition = videoComposition;
    exporter.outputURL = outputURL;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(start, 600), CMTimeMakeWithSeconds(duration, 600));
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (exporter.status == AVAssetExportSessionStatusCompleted) {
                NSLog(@"exporter success");
            } else {
                NSLog(@"exporter error: %@", [exporter error]);
            }
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }
        });
    }];
    
}
@end
