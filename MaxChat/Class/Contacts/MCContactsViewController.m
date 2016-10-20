//
//  ContactsViewController.m
//  MaxChat
//
//  Created by 周和生 on 16/5/3.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "MCContactsViewController.h"
#import "MaxChatIMClient.h"
#import "Constants.h"
@import SDWebImage;
@import MaxLeap;


@interface MCContactsViewController ()

@property (nonatomic, strong) NSArray<MLIMRelationInfo*> *myFriends;
@property (nonatomic, strong) NSArray<MLIMGroup*> *myGroups;
@property (nonatomic, strong) UIAlertController *alertWithText;

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet UITableView *myFriendsTableView;
@property (nonatomic, strong) IBOutlet UITableView *myGroupsTableView;

@end

@implementation MCContactsViewController
#pragma mark - dealloc Method
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.segmentedControl = [[UISegmentedControl alloc]initWithItems:@[@"好友", @"群组"]];
    self.segmentedControl.frame = CGRectMake(0, 0, 120, 30);
    self.segmentedControl.selectedSegmentIndex = 0;
    self.myGroupsTableView.hidden = YES;
    self.navigationItem.titleView = self.segmentedControl;
    [self.segmentedControl addTarget:self action:@selector(selectedIndexChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.myGroupsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"GroupCell"];
    [self.myFriendsTableView registerClass:[MCContactCell class] forCellReuseIdentifier:@"ContactCell"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(maxLeapDidLogout:) name:kMaxLeapDidLogoutNofitification object:nil];
}

- (void)maxLeapDidLogout:(id)sender {
    [self.myGroupsTableView reloadData];
    [self.myFriendsTableView reloadData];
}


- (void)configureNavigationButtons {
    if (IMCurrentUser) {
        switch (self.segmentedControl.selectedSegmentIndex) {
            case 0:
                self.navigationItem.leftBarButtonItem = nil;
                self.navigationItem.rightBarButtonItem = BARBUTTON(@"添加好友", @selector(addFriend:));
                break;
                
            case 1:
                self.navigationItem.leftBarButtonItem = BARBUTTON(@"加入群组", @selector(joinGroup:));
                self.navigationItem.rightBarButtonItem = BARBUTTON(@"创建群组", @selector(createGroup:));
                break;
                
            default:
                break;
        }
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
}

- (void)joinGroup:(id)sender {
    [self showAlertWithTextInputType:@"joinGroup" message:@"请输入您要加入的群组ID" userInfo:nil];
}

- (void)createGroup:(id)sender {
    [self showAlertWithTextInputType:@"createGroup" message:@"请输入您要创建的群组名字" userInfo:nil];
}

- (void)addFriend:(id)sender {
    [self showAlertWithTextInputType:@"addFriend" message:@"请输入您要添加的好友名字" userInfo:nil];
}

- (void)selectedIndexChanged:(UISegmentedControl *)sender {
    NSLog(@"selectedIndexChanged %ld", (long)sender.selectedSegmentIndex);
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.myFriendsTableView.hidden = NO;
            self.myGroupsTableView.hidden = YES;
            break;
            
        case 1:
            self.myFriendsTableView.hidden = YES;
            self.myGroupsTableView.hidden = NO;
            break;
            
        default:
            break;
    }
    
    [self configureNavigationButtons];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (IMCurrentUser==nil) {
        [[MaxChatIMClient sharedInstance] loginWithCurrentuserCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            [self updateMyFriendsAndGroups];
        }];
    } else {
        [self updateMyFriendsAndGroups];
    }
}

