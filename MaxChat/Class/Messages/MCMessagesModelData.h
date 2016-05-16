
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "JSQMessages.h"




@interface MCMessagesModelData : NSObject

@property (nonatomic, weak) JSQMessagesViewController *messagesController;

@property (strong, nonatomic) NSMutableArray<JSQMessage*> *messages;
@property (strong, nonatomic) NSMutableDictionary *avatars;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

- (id)init NS_UNAVAILABLE;
- (id)initWithFriend:(MLIMFriendInfo*)aFriend;
- (id)initWithGroup:(MLIMGroup*)aGroup;

- (void)sendMessage:(JSQMessage *)message;
- (void)receiveMessage:(MLIMMessage *)obj;

// cache url
+ (NSURL *)cacheURLForMediaURL: (NSString *)attachmentUrl extension:(NSString * )extension;

// message utilities
+ (JSQMessage *)createVideoMediaMessageWithURL:(NSURL *)mediaURL;
+ (JSQMessage *)createAudioMediaMessageWithURL:(NSURL *)mediaURL;
+ (JSQMessage *)createPhotoMediaMessageWithImage:(UIImage *)image;
+ (JSQMessage *)createLocationMediaMessageCompletion:(JSQLocationMediaItemCompletionBlock)completion;
+ (JSQMessage *)createVideoMediaMessage;
+ (JSQMessage *)createAudioMediaMessage;
+ (JSQMessage *)createPhotoMediaMessage;


// video utilities
+ (BOOL) isVideoPortrait:(AVAsset *)asset;
+ (void)cropVideo:(AVAsset *)asset toUrl:(NSURL *)outputURL renderSize:(CGSize)renderSize start:(NSTimeInterval)start duration:(NSTimeInterval)duration presetName:(NSString *)presetName completion:(void(^)())completion;
+ (void)cropVideo:(AVAsset *)asset toUrl:(NSURL *)outputURL renderSizeScale:(CGSize)renderSizeScale start:(NSTimeInterval)start duration:(NSTimeInterval)duration presetName:(NSString *)presetName completion:(void(^)())completion;
+ (void)cropVideo:(AVAsset *)asset toUrl:(NSURL *)outputURL toSquareWithSide:(CGFloat)sideLength start:(NSTimeInterval)start duration:(NSTimeInterval)duration presetName:(NSString *)presetName completion:(void(^)())completion;
+ (void)cropVideo:(AVAsset *)asset toUrl:(NSURL *)outputURL toSquareWithScale:(CGFloat)scale start:(NSTimeInterval)start duration:(NSTimeInterval)duration presetName:(NSString *)presetName completion:(void(^)())completion;
@end
