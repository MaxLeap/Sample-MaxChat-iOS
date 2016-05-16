//
//  MLIMFriendInfo.h
//  MaxLeapIM
//

#import <Foundation/Foundation.h>

@class MLIMMessage;

NS_ASSUME_NONNULL_BEGIN

/**
 *  A representation of a friend.
 */
@interface MLIMFriendInfo : NSObject

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
@property (nonatomic, readonly) MLIMMessage *recentMessage;

/**
 *  Creates a friendInfo obejct with friend userId.
 *
 *  @param uid The friend userId.
 *
 *  @return A new MLIMFriendInfo object.
 */
+ (instancetype)infoWithId:(NSString *)uid;

+ (instancetype)infoWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