- (void)updateMyFriendsAndGroups {
    [self configureNavigationButtons];
    [IMCurrentUser fetchFriendsWithDetail:YES
                               completion:^(BOOL success, NSError * _Nullable error) {
                                   self.myFriends = IMCurrentUser.friends;
                                   NSLog(@"myFriends count %ld", (long)self.myFriends.count);
                                   [self.myFriendsTableView reloadData];
                               }];
    
    [IMCurrentUser fetchGroupsWithDetail:YES
                              completion:^(BOOL success, NSError * _Nullable error) {
                                  self.myGroups = IMCurrentUser.groups;
                                  NSLog(@"myGroups count %ld", (long)self.myGroups.count);
                                  [self.myGroupsTableView reloadData];
                              }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - alert controllers
- (void)showActionsForFriend:(MLIMRelationInfo *)aFriend {
    UIAlertController *_actionController = [UIAlertController alertControllerWithTitle:nil
                                                                               message:nil
                                                                        preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *removeFriend = [UIAlertAction actionWithTitle:@"删除好友"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [IMCurrentUser deleteFriend:aFriend.uid
                                                                              completion:^(BOOL success, NSError * _Nullable error) {
                                                                                  if (success) {
                                                                                      [self updateMyFriendsAndGroups];
                                                                                  } else {
                                                                                      NSLog(@"deleteFriend error %@", error);
                                                                                  }
                                                                              }];
                                                         }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [_actionController addAction:removeFriend];
    [_actionController addAction:cancelAction];
    
    [self presentViewController:_actionController
                       animated:YES
                     completion:nil];
}

- (void)showActionsForGroup:(MLIMGroup *)aGroup {
    UIAlertController *_actionController = [UIAlertController alertControllerWithTitle:nil
                                                                               message:nil
                                                                        preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *removeGroup;
    if ([aGroup.owner isEqualToString:IMCurrentUserID]) {
        removeGroup = [UIAlertAction actionWithTitle:@"解散群组"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * _Nonnull action) {
                                                 [MLAnalytics trackEvent:@"解散群组" parameters:@{@"name":aGroup.name}];
                                                 [aGroup deleteWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                                     if (succeeded) {
                                                         [self updateMyFriendsAndGroups];
                                                     } else {
                                                         NSLog(@"deleteGroup error %@", error);
                                                     }
                                                 }];
                                             }];
    } else {
        removeGroup = [UIAlertAction actionWithTitle:@"退出群组"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * _Nonnull action) {
                                                 [MLAnalytics trackEvent:@"退出群组" parameters:@{@"name":aGroup.name}];
                                                 [aGroup removeMembers:@[IMCurrentUserID]
                                                                 block:^(BOOL succeeded, NSError * _Nullable error) {
                                                                     if (succeeded) {
                                                                         [self updateMyFriendsAndGroups];
                                                                     } else {
                                                                         NSLog(@"quitGroup error %@", error);
                                                                     }
                                                                 }];
                                             }];
    }
    
    UIAlertAction *addMember = [UIAlertAction actionWithTitle:@"添加成员"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [MLAnalytics trackEvent:@"添加成员" parameters:@{@"name":aGroup.name}];
                                                          [self addMemberToGroup: aGroup];
                                                      }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [_actionController addAction:removeGroup];
    [_actionController addAction:addMember];
    [_actionController addAction:cancelAction];
    
    [self presentViewController:_actionController
                       animated:YES
                     completion:nil];
}

-(void)addMemberToGroup:(MLIMGroup *)aGroup {
    [self showAlertWithTextInputType:@"addMember" message:@"请输入您要添加的成员名字" userInfo:@{@"group":aGroup}];
}


- (void)showAlertWithTextInputType:(NSString *)type message:(NSString *)message userInfo:(NSDictionary *)userInfo {
    
    [self presentViewController:[self alertWithTextType:type message:message userInfo:userInfo]
                       animated:YES
                     completion:nil];
}

- (UIAlertController *)alertWithTextType:(NSString *)type message:(NSString *)message userInfo:(NSDictionary *)userInfo {
    
    _alertWithText = [UIAlertController alertControllerWithTitle:@""
                                                         message:message
                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        NSLog(@"User choose OK");
                                                        NSString *textInput = [self accessAlertTextField];
                                                        NSLog(@"User Input was %@ for %@", textInput, type);
                                                        if (textInput.length) {
                                                            if ([type isEqualToString:@"createGroup"]) {
                                                                NSString *owner = IMCurrentUserID;
                                                                // 创建群组
                                                                [MLAnalytics trackEvent:@"创建群组" parameters:@{@"name":textInput}];
                                                                [MLIMGroup createWithOwner:owner
                                                                                      name:textInput
                                                                                   members:@[owner]
                                                                                     block:^(MLIMGroup * _Nonnull group, NSError * _Nonnull error) {
                                                                                         if (group) {
                                                                                             // 创建成功
                                                                                             [self updateMyFriendsAndGroups];
                                                                                         } else {
                                                                                             // 创建失败
                                                                                             NSLog(@"createGroup failed with error %@", error);
                                                                                         }
                                                                                     }];
                                                                
                                                            } else if ([type isEqualToString:@"joinGroup"]) {
                                                                [MLAnalytics trackEvent:@"加入群组" parameters:@{@"groupid":textInput}];
                                                                MLIMGroup *group = [MLIMGroup groupWithId: textInput];
                                                                [group addMembers:@[IMCurrentUserID]
                                                                            block:^(BOOL succeeded, NSError * _Nullable error) {
                                                                                if (succeeded) {
                                                                                    // 成功 ...
                                                                                    [self updateMyFriendsAndGroups];
                                                                                } else {
                                                                                    NSLog(@"joinGroup failed with error %@", error);
                                                                                }
                                                                            }];
                                                            } else if ([type isEqualToString:@"addFriend"]) {
                                                                [MLAnalytics trackEvent:@"添加好友" parameters:@{@"name":textInput}];
                                                                [IMCurrentUser addFriend:textInput
                                                                              completion:^(NSDictionary * _Nonnull result, NSError * _Nullable error) {
                                                                                  if (!error) {
                                                                                      // 成功 ...
                                                                                      NSLog(@"addFriend result %@", result);
                                                                                      [self updateMyFriendsAndGroups];
                                                                                  } else {
                                                                                      NSLog(@"addFriend failed with error %@", error);
                                                                                  }
                                                                              }];
                                                            } else if ([type isEqualToString:@"addMember"]) {
                                                                [MLAnalytics trackEvent:@"添加成员" parameters:@{@"name":textInput}];
                                                                MLIMGroup *group = userInfo[@"group"];
                                                                [group addMembers:@[textInput]
                                                                            block:^(BOOL succeeded, NSError * _Nullable error) {
                                                                                if (succeeded) {
                                                                                    // 成功 ...
                                                                                    [self updateMyFriendsAndGroups];
                                                                                } else {
                                                                                    NSLog(@"addMember failed with error %@", error);
                                                                                }
                                                                            }];
                                                            }
                                                            
                                                        }
                                                    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Cancel"
                                                      style:UIAlertActionStyleDestructive
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        NSLog(@"User choose CANCEL");
                                                    }];
    
    [_alertWithText addAction:action1];
    [_alertWithText addAction:action2];
    
    [_alertWithText addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        textField.text = [[MLUser currentUser]objectForKey:type];
    }];
    return _alertWithText;
}

