//
//  MLIMClient.h
//  MaxLeapIM
//

#import <MaxIMLib/MLIMConstants.h>

@class MLIMUser,
MLIMFriendInfo,
MLIMGroup,
MLIMRoom,
MLIMMessage,
MLIMClientConfiguration;

@protocol MLIMClientDelegate;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int, MLIMClientStatus) {
    /* Initial client status */
    MLIMClientStatusNone,
    /* Client is logging in */
    MLIMClientStatusConnecting,
    /* Client is connected */
    MLIMClientStatusConnected,
    /* Client paused. Usually for network reason */
    MLIMClientStatusPaused,
    /* Client is reconnecting */
    MLIMClientStatusResuming,
    /* Client is closing (Logging out) */
    MLIMClientStatusClosing,
    /* Client is closed (did log out) */
    MLIMClientStatusClosed
};

/**
 *  A client representation of a user connection.
 */
@interface MLIMClient : NSObject

/**
 *  @name Properties
 */

/**
 *  The client status
 */
@property (nonatomic, readonly) MLIMClientStatus status;

/**
 *  The delegate object for the client. You can implement methods defined in protocol `MLIMClientDelegate` to handle client connection events, messages, friend online status change events.
 */
@property (nullable, nonatomic, weak) id<MLIMClientDelegate> delegate;

/**
 *  The current logged in user of this client.
 */
@property (nullable, nonatomic, readonly) MLIMUser *currentUser;

/**
 *  @name Creating Clients
 */

/**
 *  Creates an `MLIMClient` object using the config.
 *
 *  @note The property `appId` and `clientKey` must not be empty.
 *
 *  @param config the client configuration
 *
 *  @return a new instance of `MLIMClient`
 */
+ (instancetype)clientWithConfiguration:(MLIMClientConfiguration *)config;

/**
 *  Creates an `MLIMClient` object using `appId`, `clientKey` and `installationId`.
 *
 *  @param appId          The MaxLeap applicationId.
 *  @param clientKey      The MaxLeap application clientKey
 *  @param installationId The installationId for the [MLInstallation currentInstallation].
 *
 *  @return A new instance of `MLIMClient`
 */
+ (instancetype)clientWithAppId:(NSString *)appId clientKey:(NSString *)clientKey installationId:(nullable NSString *)installationId;

/**
 *  @name Login/Logout
 */

/**
 *  Login or signup with a user id, without password.
 *  UserId must match `[a-zA-Z0-9_\-]+`.
 *
 *  @param uid   The user id
 *  @param block The block to execute after login completion. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
- (void)loginWithUserId:(NSString *)uid completion:(MLIMBooleanResultBlock)block;

/**
 *  Login with username and password. Only the user registered in MaxLeap can login.
 *
 *  @param username The username of a `MLUser`
 *  @param password The password of a `MLUser`
 *  @param block    The block to execute after login completion. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
- (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(MLIMBooleanResultBlock)block;

/**
 *  Login with phone number and sms code. The sms code can be requested via calling api `+[MLUser requestLoginSmsCodeWithPhoneNumber:block:]`.
 *
 *  @param phoneNumber  The phone number of a `MLUser`
 *  @param smsCode      The sms code user received
 *  @param block        The block to execute after login completion. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
- (void)loginWithPhoneNumber:(NSString *)phoneNumber smsCode:(NSString *)smsCode completion:(MLIMBooleanResultBlock)block;

/**
 *  Login with oauth info from third party like facebook.
 *  
 *  The oauth data is stored in `[MLUser currentUser].oauthData`. It has the following structure:
 *  {"platformName":{"id":"", "access_token":"", ...}, ...}
 *
 *  @param OAuth The oauth info, must contain the user id and accessToken
 *  @param block The block to execute after login completion. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
- (void)loginWithThirdPartyOAuth:(NSDictionary *)OAuth completion:(MLIMBooleanResultBlock)block;

/**
 *  Disconnect the connection and logout.
 *
 *  @note After logout, this device cannot receive any furture messages send to the user, include offline push notifications.
 *
 *  @param block The block to execute after login completion. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
- (void)logoutWithCompletion:(MLIMBooleanResultBlock)block;

/**
 *  Disconnect the connection, do not logout. User will be offline and receive offline push notifications.
 */
