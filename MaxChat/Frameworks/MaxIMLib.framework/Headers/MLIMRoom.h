//
//  MLIMRoom.h
//  MaxLeapIM
//

#import <MaxIMLib/MLIMConstants.h>
#import <MaxIMLib/MLIMRuntimeObject.h>

@class MLIMMessage;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The representation of a room.
 */
@interface MLIMRoom : MLIMRuntimeObject

/**
 *  The room id.
 */
@property (nonatomic, readonly) NSString *roomId;

/**
 *  The room name
 */
@property (nullable, nonatomic) NSString *name;

/**
 *  The id list of room member.
 */
@property (nullable, nonatomic, readonly) NSArray<NSString *> *members;

/**
 *  The timestamp of room creation.
 */
@property (nonatomic, readonly) NSTimeInterval createTs;

@property (nullable, nonatomic, strong) NSDictionary<NSString *, id> *attributes;

/**
 *  Creates a MLIMRoom object with room id.
 *
 *  @param rid The room id.
 *
 *  @return A MLIMRoom object.
 */
+ (instancetype)roomWithId:(NSString *)rid;

+ (nullable instancetype)roomWithDictionary:(NSDictionary *)dictionary;

/**
 *  Creates a room.
 *
 *  @param name    The room name.
 *  @param members The members to join in the room.
 *  @param block   A block to be executed after creation complete.
 */
+ (void)createWithName:(NSString *)name
                members:(nullable NSArray *)members
                  block:(void(^)(MLIMRoom *room, NSError *error))block;

/**
 *  Fetch the room's info. Info will be filled in room's properties.
 *
 *  @param block A block to be execute after request completion.
 */
- (void)fetchWithBlock:(nullable MLIMBooleanResultBlock)block;

/**
 *  Update name of the room.
 *
 *  @param name  The new room name.
 *  @param block A block to be execute after operation complete.
 */
- (void)updateName:(NSString *)name block:(MLIMBooleanResultBlock)block;

/**
 *  Add members to the room.
 *
 *  @param newMembers The new member userIds to join in the room.
 *  @param block      A block to be executed after opertion complete
 */
- (void)addMembers:(NSArray<NSString*> *)newMembers block:(MLIMBooleanResultBlock)block;

/**
 *  Remove members from the room.
 *
 *  @param members The member userIds to remove.
 *  @param block   A block to be executed after operation complete
 */
- (void)removeMembers:(NSArray<NSString*> *)members block:(MLIMBooleanResultBlock)block;

/**
 *  Delete the room.
 *
 *  @param block A block to be execute after room delete completion.
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


