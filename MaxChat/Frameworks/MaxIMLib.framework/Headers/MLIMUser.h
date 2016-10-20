//
//  MLIMUser.h
//  MaxLeapIM
//

#import <Foundation/Foundation.h>
#import "MLIMRuntimeObject.h"

@class MLIMGroup, MLIMRoom, MLIMMessage, MLIMRelationInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 *  A representation of current logged in user.
 */
@interface MLIMUser : MLIMRuntimeObject

/**
 *  The user ID.
 */
@property (nonatomic, strong) NSString *uid; // clientId

/**
 *  The username.
 */
@property (nullable, nonatomic, strong) NSString *username;

/**
 *  The user's phone number.
 */
@property (nullable, nonatomic, strong) NSString *phoneNumber;

/**
 *  The last time user updated
 */
@property (nullable, nonatomic, readonly) NSDate *updatedAt;

/**
 *  The number of user logged in client.
 */
@property (nonatomic, readonly) NSInteger sessionCount;

/**
 *  Custom attributes for the user.
 */
@property (nullable, nonatomic, strong) NSDictionary *attributes;

/**
 *  Online status of the user
 */
@property (nonatomic) BOOL online;

/**
 *  Friends of the user.
 */
@property (nonatomic, readonly) NSArray<MLIMRelationInfo*> *friends;

/**
 *  Groups of the user.
 */
@property (nonatomic, readonly) NSArray<MLIMGroup*> *groups;

/**
 *  Rooms of the user.
 */
@property (nonatomic, readonly) NSArray<MLIMRoom*> *rooms;

/**
 *  Create user object with userID.
 *
 *  @param uid The userId, the userId should match `[a-zA-Z0-9_\-]+`.
 *
 *  @return a MLIMUser object.
 */
+ (instancetype)userWithId:(NSString *)uid;

/**
 *  Fetch the user data, including user's friendIds, groupIds and roomIds.
 *
 *  @param block A block to be executed after request completion.
 */
- (void)fetchWithCompletion:(void(^)(BOOL success, NSError *_Nullable error))block;

#pragma mark - Friends

/**
 *  Fetch friend info. The friend's info will be saved in user.friends property.
 *
 *  @param detail Should get friend detail info or not. If `NO`, only friend ID will be retured.
 *  @param block  A block to be executed after request completion.
 */
- (void)fetchFriendsWithDetail:(BOOL)detail completion:(void(^)(BOOL success, NSError *_Nullable error))block;

/**
 *  Add a friend with userId.
 *
 *  @param uid   The friend's uid.
 *  @param block A block to be executed after request completion.
 */
- (void)addFriendWithUser:(NSString *)uid completion:(void(^)(NSDictionary *result, NSError *_Nullable error))block __deprecated_msg("Use -addFriend:completion: instead");

/**
 *  Add a friend with userId.
 *
 *  @param uid   The friend's uid.
 *  @param block A block to be executed after request completion.
 */
- (void)addFriend:(NSString *)uid completion:(void(^)(NSDictionary *result, NSError *_Nullable error))block;

/**
 *  Batch add friends
 *
 *  @param ids   friend user ids
 *  @param block A block to be executed after request completion.
 */
- (void)batchAddFriends:(NSArray *)ids completion:(void(^)(NSArray<NSDictionary*> *result, NSError *_Nullable error))block;

/**
 *  Get the friend detail with friend uid.
 *
 *  @param friendId The friend userId.
 *  @param block    A block to be executed after request completion.
 */
- (void)getFriendInfo:(NSString *)friendId completion:(void (^)(MLIMRelationInfo*, NSError * _Nullable))block;

/**
 *  Remove a friend with friend's userId.
 *
 *  @param uid   The friend's userId.
 *  @param block A block to be executed after request completion.
 */
- (void)deleteFriend:(NSString *)uid completion:(void(^)(BOOL success, NSError *_Nullable error))block;

