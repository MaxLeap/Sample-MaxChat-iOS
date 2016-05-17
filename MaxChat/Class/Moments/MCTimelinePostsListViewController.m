//
//  MCTimelinePostsListViewController.m
//  MaxChat
//
//  Created by 周和生 on 16/5/10.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "MCTimelinePostsListViewController.h"
#import "MCTimelinePostActionCell.h"
#import "MCTimelinePostImagesCell.h"
#import "MCTimelineTextTableViewCell.h"
#import "MaxSocialRemoteShuoShuo.h"
#import "UIView+Borders.h"
#import "MCTimelinePostLikesCell.h"
#import "MCTimelinePostCommentCell.h"
#import "MCTextViewInternal.h"
#import "UIView+AutoLayout.h"
#import "Constants.h"
@import SVProgressHUD;
@import MJRefresh;
@import MaxLeap;


@interface MCTimelinePostsListViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *emptyNotesLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *shuoshuos;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *introductionLabel;

@property (weak, nonatomic) IBOutlet UIView *toolBarView;
@property (weak, nonatomic) IBOutlet MCTextViewInternal *commentTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendCommentButton;

@property (nonatomic, strong) UIAlertController *actionController;
@property (nonatomic, strong) MaxSocialComment *selectedComment;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarViewHeightConstraint;

@property (nonatomic, strong) NSString *selectedTimelineUser;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) UIAlertController *changeCoverActionController;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation MCTimelinePostsListViewController

#pragma mark - dealloc Method
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.timelineUser==nil) {
        self.timelineUser =  MaxLeapSignedUserId;
    }
    
    if (self.isSquare) {
        self.navigationItem.title = @"广场";
    } else {
        
        if (self.isCycle) {
            self.navigationItem.title = [NSString stringWithFormat: @"%@的朋友圈", self.timelineUser];
        } else {
            self.navigationItem.title = [NSString stringWithFormat: @"%@的说说", self.timelineUser];
        }
        
    }
    
    [self configureTableView];
    [self configureToolBarView];
    [self configureEmptyNotesView];
    
    [self reloadViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardChangeNotification:)
                                                 name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MCTimelinePostCommentCell" bundle:nil] forCellReuseIdentifier:@"MCTimelinePostCommentCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MCTimelinePostLikesCell" bundle:nil] forCellReuseIdentifier:@"MCTimelinePostLikesCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MCTimelinePostActionCell" bundle:nil] forCellReuseIdentifier:@"MCTimelinePostActionCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MCTimelinePostImagesCell" bundle:nil] forCellReuseIdentifier:@"MCTimelinePostImagesCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MCTimelineTextTableViewCell" bundle:nil] forCellReuseIdentifier:@"MCTimelineTextTableViewCell"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [MLAnalytics beginLogPageView:@"MCTimelinePostsListViewController"];
    [self reloadViews];
    if (MaxSocialCurrentUser) {
        [self.tableView.mj_header beginRefreshing];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MLAnalytics endLogPageView:@"MCTimelinePostsListViewController"];

    [self hideCommentToolBarView];
    [self hideActionPanelView];
}

- (void)triggerPullToRefresh {
    [self.tableView.mj_header beginRefreshing];
    [self hideCommentToolBarView];
}


#pragma mark- SubView Configuration
- (void)configureTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.mj_header.scrollView.scrollsToTop = NO;
    self.tableView.mj_footer.scrollView.scrollsToTop = NO;
    
    __weak typeof(self) wSelf = self;
    __block int page = 0;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 0;
        [wSelf requestDataFromPage:page completion:^(NSArray *shuoshuos, BOOL didReachEnd, NSError *error) {
            [wSelf.tableView.mj_header endRefreshing];
            wSelf.tableView.mj_footer.hidden = didReachEnd;
            
            if (error) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
                return;
            }
            
            wSelf.shuoshuos = [shuoshuos mutableCopy];
            [wSelf.tableView reloadData];
            [wSelf reloadViews];
        }];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [wSelf requestDataFromPage:page + 1 completion:^(NSArray *shuoshuos, BOOL didReachEnd, NSError *error) {
            [wSelf.tableView.mj_footer endRefreshing];
            wSelf.tableView.mj_footer.hidden = didReachEnd;
            
            if (error) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
                return;
            }
            
            if (shuoshuos.count > 0) {
                page = page + 1;
                [wSelf.shuoshuos addObjectsFromArray:shuoshuos];
                [wSelf.tableView reloadData];
                [wSelf reloadViews];
            }
        }];
    }];
    
    ((MJRefreshNormalHeader *)self.tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_footer.hidden = YES;
    
    [self configureHeaderView];
}

