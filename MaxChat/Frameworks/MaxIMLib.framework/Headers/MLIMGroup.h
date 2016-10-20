//
//  MLIMGroup.h
//  MaxLeapIM
//

#import "MLIMConstants.h"
#import "MLIMRuntimeObject.h"

@class MLIMMessage;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The representation of a group.
 */
@interface MLIMGroup : MLIMRuntimeObject

/**
 *  @name Properties
 */

/**
*  The group ID.
*/
@property (nonatomic, readonly) NSString *groupId;

/**
 *  The group's owner.
 */
@property (nonatomic, strong) NSString *owner;

/**
 *  The group's name.
 */
@property (nullable, nonatomic, strong) NSString *name;

/**
 *  The userIds of group member.
 */
@property (nonatomic, readonly) NSArray<NSString *> *members;

/**
 *  The custom attributes
 */
@property (nullable, nonatomic, strong) NSDictionary *attributes;

/**
 *  The recent message
 */
@property (nullable, nonatomic, readonly) MLIMMessage *recentMessage;

/**
 *  @name Creating `MLIMGroup` instances
 */

/**
 *  Creates a group object with groupId.
 *
 *  @param gid The groupId.
 *
 *  @return A group object without group metadata.
 */
+ (instancetype)groupWithId:(NSString *)gid;

/**
 *  Creates a group object with group payload dictionary.
 *
 *  @param dictionary The group payload dictionary.
 *
 *  @return A group object.
 */
+ (instancetype)groupWithDictionary:(NSDictionary *)dictionary;

/**
 *  @name Creates Groups
 */

/**
 *  Creates a group.
 *
 *  @param owner   The group owner
 *  @param name    The group name
 *  @param members The group members
 *  @param block   A block to be executed after creation complete. The block should have the following signature: (MLIMGroup *group, NSError *error)
 */
+ (void)createWithOwner:(NSString *)owner
                   name:(NSString *)name
                members:(nullable NSArray *)members
                  block:(void(^)(MLIMGroup *group, NSError *error))block;

/**
 *  @name Fetch data of a group.
 */

/**
 *  Fetch the group info.
 *
 *  @param block A block to be executed after creation complete. The block should have the following signature: (BOOL succeeded, NSError *error)
 */
- (void)fetchWithBlock:(MLIMBooleanResultBlock)block;

/**
 *  Get limit group messages before time.
 *
 *  @param time  The timestamp
 *  @param limit A limit on the number of messages to return. The default limit is 20.
 *  @param block A block to be executed after get the messages.
 */
- (void)getLatestMessagesBefore:(NSTimeInterval)time limit:(int)limit completion:(void (^)(NSArray<MLIMMessage*> *_Nullable messages, NSError *_Nullable error))block;

/**
 *  @name Update group.
 */

/**
 *  Change the owner of the group.
 *
 *  @param newOwner The userId of new owner.
 *  @param block    A block to notify the result.
 */
- (void)changeOwner:(NSString *)newOwner block:(MLIMBooleanResultBlock)block;

/**
 *  Add one member to the group.
 *
 *  @param mem   Id of the new member
 *  @param block A block to be executed after member add completion.
 */
- (void)addAMember:(NSString *)mem block:(void(^)(BOOL, NSError*__Nullable))block;

/**
 *  Add members to the group.
 *
 *  @param newMembers The new members to add.
 *  @param block      A block to be executed after member add completion.
 */
- (void)addMembers:(NSArray *)newMembers block:(MLIMBooleanResultBlock)block;

/**
 *  Remove a member from the group.
 *
 *  @param mem   Id of the member to remove.
 *  @param block A block to be executed after member remove completion.
 */
- (void)removeAMember:(NSString *)mem block:(void(^)(BOOL, NSError*__Nullable))block;

/**
 *  Remove members from the group. The group owner cannot be removed.
 *
 *  @param members The members to remove.
 *  @param block   A block to be executed after member remove completion.
 */
- (void)removeMembers:(NSArray *)members block:(MLIMBooleanResultBlock)block;

/**
 *  Replace all group members except the owner with newMembers.
 *
 *  @param newMembers New members for the group.
 *  @param block      A block to be executed after member replace completion.
 */
- (void)overwriteMembers:(NSArray *)newMembers block:(MLIMBooleanResultBlock)block;

/**
 *  @name Delete Groups
 */

/**
 *  Delete the group.
 *
 *  @param block A block to be execute after group delete completion.
 */
- (void)deleteWithBlock:(MLIMBooleanResultBlock)block;

/**
 *  @name Group Attributes
 */

/**
 *  Update user attributes. The attributes keys must be a string, the values can be any json serializable type.
 *
 *  @param attrs the custom user attributes
 *  @param block A block to return the result.
 */
- (void)updateAttributes:(NSDictionary<NSString *, id> *)attrs completion:(void(^)(BOOL success, NSError *_Nullable error))block;

/**
 *  Update the `name` field of group attributes.
 *
 *  @param name  The new group name.
 *  @param block A block to be executed after update completion.
 */
- (void)updateName:(NSString *)name block:(MLIMBooleanResultBlock)block;

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
