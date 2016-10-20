//
//  ChattingViewController.m
//  MaxChat
//
//  Created by 周和生 on 16/5/3.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "MCRecentChatsViewController.h"
#import "MaxChatIMClient.h"
#import "Constants.h"
@import SDWebImage;
@import MaxLeap;


@interface MCRecentChatsViewController ()
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation MCRecentChatsViewController

#pragma mark - dealloc Method
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"最近聊天";
    [self.tableView registerClass:[MCChatCell class] forCellReuseIdentifier:@"MCChatCell"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateChats:) name:kRecentChatsUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(maxLeapDidLogout:) name:kMaxLeapDidLogoutNofitification object:nil];
}

- (void)maxLeapDidLogout:(id)sender {
    [self.tableView reloadData];
}

- (void)updateChats:(id)sender {
    
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return MaxLeapSignedUser?1:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [MaxChatIMClient sharedInstance].recentChats.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MCChatCell"];
    id chat = [MaxChatIMClient sharedInstance].recentChats[indexPath.row];
    [cell configWithChat:chat];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id chat = [MaxChatIMClient sharedInstance].recentChats[indexPath.row];
    if ([chat isKindOfClass:[MLIMRelationInfo class]]) {
        [[MaxChatIMClient sharedInstance]pushMessagesControllerForFriend:chat withNavigator:self.navigationController];
    } else {
        [[MaxChatIMClient sharedInstance]pushMessagesControllerForGroup:chat withNavigator:self.navigationController];
    }
}

@end

@interface MCChatCell()
@property (nonatomic, strong) MLIMRelationInfo *theFriend;
@property (nonatomic, strong) MLIMGroup *theGroup;

@end

@implementation MCChatCell

- (void)configWithChat:(id)chat {
    if ([chat isKindOfClass:[MLIMRelationInfo class]]) {
        [self configWithFriend:chat];
        self.theGroup = nil;
    } else {
        self.theFriend = nil;
        self.theGroup = chat;
        self.imageView.image = ImageNamed(@"ic_im_user_placeholder");
        if (self.theGroup.name) {
            self.textLabel.text = self.theGroup.name;
        } else {
            [self.theGroup fetchWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if ([self.theGroup.groupId isEqualToString:[chat groupId]]) {
                    self.textLabel.text = self.theGroup.name;
                }
            }];
        }
    }
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


- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageView sd_cancelCurrentImageLoad];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(12, 7, 30, 30);
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 15.0f;
    self.textLabel.frame = CGRectMake(60, 7, self.contentView.frame.size.width-120, 30);
}


@end
