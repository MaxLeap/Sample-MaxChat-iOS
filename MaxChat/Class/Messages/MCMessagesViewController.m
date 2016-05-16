#import "MCVideoMediaItem.h"
#import "MCMessagesViewController.h"
#import "MaxChatIMClient.h"

#define TIMECAPTIONSPACE 2

@interface MCMessagesViewController() <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation MCMessagesViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.senderId = IMCurrentUserID;
    self.senderDisplayName = IMCurrentUserID;
    
    self.inputToolbar.contentView.textView.pasteDelegate = self;
    self.showLoadEarlierMessagesHeader = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MLAnalytics endLogPageView:@"MCMessagesViewController"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MLAnalytics beginLogPageView:@"MCMessagesViewController"];

    self.collectionView.collectionViewLayout.springinessEnabled = NO;
}


#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    
    [self.messageModel sendMessage:message];
    
    [self finishSendingMessageAnimated:YES];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Media messages"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Send photo", @"Send video", @"Send audio", @"Send location",  nil];
    
    [sheet showFromToolbar:self.inputToolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
        return;
    }
    
    switch (buttonIndex) {
            case 0:
            [self pickPhotoAndSend];
            break;
            
            case 1:
            [self pickVideoAndSend];
            break;
            
            case 2:
            [self.messageModel sendMessage:[MCMessagesModelData createAudioMediaMessage]];
            break;
            
            case 3:
        {
            __weak UICollectionView *weakView = self.collectionView;
            
            JSQMessage *message = [MCMessagesModelData createLocationMediaMessageCompletion:^{
                [weakView reloadData];
            }];
            [self.messageModel sendMessage:message];
        }
            break;
            
            
        default:
            break;
    }
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [self finishSendingMessageAnimated:YES];
}

- (void)pickPhotoAndSend {
    UIImagePickerController *imagePickController=[[UIImagePickerController alloc]init];
    imagePickController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickController.delegate=self;
    
    imagePickController.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePickController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    
    imagePickController.allowsEditing=NO;
    [self presentViewController:imagePickController animated:YES completion:nil];
}

- (void)pickVideoAndSend {
    UIImagePickerController *imagePickController=[[UIImagePickerController alloc]init];
    imagePickController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickController.delegate=self;
    
    imagePickController.mediaTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeAVIMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];
    imagePickController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    
    imagePickController.allowsEditing=NO;
    [self presentViewController:imagePickController animated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL *mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
    if (mediaURL) {
        // video
        NSLog(@"mediaURL = %@", mediaURL);
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     [SVProgressHUD showWithStatus:@"正在处理视频"];
                                     
                                     NSDictionary *asset_options = @{AVURLAssetPreferPreciseDurationAndTimingKey: @YES};
                                     AVAsset *avAsset = [[AVURLAsset alloc] initWithURL:mediaURL options:asset_options];
                                     NSURL *cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory: NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
                                     NSURL *saveUrl = [NSURL fileURLWithPath:@"output.mp4" relativeToURL:cacheUrl];
                                     [MCMessagesModelData cropVideo:avAsset
                                                              toUrl:saveUrl
                                                  toSquareWithScale:0.3
                                                              start:0
                                                           duration:5
                                                         presetName:AVAssetExportPresetMediumQuality completion:^{
                                                             [self.messageModel sendMessage: [MCMessagesModelData createVideoMediaMessageWithURL:saveUrl]];
                                                             [SVProgressHUD dismiss];
                                                             [JSQSystemSoundPlayer jsq_playMessageSentSound];
                                                             [self finishSendingMessageAnimated:YES];
                                                         }];
                                 }];
    } else {
        UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
        ILSLogImage(@"SelectImage", image);
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     UIImage *resizedImage;
                                     CGSize size = image.size;
                                     resizedImage = [image imageByScalingAndCroppingForSize:CGSizeMake(size.width/4, size.height/4)];
                                     [self.messageModel sendMessage: [MCMessagesModelData createPhotoMediaMessageWithImage: resizedImage]];
                                     [JSQSystemSoundPlayer jsq_playMessageSentSound];
                                     [self finishSendingMessageAnimated:YES];
                                 }];
    }
}


#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messageModel.messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [self.messageModel.messages removeObjectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messageModel.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.messageModel.outgoingBubbleImageData;
    }
    
    return self.messageModel.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messageModel.messages objectAtIndex:indexPath.item];
    return [self.messageModel.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % TIMECAPTIONSPACE == 0) {
        JSQMessage *message = [self.messageModel.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messageModel.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messageModel.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messageModel.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    JSQMessage *msg = [self.messageModel.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}



#pragma mark - UICollectionView Delegate
// 如果视频media cell消失，则关闭正在播放的视频
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *msg = [self.messageModel.messages objectAtIndex:indexPath.item];
    if (msg.isMediaMessage && [msg.media isKindOfClass:[MCVideoMediaItem class]]) {
        [(MCVideoMediaItem *)msg.media endDisplaying];
    }
}

#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % TIMECAPTIONSPACE == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.messageModel.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messageModel.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods


- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    if ([UIPasteboard generalPasteboard].image) {
        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:[NSDate date]
                                                             media:item];
        [self.messageModel.messages addObject:message];
        [self finishSendingMessage];
        return NO;
    }
    return YES;
}

@end
