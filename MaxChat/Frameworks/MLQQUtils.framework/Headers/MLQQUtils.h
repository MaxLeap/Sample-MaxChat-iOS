//
//  MLQQUtils.h
//  MLQQUtils
//
//  Created by Sun Jin on 3/9/16.
//  Copyright © 2016 maxleap. All rights reserved.
//

#import <MaxLeap/MaxLeap.h>

@class TencentOAuth;
@protocol TencentSessionDelegate;

NS_ASSUME_NONNULL_BEGIN

/*!
 The `MLQQUtils` class provides utility functions for using QQ authentication with <MLUser>s.
 */
@interface MLQQUtils : NSObject

///--------------------------------------
/// @name Interacting With QQ
///--------------------------------------

/*!
 @abstract Initializes MaxLeap QQ Utils.
 
 @warning You must invoke this in order to use the QQ functionality in MaxLeap.
 
 @param appId Your qq appId.
 @param delegate The delegate used to create `TencentOAuth` instance.
 */
+ (void)initializeQQWithAppId:(NSString *)appId qqDelegate:(id<TencentSessionDelegate>)delegate;

/*!
 @abstract `TencentOAuth` provides methods for configuring login behavior, default audience and managing QQ Access Token.
 
 @returns An instance of `TencentOAuth` that is used by `MLQQUtils`.
 */
+ (TencentOAuth *)tencentOAuth;

///--------------------------------------
/// @name Logging In
///--------------------------------------

/*!
 @abstract *Asynchronously* logs in a user using QQ with read permissions.
 
 @discussion This method delegates to the Tencent Open API SDK to authenticate the user,
 and then automatically logs in (or creates, in the case where it is a new user) a <MLUser>.
 
 @param permissions Array of read permissions to use.
 @param block       The block to execute when the log in completes.
 It should have the following signature: `^(MLUser *user, NSError *error)`.
 */
+ (void)loginInBackgroundWithPermissions:(NSArray ML_GENERIC(NSString*) *)permissions
                                       block:(nullable MLUserResultBlock)block;

/*!
 @abstract *Asynchronously* logs in a user using given Facebook Acess Token.
 
 @discussion This method delegates to the Tencent Open API SDK to authenticate the user,
 and then automatically logs in (or creates, in the case where it is a new user) a <MLUser>.
 
 @param tencentOAuth An instance of `TencentOAuth` to use when logging in.
 @param block        The block to execute when the log in completes.
 It should have the following signature: `^(MLUser *user, NSError *error)`.
 */
+ (void)loginInBackgroundWithTencentOAuth:(TencentOAuth *)tencentOAuth
                                   block:(nullable MLUserResultBlock)block;

///--------------------------------------
/// @name Linking Users
///--------------------------------------

/*!
 @abstract *Asynchronously* links Facebook with read permissions to an existing <MLUser>.
 
 @discussion This method delegates to the Tencent Open API SDK to authenticate
 the user, and then automatically links the account to the <MLUser>.
 It will also save any unsaved changes that were made to the `user`.
 
 @param user        User to link to Facebook.
 @param permissions Array of read permissions to use.
 @param block       The block to execute when the linking completes.
 It should have the following signature: `^(BOOL succeeded, NSError *error)`.
 */
+ (void)linkUserInBackground:(MLUser *)user
         withPermissions:(NSArray ML_GENERIC(NSString *) *)permissions
                       block:(nullable MLBooleanResultBlock)block;

/*!
 @abstract *Asynchronously* links Facebook Access Token to an existing <MLUser>.
 
 @discussion This method delegates to the Tencent Open API SDK to authenticate
 the user, and then automatically links the account to the <MLUser>.
 It will also save any unsaved changes that were made to the `user`.
 
 @param user         User to link to Facebook.
 @param tencentOAuth An instance of `TencentOAuth` to use.
 @param block        The block to execute when the linking completes.
 It should have the following signature: `^(BOOL succeeded, NSError *error)`.
 */
+ (void)linkUserInBackground:(MLUser *)user
             withTencentOAuth:(TencentOAuth *)tencentOAuth
                       block:(nullable MLBooleanResultBlock)block;

/*!
 @abstract Unlinks the <MLUser> from a Facebook account *asynchronously*.
 
 @param user User to unlink from Facebook.
 @param block The block to execute.
 It should have the following argument signature: `^(BOOL succeeded, NSError *error)`.
 */
+ (void)unlinkUserInBackground:(MLUser *)user block:(nullable MLBooleanResultBlock)block;

///--------------------------------------
/// @name Getting Linked State
///--------------------------------------

/*!
 @abstract Whether the user has their account linked to Facebook.
 
 @param user User to check for a facebook link. The user must be logged in on this device.
 
 @returns `YES` if the user has their account linked to Facebook, otherwise `NO`.
 */
+ (BOOL)isLinkedWithUser:(nullable MLUser *)user;

@end

NS_ASSUME_NONNULL_END