- (void)pause;

/**
 *  Recover the connection, different from login. User will be online and receive realtime messages.
 */
- (void)resume;

/**
 *  @name Sending Messages
 */

/**
 *  Send messages.
 *
 *  @note The message should specify a receiver.
 *
 *  @param message The message to send, should specify a receiver.
 *  @param block   The block to execute after message sending. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
- (void)sendMessage:(MLIMMessage *)message completion:(nullable MLIMBooleanResultBlock)block;

/**
 *  Send message
 *
 *  @param message  The message to send, should specify a receiver.
 *  @param progress The progress block to notify attachment upload progress. The block should have the following argument signature: (int percentDone)
 *  @param block    The block to execute after message sending. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
- (void)sendMessage:(MLIMMessage *)message progress:(nullable MLIMProgressBlock)progress completion:(nullable MLIMBooleanResultBlock)block;

/**
 *  Send message to friend.
 *
 *  @param message The message to send, message.receiver will be mutated.
 *  @param uid     Friend's userId.
 *  @param block   Block to execute after message send completion. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
- (void)sendMessage:(MLIMMessage *)message toFriend:(NSString *)uid completion:(MLIMBooleanResultBlock)block;

/**
 *  Send message to group.
 *
 *  @param message The message to send, message.receiver will be mutated
 *  @param gid     The target group Id.
 *  @param block   The block should have the following signature: (BOOL succeeded, NSError *error)
 */
- (void)sendMessage:(MLIMMessage *)message toGroup:(NSString *)gid completion:(MLIMBooleanResultBlock)block;

/**
 *  Send message to room.
 *
 *  @param message The message to send. message.receiver will be mutated
 *  @param rid     The target roomId.
 *  @param block   The block should have the following signature: (BOOL succeeded, NSError *error)
 */
- (void)sendMessage:(MLIMMessage *)message toRoom:(NSString *)rid completion:(MLIMBooleanResultBlock)block;

/**
 *  @name Sending System Messages
 */

- (void)sendSystemMessage:(MLIMMessage *)message progress:(nullable MLIMProgressBlock)progress completion:(nullable MLIMBooleanResultBlock)block;

/**
 *  Send system message to all users. Only online users can recieve the message.
 *
 *  @param message message to send.
 *  @param block   A block to notify the result.
 */
- (void)sendSystemMessageToAllUsers:(MLIMMessage *)message completion:(MLIMBooleanResultBlock)block;

/**
 *  Send system message to single user. If the user is offline, a push notification will be send.
 *
 *  @param message the message
 *  @param uid     the user to send
 *  @param block   A block to notify the result.
 */
- (void)sendSystemMessage:(MLIMMessage *)message toUser:(NSString *)uid completion:(MLIMBooleanResultBlock)block;

/**
 *  Send system message to group. The offline users in the group will recieve push notifications.
 *
 *  @param message the message
 *  @param gid     the target group id
 *  @param block   A block to notify the result.
 */
- (void)sendSystemMessage:(MLIMMessage *)message toGroup:(NSString *)gid completion:(MLIMBooleanResultBlock)block;

/**
 *  Send system message to room. No offline notifications support.
 *
 *  @param message the message
 *  @param rid     the target room id
 *  @param block   A block to notify the result.
 */
- (void)sendSystemMessage:(MLIMMessage *)message toRoom:(NSString *)rid completion:(MLIMBooleanResultBlock)block;

@end

/**
 *  The methods decleared by `MLIMClientDelegate` protocol allows you handle client status change events, messages, and friend status change events.
 */
@protocol MLIMClientDelegate <NSObject>

@optional

/**
 *  Called when connection broken.
 *
 *  @param client The client object that disconnect.
 */
- (void)clientDidDisconnect:(MLIMClient *)client;

/**
 *  Called when client reconnect.
 *
 *  @param client The client object that attempts to reconnect.
 */
- (void)clientAttemptReconnect:(MLIMClient *)client;

/**
 *  Called when user login success.
 *
 *  @param client The client object that login success.
 */
- (void)clientDidLogin:(MLIMClient *)client;

