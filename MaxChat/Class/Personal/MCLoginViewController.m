//
//  LoginViewController.m
//  MaxChat
//
//  Created by 周和生 on 16/5/3.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "MCLoginViewController.h"

@import MLQQUtils;
@import MLWeChatUtils;
@import MLWeiboUtils;

#define kPasscodeWaitSeconds    60


@interface MCLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *telInputTextField;
@property (weak, nonatomic) IBOutlet UITextField *passcodeInputTextField;
@property (weak, nonatomic) IBOutlet UIButton *gainPasscodeButton;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@property (weak, nonatomic) IBOutlet UILabel *footerNotesLabel;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UILabel *otherLoginMethodLabel;
@property (weak, nonatomic) IBOutlet UIButton *qqLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *weiboLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *wechatLoginButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qqLoginButtonCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weiboLoginButtonCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wechatLoginButtonCenterXConstraint;


@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSUInteger secondsToCountDown;

@property (nonatomic, strong) UITapGestureRecognizer *touchGesture;
@end

@implementation MCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = NSLocalizedString(@"其它登录", nil);
    self.view.backgroundColor = kSeparatorLineColor;
    [self.view addGestureRecognizer:self.touchGesture];
    
    [self configureSubViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark- SubView Configuration
- (void)configureSubViews {
    self.telInputTextField.placeholder = @"输入您的手机号码";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:self.telInputTextField];
    
    self.passcodeInputTextField.placeholder = NSLocalizedString(@"输入验证码", @"");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:self.passcodeInputTextField];
    
    [self.gainPasscodeButton setTitle:NSLocalizedString(@"获取验证码", @"") forState:UIControlStateNormal];
    self.gainPasscodeButton.backgroundColor = kDefaultGrayColor;
    [self.gainPasscodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.gainPasscodeButton.layer.cornerRadius = 2;
    self.gainPasscodeButton.layer.masksToBounds = YES;
    
    self.timerLabel.hidden = YES;
    self.timerLabel.text = NSLocalizedString(@"60s", @"");
    self.timerLabel.textAlignment = NSTextAlignmentCenter;
    self.timerLabel.backgroundColor = kDefaultGrayColor;
    self.timerLabel.layer.cornerRadius = 2;
    self.timerLabel.layer.masksToBounds = YES;
    self.timerLabel.textColor = [UIColor whiteColor];
    
    self.footerNotesLabel.numberOfLines = 0;
    self.footerNotesLabel.textColor = kDefaultGrayColor;
    self.footerNotesLabel.font = [UIFont systemFontOfSize:15];
    self.footerNotesLabel.text = [NSString stringWithFormat:@"未注册过的手机将自动创建为 %@ 用户", @"MaxChat"];
    
    self.loginButton.backgroundColor = kDefaultGrayColor;
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginButton setTitle:NSLocalizedString(@"验证并登录", @"") forState:UIControlStateNormal];
    self.loginButton.layer.cornerRadius = 2;
    self.loginButton.layer.masksToBounds = YES;
    
    [self configureNavigationBar];
    [self configureThirdPartyLoginView];
}

- (void)configureNavigationBar {
    if (!self.shouldHideCancelButton) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"取消", nil)
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(cancelButtonPressed:)];
    }
}

- (void)configureThirdPartyLoginView {
    self.otherLoginMethodLabel.text = NSLocalizedString(@"使用其他方式登录", @"");
    self.otherLoginMethodLabel.font = [UIFont systemFontOfSize:15];
    self.otherLoginMethodLabel.textColor = kDefaultGrayColor;
    
    [self.qqLoginButton setImage:ImageNamed(@"ic_qq") forState:UIControlStateNormal];
    [self.weiboLoginButton setImage:ImageNamed(@"ic_weibo") forState:UIControlStateNormal];
    [self.wechatLoginButton setImage:ImageNamed(@"ic_wechat") forState:UIControlStateNormal];
    
    BOOL isQQAvailable = YES;
    BOOL isWeiboAvailable = YES;
    BOOL isWechatAvailable = YES;
    
    self.qqLoginButton.hidden = !isQQAvailable;
    self.weiboLoginButton.hidden = !isWeiboAvailable;
    self.wechatLoginButton.hidden = !isWechatAvailable;
    
    if (isQQAvailable && isWeiboAvailable && isWechatAvailable) {
        self.qqLoginButtonCenterXConstraint.constant = -86;
        self.weiboLoginButtonCenterXConstraint.constant = 0;
        self.wechatLoginButtonCenterXConstraint.constant = 86;
        
    } else if (isQQAvailable && isWeiboAvailable && !isWechatAvailable) {
        self.qqLoginButtonCenterXConstraint.constant = -43;
        self.weiboLoginButtonCenterXConstraint.constant = 43;
        
    } else if (isQQAvailable && !isWeiboAvailable && isWechatAvailable) {
        self.qqLoginButtonCenterXConstraint.constant = -43;
        self.wechatLoginButtonCenterXConstraint.constant = 43;
        
    } else if (!isQQAvailable && isWeiboAvailable && isWechatAvailable) {
        self.weiboLoginButtonCenterXConstraint.constant = -43;
        self.wechatLoginButtonCenterXConstraint.constant = 43;
        
    } else {
        self.qqLoginButtonCenterXConstraint.constant = 0;
        self.weiboLoginButtonCenterXConstraint.constant = 0;
        self.wechatLoginButtonCenterXConstraint.constant = 0;
    }
    
    if (!isQQAvailable && !isWeiboAvailable && !isWechatAvailable) {
        self.otherLoginMethodLabel.hidden = YES;
    }
}