- (void)requestDataFromPage:(NSUInteger)page completion:(void(^)(NSArray *shuoshuos, BOOL didReachEnd, NSError *error))completion {
    
    MaxSocialQuery *query = [MaxSocialQuery new]; // default query
    query.page = page;
    query.limit = 10;
    
    MLDictionaryResultBlock block = ^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        NSDictionary *likes = result[@"zans"];
        NSDictionary *comments = result[@"comments"];
        
        NSArray<MaxSocialShuoShuo *> *shuoshuos = result[@"shuoshuos"];
        NSMutableArray *remoteShuoshuos = [NSMutableArray arrayWithCapacity:shuoshuos.count];
        
        for (MaxSocialShuoShuo *s in shuoshuos) {
            MaxSocialRemoteShuoShuo *rs = [[MaxSocialRemoteShuoShuo alloc]initWithMaxSocialShuoShuo:s];
            rs.zans = [NSMutableArray array];
            rs.comments = [NSMutableArray array];
            
            [likes enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([key isEqualToString:rs.objectId]) {
                    [rs.zans addObjectsFromArray:obj];
                }
            }];
            
            [comments enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([key isEqualToString:rs.objectId]) {
                    [rs.comments addObjectsFromArray:obj];
                }
            }];
            
            [remoteShuoshuos addObject:rs];
        }
        
        if (completion) {
            completion(remoteShuoshuos, YES, error);
        }
    };
    
    if (self.isSquare) {
        [MaxSocialCurrentUser getLatestShuoShuoInSquareWithQuery:query block:block];
    } else {
        
        if (self.isCycle) {
            [MaxSocialUserWithId(self.timelineUser) getLatestShuoShuoInFriendCycleWithQuery:query block:block];
        } else {
            [MaxSocialUserWithId(self.timelineUser) getShuoShuoWithQuery:query block:block];
        }
        
    }
}

- (BOOL)shouldHideHeaderView {
    return self.isCycle || self.isSquare;
}

- (void)configureHeaderView {
    CGFloat headerHeight = self.shouldHideHeaderView ? 10 : 158;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, headerHeight)];
    self.tableView.tableHeaderView = view;
    if (self.shouldHideHeaderView) {
        return;
    }
    
    [view addSubview:self.headerView];
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView pinToSuperviewEdges:JRTViewPinAllEdges inset:0];
    
    self.iconImageView.layer.cornerRadius = self.iconImageView.bounds.size.width / 2;
    self.iconImageView.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedUserIconImageView:)];
    [self.iconImageView addGestureRecognizer:tap];
    self.iconImageView.userInteractionEnabled = YES;
    
    self.nameLabel.text = self.timelineUser;
    self.nameLabel.textColor = [UIColor whiteColor];
    
    self.introductionLabel.textColor = [UIColor whiteColor];
    
    self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bgImageView.clipsToBounds = YES;
    
    UITapGestureRecognizer *bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBgView:)];
    self.bgImageView.userInteractionEnabled = YES;
    [self.bgImageView addGestureRecognizer:bgTap];
}

- (void)configureToolBarView {
    self.toolBarView.backgroundColor = kSeparatorLineColor;
    
    self.commentTextView.text = @"";
    self.commentTextView.textColor = kDefaultGrayColor;
    self.commentTextView.delegate = self;
    
    [self.sendCommentButton setTitle:@"提交" forState:UIControlStateNormal];
    
    self.toolBarView.hidden = YES;
}

- (void)configureEmptyNotesView {
    self.emptyNotesLabel.text = @"暂无内容";
    self.emptyNotesLabel.textColor = [UIColor lightGrayColor];
    self.emptyNotesLabel.hidden = YES;
}



- (void)reloadViews {
    self.tableView.hidden = NO;
    [self.tableView reloadData];
    self.emptyNotesLabel.hidden = self.shuoshuos.count > 0;
}