/**
 *  Get the latest messages chat with friend.
 *
 *  @param uid   The friend userId.
 *  @param ts    The time
 *  @param limit The limit on number of messages to return.
 *  @param block A block to be executed after reuqest completion.
 */
- (void)getLatestChatsWithFriend:(NSString *)uid beforeTimestamp:(NSTimeInterval)ts limit:(int)limit block:(void (^)(NSArray<MLIMMessage*> *_Nullable messages, NSError *_Nullable error))block;

#pragma mark - Strangers

/**
 *  Fetch stranger list that the user have contacted with. The list can be retrieved from user.strangers property later.
 *
 *  @param detail If true, stranger detail information will be returned, otherwise only stranger id will be re
 *  @param params {"limit":"10", "skip":"0", "ids":"id1,id2,id3"}
 *  @param block  A block to be executed after reuqest completion.
 */
- (void)fetchStrangersWithDetail:(BOOL)detail params:(nullable NSDictionary<NSString*, NSString*> *)params completion:(void(^)(NSArray<MLIMRelationInfo*> *_Nullable result, NSError *_Nullable error))block;

/**
 *  Get the detail stranger info
 *
 *  @param strangerId the stranger userId
 *  @param block      A block to be executed after reuqest completion.
 */
- (void)getInfoOfStranger:(NSString *)strangerId completion:(void (^)(MLIMRelationInfo*, NSError * _Nullable))block;

/**
 *  Get the latest message chat with the stranger
 *
 *  @param uid   the stranger userId
 *  @param ts    the time
 *  @param limit the limit on number of messages to return
 *  @param block A block to be executed after reuqest completion.
 */
- (void)getLatestChatsWithStranger:(NSString *)uid before:(NSTimeInterval)ts limit:(int)limit block:(void (^)(NSArray<MLIMMessage*> *_Nullable messages, NSError *_Nullable error))block;

#pragma mark - Groups & Rooms

/**
 *  Fetch user's group list. The group's info will be saved in user.groups property.
 *
 *  @param detail Should get group detail info or not. If `NO`, only group ID will be retured.
 *  @param block  A block to be executed after request completion.
 */
- (void)fetchGroupsWithDetail:(BOOL)detail completion:(void(^)(BOOL success, NSError *_Nullable error))block;

/**
 *  Fetch room info. The room's info will be saved in user.rooms property.
 *
 *  @param detail Should get room detail info or not. If `NO`, only room ID will be retured.
 *  @param block  A block to be executed after request completion.
 */
- (void)fetchRoomsWithDetail:(BOOL)detail completion:(void(^)(BOOL success, NSError *_Nullable error))block;

#pragma mark - Attributes

/**
 *  Update user attributes. The attributes keys must be a string, the values can be any json serializable type.
 *
 *  @param attrs the custom user attributes
 *  @param block A block to return the result.
 */
- (void)updateAttributes:(NSDictionary<NSString *, id> *)attrs completion:(void(^)(BOOL success, NSError *_Nullable error))block;

/**
 *  Replace whole attributes with the new one. The attributes keys must be a string, the values can be any json serializable type.
 *
 *  @param attrs the custom user attributes
 *  @param block A block to return the result.
 */
- (void)replaceAttributes:(NSDictionary<NSString*, id> *)attrs completion:(void(^)(BOOL success, NSError *_Nullable error))block;

/**
 *  Fetch the attributes.
 *
 *  @param block A block to return the result.
 */
- (void)fetchAttributesWithCompletion:(void(^)(NSDictionary *_Nullable attrs, NSError *_Nullable error))block;

/**
 *  Get one attribute with key.
 *
 *  @param key   attribute name
 *  @param block A block to return the result.
 */
- (void)getAttributeForKey:(NSString *)key completion:(void(^)(id _Nullable value, NSError *_Nullable error))block;

/**
 *  Delete the whole attributes.
 *
 *  @param block A block to return the result.
 */
- (void)deleteAttributesWithCompletion:(void(^)(BOOL success, NSError *_Nullable error))block;

@end

NS_ASSUME_NONNULL_END


