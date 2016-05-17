//
//  MCCreateNewPostViewController.m
//  MaxChat
//
//  Created by 周和生 on 16/5/11.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "MCCreateNewPostViewController.h"
#import <AssetsLibrary/ALAsset.h>
#import "MCPhotoBroswer.h"
#import "MCLotteryCommentImageCell.h"
#import "UIImage+Additions.h"

#import "Constants.h"
@import SVProgressHUD;
@import MaxSocial;
@import MaxLeap;

NSString * const newPostPlaceholderText = @"说点什么吧...";

@interface MCCreateNewPostViewController ()  <UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, MCPhotoBroswerDataSource, MCPhotoBroswerDelegate>

@property (weak, nonatomic) IBOutlet UIView *postBgView;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *separatorLine;

@property (weak, nonatomic) IBOutlet UIView *permissionsView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *permissionNotesLabel;
@property (weak, nonatomic) IBOutlet UILabel *permissionStatusLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendToSquareViewTopConstraint; //set to 8 to hide permissionView
@property (weak, nonatomic) IBOutlet UILabel *sendToSquareLabel;
@property (weak, nonatomic) IBOutlet UISwitch *toggleSwitch;

@property (nonatomic, strong) UIAlertController *actionController;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@property (nonatomic, copy) NSString *contentString;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *imageAssetPaths;
@property (nonatomic, strong) NSMutableArray *imageURLs;
@property (nonatomic, assign) BOOL sendToSquare;


@property (strong, nonatomic) MCPhotoBroswer *imagePreviewView;
@property (nonatomic, copy) NSString *uploadImageTempDirectory;
@end

@implementation MCCreateNewPostViewController
#pragma mark - dealloc Method
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kSeparatorLineColor;
    self.navigationItem.title = @"创建说说";
    [self configureSubViews];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MCLotteryCommentImageCell" bundle: nil] forCellWithReuseIdentifier:@"MCLotteryCommentImageCell"];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [[NSFileManager defaultManager] removeItemAtPath:self.uploadImageTempDirectory error:nil];
    }
    
    [super viewWillDisappear:animated];
}

#pragma mark- SubView Configuration
- (void)configureSubViews {
    [self configureNavigationBar];
    [self configurePostView];
    [self configureCollectionView];
    //    [self configurePermissionStatusView];
    [self configureSendToSquareView];
    
    self.separatorLine.backgroundColor = kSeparatorLineColor;
}

- (void)configureNavigationBar {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStyleDone target:self action:@selector(submitNewPost)];
}

- (void)configurePostView {
    self.postBgView.backgroundColor = [UIColor whiteColor];
    
    [self configureTextView];
    [self configureCollectionView];
}

- (void)configureTextView {
    self.textView.textColor = kDefaultGrayColor;
    self.textView.text = newPostPlaceholderText;
    self.textView.returnKeyType = UIReturnKeyDone;
    self.textView.enablesReturnKeyAutomatically = YES;
    self.textView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidBeginEditing) name:UITextViewTextDidBeginEditingNotification object:self.textView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange) name:UITextViewTextDidChangeNotification object:self.textView];
}

- (void)configureCollectionView {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self updateCollectionViewHeight];
}

- (void)configurePermissionStatusView {
    self.permissionsView.backgroundColor = [UIColor whiteColor];
    self.imageView.image = ImageNamed(@"ic_item_default");
    self.imageView.layer.cornerRadius = self.imageView.bounds.size.width / 2;
    self.imageView.layer.masksToBounds = YES;
    self.permissionNotesLabel.text = @"谁可以看";
    self.permissionNotesLabel.textColor = kDefaultTextColor;
    self.permissionStatusLabel.textColor = kDefaultGrayColor;
    self.permissionStatusLabel.text = @"全部好友可见";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(modifyPermissionStatus)];
    [self.permissionsView addGestureRecognizer:tap];
    self.permissionsView.userInteractionEnabled = YES;
    
    //hide permissionView
    self.permissionsView.hidden = YES;
}

- (void)configureSendToSquareView {
    self.sendToSquareLabel.text = @"发布到广场";
    self.sendToSquareLabel.textColor = kDefaultTextColor;
    self.toggleSwitch.on = NO;
    
    self.sendToSquareViewTopConstraint.constant = 8;
}

