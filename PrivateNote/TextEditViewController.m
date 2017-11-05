//
//  TextEditViewController.m
//  PrivateNoteBook
//
//  Created by sandy on 2017/8/19.
//  Copyright © 2017年 concox. All rights reserved.
//

#import "TextEditViewController.h"
#import "SetPwdViewController.h"

const static CGFloat titleH = 44.f;
const static CGFloat offset = 2.f;

@interface TextEditViewController () <UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong)UIButton *confirmBtn;

@property (nonatomic, strong)UITextField *titleTextField;
@property (nonatomic, strong)UITextView *textView;
@property (nonatomic, strong)UILabel *textViewPlaceholder;

@property (nonatomic, assign)BOOL isFirstIn;

@end

@implementation TextEditViewController

- (UITextField *)titleTextField
{
    if (!_titleTextField) {
        _titleTextField = [[UITextField alloc]initWithFrame:CGRectMake(offset, kNaviAndStatusHeight + offset, kScreenWidth - 2*offset, titleH)];
        _titleTextField.layer.borderColor = [UIColor blackColor].CGColor;
        _titleTextField.layer.cornerRadius = 3.f;
        _titleTextField.layer.borderWidth = 0.5f;
        _titleTextField.font = [UIFont systemFontOfSize:20];
        _titleTextField.placeholder = @"请输入标题";
        _titleTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _titleTextField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, 0)];
        _titleTextField.leftViewMode = UITextFieldViewModeUnlessEditing;
        _titleTextField.returnKeyType = UIReturnKeyDone;
        _titleTextField.delegate = self;
    }
    return _titleTextField;
}

- (UITextView *)textView
{
    if (_textView == nil) {
        _textView = [[UITextView alloc]initWithFrame:CGRectMake(offset, kNaviAndStatusHeight + titleH + 2*offset, kScreenWidth - 2*offset, kScreenHeight - (kNaviAndStatusHeight + titleH + 2*offset) - 10)];
        _textView.textColor = [UIColor blackColor];
        _textView.font = [UIFont systemFontOfSize:20];
        _textView.layer.borderColor = [UIColor blackColor].CGColor;
        _textView.layer.cornerRadius = 3.f;
        _textView.layer.borderWidth = 0.5f;
        _textView.delegate = self;
    }
    return _textView;
}

- (UILabel *)textViewPlaceholder
{
    if (!_textViewPlaceholder) {
        _textViewPlaceholder = [[UILabel alloc]initWithFrame:CGRectMake(offset, kNaviAndStatusHeight + titleH + 2*offset, kScreenWidth - 2*offset, 44.f)];
        _textViewPlaceholder.text = @"请输入内容";
        _textViewPlaceholder.textColor = [UIColor grayColor];
        _textViewPlaceholder.textAlignment = NSTextAlignmentLeft;
    }
    return _textViewPlaceholder;
}

- (UIButton *)confirmBtn
{
    if (!_confirmBtn) {
        CGFloat btnW = 44.f, btnH = 30.f;
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.frame = CGRectMake(kScreenWidth - btnW - 10.f, kStatusBarHeight + (kNavigationBarHeight - btnH) / 2, btnW, btnH);
        _confirmBtn.backgroundColor = [UIColor clearColor];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        _confirmBtn.highlighted = NO;
        _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_confirmBtn addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.userInteractionEnabled = NO;
    self.isFirstIn = YES;
    [self initNavigationBar];
    [self.view addSubview:self.titleTextField];
    [self.view addSubview:self.textView];
    [self.view addSubview:self.confirmBtn];
    
    if (self.originalData) {
        [self.titleTextField setText:self.originalData.name];
        [self.textView setText:self.originalData.content];
    }
    
    if (!self.textView.text || [self.textView.text isEqualToString:@""]) {
        [self.view addSubview:self.textViewPlaceholder];
        [self.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    } else {
        [self.confirmBtn setTitle:@"修改" forState:UIControlStateNormal];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.userInteractionEnabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needLogin) name:KEY_NEEDLOGIN_NOTIFICATION object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.view.userInteractionEnabled = YES;
    if (self.isFirstIn) {
        self.isFirstIn = NO;
        if (self.textView.text && self.textView.text.length > 0) {
            [self.textView becomeFirstResponder];
        } else
            [self.titleTextField becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.titleTextField resignFirstResponder];
    [self.textView resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEY_NEEDLOGIN_NOTIFICATION object:nil];
}

- (void)initNavigationBar
{
    UIView *statusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kStatusBarHeight)];
    statusView.backgroundColor = ZJColorFromRGB(0x019d92);
    [self.view addSubview:statusView];
    
    UIView *navView = [[UIView alloc]initWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth, kNavigationBarHeight)];
    navView.backgroundColor = ZJColorFromRGB(0x019d92);
    [self.view addSubview:navView];
    
    UIImage *backImg = [UIImage imageNamed:@"icon_back_no"];
    UIButton *backBut = [[UIButton alloc] initWithFrame:CGRectMake(10, 7.5f, backImg.size.width, backImg.size.width)];
    [backBut setBackgroundImage:backImg forState:UIControlStateNormal];
    [backBut setBackgroundImage:[UIImage imageNamed:@"icon_back_sel"] forState:UIControlStateHighlighted];
    backBut.highlighted = NO;
    [backBut setBackgroundColor:[UIColor clearColor]];
    [backBut addTarget:self action:@selector(navLeftBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backBut];
}

- (void)navLeftBtnAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)confirmAction: (UIButton *)button
{
    __weak typeof(self) weakSelf = self;
    if (!self.titleTextField.text || self.titleTextField.text.length <= 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"标题不能为空" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if (!self.textView.text || self.textView.text.length <= 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"内容不能为空" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    BOOL res = NO;
    if (self.originalData) {
        if ([self.originalData.name isEqualToString:self.titleTextField.text] && [self.originalData.content isEqualToString:self.textView.text]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"未做任何修改，是否返回上一个页面？" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        self.originalData.name = self.titleTextField.text;
        self.originalData.content = self.textView.text;
        res = [[DataBase sharedDataBase] modifyData:self.originalData];
    } else {
        DataModel *model = [[DataModel alloc]init];
        model.name = [NSString stringWithString:self.titleTextField.text];
        model.content = [NSString stringWithString:self.textView.text];
        res = [[DataBase sharedDataBase] insertData:model];
    }
    
    if (res) {
        NSString *tmp = nil;
        if (self.originalData) {
            tmp = @"修改成功";
        } else
            tmp = @"添加成功";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:tmp preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:nil];
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
        }];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"修改数据失败，联系开发者！！！" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        self.textViewPlaceholder.hidden = NO;
    } else {
        self.textViewPlaceholder.hidden = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.textView becomeFirstResponder];
    return YES;
}

#pragma mark - KEY_NEEDLOGIN_NOTIFICATION
- (void)needLogin
{
    SetPwdViewController *setVC = [[SetPwdViewController alloc]init];
    [self presentViewController:setVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