/**
 *  Called when user logout.
 *
 *  @param client The client object that logout.
 */
- (void)clientDidLogout:(MLIMClient *)client;

/**
 *  Called when receive a message from friend or message send to friend by your other clients.
 *
 *  @param client  The client which received message.
 *  @param message The message received.
 *  @param aFriend The message sender.
 */
- (void)client:(MLIMClient *)client didReceiveMessage:(MLIMMessage *)message fromFriend:(MLIMFriendInfo *)aFriend;

/**
 *  Called when receive a message from group or message send to group by your other clients.
 *
 *  @param client  The client which received message.
 *  @param message The message received
 *  @param group   The group that message belongs to.
 */
- (void)client:(MLIMClient *)client didReceiveMessage:(MLIMMessage *)message fromGroup:(MLIMGroup *)group;

/**
 *  Called when receive a message from room or message send to room by your other clients.
 *
 *  @param client  The client which received message.
 *  @param message The message received.
 *  @param room    The room that message belongs to.
 */
- (void)client:(MLIMClient *)client didReceiveMessage:(MLIMMessage *)message fromRoom:(MLIMRoom *)room;

/**
 *  Called when receive a message from system.
 *
 *  @param client  The client which received message
 *  @param message The message received
 */
- (void)client:(MLIMClient *)client didReceiveSystemMessage:(MLIMMessage *)message;

/**
 *  Called when a friend online.
 *
 *  @param client  The client
 *  @param aFriend The friend online.
 */
- (void)client:(MLIMClient *)client friendDidOnline:(MLIMFriendInfo *)aFriend;

/**
 *  Called when a friend offline
 *
 *  @param client  The client
 *  @param aFriend The friend offline.
 */
- (void)client:(MLIMClient *)client friendDidOffline:(MLIMFriendInfo *)aFriend;

@end


/**
 *  Configuration options for a MLIMClient. You should not modify a configuration after a MLIMClient is created.
 */
@interface MLIMClientConfiguration : NSObject

/**
 *  (Required) The MaxLeap app's applicationId.
 */
@property (nonatomic, strong) NSString *appId;

/**
 *  (Required) The MaxLeap app's clientKey.
 */
@property (nonatomic, strong) NSString *clientKey;

/**
 *  (Optional) Should be set [MLInstallation currentInstallation].installationId.
 *  If not set, no offline push notification will be received.
 */
@property (nullable, nonatomic, strong) NSString *installationId;

/**
 *  If set `YES`, will print socket.io log.
 */
@property (nonatomic) BOOL shouldLog;

/**
 *  Should automatically reconnect or not. Default is `YES`.
 */
@property (nonatomic) BOOL autoReconnect;

/**
 *  The number of auto-reconnect attempts. Default is un-limited.
 */
@property (nonatomic) NSInteger reconnectAttempts;

/**
 *  The delay before reconnecting. Default is 0.
 */
@property (nonatomic) NSInteger reconnectWait;

/**
 *  Creates a default configuration.
 *
 *  @return A new configuration.
 */
+ (instancetype)defaultConfiguration;

@end



/**
 *  Post when user login. The user object can be retrieved from `notification.userInfo[@"user"]`.
 */
FOUNDATION_EXPORT NSString * const MLIMUserDidLoginNotification;

/**
 *  Post when receive a message from friend, group, room or yourself on other client. The message can be retrieved from `notification.userInfo[@"msg"]`.
 */
FOUNDATION_EXPORT NSString * const MLIMClientDidReceiveMessageNotification;

/**
 *  Post when receive a system message. The message can be retrieved from `notification.userInfo[@"msg"]`.
 */
FOUNDATION_EXPORT NSString * const MLIMClientDidReceiveSystemMessageNotification;

/**
 *  Post when friend online. The friend id can be retrieved from `notification.userInfo[@"id"]`
 */
FOUNDATION_EXPORT NSString * const MLIMFriendOnlineNotification;

/**
 *  Post when friend offline. The friend id can be retrieved from `notification.userInfo[@"id"]`
 */
FOUNDATION_EXPORT NSString * const MLIMFriendOfflineNotification;

NS_ASSUME_NONNULL_END

