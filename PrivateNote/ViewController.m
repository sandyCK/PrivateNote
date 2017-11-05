//
//  ViewController.m
//  MPM
//
//  Created by sandy on 2017/8/10.
//  Copyright © 2017年 concox. All rights reserved.
//

#import "ViewController.h"
#import "SetPwdViewController.h"
#import "TextEditViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)LAContext *context;
@property (nonatomic, strong)UITableView *mTableView;
@property (nonatomic, strong)UIView *noRecordView;

@property (nonatomic, strong)NSArray<DataModel *> *dataArray;

@end

@implementation ViewController

- (LAContext *)context
{
    if (_context == nil) {
        _context = [[LAContext alloc]init];
        _context.localizedFallbackTitle = @"输入密码";
    }
    return _context;
}

- (UITableView *)mTableView
{
    if (_mTableView == nil) {
        _mTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kNaviAndStatusHeight, kScreenWidth, kScreenHeight - kNaviAndStatusHeight) style:UITableViewStylePlain];
        _mTableView.sectionHeaderHeight = 0.1f;
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
    }
    return _mTableView;
}

- (UIView *)noRecordView
{
    if (_noRecordView == nil) {
        _noRecordView = [[UIView alloc]initWithFrame:CGRectMake(0, kNaviAndStatusHeight, kScreenWidth, kScreenHeight - kNaviAndStatusHeight)];
        _noRecordView.backgroundColor = [UIColor clearColor];
        
        CGFloat labelH = 44.f;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, (_noRecordView.frame.size.height - labelH) / 2, kScreenWidth - 20, labelH)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor blackColor];
        label.text = @"还没有记录，点击右上角添加";
        [_noRecordView addSubview:label];
    }
    return _noRecordView;
}

- (NSArray<DataModel *> *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[DataBase sharedDataBase] getAllData];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    self.view.userInteractionEnabled = NO;
    [self initNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needLogin) name:KEY_NEEDLOGIN_NOTIFICATION object:nil];
    [self reloadData];
    
    [self.mTableView removeFromSuperview];
    [self.noRecordView removeFromSuperview];
    if (self.dataArray.count > 0) {
        [self.view addSubview:self.mTableView];
        [self.mTableView reloadData];
    } else {
        [self.view addSubview:self.noRecordView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.view.userInteractionEnabled = YES;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:KEY_LOGIN_OR_NOT]) {
        SetPwdViewController *setVC = [[SetPwdViewController alloc]init];
        [self presentViewController:setVC animated:YES completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    
    CGFloat btnW = 28.f;
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.backgroundColor = [UIColor clearColor];
    addBtn.frame = CGRectMake(kScreenWidth - 40, kStatusBarHeight + (kNavigationBarHeight - btnW) / 2, btnW, btnW);
    [addBtn setBackgroundImage:[UIImage imageNamed:@"icon_preview_add_no"] forState:UIControlStateNormal];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"icon_preview_add_pre"] forState:UIControlStateHighlighted];
    addBtn.highlighted = NO;
    [addBtn addTarget:self action:@selector(addData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
}

- (void)identifyTouchID: (NSInteger)index
{
    __weak typeof(self) weakSelf = self;
    NSError *error = nil;
    if ([self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
        [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"请验证指纹" reply:^(BOOL success, NSError * _Nullable error) {
            [weakSelf.context invalidate];
            _context = nil;
            if (success) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    TextEditViewController *vc = [[TextEditViewController alloc]init];
                    vc.originalData = [[DataModel alloc] init];
                    vc.originalData.index = [weakSelf.dataArray objectAtIndex:index].index;
                    vc.originalData.name = [weakSelf.dataArray objectAtIndex:index].name;
                    vc.originalData.content = [weakSelf.dataArray objectAtIndex:index].content;
                    [weakSelf presentViewController:vc animated:YES completion:nil];
                });
            } else {
                NSLog(@"%@",error.localizedDescription);
                switch (error.code) {
                    case LAErrorSystemCancel:
                    {
                        NSLog(@"系统取消授权，如其他APP切入");
                        break;
                    }
                    case LAErrorUserCancel:
                    {
                        break;
                    }
                    case LAErrorAuthenticationFailed:
                    {
                        break;
                    }
                    case LAErrorPasscodeNotSet:
                    {
                        NSLog(@"系统未设置密码");
                        break;
                    }
                    case LAErrorTouchIDNotAvailable:
                    {
                        NSLog(@"设备Touch ID不可用，例如未打开");
                        break;
                    }
                    case LAErrorTouchIDNotEnrolled:
                    {
                        NSLog(@"设备Touch ID不可用，用户未录入");
                        break;
                    }
                    case LAErrorUserFallback:
                    {
                        NSLog(@"用户选择输入密码，切换主线程处理");
                        break;
                    }
                    case LAErrorTouchIDLockout:
                    {
                        NSLog(@"Too many failed Touch ID attempts");
                        break;
                    }
                    case LAErrorAppCancel:
                    {
                        NSLog(@"Authentication was canceled by application");
                        break;
                    }
                    default:
                    {
                        NSLog(@"其他情况");
                        break;
                    }
                }
            }
        }];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"不支持指纹解锁" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)addData
{
    TextEditViewController *vc = [[TextEditViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)reloadData
{
    _dataArray = nil;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell_id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    DataModel *data = (DataModel *)[self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", data.name];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self identifyTouchID:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"%s", __FUNCTION__);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        __weak typeof(self) weakSelf = self;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"数据删除后不能恢复，是否确定？" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action){
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            
            if ([[DataBase sharedDataBase] deleteData:weakSelf.dataArray[indexPath.row].index]) {
                _dataArray = nil;
                if (weakSelf.dataArray.count == 0) {
                    [weakSelf.mTableView removeFromSuperview];
                    [weakSelf.view addSubview:weakSelf.noRecordView];
                } else
                    [tableView reloadData];
            } else
                NSLog(@"---> 删除失败！！！");
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

#pragma mark - KEY_NEEDLOGIN_NOTIFICATION
- (void)needLogin
{
    SetPwdViewController *setVC = [[SetPwdViewController alloc]init];
    [self presentViewController:setVC animated:YES completion:nil];
}


@end
