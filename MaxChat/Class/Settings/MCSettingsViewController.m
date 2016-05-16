//
//  SettingsViewController.m
//  MaxChat
//
//  Created by 周和生 on 16/5/3.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "MCSettingsViewController.h"
@import MLHelpCenter;


@interface MCSettingsViewController ()
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation MCSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"设置";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [MLHelpCenter install];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark- Delegate，DataSource, Callback Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"FAQ";
            break;
            
        case 1:
            cell.textLabel.text = @"用户反馈";
            break;
            
 
            
        default:
            break;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch(indexPath.row) {
        case 0:
            [[MLHelpCenter sharedInstance] showFAQs:self];
            break;
            
        case 1:
            [[MLHelpCenter sharedInstance] showConversation:self];
            break;
            
        default:
            break;
    }
    
 
}



@end
