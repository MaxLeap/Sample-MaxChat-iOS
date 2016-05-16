//
//  RegisterViewController.h
//  MaxChat
//
//  Created by 周和生 on 16/5/4.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    MaxChatSignUp = 0,
    MaxChatSignIn = 1
} MaxChatSignType;

@interface MCSignViewController : UIViewController

@property (nonatomic, assign) BOOL shouldHideCancelButton;
@property (nonatomic, assign) MaxChatSignType signType;

@end