- (void)textDidChange {
    if (self.telInputTextField.text.length == 0) {
        [self resumeGainPasscodeButton];
        return;
    }
    
    if (self.telInputTextField.text.length == 11) {
        self.gainPasscodeButton.backgroundColor = kMainBGColor;
        if (self.passcodeInputTextField.text.length == 6) {
            self.loginButton.backgroundColor = kNavigationBGColor;
        }
    } else {
        self.gainPasscodeButton.backgroundColor = kDefaultGrayColor;
        self.loginButton.backgroundColor = kDefaultGrayColor;
    }
    [self updateLoginButtonStatus];
}

- (void)updateLoginButtonStatus {
    if (self.telInputTextField.text.length == 11 && self.passcodeInputTextField.text.length == 6) {
        self.loginButton.backgroundColor = kNavigationBGColor;
    } else {
        self.loginButton.backgroundColor = kDefaultGrayColor;
    }
}

#pragma mark- Action
- (void)contentViewDidTap:(id)sender {
    [self.view endEditing:YES];
}

- (void)cancelButtonPressed:(id)sender {
    [self.telInputTextField resignFirstResponder];
    [self.passcodeInputTextField resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)gainPasscodeButtonPressed:(id)sender {
    if (self.telInputTextField.text.length == 11) {
        self.gainPasscodeButton.hidden = YES;
        self.timerLabel.hidden = NO;
        
        self.secondsToCountDown = kPasscodeWaitSeconds;
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
        self.timer =  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimer:) userInfo:nil repeats:kPasscodeWaitSeconds];
        [self updateTimer:self.timer];
        [MLUser requestLoginSmsCodeWithPhoneNumber:self.telInputTextField.text block:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded && !error) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"验证码已发送", @"")];
                
            } else {
                if (error) {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
                } else {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
                }
                [self resumeGainPasscodeButton];
            }
        }];
        
    } else {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号"];
    }
}

- (IBAction)loginButtonPressed:(id)sender {
    if (self.telInputTextField.text.length != 11) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号"];
        return;
    }
    if (self.passcodeInputTextField.text.length != 6) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的验证码"];
        return;
    }
    
    [self.timer invalidate];
    self.timer = nil;
    self.secondsToCountDown = kPasscodeWaitSeconds;
    
    [SVProgressHUD showWithStatus:@"正在登录"];
    
    [MLUser loginWithPhoneNumber:self.telInputTextField.text smsCode:self.passcodeInputTextField.text block:^(MLUser * _Nullable user, NSError * _Nullable error) {
        BOOL succeeded = !error && [MLUser currentUser];
        if (succeeded) {
            
            [self.telInputTextField resignFirstResponder];
            [self.passcodeInputTextField resignFirstResponder];
            [self proceedAfterLoginSuccess];
            
            [SVProgressHUD dismiss];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:kMaxLeapDidLoginNofitification object:nil];
        } else {
            if (error) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
            } else {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了", nil)]];
            }
            self.gainPasscodeButton.hidden = NO;
            self.timerLabel.hidden = YES;
        }
    }];
}

- (IBAction)qqLoginButtonPressed:(id)sender {
    NSArray *permissions = @[@"get_user_info", @"get_simple_userinfo", @"add_t"];
    [MLQQUtils loginInBackgroundWithPermissions:permissions block:^(MLUser * _Nullable user, NSError * _Nullable error) {
        if (user) {
            // 登录成功
            [self proceedAfterLoginSuccess];
        } else {
            // 登录失败
            if (error) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
            } else {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了", nil)]];
            }
        }
    }];
}

- (IBAction)weiboLoginButtonPressed:(id)sender {
    
    [MLWeiboUtils loginInBackgroundWithScope:@"all" block:^(MLUser * _Nullable user, NSError * _Nullable error) {
        if (user) {
            // 登录成功
            [self proceedAfterLoginSuccess];
        } else {
            // 登录失败
            if (error) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
            } else {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了", nil)]];
            }
        }
    }];
}

- (IBAction)wechatLoginButtonPressed:(id)sender {
    [MLWeChatUtils loginInBackgroundWithScope:@"snsapi_userinfo" block:^(MLUser * _Nullable user, NSError * _Nullable error) {
        if (user) {
            [self proceedAfterLoginSuccess];
        } else {
            // 登录失败
            if (error) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
            } else {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了", nil)]];
            }
        }
    }];

}





#pragma mark- Delegate，DataSource, Callback Method

#pragma mark- Override Parent Method
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark- Private Method
- (void)updateTimer:(NSTimer *)timer {
    NSUInteger currentSecond = self.secondsToCountDown;
    self.timerLabel.text = [NSString stringWithFormat:@"%ds", (int)currentSecond];
    if (self.secondsToCountDown > 0) {
        self.secondsToCountDown--;
    }
    
    if (self.secondsToCountDown == 0) {
        [self resumeGainPasscodeButton];
    }
}

- (void)resumeGainPasscodeButton {
    self.gainPasscodeButton.hidden = NO;
    self.timerLabel.hidden = YES;
    
    [self.timer invalidate];
    self.timer = nil;
    self.secondsToCountDown = kPasscodeWaitSeconds;
}

- (void)proceedAfterLoginSuccess {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark- Getter Setter
- (UITapGestureRecognizer *)touchGesture {
    if (!_touchGesture) {
        _touchGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewDidTap:)];
    }
    
    return _touchGesture;
}




@end
