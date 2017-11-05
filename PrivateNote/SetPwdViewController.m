//
//  SetPwdViewController.m
//  MPM
//
//  Created by sandy on 2017/8/11.
//  Copyright © 2017年 concox. All rights reserved.
//

#import "SetPwdViewController.h"

@interface SetPwdViewController ()

@property (nonatomic, assign)CGFloat screenW;
@property (nonatomic, assign)CGFloat screenH;

@property (nonatomic, assign)BOOL isFirstUse;
@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UIButton *cancelBtn;
@property (nonatomic, strong)NSArray<UIView *> *circleArray;
@property (nonatomic, strong)NSString *userEnteredPwd;
@property (nonatomic, strong)NSString *firstEnteredPwd;

@end

@implementation SetPwdViewController

- (NSString *)userEnteredPwd
{
    if (_userEnteredPwd == nil) {
        _userEnteredPwd = [NSString string];
    }
    return _userEnteredPwd;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:9.f / 255.f green:51.f / 255.f blue:46.f / 255.f alpha:0.8];
    self.screenW = [[UIScreen mainScreen]bounds].size.width;
    self.screenH = [[UIScreen mainScreen]bounds].size.height;
    
    NSString *pwd = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:KEY_PASSWORD];
    if (pwd == nil || [pwd isEqualToString:@""]) {
        self.isFirstUse = YES;
    } else
        self.isFirstUse = NO;
    
    [self initNumKeyboard];
}

- (void)initNumKeyboard {
    CGFloat circleW = 75.f;
    CGFloat XOffSet = 44.f;
    CGFloat XSpace = (self.screenW - 2 * XOffSet  - 3 * circleW) / 2;
    CGFloat YSpace = 15.f;
    CGFloat littleCircleW = 10.f;
    CGFloat littleCircleDelta = (self.screenW - 2 * (XOffSet + circleW / 2) - 6 * littleCircleW) / 5;
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.screenH - (5 * circleW + 4 * YSpace) - 120.f, self.screenW - 20, 60.f)];
    if (self.isFirstUse) {
        self.titleLabel.text = @"初次使用，请设置6位数字独立密码";
    } else
        self.titleLabel.text = @"请输入密码";
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.titleLabel setFont:[UIFont systemFontOfSize:18]];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
    
    NSMutableArray *tmp = [NSMutableArray array];
    for (int i = 0; i < 6; i++) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(XOffSet + circleW / 2 + i * (littleCircleW + littleCircleDelta), self.screenH - (5 * circleW + 4 * YSpace) - 40.f, littleCircleW, littleCircleW)];
        view.layer.cornerRadius = littleCircleW / 2;
        view.layer.borderColor = [UIColor colorWithRed:0 green:144.f / 255.f blue:121.f / 255.f alpha:0.8].CGColor;
        view.layer.borderWidth = 1.5f;
        view.layer.masksToBounds = YES;
        view.backgroundColor = [UIColor clearColor];
        [self.view addSubview:view];
        [tmp addObject:view];
    }
    self.circleArray = [NSArray arrayWithArray:tmp];
    
    for (int i = 0; i < 12; i++) {
        if (i == 9) {
            continue;
        }
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(XOffSet + (i % 3) * (circleW + XSpace), (self.screenH - (5 * circleW + 4 * YSpace)) + (i / 3) * (circleW + YSpace), circleW, circleW);
        btn.highlighted = YES;
        if (i == 11) {
            [btn setTitle:@"取消" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(warnExit) forControlEvents:UIControlEventTouchUpInside];
            self.cancelBtn = btn;
        } else {
            btn.titleLabel.font = [UIFont systemFontOfSize:44.f];
            [btn setBackgroundImage:[self createImageWithColor:self.view.backgroundColor] forState:UIControlStateNormal];
            [btn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:0 green:144.f / 255.f blue:121.f / 255.f alpha:0.8]] forState:UIControlStateHighlighted];
            btn.highlighted = NO;
            btn.layer.cornerRadius = circleW / 2;
            btn.layer.borderColor = [UIColor colorWithRed:0 green:144.f / 255.f blue:121.f / 255.f alpha:0.8].CGColor;
            btn.layer.borderWidth = 1.5f;
            btn.layer.masksToBounds = YES;
            if (i < 10) {
                [btn setTitle:[NSString stringWithFormat:@"%d", i + 1] forState:UIControlStateNormal];
            } else
                [btn setTitle:[NSString stringWithFormat:@"%d", 0] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(numClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.view addSubview:btn];
    }
}