#pragma mark- Action
- (void)submitNewPost {
    if (self.contentString.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"内容不能为空" ];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在发表说说，请稍候..." maskType:SVProgressHUDMaskTypeBlack];
    // 一条带文字和图片的说说
    MaxSocialShuoShuoContent *content = [MaxSocialShuoShuoContent contentWithText:self.contentString imageURLs:self.imageURLs];
    MaxSocialShuoShuo *shuoshuo = [[MaxSocialShuoShuo alloc]init];
    shuoshuo.content = content;
    [MLAnalytics trackEvent:@"发布说说" parameters:@{@"sendToSquare":self.sendToSquare?@"YES":@"NO"}];
    [MaxSocialCurrentUser postShuoShuo:shuoshuo toSquare:self.sendToSquare block:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [SVProgressHUD showSuccessWithStatus:@"发表成功"];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [SVProgressHUD showErrorWithStatus:@"发表失败"];
        }
    }];
}

- (IBAction)toggleSwitchValueChanged:(id)sender {
    self.sendToSquare = self.toggleSwitch.on;
}


#pragma mark- Delegate，DataSource, Callback Method
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MCLotteryCommentImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MCLotteryCommentImageCell" forIndexPath:indexPath];
    
    if (indexPath.row == [collectionView numberOfItemsInSection:0] - 1) {
        cell.imageView.layer.borderWidth = 1;
        cell.imageView.layer.borderColor = kSeparatorLineColor.CGColor;
        cell.imageView.image = ImageNamed(@"add_item");
        cell.deleteButton.hidden = YES;
        
    } else {
        cell.imageView.layer.borderColor = [UIColor clearColor].CGColor;
        cell.imageView.image = self.images[indexPath.row];
        [cell.deleteButton setImage:ImageNamed(@"ic_single_delete") forState:UIControlStateNormal];
        cell.deleteButton.hidden = NO;
        __weak typeof(self) wSelf = self;
        cell.removeImageBlock = ^{
            [wSelf.images removeObjectAtIndex:indexPath.row];
            
            NSURL *imagePathURL = [wSelf.imageURLs objectAtIndex:indexPath.row];
            [[NSFileManager defaultManager] removeItemAtURL:imagePathURL error:nil];
            [wSelf.imageURLs removeObjectAtIndex:indexPath.row];
            
            [wSelf.imageAssetPaths removeObjectAtIndex:indexPath.row];
            [wSelf.collectionView reloadData];
        };
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == [collectionView numberOfItemsInSection:0] - 1) {
        if (self.images.count == 9) {
            [SVProgressHUD showErrorWithStatus:@"最多仅可选择9张图片"];
            return;
        }
        
        [self presentViewController:self.actionController animated:YES completion:nil];
        
    } else {
        MCLotteryCommentImageCell *cell = (MCLotteryCommentImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        CGRect relativeFrame = [self frameInRootViewForCellAtIndexPath:indexPath];
        [self.imagePreviewView showImage:cell.imageView.image originPage:indexPath.row originLocation:relativeFrame];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (!image) {
        [SVProgressHUD showErrorWithStatus:@"无效图片"];
        return;
    }
    
    void (^imageSelectionCompletion)(NSURL *assetURL) = ^(NSURL *assetURL) {
        if (assetURL && ![self.imageAssetPaths containsObject:assetURL]) {
            NSURL *diskPathOfImage = [self writeImage:image];
            if (diskPathOfImage) {
                [self.images addObject:image];
                [self.imageAssetPaths addObject:assetURL];
                [self.imageURLs addObject:diskPathOfImage];
                
                [self updateCollectionViewHeight];
                [self.collectionView reloadData];
            }
        }
    };
    
    if (self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error ) {
            BLOCK_SAFE_ASY_RUN_MainQueue(imageSelectionCompletion, assetURL);
        }];
        
    } else {
        NSURL *assetURL = info[UIImagePickerControllerReferenceURL];
        BLOCK_SAFE_ASY_RUN_MainQueue(imageSelectionCompletion, assetURL);
    }
    
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (NSURL *)writeImage:(UIImage *)image {
    if (!image) {
        return nil;
    }
    
    UIImage *scaledImage = [image imageScaleAspectToMaxSize:640];
    NSData *webData = UIImagePNGRepresentation(scaledImage);
    
    BOOL isExistUploadImageDirectory = [[NSFileManager defaultManager] fileExistsAtPath:self.uploadImageTempDirectory];
    if (!isExistUploadImageDirectory) {
        [[NSFileManager defaultManager] createDirectoryAtPath:self.uploadImageTempDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    int timeinterval = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%@.png", [@(timeinterval) stringValue]];
    NSString *imageFilePath = [self.uploadImageTempDirectory stringByAppendingPathComponent:fileName];
    [webData writeToFile:imageFilePath atomically:NO];
    
    NSURL *imagePathURL = [NSURL fileURLWithPath:imageFilePath];
    
    return imagePathURL;
}

#pragma mark MFLMImagePreviewViewDataSource
- (NSUInteger)numberOfPhotoInPhotoBroswer:(MCPhotoBroswer *)photoBroswer {
    return [self.images count];
}

- (UIImage *)photoBroswer:(MCPhotoBroswer *)photoBroswer thumbnieImageAtIndex:(NSUInteger)index {
    return self.images[index];
}

//#pragma mark MFLMImagePreviewDelegate
- (CGRect)finalDismissFrameAtPage:(NSUInteger)page inPhotoBroswer:(MCPhotoBroswer *)photoBroswer {
    CGRect frame = [self frameInRootViewForCellAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0]];
    return frame;
}

- (void)photoBroswer:(MCPhotoBroswer *)photoBroswer didShowPhotoAtIndex:(NSUInteger)page {
}

- (void)photoBroswer:(MCPhotoBroswer *)photoBroswer willExitPhotoAtIndex:(NSUInteger)index {
    
}

- (void)photoBroswer:(MCPhotoBroswer *)photoBroswer didDismissPhotoAtIndex:(NSUInteger)index {
    
}

#pragma mark- Override Parent Method

#pragma mark- Private Method
- (void)updateCollectionViewHeight {
    NSUInteger rowCount = [self collectionViewRowCount];
    self.collectionViewHeightConstraint.constant = rowCount * kLotteryCommentImageCellHeight;
}

- (CGFloat)collectionViewRowCount {
    NSUInteger numberOfImagesPerRow = (self.view.bounds.size.width - 10) / 70;
    NSUInteger rowCount =  (self.images.count + 1) / numberOfImagesPerRow;
    if ((self.images.count + 1) % numberOfImagesPerRow > 0) {
        rowCount++;
    }
    return rowCount;
}

- (void)textViewDidBeginEditing {
    if ([self.textView.text isEqualToString:newPostPlaceholderText]) {
        self.textView.textColor = kDefaultTextColor;
        self.textView.text = @"";
    }
}

- (void)textViewDidChange {
    if (self.textView.text.length > 140) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"不得超过140字!", @"")];
        
        self.textView.text = [self.textView.text substringToIndex:140];
        return;
    }
    
    self.contentString = self.textView.text;
}

