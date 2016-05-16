//
//  MSFollowInfo.h
//  MaxSocial
//
//  Created by Sun Jin on 3/25/16.
//  Copyright © 2016 maxleap. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MaxSocialRelationInfo : NSObject

@property (readonly, nonatomic) NSString *objectId;

@property (readonly, nullable, nonatomic) NSDate *createdAt;
@property (readonly, nullable, nonatomic) NSDate *updatedAt;

@property (readonly, nullable, nonatomic) NSString *followerId;
@property (readonly, nullable, nonatomic) NSString *followeeId;

@property (readonly, nonatomic) BOOL reverse;
@property (readonly, nonatomic) BOOL black;

+ (instancetype)infoWithObjectId:(NSString *)objectId;
+ (instancetype)infoWithDictionary:(NSDictionary<NSString*, id> *)dictionary;

@end

NS_ASSUME_NONNULL_END
