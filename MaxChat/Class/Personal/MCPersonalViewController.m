//
//  PersonalViewController.m
//  MaxChat
//
//  Created by 周和生 on 16/5/3.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "MCPersonalViewController.h"
#import "MCLoginViewController.h"
#import "MCUserIconCell.h"
#import "MCSignViewController.h"
#import "Constants.h"
@import SVProgressHUD;
@import SDWebImage;
@import MaxLeap;



@interface MCPersonalViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIAlertController *actionController;
@property (nonatomic, strong) UIAlertController *alertWithText;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation MCPersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = NSLocalizedString(@"个人信息", nil);
    NSLog(@"Current user is %@", [MLUser currentUser]);
    
    [self.tableView registerClass:[MCUserIconCell class] forCellReuseIdentifier:@"UserIconCell"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showNavigationButtons];
    [self.tableView reloadData];
}

- (void)showNavigationButtons {
    if ([self isLoginRequired]) {
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"其它登录", @selector(login:));
        self.navigationItem.leftBarButtonItems = @[BARBUTTON(@"登录", @selector(loginUser:)), BARBUTTON(@"注册", @selector(registerUser:))];
    } else {
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"登出", @selector(logout:));
        self.navigationItem.leftBarButtonItems = nil;
    }
}

- (void)login:(id)sender {
    MCLoginViewController *loginViewController = [[MCLoginViewController alloc]init];
    UINavigationController *loginNavigationController = [[UINavigationController alloc]initWithRootViewController:loginViewController];
    [self presentViewController:loginNavigationController animated:YES completion:nil];
}

- (void)registerUser:(id)sender {
    MCSignViewController *signViewController = [[MCSignViewController alloc]init];
    signViewController.signType = MaxChatSignUp;
    UINavigationController *signNavigationController = [[UINavigationController alloc]initWithRootViewController:signViewController];
    [self presentViewController:signNavigationController animated:YES completion:nil];
}

- (void)loginUser:(id)sender {
    MCSignViewController *signViewController = [[MCSignViewController alloc]init];
    signViewController.signType = MaxChatSignIn;
    UINavigationController *signNavigationController = [[UINavigationController alloc]initWithRootViewController:signViewController];
    [self presentViewController:signNavigationController animated:YES completion:nil];
}

- (void)logout:(id)sender {
    [MLUser logOut];
    [[NSNotificationCenter defaultCenter]postNotificationName:kMaxLeapDidLogoutNofitification object:nil];
    
    [self showNavigationButtons];
    [self.tableView reloadData];
}



- (BOOL)isLoginRequired {
    MLUser *currentUser = [MLUser currentUser];
    if (currentUser) {
        if ([MLAnonymousUtils isLinkedWithUser:currentUser]) {
            // 已经匿名登录
            return YES;
        } else {
            // 常规登录
            return NO;
        }
    } else {
        // 未登录
        return YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark- Delegate，DataSource, Callback Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self isLoginRequired]) {
        return 0;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
            cell.textLabel.text = @"用户名";
            cell.detailTextLabel.text = [MLUser currentUser].username;
            
        } else if (indexPath.row == 1) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
            cell.textLabel.text = @"手机号";
            cell.detailTextLabel.text = [[MLUser currentUser] objectForKey:@"mobilePhone"];
            
        } else if (indexPath.row == 2) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
            cell.textLabel.text = @"昵称";
            cell.detailTextLabel.text = [[MLUser currentUser] objectForKey:@"nickName"];
            
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"UserIconCell" forIndexPath:indexPath];
            MCUserIconCell *iconCell = (MCUserIconCell *)cell;
            iconCell.textLabel.text = @"头像";
            
            [iconCell.iconImageView sd_setImageWithURL:[NSURL URLWithString: [[MLUser currentUser]objectForKey:@"iconUrl"]]
                                      placeholderImage:ImageNamed(@"default_portrait")
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             }];
        }
        
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // 不允许修改
        } else if (indexPath.row == 1) {
            // 谨慎修改
        } else if (indexPath.row == 2) {
            [self showAlertWithTextInputType:@"nickName" message:@"请输入您的昵称："];
        } else {
            [self presentViewController:self.actionController animated:YES completion:nil];
        }
    }
    
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        
        [SVProgressHUD showWithStatus:@"正在更新"];
        [self.imagePickerController dismissViewControllerAnimated:YES completion:^{
            
            NSData *data = UIImageJPEGRepresentation(image, 0.8);
            MLFile *file = [MLFile fileWithName:@"icon.jpg" data:data];
            [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSString *urlString = file.url;
                    [[MLUser currentUser]setObject:urlString forKey:@"iconUrl"];
                    [[MLUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (succeeded) {
                            [SVProgressHUD dismiss];
                            [self.tableView reloadData];
                        } else {
                            if (error) {
                                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"出错了:%@", nil), error.localizedDescription]];
                            } else {
                                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"头像上传失败!", nil)]];
                            }
                        }
                    }];
                } else {
                    [SVProgressHUD showErrorWithStatus:@"上传文件出错了!"];
                }
            }];
        }];
    }
}


#pragma mark - alert controllers
- (void)showAlertWithTextInputType:(NSString *)type message:(NSString *)message {
    
    [self presentViewController:[self alertWithTextType:type message:message]
                       animated:YES
                     completion:nil];
}

- (UIAlertController *)alertWithTextType:(NSString *)type message:(NSString *)message {
    
    _alertWithText = [UIAlertController alertControllerWithTitle:@"个人信息"
                                                         message:message
                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        NSLog(@"User choose OK");
                                                        NSString *textInput = [self accessAlertTextField];
                                                        NSLog(@"User Input was %@ for %@", textInput, type);
                                                        if (textInput.length) {
                                                            [[MLUser currentUser]setObject:textInput forKey:type];
                                                            [[MLUser currentUser]saveInBackgroundWithBlock:nil];
                                                            [self.tableView reloadData];
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

- (UIAlertController *)actionController {
    if (!_actionController) {
        _actionController = [UIAlertController alertControllerWithTitle:nil
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"拍照"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                                                                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
                                                                        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                                        [self presentViewController:self.imagePickerController animated:YES completion:nil];
                                                                    }
                                                                }];
        
        UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"从相册中选择"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
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
@end
