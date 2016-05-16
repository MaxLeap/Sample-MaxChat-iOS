//
//  RegisterViewController.m
//  MaxChat
//
//  Created by 周和生 on 16/5/4.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "MCSignViewController.h"



@interface MCSignViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameInputTextField;
@property (weak, nonatomic) IBOutlet UITextField *passcodeInputTextField;

@property (weak, nonatomic) IBOutlet UIButton *signButton;

@property (nonatomic, strong) UITapGestureRecognizer *touchGesture;
@end

@implementation MCSignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.signType==MaxChatSignUp) {
        self.navigationItem.title = @"注册";
    } else {
        self.navigationItem.title = @"登录";
    }
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
    self.usernameInputTextField.placeholder = @"输入您的用户名";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:self.usernameInputTextField];
    
    self.passcodeInputTextField.placeholder = NSLocalizedString(@"输入您的密码", @"");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:self.passcodeInputTextField];
    
    self.signButton.backgroundColor = kDefaultGrayColor;
    [self.signButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (self.signType==MaxChatSignUp) {
        [self.signButton setTitle:NSLocalizedString(@"注册", @"") forState:UIControlStateNormal];
    } else {
        [self.signButton setTitle:NSLocalizedString(@"登录", @"") forState:UIControlStateNormal];
    }
    self.signButton.layer.cornerRadius = 2;
    self.signButton.layer.masksToBounds = YES;
    
    [self configureNavigationBar];
}

- (void)configureNavigationBar {
    if (!self.shouldHideCancelButton) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"取消", nil)
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(cancelButtonPressed:)];
    }
}

- (BOOL)isValidUser:(NSString *)username password:(NSString *)password {
    return [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length>1 && password.length>6;
}

- (void)textDidChange {
    [self updatesignButtonStatus];
}

- (void)updatesignButtonStatus {
    if ([self isValidUser:self.usernameInputTextField.text password:self.passcodeInputTextField.text]) {
        self.signButton.backgroundColor = kNavigationBGColor;
    } else {
        self.signButton.backgroundColor = kDefaultGrayColor;
    }
}

#pragma mark- Action
- (void)contentViewDidTap:(id)sender {
    [self.view endEditing:YES];
}

- (void)cancelButtonPressed:(id)sender {
    [self.usernameInputTextField resignFirstResponder];
    [self.passcodeInputTextField resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)signButtonPressed:(id)sender {
    

    if (self.signType==MaxChatSignUp) {
        [SVProgressHUD showWithStatus:@"正在注册"];
        MLUser *user = [MLUser user];
        user.username = self.usernameInputTextField.text;
        user.password = self.passcodeInputTextField.text;
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self.usernameInputTextField resignFirstResponder];
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
            }
        }];
    } else {
        [SVProgressHUD showWithStatus:@"正在登录"];
        [MLUser logInWithUsernameInBackground: self.usernameInputTextField.text
                                     password: self.passcodeInputTextField.text
                                        block:^(MLUser *user, NSError *error) {
                                            if (user) {
                                                [self.usernameInputTextField resignFirstResponder];
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
                                            }
        }];
    }
}




#pragma mark- Delegate，DataSource, Callback Method

#pragma mark- Override Parent Method
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark- Private Method

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
