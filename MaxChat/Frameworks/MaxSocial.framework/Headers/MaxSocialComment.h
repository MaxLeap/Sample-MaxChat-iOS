//
//  MaxSocialComment.h
//  MaxSocial
//
//  Created by Sun Jin on 3/25/16.
//  Copyright © 2016 maxleap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MaxSocialComment : NSObject

@property (nonatomic, strong) NSString *objectId;

@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *statusId;

@property (nonatomic, strong) NSString *content;

@property (nonatomic) BOOL read;
@property (nonatomic) BOOL isLike;

+ (instancetype)commentFromDictionary:(NSDictionary *)dictionary;

@end