#pragma mark- Action
- (IBAction)submitCommentButtonPressed:(id)sender {
    [SVProgressHUD showWithStatus:@"请稍候"];
    MaxSocialRemoteShuoShuo *currentPost = self.shuoshuos[self.selectedIndexPath.section];
    [MLAnalytics trackEvent:@"发布评论"];
    [MaxSocialCurrentUser createCommentForShuoShuo:currentPost.objectId
                                       withContent:self.commentTextView.text
                                             block:^(MaxSocialComment * _Nullable comment, NSError * _Nullable error) {
                                                 [currentPost.comments insertObject:comment atIndex:0];
                                                 [self hideCommentToolBarView];
                                                 if (error) {
                                                     [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                                                 } else {
                                                     [SVProgressHUD showSuccessWithStatus:@"评论成功!"];
                                                     [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.selectedIndexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
                                                 }
                                             }];
}



- (void)tappedUserIconImageView:(id)sender {
    NSLog(@"tappedUserIconImageView");
}

- (void)tappedBgView:(id)sender {
    NSLog(@"tappedBgView");
}

#pragma mark- Delegate，DataSource, Callback Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.shuoshuos.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    MaxSocialRemoteShuoShuo *shuoshuo = self.shuoshuos[section];
    NSUInteger rowCount = 2; //text; actionCell
    if (shuoshuo.content.imageNames.count > 0) {
        rowCount++;
    }
    if (shuoshuo.zans.count > 0) {
        rowCount++;
    }
    if (shuoshuo.comments.count > 0) {
        rowCount += shuoshuo.comments.count;
    }
    return rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MaxSocialRemoteShuoShuo *shuoshuo = self.shuoshuos[indexPath.section];
    if (shuoshuo.content.imageNames.count > 0 && indexPath.row == 1) {
        return [self imagesCollectionViewHeightFor:shuoshuo];
    }
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.shuoshuos.count - 1) {
        return 10;
    }
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MaxSocialRemoteShuoShuo *shuoshuo = self.shuoshuos[indexPath.section];
    
    UITableViewCell *cell = nil;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MCTimelineTextTableViewCell" forIndexPath:indexPath];
        MCTimelineTextTableViewCell *textCell = (MCTimelineTextTableViewCell *)cell;
        __weak typeof(self) wSelf = self;
        textCell.tapUserBlock = ^(NSString *timelineUser) {
            wSelf.selectedTimelineUser = timelineUser;
            [wSelf performTappedTimelineUserAction];
        };
        [textCell configureCell:shuoshuo];
        
    }
    if (shuoshuo.content.imageNames.count > 0 && indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MCTimelinePostImagesCell" forIndexPath:indexPath];
        MCTimelinePostImagesCell *imagesCell = (MCTimelinePostImagesCell *)cell;
        [imagesCell configureCell:shuoshuo];
    }
    
    if ((shuoshuo.content.imageNames.count > 0 && indexPath.row == 2) || (shuoshuo.content.imageNames.count == 0 && indexPath.row == 1)) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MCTimelinePostActionCell" forIndexPath:indexPath];
        MCTimelinePostActionCell *actionCell = (MCTimelinePostActionCell *)cell;
        [actionCell configureCell:self.shuoshuos[indexPath.section]];
        
        __weak typeof(self) wSelf = self;
        __weak MCTimelinePostActionCell *wCell = actionCell;
        actionCell.actionButtonHandler = ^{
            // 隐藏其它cell的ActionButton
            [wSelf.tableView.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[MCTimelinePostActionCell class]] && obj != wCell) {
                    MCTimelinePostActionCell *actionCell = (MCTimelinePostActionCell *)obj;
                    [actionCell hideActionPanel];
                }
            }];
            [wSelf hideCommentToolBarView];
        };
        
        actionCell.likeActionBlock = ^{
            [wCell hideActionPanel];
            MaxSocialRemoteShuoShuo *currentPost = wSelf.shuoshuos[indexPath.section];
            BOOL isLikedAlready = [[currentPost.zans valueForKeyPath:@"userId"] containsObject:MaxLeapSignedUserId];
            if (isLikedAlready) {
                NSUInteger idx = [[currentPost.zans valueForKeyPath:@"userId"] indexOfObject:MaxLeapSignedUserId];
                NSString *commentId = currentPost.zans[idx].objectId;
                [MLAnalytics trackEvent:@"取消赞"];
                [MaxSocialCurrentUser deleteCommentWithId:commentId
                                                    block:^(BOOL succeeded, NSError * _Nullable error) {
                                                        if (succeeded) {
                                                            [currentPost.zans removeObjectAtIndex:idx];
                                                            [wSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
                                                        } else {
                                                            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                                                        }
                                                        
                                                    }];
            } else {
                [MLAnalytics trackEvent:@"赞"];
                [MaxSocialCurrentUser likeShuoShuo:currentPost.objectId
                                             block:^(MaxSocialComment * _Nullable comment, NSError * _Nullable error) {
                                                 // comment.isLike 应该为 YES.
                                                 // 可以通过评论对象 comment 的 isLike 属性判断该评论是点赞还是文字评论
                                                 
                                                 if (comment.isLike && !error) {
                                                     [currentPost.zans insertObject:comment atIndex:0];
                                                     [wSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
                                                 } else {
                                                     [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                                                 }
                                             }];
            }
        };
        
        actionCell.commentActionBlock = ^{
            [wCell hideActionPanel];
            wSelf.selectedIndexPath = indexPath;
            [wSelf.commentTextView becomeFirstResponder];
        };
        
        actionCell.deleteActionBlock = ^{
            [wCell hideActionPanel];
            MaxSocialRemoteShuoShuo *currentPost = wSelf.shuoshuos[indexPath.section];
            [SVProgressHUD showWithStatus:@"请稍候"];
            [MLAnalytics trackEvent:@"删除说说"];
            [MaxSocialCurrentUser deleteShuoShuoWithId:currentPost.objectId
                                                 block:^(BOOL shuoDelete, BOOL photosDelete, NSError * _Nullable error) {
                                                     [SVProgressHUD dismiss];
                                                     if (error) {
                                                         [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                                                     } else {
                                                         [wSelf.shuoshuos removeObject:currentPost];
                                                         [wSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                                                     }
                                                     
                                                 }];
        };
    }
    
    if (shuoshuo.zans.count > 0) {
        if ((shuoshuo.content.imageNames.count > 0 && indexPath.row == 3) || (shuoshuo.content.imageNames.count == 0 && indexPath.row == 2)) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MCTimelinePostLikesCell" forIndexPath:indexPath];
            MCTimelinePostLikesCell *likesCell = (MCTimelinePostLikesCell *)cell;
            
            __weak typeof(self) wSelf = self;
            likesCell.tapUserBlock = ^(NSString *timelineUser) {
                wSelf.selectedTimelineUser = timelineUser;
                [wSelf performTappedTimelineUserAction];
            };
            [likesCell configureCell:shuoshuo];
            
            likesCell.likesLabelBottomConstraint.constant = indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1 ? 15 : 5;
        }
    }
    
    if (shuoshuo.comments.count > 0) {
        if (indexPath.row <= [tableView numberOfRowsInSection:indexPath.section] - 1 &&
            indexPath.row >= [tableView numberOfRowsInSection:indexPath.section] - shuoshuo.comments.count) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"MCTimelinePostCommentCell" forIndexPath:indexPath];
            MCTimelinePostCommentCell *commentCell = (MCTimelinePostCommentCell *)cell;
            NSUInteger indexOffset = [tableView numberOfRowsInSection:indexPath.section] - shuoshuo.comments.count;
            NSUInteger commentIndex = indexPath.row - indexOffset;
            MaxSocialComment *comment = shuoshuo.comments[commentIndex];
            [commentCell configureCell:comment];
            
            __weak typeof(self) wSelf = self;
            commentCell.tapUserBlock = ^(NSString *timelineUser) {
                wSelf.selectedTimelineUser = timelineUser;
                [wSelf performTappedTimelineUserAction];
            };
            
            commentCell.commentLabelBottomConstraint.constant = indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1 ? 15 : 5;
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 0) {
        [cell.contentView addTopBorderWithColor:kSeparatorLineColor andWidth:0.5];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MaxSocialRemoteShuoShuo *post = self.shuoshuos[indexPath.section];
    if (indexPath.row <= [tableView numberOfRowsInSection:indexPath.section] - 1 &&
        indexPath.row >= [tableView numberOfRowsInSection:indexPath.section] - post.comments.count) {
        
        self.selectedIndexPath = indexPath;
        NSUInteger indexOffset = [tableView numberOfRowsInSection:indexPath.section] - post.comments.count;
        NSUInteger commentIndex = indexPath.row - indexOffset;
        self.selectedComment = post.comments[commentIndex];
        
        if ([self.selectedComment.userId isEqualToString:MaxLeapSignedUserId]) {
            [self presentViewController:self.actionController animated:YES completion:nil];
            
        } else {
            self.selectedIndexPath = indexPath;
            [self.commentTextView becomeFirstResponder];
            
            NSString *text = [@"回复" stringByAppendingFormat:@"%@: ", self.selectedComment.userId];
            self.commentTextView.text = text;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:[UITextView class]]) {
        [self hideActionPanelView];
        [self hideCommentToolBarView];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    CGFloat height = [textView sizeThatFits:textView.frame.size].height;
    self.toolBarViewHeightConstraint.constant =  MIN(100, MAX(50, height+16));
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        // update backgroud image
    }
}

#pragma mark- Override Parent Method

#pragma mark- Private Method
- (void)keyboardChangeNotification:(NSNotification *)notification{
    if (!self.commentTextView.isFirstResponder) {
        return;
    }
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    NSNumber *durationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    
    NSNumber *curveValue = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    
    self.toolBarView.hidden = NO;
    self.toolBarViewBottomConstraint.constant = keyboardFrame.size.height;
    if (!self.hidesBottomBarWhenPushed) {
        self.toolBarViewBottomConstraint.constant -= 50;
    }
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:animationCurve << 16
                     animations:^{
                         [self.view layoutIfNeeded];
                         
                     } completion:^(BOOL finished){
                     }];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    self.toolBarView.hidden = YES;
    self.toolBarViewBottomConstraint.constant = 0;
}

- (void)hideActionPanelView {
    [self.tableView.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[MCTimelinePostActionCell class]]) {
            MCTimelinePostActionCell *actionCell = (MCTimelinePostActionCell *)obj;
            [actionCell hideActionPanel];
        }
    }];
}

