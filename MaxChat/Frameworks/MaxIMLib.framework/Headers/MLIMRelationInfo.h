//
//  MLIMRelationInfo.h
//  MaxLeapIM
//

#import <Foundation/Foundation.h>
#import "MLIMRuntimeObject.h"
#import "MLIMClient.h"

@class MLIMMessage;

typedef NS_ENUM(NSInteger, MLIMRelationType) {
    MLIMRelationTypeFriend = 0,
    MLIMRelationTypeStranger
};

NS_ASSUME_NONNULL_BEGIN

/**
 *  A representation of a friend.
 */
@interface MLIMRelationInfo : MLIMRuntimeObject

/**
 *  The friend userId.
 */
@property (nonatomic, readonly) NSString *uid;

/**
 *  Online status of the friend. Observable.
 */
@property (nonatomic, readonly) BOOL online;

@property (nonatomic, readonly) int64_t ts;

/**
 *  Relation type
 */
@property (nonatomic) MLIMRelationType type;

/**
 *  Friend request sender
 */
@property (nonatomic, readonly) NSString *from;

/**
 *  Friend request receiver
 */
@property (nonatomic, readonly) NSString *to;

/**
 *  The recent message
 */
@property (nonatomic, strong) MLIMMessage *recentMessage;

/**
 *  custom attributes, should only be json types
 */
@property (nullable, nonatomic, strong) NSDictionary *attributes;

/**
 *  Creates a relationInfo obejct with friend userId.
 *
 *  @param uid The friend userId.
 *
 *  @return A new MLIMRelationInfo object.
 */
+ (instancetype)infoWithId:(NSString *)uid;

/**
 *  Creates a relationInfo obejct with friend userId.
 *
 *  @param uid      The friend userId.
 *  @param client   The client to observe
 *
 *  @return A new MLIMRelationInfo object.
 */
+ (instancetype)infoWithId:(NSString *)uid client:(nullable MLIMClient *)client;

/**
 *  Create a MLIMRelationInfo object using payload data
 *
 *  @param dictionary the payload
 *
 *  @return a MLIMRelationInfo instance
 */
+ (instancetype)infoWithDictionary:(NSDictionary *)dictionary;

/**
 *  Creates a relationInfo obejct with friend userId.
 *
 *  @param uid The friend userId.
 *  @param client   The client to observe
 *
 *  @return A new MLIMRelationInfo object.
 */
+ (instancetype)infoWithDictionary:(NSDictionary *)dictionary client:(nullable MLIMClient *)client;

@end

typedef MLIMRelationInfo MLIMFriendInfo __deprecated_msg("Use MLIMRelationInfo instead");

NS_ASSUME_NONNULL_END
