//
//  MaxSocialUser.h
//  MaxSocial
//
//  Created by Sun Jin on 3/24/16.
//  Copyright © 2016 maxleap. All rights reserved.
//

#import <MaxLeap/MLConstants.h>
#import "MaxSocialShuoShuo.h"
#import "MaxSocialRelationInfo.h"
#import "MaxSocialQuery.h"
#import "MaxSocialLocation.h"
#import "MaxSocialLocationInfo.h"
#import "MaxSocialComment.h"
#import "MaxSocialRelationInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^MLSRelationResultBlock)(MaxSocialRelationInfo *_Nullable relation, NSError *_Nullable error);
typedef void (^MLSShuoShuoResultBlock)(MaxSocialShuoShuo *_Nullable status, NSError *_Nullable error);
typedef void (^MLSCommentResultBlock)(MaxSocialComment *_Nullable comment, NSError *_Nullable error);
typedef void (^MLSLocationResultBlock)(MaxSocialLocationInfo *_Nullable location, NSError *_Nullable error);


@interface MaxSocialUser : NSObject

///--------------------------------------
/// @name Properties
///--------------------------------------

/**
*  An opaque value that represents a user in your user system.
*/
@property (nonatomic, strong) NSString *userId;

/**
 *  The username of the user.
 */
@property (nullable, nonatomic, strong) NSString *username;

#pragma mark - Constructors
///--------------------------------------
/// @name Constructors
///--------------------------------------

/**
 *  Create a `MaxSocialUser` object using the opaque user id.
 *
 *  @param userId The opaque user id that represents a user in your user system.
 *
 *  @return A new `MaxSocialUser` object.
 */
+ (instancetype)userWithId:(NSString *)userId;

#pragma mark - Relation
///--------------------------------------
/// @name Relation
///--------------------------------------

/**
 *  Follow the user which has an id `userId`. The method calls `followUser:reverse:block:` by passing reverse `NO`.
 *
 *  @discussion The user following relation was maintained by a `MaxSocialRelationInfo` object. Following a user will create or update the relation object. And the callback will return the following results:
 *
 *  @code
 *  // on creation
 *  [
 *      {"createdAt":"2016-04-08T03:06:19.911Z","objectId":"5707202b238c8f00018dd535"},
 *      {}
 *  ]
 *
 *  // on updating
 *  [
 *      {"updateResult":1},
 *      {}
 *  ]
 *  @endcode
 *
 *  @param userId The followee's id.
 *  @param block  A block to return the follow operation result. The block should have the following signatures: (NSArray<NSDictionary*> *array, NSError *error)
 */
- (void)followUser:(NSString *)userId block:(MLArrayResultBlock)block;

/**
 *  Follow the user which has an id `userId`.
 *
 *
 *  @discussion The user following relation was maintained by a `MaxSocialRelationInfo` object. Following a user will create or update the relation object. And the callback will return the following results:
 *
 *  @code
 *  // on creation
 *  [
 *      {"createdAt":"2016-04-08T03:06:19.911Z","objectId":"5707202b238c8f00018dd535"},
 *      // if reverse is NO, the following dictionary will be empty
 *      {"createdAt":"2016-04-08T03:06:19.911Z","objectId":"5707202b238c8f00018dd535"}
 *  ]
 *
 *  // on updating
 *  [
 *      {"updateResult":1},
 *      {"updateResult":1}
 *  ]
 *  @endcode
 *
 *  @param userId  The followee's id.
 *  @param reverse Whether follow each other.
 *  @param block   A block to return the follow operation result. The block should have the following signatures: (NSArray<NSDictionary*> *array, NSError *error)
 */
- (void)followUser:(NSString *)userId reverse:(BOOL)reverse block:(MLArrayResultBlock)block;

/**
 *  Unfollow the user which has an id `userId`.
 *
 *  @param userId The followee's id.
 *  @param block  A block to return the unfollow operation result. The block should have the following signatures: (BOOL succeeded, NSError *error)
 */
- (void)unfollowUser:(NSString *)userId block:(MLBooleanResultBlock)block;

/**
 *  Block a follower. Followers were blocked cannot read your shuoshuos.
 *
 *  @param userId     The follower's id to block.
 *  @param completion A block to return the operation result. The block should have the following signatures: (BOOL succeeded, NSError *error)
 */
- (void)blockUser:(NSString *)userId completion:(MLBooleanResultBlock)completion;

