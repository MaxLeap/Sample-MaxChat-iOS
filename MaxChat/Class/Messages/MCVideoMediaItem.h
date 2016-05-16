//
//  MCVideoMediaItem.h
//  MaxChat
//
//  Created by 周和生 on 16/5/6.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "JSQVideoMediaItem.h"

@interface MCVideoMediaItem : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, assign) BOOL isReadyToPlay;
- (instancetype)initWithVideoURL:(NSURL *)videoURL isReadyToPlay:(BOOL)isReadyToPlay;
- (void)endDisplaying;
@end
