

#import "JSQMessages.h"
#import "MCMessagesModelData.h"

@interface MCMessagesViewController : JSQMessagesViewController <UIActionSheetDelegate, JSQMessagesComposerTextViewPasteDelegate>

@property (nonatomic, weak) MCMessagesModelData *messageModel;

@end
