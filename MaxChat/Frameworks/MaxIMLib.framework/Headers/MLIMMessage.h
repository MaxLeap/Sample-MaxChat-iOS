//
//  MLIMMessage.h
//  MaxLeapIM
//

#import <UIKit/UIKit.h>
#import "MLIMRuntimeObject.h"

typedef NS_ENUM(int, MLIMMessageStatus) {
    /*  */
    MLIMMessageStatusNone = 0,
    
    /*  */
    MLIMMessageStatusSending,
    
    /*  */
    MLIMMessageStatusSent,
    
    /*  */
    MLIMMessageStatusReceived,
    
    /*  */
    MLIMMessageStatusFailed
};

typedef NS_ENUM(int, MLIMMediaType) {
    MLIMMediaTypeText,
    MLIMMediaTypeImage,
    MLIMMediaTypeAudio,
    MLIMMediaTypeVideo
};

typedef NS_ENUM(int, MLIMMessageTargetType) {
    MLIMMessageTargetTypeToAll = -3,
    MLIMMessageTargetTypeSystem = -2,
    MLIMMessageTargetTypeNone = -1,
    MLIMMessageTargetTypeFriend = 0,
    MLIMMessageTargetTypeGroup = 1,
    MLIMMessageTargetTypeRoom = 2,
    MLIMMessageTargetTypePassenger = 3,
    MLIMMessageTargetTypeStranger = 4,
    
    MLIMMessageTargetTypeSingleUser __deprecated = MLIMMessageTargetTypePassenger
};

NS_ASSUME_NONNULL_BEGIN

///--------------------------------------
/// @name MLIMMessageTarget
///--------------------------------------

/**
 *  A representation of message sender or receiver.
 */
@interface MLIMMessageTarget : NSObject

/**
 *  The id of a user, passenger or stranger.
 */
@property (nonatomic, strong, nullable) NSString *userId;

/**
 *  The target gourpId.
 */
@property (nonatomic, strong, nullable) NSString *groupId;

/**
 *  The target roomId.
 */
@property (nonatomic, strong, nullable) NSString *roomId;

/**
 *  The target passenger's id.
 */
@property (nonatomic, strong, nullable) NSString *passengerId __deprecated_msg("Access userId instead");

/**
 *  Target Type.
 */
@property (nonatomic) MLIMMessageTargetType type;

@end

///--------------------------------------
/// @name MLIMMessage
///--------------------------------------

/**
 *  The representation of a message.
 */
@interface MLIMMessage : MLIMRuntimeObject <NSSecureCoding, NSCopying>

/**
 *  @name Properties
 */

/**
 *  Message status @see MLIMMessageStatus
 */
@property (nonatomic, readonly) MLIMMessageStatus status;

/**
 *  The message send timestamp. Seconds since 1970.
 */
@property (nonatomic) NSTimeInterval sendTimestamp;

/**
 *  The message sender.
 */
@property (nonatomic, readonly) MLIMMessageTarget *sender;

/**
 *  The message receiver.
 */
@property (nonatomic, readonly) MLIMMessageTarget *receiver;

/**
 *  Check whether a message is from system.
 *
 *  @return `YES` if from system, `NO` otherwise.
 */
- (BOOL)isSystemMessage;

/**
 *  The media type of the message.
 */
@property (nonatomic) MLIMMediaType mediaType;

/**
 *  Text of text message, `nil` if mediaType != MLIMMediaTypeText.
 *
 *  @disscussion MaxLeap recommends that you use the `remark` property to define custom message structure.
 */
@property (nonatomic, copy, nullable) NSString *text;

/**
 *  If NO, this message will not trigger a remote push notification.
 */
@property (nonatomic) BOOL pushEnable;

/**
 *  The name of a sound file in the app bundle or in the Library/Sounds folder of the app’s data container.
 *  See https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/TheNotificationPayload.html for details.
 */
@property (nonatomic, strong) NSString *pushSound;

/**
 *  The prefix for push notification.
 */
@property (nonatomic, copy, nullable) NSString *pushPrefix;

/**
 *  The suffix for push notification.
 */
@property (nonatomic, copy, nullable) NSString *pushSuffix;

/**
 *  The message body for push notification. If the value of this property doesn't exist, message.text will be used.
 *
 *  The final push alert body is: pushPrefix + (pushBodyOverwrite || message.text) + pushSuffix.
 */
@property (nonatomic, copy, nullable) NSString *pushBodyOverwrite;

/**
 *  The `content-available` key in aps. See https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/TheNotificationPayload.html for details.
 */
@property (nonatomic) BOOL pushContentAvailable;

/**
 *  Some addtional information for the message.
 *
 *  @disscussion MaxLeap recommends that you use this property to define custom message structure.
 */
@property (nonatomic, copy, nullable) NSString *remark;

/**
 *  The attachment url of non-text message.
 */
@property (nonatomic, copy, nullable) NSString *attachmentUrl;

/**
 *  @name Creates a new message.
 */

/**
 *  Creates a message object from message payload.
 *
 *  @param dictionary The message payload dictionary.
 *
 *  @return A new message object.
 */
- (instancetype)initWithPayloadDictionary:(NSDictionary *)dictionary;

/**
 *  Creates a new text message with the `text`.
 *
 *  @param text The content of text message.
 *
 *  @return A new text message object. Will throw an exception if text is `nil`.
 */
+ (instancetype)messageWithText:(NSString *)text;

/**
 *  Creates a new image message with an image.
 *
 *  @param image The content of image message.
 *
 *  @return A new image message object.
 */
+ (nullable instancetype)messageWithImage:(UIImage *)image;

/**
 *  Creates a new image message with the path to the image file.
 *
 *  @param imagePath The path to the image file.
 *
 *  @return A new image message object.
 */
+ (nullable instancetype)messageWithImageFileAtPath:(NSString *)imagePath;

/**
 *  Creates a new audio message with audio file path.
 *
 *  @param path The audio file path.
 *
 *  @return A new audio message object.
 */
+ (nullable instancetype)messageWithAudioFileAtPath:(NSString *)path;

/**
 *  Creates a video message with video file path.
 *
 *  @param path The video file path
 *
 *  @return A new video message object.
 */
+ (nullable instancetype)messageWithVideoFileAtPath:(NSString *)path;

//TODO: message attachment download api

@end

NS_ASSUME_NONNULL_END