- (void)hideCommentToolBarView {
    self.commentTextView.text = @"";
    [self.commentTextView resignFirstResponder];
    self.toolBarView.hidden = YES;
    self.toolBarViewBottomConstraint.constant = 0;
    self.toolBarViewHeightConstraint.constant = 50;
}

- (void)performTappedTimelineUserAction {
    if ([self.selectedTimelineUser isEqualToString:MaxLeapSignedUserId]) {
        NSLog(@"performTappedTimelineUserAction for me `%@`", self.selectedTimelineUser);
    } else {
        [MaxSocialUser queryWhetherUser:MaxLeapSignedUserId
                        isFollowingUser:self.selectedTimelineUser
                            resultBlock:^(BOOL isFollowing, BOOL isReverse, NSError * _Nonnull error) {
                                if (isFollowing==NO) {
                                    [MaxSocialUserWithId(self.timelineUser) followUser:self.selectedTimelineUser block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                                        [SVProgressHUD showSuccessWithStatus:@"关注好友成功"];
                                    }];
                                } else {
                                    [MaxSocialUserWithId(self.timelineUser) unfollowUser:self.selectedTimelineUser block:^(BOOL succeeded, NSError * _Nullable error) {
                                        [SVProgressHUD showSuccessWithStatus:@"取消关注成功"];
                                    }];
                                }
                            }];
    }
}