// 数字键点击事件
- (void)numClick:(UIButton *)sender {
    if (self.userEnteredPwd.length == 6) {
        return;
    }
    
//    NSLog(@"%@", sender.titleLabel.text);
    self.userEnteredPwd = [NSString stringWithFormat:@"%@%@", self.userEnteredPwd, sender.titleLabel.text];
    [self updateCircles:self.userEnteredPwd.length];
    
    if (self.userEnteredPwd.length == 6) {
        if (self.isFirstUse) {
            if (self.firstEnteredPwd == nil) {
                self.firstEnteredPwd = [NSString stringWithString:self.userEnteredPwd];
                self.titleLabel.text = @"请再次输入密码以确认";
                self.userEnteredPwd = nil;
                [self updateCircles:0];
            } else {
                if (![self.firstEnteredPwd isEqualToString:self.userEnteredPwd]) {
                    [self updateCircles:0];
                    self.titleLabel.text = @"初次使用，请设置6位数字独立密码";
                    self.userEnteredPwd = nil;
                    self.firstEnteredPwd = nil;
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"两次输入密码不一致，请重新输入" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    [self presentViewController:alert animated:YES completion:^{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [alert dismissViewControllerAnimated:YES completion:nil];
                        });
                    }];
                } else {
                    // 保存密码
                    [[NSUserDefaults standardUserDefaults] setObject:self.userEnteredPwd forKey:KEY_PASSWORD];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_LOGIN_OR_NOT];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    __weak typeof(self) weakSelf = self;
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"独立密码设置成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    [self presentViewController:alert animated:YES completion:^{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [alert dismissViewControllerAnimated:YES completion:nil];
                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                        });
                    }];
                }
            }
        } else {
            NSString *pwd = (NSString *) [[NSUserDefaults standardUserDefaults] objectForKey:KEY_PASSWORD];
            if ([pwd isEqualToString:self.userEnteredPwd]) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_LOGIN_OR_NOT];
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                self.userEnteredPwd = nil;
                [self updateCircles:0];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"一天之内输错三次，当天将不能再使用" preferredStyle:UIAlertControllerStyleAlert];
                [self presentViewController:alert animated:YES completion:^{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [alert dismissViewControllerAnimated:YES completion:nil];
                    });
                }];
            }
        }
    }
}

// 取消键点击事件
- (void)warnExit {
    if (self.userEnteredPwd == nil || [self.userEnteredPwd isEqualToString:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"点击确定程序将退出，是否确定？" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            exit(0);
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        if (self.userEnteredPwd.length <= 1) {
            self.userEnteredPwd = @"";
        } else {
            self.userEnteredPwd = [self.userEnteredPwd substringToIndex:self.userEnteredPwd.length - 1];
        }
        [self updateCircles:self.userEnteredPwd.length];
    }
}

- (void)updateCircles:(NSInteger)num {
    for (int i = 0; i < self.circleArray.count; i++) {
        UIView *view = [self.circleArray objectAtIndex:i];
        if (i < num) {
            view.backgroundColor = [UIColor colorWithRed:0 green:144.f / 255.f blue:121.f / 255.f alpha:0.8];
        } else
            view.backgroundColor = [UIColor clearColor];
    }
    
    if (self.userEnteredPwd.length > 0) {
        [self.cancelBtn setTitle:@"删除" forState:UIControlStateNormal];
    } else {
        [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    }
}

- (UIImage*) createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