- (void)modifyPermissionStatus {
    [self performSegueWithIdentifier:@"MCTimelinePermissionSettingsControllerSegueIdentifier" sender:nil];
}

#pragma mark- Getter Setter
- (NSMutableArray *)images {
    if (!_images) {
        _images = [NSMutableArray new];
    }
    return _images;
}

- (NSMutableArray *)imageURLs {
    if (!_imageURLs) {
        _imageURLs = [NSMutableArray new];
    }
    return _imageURLs;
}

- (NSMutableArray *)imageAssetPaths {
    if (!_imageAssetPaths) {
        _imageAssetPaths = [NSMutableArray new];
    }
    return _imageAssetPaths;
}


- (UIAlertController *)actionController {
    if (!_actionController) {
        _actionController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
                self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:self.imagePickerController animated:YES completion:nil];
            }
        }];
        UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"从相册中选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:self.imagePickerController animated:YES completion:nil];
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [_actionController addAction:takePhotoAction];
        [_actionController addAction:albumAction];
        [_actionController addAction:cancelAction];
    }
    return _actionController;
}

- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
    }
    return _imagePickerController;
}

- (MCPhotoBroswer *)imagePreviewView {
    if (!_imagePreviewView) {
        _imagePreviewView = [MCPhotoBroswer new];
        _imagePreviewView.delegate = self;
        _imagePreviewView.dataSource = self;
    }
    
    return _imagePreviewView;
}

- (NSString *)uploadImageTempDirectory {
    if (!_uploadImageTempDirectory) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        _uploadImageTempDirectory = [documentsDirectory stringByAppendingPathComponent:@"uploadImageTempDirectory"];
    }
    return _uploadImageTempDirectory;
}

#pragma mark- Helper Method
- (CGRect)frameInRootViewForCellAtIndexPath:(NSIndexPath *)indexPath {
    MCLotteryCommentImageCell *cell = (MCLotteryCommentImageCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    CGRect cellFrameInRootView = [cell.imageView convertRect:cell.imageView.frame toView:self.navigationController.view];
    CGRect frame = cellFrameInRootView;
    frame.origin.y -= 10;
    return frame;
    
    return cellFrameInRootView;
}


@end