/**
 *  Unblock a follower. Followers were blocked cannot read your shuoshuos.
 *
 *  @param userId     The follower's id to unblock.
 *  @param completion A block to return the operation result. The block should have the following signatures: (BOOL succeeded, NSError *error)
 */
- (void)unblockUser:(NSString *)userId completion:(MLBooleanResultBlock)completion;

/**
 *  Retrieve the `MaxSocialRelationInfo` object with `objectId`.
 *
 *  @param objectId The relation info object's objectId.
 *  @param block    A block to return the result. The block should have the following signatures: (MaxSocialRelationInfo *relation, NSError *error)
 */
- (void)getRelationInfoWithId:(NSString *)objectId block:(MLSRelationResultBlock)block;

/**
 *  Retrieve the `MaxSocialRelationInfo` object by userId and followerId.
 *
 *  @param userId     The followee id.
 *  @param followerId The follower id.
 *  @param block      A block to return the result. The block should have the following signatures: (MaxSocialRelationInfo *relation, NSError *error)
 */
- (void)getRelationInfoWithUserId:(NSString *)userId followerId:(NSString *)followerId block:(MLSRelationResultBlock)block;

/**
 *  Delete the relation info object by id.
 *
 *  @param relationInfoId The relation info object's objectId.
 *  @param block          A block to return the result. The block should have the following signatures: (BOOL succeeded, NSError *error)
 */
- (void)deleteRelationInfoWithId:(NSString *)relationInfoId block:(MLBooleanResultBlock)block;

/**
 *  Query the relation between `userId` and `anotherUserId`.
 *
 *  @param userId        The follower id.
 *  @param anotherUserId The followee id.
 *  @param block         A block to return the result. The block has 3 parameters: isFollowing indicates whether the `userId` is following the `anotherUserId`; isReverse indicates whether the `anotherUserId` is following `userId` at the same time; error represents any error occured while performing the request.
 */
+ (void)queryWhetherUser:(NSString *)userId isFollowingUser:(NSString *)anotherUserId resultBlock:(void(^)(BOOL isFollowing, BOOL isReverse, NSError *error))block;

/**
 *  Retrieve the followee list with a query object.
 *
 *  @param query A max social query object.
 *  @param block A block to return the result. The block should have the following signatures: (NSArray<MaxSocialRelationInfo*> *followees, NSError *error)
 */
- (void)getFolloweesWithQuery:(MaxSocialQuery *)query block:(MLArrayResultBlock)block;

/**
 *  Retrieve the follower list with a query object.
 *
 *  @param query A max social query object.
 *  @param block A block to return the result. The block should have the following signatures: (NSArray<MaxSocialRelationInfo*> *followers, NSError *error)
 */
- (void)getFollowersWithQuery:(MaxSocialQuery *)query block:(MLArrayResultBlock)block;

#pragma mark - Shuoshuo
///--------------------------------------
/// @name Shuoshuo
///--------------------------------------

/**
 *  Post a new shuoshuo.
 *
 *  @param shuoshuo The shuoshuo object.
 *  @param toSquare Whether post the shuoshuo to the square. If `NO`, the shuoshuo will not appear in shuoshuo square.
 *  @param block    A block to return the result. The block should have the following signatures: (BOOL succeeded, NSError *error)
 */
- (void)postShuoShuo:(MaxSocialShuoShuo *)shuoshuo toSquare:(BOOL)toSquare block:(MLBooleanResultBlock)block;

/**
 *  List user's own shuoshuo.
 *
 *  The result have the following structure:
 *  @code
 *  {
 *      "shuoshuos":[
 *                      ...
 *                      <MaxSocialShuoShuo objects>
 *                      ...
 *                  ],
 *      "comments" :{
 *                      "shuoshuoId" : [
 *                          ...
 *                          <MaxSocialComment objects>
 *                          ...
 *                      ],
 *                      ...
 *                  },
 *      "zans"     :{
 *                      "shuoshuoId" : [
 *                          ...
 *                          <MaxSocialComment objects>
 *                          ...
 *                      ],
 *                      ...
 *                  },
 *  }
 *  @endcode
 *
 *  @param query The query object.
 *  @param block A block to return the result. The block should have the following signatures: (NSDictionary *result, NSError *error)
 */
- (void)getShuoShuoWithQuery:(MaxSocialQuery *)query block:(MLDictionaryResultBlock)block;

