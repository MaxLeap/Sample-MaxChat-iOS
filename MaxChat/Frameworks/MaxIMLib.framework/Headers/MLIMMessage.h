//
//  MLIMMessage.h
//  MaxLeapIM
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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
    MLIMMessageTargetTypeGroup,
    MLIMMessageTargetTypeRoom,
    MLIMMessageTargetTypeSingleUser = MLIMMessageTargetTypeFriend
};

NS_ASSUME_NONNULL_BEGIN

/**
 *  A representation of message sender or receiver.
 */
@interface MLIMMessageTarget : NSObject

/**
 *  The userId.
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
 *  Target Type.
 */
@property (nonatomic, readonly) MLIMMessageTargetType type;

@end

/**
 *  The representation of a message.
 */
@interface MLIMMessage : NSObject <NSSecureCoding, NSCopying>

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
@property (nonatomic, readonly) NSTimeInterval sendTimestamp;

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
 */
@property (nonatomic, copy, nullable) NSString *text;

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

