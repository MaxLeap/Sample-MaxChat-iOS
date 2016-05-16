//
//  MaxSocialShuoShuo.h
//  MaxSocial
//
//  Created by Sun Jin on 3/24/16.
//  Copyright © 2016 maxleap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MaxSocialLocation.h"

NS_ASSUME_NONNULL_BEGIN

@interface MaxSocialShuoShuoContent : NSObject

@property (nonatomic, strong) NSArray<NSString*> *imageNames;

@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSURL *url;

// 图片链接需要 NSInputStream 支持的
@property (nonatomic, strong, readonly) NSArray<NSURL*> *imageURLs;

+ (instancetype)contentWithText:(NSString *)text;
+ (instancetype)contentWithURL:(NSURL *)url;
+ (instancetype)contentWithText:(NSString *)text url:(NSURL *)url;
+ (instancetype)contentWithText:(NSString *)text imageURLs:(NSArray<NSURL*> *)imageURLs;

@end


@interface MaxSocialShuoShuo : NSObject

@property (nonatomic, strong) NSString *objectId;

@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;

@property (nonatomic, strong) NSString *userId;

// location
@property (nonatomic, strong) MaxSocialLocation *location;

@property (nonatomic, strong) MaxSocialShuoShuoContent *content;

+ (instancetype)statusFromDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
