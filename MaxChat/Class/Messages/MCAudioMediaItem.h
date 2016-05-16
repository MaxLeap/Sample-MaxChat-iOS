//
//  MCAudioMediaItem.h
//  MaxChat
//
//  Created by 周和生 on 16/5/9.
//  Copyright © 2016年 zhouhs. All rights reserved.
//


#import "JSQMediaItem.h"
#import "JSQAudioMediaViewAttributes.h"

#import <AVFoundation/AVFoundation.h>

@class JSQAudioMediaItem;

NS_ASSUME_NONNULL_BEGIN


@interface MCAudioMediaItem : JSQMediaItem <JSQMessageMediaData, AVAudioPlayerDelegate, NSCoding, NSCopying>

@property (nonatomic, strong, readonly) NSURL *audioURL;

- (instancetype)init;
- (void)setAudioDataWithUrl:(nonnull NSURL *)audioURL;

@end

NS_ASSUME_NONNULL_END