/**
 *  Query shuoshuos posted in the square.
 *
 *  The result have the following structure:
 *  @code
 *  {
 *      "shuoshuos":[
 *                      ...
 *                      <MaxSocialShuoShuo objects>
 *                      ...
 *                  ],
 *      "comments" :{
 *                      "shuoshuoId" : [
 *                          ...
 *                          <MaxSocialComment objects>
 *                          ...
 *                      ],
 *                      ...
 *                  },
 *      "zans"     :{
 *                      "shuoshuoId" : [
 *                          ...
 *                          <MaxSocialComment objects>
 *                          ...
 *                      ],
 *                      ...
 *                  },
 *  }
 *  @endcode
 *
 *  @param query The query object.
 *  @param block A block to return the result. The block should have the following signatures: (NSDictionary *result, NSError *error)
 */
- (void)getLatestShuoShuoInSquareWithQuery:(MaxSocialQuery *)query block:(MLDictionaryResultBlock)block;

/**
 *  Query shuoshuos posted by user's followees.
 *
 *  The result have the following structure:
 *  @code
 *  {
 *      "shuoshuos":[
 *                      ...
 *                      <MaxSocialShuoShuo objects>
 *                      ...
 *                  ],
 *      "comments" :{
 *                      "shuoshuoId" : [
 *                          ...
 *                          <MaxSocialComment objects>
 *                          ...
 *                      ],
 *                      ...
 *                  },
 *      "zans"     :{
 *                      "shuoshuoId" : [
 *                          ...
 *                          <MaxSocialComment objects>
 *                          ...
 *                      ],
 *                      ...
 *                  },
 *  }
 *  @endcode
 *
 *  @param query The query object.
 *  @param block A block to return the result. The block should have the following signatures: (NSDictionary *result, NSError *error)
 */
- (void)getLatestShuoShuoInFriendCycleWithQuery:(MaxSocialQuery *)query block:(MLDictionaryResultBlock)block;

/**
 *  Query shuoshuos near the location.
 *
 *  The result have the following structure:
 *  @code
 *  {
 *      "shuoshuos":[
 *                      ...
 *                      <MaxSocialShuoShuo objects>
 *                      ...
 *                  ],
 *      "comments" :{
 *                      "shuoshuoId" : [
 *                          ...
 *                          <MaxSocialComment objects>
 *                          ...
 *                      ],
 *                      ...
 *                  },
 *      "zans"     :{
 *                      "shuoshuoId" : [
 *                          ...
 *                          <MaxSocialComment objects>
 *                          ...
 *                      ],
 *                      ...
 *                  },
 *  }
 *  @endcode
 *
 *  @param query The query object.
 *  @param block A block to return the result. The block should have the following signatures: (NSDictionary *result, NSError *error)
 */
- (void)getShuoShuoNearLocation:(MaxSocialLocation *)location distance:(int64_t)distance block:(MLDictionaryResultBlock)block;

/**
 *  Retrieve the image names of a shuoshuo.
 *
 *  @discussion The image name is an opaque string that represents an image. It's NOT a URI. The image can be download by calling `downloadImageWithName:ofShuoShuo:progress:completion:`.
 *
 *  @param shuoId The shuoshuo's objectId.
 *  @param block  A block to return the result. The block should have the following signatures: (NSArray<NSString*> *imageNames, NSError *error)
 */
- (void)getImageNamesOfShuoShuo:(NSString *)shuoId block:(MLArrayResultBlock)block;

/**
 *  Download the shuoshuo image by the given opaque image name.
 *
 *  @param imageName  An opaque string that represents an shuoshuo image.
 *  @param shuoId     The shuoshuo objectId.
 *  @param progress   A block to notify the image downloading progress. It should have the following signatures: (int percentDone)
 *  @param completion A block to return the result. It should have the following signatures: (NSString *downloadedImagePath, NSError *error)
 */
- (void)downloadImageWithName:(NSString *)imageName ofShuoShuo:(NSString *)shuoId progress:(nullable MLProgressBlock)progress completion:(nullable MLStringResultBlock)completion;

/**
 *  Retrieve a shuoshuo object with shuoshuoId.
 *
 *  @param shuoId The shuoshuo's objectId.
 *  @param block  A block to return the shuoshuo object. It should have the following signatures: (MaxSocialShuoShuo *status, NSError *error)
 */
- (void)fetchShuoShuoWithId:(NSString *)shuoId block:(MLSShuoShuoResultBlock)block;

/**
 *  Delete a shuoshuo by shuoshuoId. This also remove all photos related to the shuoshuo.
 *
 *  @param shuoId The shuoshuo's objectId.
 *  @param block  A block to return the result. It should have the following signatures: (BOOL shuoDelete, BOOL photosDelete, NSError *error)
 */
