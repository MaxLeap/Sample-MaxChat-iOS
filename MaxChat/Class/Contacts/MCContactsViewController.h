//
//  ContactsViewController.h
//  MaxChat
//
//  Created by 周和生 on 16/5/3.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MaxIMLib;

@interface MCContactCell : UITableViewCell
- (void)configWithFriend:(MLIMRelationInfo *)aFriend;
@end

@interface MCGroupCell : UITableViewCell

@end
@interface MCContactsViewController : UIViewController

@end