- (NSString *)accessAlertTextField {
    
    return [self.alertWithText.textFields lastObject].text;
}


#pragma mark- Delegate，DataSource, Callback Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return MaxLeapSignedUser?1:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView==self.myFriendsTableView) {
        return self.myFriends.count;
    } else {
        return self.myGroups.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (tableView==self.myGroupsTableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
        MLIMGroup *theGroup = self.myGroups[indexPath.row];
        cell.textLabel.text = theGroup.name;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
        MLIMRelationInfo *theFriend = self.myFriends[indexPath.row];
        [(MCContactCell *)cell configWithFriend: theFriend];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView==self.myFriendsTableView) {
        [MLAnalytics trackEvent:@"和联系人聊天" parameters:@{@"uid":self.myFriends[indexPath.row].uid}];
        [[MaxChatIMClient sharedInstance]pushMessagesControllerForFriend:self.myFriends[indexPath.row] withNavigator:self.navigationController];
    } else {
        [MLAnalytics trackEvent:@"群组聊天"  parameters:@{@"name":self.myGroups[indexPath.row].name}];
        [[MaxChatIMClient sharedInstance]pushMessagesControllerForGroup:self.myGroups[indexPath.row] withNavigator:self.navigationController];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (tableView==self.myFriendsTableView) {
        [self showActionsForFriend: self.myFriends[indexPath.row]];
    } else {
        [self showActionsForGroup: self.myGroups[indexPath.row]];
    }
}


@end


@interface MCGroupCell()
@end
@implementation MCGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

@end

@interface MCContactCell()
@property (nonatomic, strong) MLIMRelationInfo *theFriend;
@end

@implementation MCContactCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageView sd_cancelCurrentImageLoad];
}

- (void)configWithFriend:(MLIMRelationInfo *)aFriend {
    self.theFriend = aFriend;
    self.textLabel.text = aFriend.uid;
    
    // 获得好友 attributes 及 iconUrl，设置好友头像
    NSString *friendID = aFriend.uid;
    MLIMUser *imUser = [MLIMUser userWithId:friendID];
    [imUser fetchAttributesWithCompletion:^(NSDictionary * _Nullable attrs, NSError * _Nullable error) {
        NSString *iconUrl = attrs[@"iconUrl"];
        if ([friendID isEqualToString:self.theFriend.uid]) {
            if (iconUrl) {
                [self.imageView sd_setImageWithURL:[NSURL URLWithString:iconUrl] placeholderImage:ImageNamed(@"ic_im_user_placeholder")];
            } else {
                self.imageView.image = ImageNamed(@"ic_im_user_placeholder");
            }
        }
    }];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(12, 7, 30, 30);
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 15.0f;
    self.textLabel.frame = CGRectMake(60, 7, self.contentView.frame.size.width-120, 30);
}

@end