- (void)deleteShuoShuoWithId:(NSString *)shuoId block:(void(^)(BOOL shuoDelete, BOOL photosDelete, NSError *_Nullable error))block;

#pragma mark - Relation
///--------------------------------------
/// @name Location
///--------------------------------------

/**
 *  Update the user's location.
 *
 *  @param location A object that represents the user's location.
 *  @param block    A block to return the result. It should have the following signatures: (BOOL succeeded, NSError *error)
 */
- (void)updateLocation:(MaxSocialLocation *)location block:(MLBooleanResultBlock)block;

/**
 *  Find people near `location`. UserIds can be retrieved by reading `locationInfo.userId`.
 *
 *  @param location A location
 *  @param distance The radius
 *  @param block    The result callback. It should have the following signatures: (NSArray<MaxSocialLocationInfo*> *locationInfoList, NSError *error)
 */
- (void)queryUserNearLocation:(MaxSocialLocation *)location distance:(int64_t)distance block:(MLArrayResultBlock)block;

/**
 *  Retrieve user's location.
 *
 *  @param block The result callback. It should have the following signatures: (MaxSocialLocationInfo *locationInfo, NSError *error)
 */
- (void)getLocationInfoWithBlock:(MLSLocationResultBlock)block;

/**
 *  Retrieve location info object by objectId.
 *
 *  @param objectId The location info objectId.
 *  @param block    The result callback. It should have the following signatures: (MaxSocialLocationInfo *locationInfo, NSError *error)
 */
- (void)fetchLocationInfoWithObjectId:(NSString *)objectId block:(MLSLocationResultBlock)block;

/**
 *  Delete location info object by objectId.
 *
 *  @param objectId The lcoation info objectId.
 *  @param block    The callback. It should have the following signatures: (BOOL succeeded, NSError *error)
 */
- (void)deleteLocationInfoWithObjectId:(NSString *)objectId block:(MLBooleanResultBlock)block;

#pragma mark - Relation
///--------------------------------------
/// @name Comment
///--------------------------------------

/**
 *  Create a comment for a shuoshuo.
 *
 *  @param shuoId The id of shuoshuo to comment.
 *  @param text   The content of the comment.
 *  @param block  The result callback. It should have the following signatures: (MaxSocialComment *comment, NSError *error)
 */
- (void)createCommentForShuoShuo:(NSString *)shuoId withContent:(NSString *)text block:(MLSCommentResultBlock)block;

/**
 *  Mark a comment as read.
 *
 *  @param commentId The id of comment.
 *  @param block     The result callback. It should have the following signatures: (BOOL updated, NSError *error)
 */
- (void)markCommentAsRead:(NSString *)commentId completion:(void(^)(BOOL updated, NSError *_Nullable error))block;

/**
 *  Like a shuoshuo. This operation creates a comment without content.
 *
 *  @param shuoId The shuoshuoId
 *  @param block  The result callback. It should have the following signatures: (MaxSocialComment *comment, NSError *error)
 */
- (void)likeShuoShuo:(NSString *)shuoId block:(MLSCommentResultBlock)block;

/**
 *  Retrieve a comment object with commentId.
 *
 *  @param commentId The comment's objectId.
 *  @param block     The result callback. It should have the following signatures: (MaxSocialComment *comment, NSError *error)
 */
- (void)getCommentWithId:(NSString *)commentId block:(MLSCommentResultBlock)block;

/**
 *  Delete a comment by comentId.
 *
 *  @param commentId The comment's objectId.
 *  @param block     The result callback. It should have the following signatures: (BOOL succeeded, NSError *error)
 */
- (void)deleteCommentWithId:(NSString *)commentId block:(MLBooleanResultBlock)block;

/**
 *  Retrieve comments of a shuoshuo. The query object can be used to restrict the number of comments to return, and the order of comments.
 *
 *  @param shuoId The shuoshuoId
 *  @param query  A query object
 *  @param block  The result block. It should have the following signatures: (NSArray<MaxSocialComment*> *comments, NSError *error)
 */
- (void)getCommentOfShuoshuo:(NSString *)shuoId withQuery:(MaxSocialQuery *)query block:(MLArrayResultBlock)block;

/**
 *  Retrieve user's unread comments.
 *
 *  @param block The result block. It should have the following signatures: (NSArray<MaxSocialComment*> *comments, NSError *error)
 */
- (void)getUnreadCommentWithBlock:(MLArrayResultBlock)block;

@end

NS_ASSUME_NONNULL_END


