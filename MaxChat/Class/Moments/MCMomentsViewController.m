//
//  MomentsViewController.m
//  MaxChat
//
//  Created by 周和生 on 16/5/3.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "MCMomentsViewController.h"
#import "MCTimelinePostsListViewController.h"
#import "MCCreateNewPostViewController.h"

@interface MCMomentsViewController () 
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation MCMomentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    MaxSocialUser *user = MaxSocialCurrentUser;
    NSLog(@"MaxSocial UserId is `%@`", user.userId);

    self.navigationItem.title = @"朋友圈";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(maxLeapDidLogout:) name:kMaxLeapDidLogoutNofitification object:nil];
}

- (void)maxLeapDidLogout:(id)sender {
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationItem.rightBarButtonItem = MaxSocialCurrentUser ? BARBUTTON(@"发布说说", @selector(createNewPost:)) : nil;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createNewPost:(id)sender {
    MCCreateNewPostViewController *postViewController = [[MCCreateNewPostViewController alloc]init];
    [self.navigationController pushViewController:postViewController animated:YES];
}


#pragma mark- Delegate，DataSource, Callback Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return MaxSocialCurrentUser?1:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    switch (indexPath.row) {
            case 0:
            cell.textLabel.text = @"广场";
            break;
            
            case 1:
            cell.textLabel.text = @"我的朋友圈";
            break;
            
        case 2:
            cell.textLabel.text = @"我的说说";
            break;
            
        default:
            break;
    }
   
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MCTimelinePostsListViewController *timeLinePostsVC;
    switch(indexPath.row) {
        case 0:
            timeLinePostsVC = [[MCTimelinePostsListViewController alloc]init];
            timeLinePostsVC.isSquare = YES;
            [MLAnalytics trackEvent:@"进入广场"];
            break;
            
        case 1:
            timeLinePostsVC = [[MCTimelinePostsListViewController alloc]init];
            timeLinePostsVC.isCycle = YES;
            [MLAnalytics trackEvent:@"进入朋友圈"];
            break;
            
        case 2:
            timeLinePostsVC = [[MCTimelinePostsListViewController alloc]init];
            [MLAnalytics trackEvent:@"进入我的说说"];
            break;
            
        default:
            break;
    }
    
    timeLinePostsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:timeLinePostsVC animated:YES];
}

@end
