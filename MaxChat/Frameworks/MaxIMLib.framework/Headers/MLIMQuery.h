//
//  MLIMQuery.h
//  MaxIMLib
//

#import <Foundation/Foundation.h>

@class MLIMUser, MLIMGroup, MLIMRoom;

NS_ASSUME_NONNULL_BEGIN

@interface MLIMQuery : NSObject

/** @name Creating a Query for a Class */

/*!
 Creats a new query object.
 
 @return A MLIMQuery object.
 */
+ (MLIMQuery *)query;

#pragma mark -
#pragma mark Pagination properties

/** @name Paginating Results */

/*!
 The number of objects to skip before returning any. 0 by default.
 */
@property (nonatomic) int skip;

/**
 *  A limit on the number of objects to return. The default limit is 20, with a
 *  maximum of 1000 results being returned at a time.
 */
@property (nonatomic) int limit;

/** @name Adding Basic Constraints */

/*!
 Add a constraint to the query that requires a particular attrName's value to be equal to the provided value.
 
 @param attrName The attribute name to be constrained.
 @param object   The value that must be equalled.
 */
- (void)whereAttribute:(NSString *)attrName equalTo:(NSString *)value;

#pragma mark -
#pragma mark Sorting

/** @name Sorting */

/*!
 Sort the results in ascending order with the given key.
 
 @param attrName The attribute to order by.
 */
- (void)orderByAscending:(NSString *)attrName;

/*!
 Also sort in ascending order by the given key.  The previous keys provided will precedence over this key.
 
 @param attrName The attribute to order by.
 */
- (void)addAscendingOrder:(NSString *)attrName;

/*!
 Sort the results in descending order with the given key.
 
 @param attrName The attribute to order by.
 */
- (void)orderByDescending:(NSString *)attrName;

/*!
 Also sort in descending order by the given key.  The previous keys provided will precedence over this key.
 
 @param attrName The attribute to order by.
 */
- (void)addDescendingOrder:(NSString *)attrName;

/*!
 Sort the results in descending order with the given descriptor.
 
 @param sortDescriptor The NSSortDescriptor to order by.
 */
- (void)orderBySortDescriptor:(NSSortDescriptor *)sortDescriptor;

/*!
 Sort the results in descending order with the given descriptors.
 
 @param sortDescriptors An NSArray of NSSortDescriptor instances to order by.
 */
- (void)orderBySortDescriptors:(nullable NSArray<NSSortDescriptor*> *)sortDescriptors;

#pragma mark -
#pragma mark Find Entities

/** @name Find Entities */

/**
 *  Find users.
 *
 *  @param block A block to return the result.
 */
- (void)findUserWithBlock:(void(^)(NSArray<MLIMUser *> *_Nullable users, NSError *_Nullable error))block;

/**
 *  Find groups.
 *
 *  @param block A block to return the result.
 */
- (void)findGroupWithBlock:(void(^)(NSArray<MLIMGroup *> *_Nullable groups, NSError *_Nullable error))block;

/**
 *  Find rooms.
 *
 *  @param block A block to return the result.
 */
- (void)findRoomWithBlock:(void(^)(NSArray<MLIMRoom *> *_Nullable rooms, NSError *_Nullable error))block;


@end

NS_ASSUME_NONNULL_END
