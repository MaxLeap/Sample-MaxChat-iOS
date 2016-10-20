//
//  MLIMPassenger.h
//  MaxIMLib
//

#import <Foundation/Foundation.h>
#import "MLIMConstants.h"
#import "MLIMRuntimeObject.h"

@class MLIMMessage;

NS_ASSUME_NONNULL_BEGIN

/**
 *  A MLIMPassenger object represent a passenger.</br>
 *  A passenger can have some custom attributes. You can access them using 
 *  `[passenger objectForKey:@"attrname"]` or `passenger[@"attrname"]` syntax.
 *
 *  You can also create a subclass that inherits from MLIMPassenger, defining
 *  some dynamic property to access the attributes. A simple example:
 *
 *  @code
 *  @interface MyPassenger : MLIMPassenger
 *  @property (nonatomic) int age;
 *  @end
 *
 *  @implementation MYPassenger
 *  // !!!IMPORTANT!!! The property `age` must be declared as dynamic property.
 *  @dynamic age;
 *
 *  @end
 *
 *  // Then, you can get the passenger's age by using `passenger.age` syntax.
 *  @endcode
 */
@interface MLIMPassenger : MLIMRuntimeObject

/**
 *  The passenger id.
 */
@property (nonatomic, strong) NSString *pid;

/**
 *  Create an instance of MLIMPassenger with passenger id.
 *
 *  @param pid the passenger id
 *
 *  @return A new instance of MLIMPassenger.
 */
+ (instancetype)passengerWithId:(NSString *)pid;

/**
 *  Create or update a passenger with attributes.
 *
 *  If passenge with the id `attributes[@"id"]` exsits, update it,
 *  otherwise, create a new passenger.
 *
 *  The api always create new passenger if attributes[@"id"] is empty.
 *
 *  @param attributes The custom passenger attributes.
 *  @param completion A block to notify the result.
 */
+ (void)createOrUpdatePassengerWithAttributes:(NSDictionary<NSDictionary *, id> *)attributes
                                   completion:(void(^)(MLIMPassenger *_Nullable passenger,
                                                       NSError *_Nullable error)
                                               )completion;

/**
 *  Update passenger attributes. The keys that are not in the attributes will not be updated.
 *
 *  @param attributes Attributes to update
 *  @param completion A block to notify the resutl.
 */
- (void)updatePassengerAttributes:(NSDictionary<NSString *, id> *)attributes
                       completion:(MLIMBooleanResultBlock)completion;

/**
 *  Fetch the passenger's attributes.
 *
 *  @param completion A block to notify the result.
 */
- (void)fetchWithCompletion:(MLIMBooleanResultBlock)completion;

/**
 *  Get history messages chat with user.
 *
 *  @param userId     The talking target
 *  @param ts         The timestamp
 *  @param limit      Limit for message count return
 *  @param completion A block to notify the result.
 */
- (void)getHistoryMessagesWithUser:(NSString *)userId
                        beforeTime:(NSTimeInterval)ts
                             limit:(int)limit
                        completion:(void(^)(NSArray<MLIMMessage *> *_Nullable messages,
                                            NSError *_Nullable error)
                                    )completion;

@end

NS_ASSUME_NONNULL_END