- (UIAlertController *)actionController {
    if (!_actionController) {
        _actionController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *deleteCommentAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [SVProgressHUD showWithStatus:@"正在删除评论..."];
            [MLAnalytics trackEvent:@"删除评论"];
            // delete post
            [MaxSocialCurrentUser deleteCommentWithId:self.selectedComment.objectId
                                                block:^(BOOL succeeded, NSError * _Nullable error) {
                                                    if (error) {
                                                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                                                    } else {
                                                        
                                                        [SVProgressHUD showSuccessWithStatus:@"删除成功"];
                                                        MaxSocialRemoteShuoShuo *post = self.shuoshuos[self.selectedIndexPath.section];
                                                        [post.comments removeObject:self.selectedComment];
                                                        [self.tableView deleteRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                                                    }
                                                }];
            
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [_actionController addAction:deleteCommentAction];
        [_actionController addAction:cancelAction];
    }
    return _actionController;
}


- (UIAlertController *)changeCoverActionController {
    if (!_changeCoverActionController) {
        _changeCoverActionController = [UIAlertController alertControllerWithTitle:@"更改背景" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
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
        
        [_changeCoverActionController addAction:takePhotoAction];
        [_changeCoverActionController addAction:albumAction];
        [_changeCoverActionController addAction:cancelAction];
    }
    return _changeCoverActionController;
}

- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
    }
    return _imagePickerController;
}

#pragma mark- Helper Method
- (CGFloat)imagesCollectionViewHeightFor:(MaxSocialShuoShuo *)post {
    NSUInteger imageCount = post.content.imageNames.count;
    NSInteger rowCount = imageCount % kMaxNumberOfImagesPerRow == 0 ? (imageCount / kMaxNumberOfImagesPerRow) : (imageCount / kMaxNumberOfImagesPerRow + 1);
    CGFloat cellWidth = (self.view.bounds.size.width - 63 - kCollectionViewRightMargin) / kMaxNumberOfImagesPerRow;
    CGFloat rowHeight = cellWidth;
    return rowHeight * rowCount;
}




@end
