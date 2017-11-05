//
//  AppDelegate.m
//  PrivateNoteBook
//
//  Created by sandy on 2017/8/18.
//  Copyright © 2017年 concox. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@property (nonatomic,assign) UIBackgroundTaskIdentifier backgroundUpdateTask;  //后台线程
@property (nonatomic,strong) NSTimer *backgroundTimer;      //后台计时器
@property (nonatomic,assign) NSInteger backgroundTimeCount; //后台计时数

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    ViewController *vc = [[ViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    self.window.rootViewController = nav;
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KEY_LOGIN_OR_NOT];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    NSLog(@"%s", __FUNCTION__);
    [self beginBackgroundUpdateTask];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    NSLog(@"%s", __FUNCTION__);
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self endBackgroundUpdateTask];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:KEY_LOGIN_OR_NOT]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KEY_NEEDLOGIN_NOTIFICATION object:nil];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)beginBackgroundUpdateTask
{
    self.backgroundTimeCount = 0;
    [self.backgroundTimer invalidate];
    self.backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(backgroundDataAction:) userInfo:nil repeats:YES];
    self.backgroundUpdateTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void)endBackgroundUpdateTask
{
    if (self.backgroundTimer) {
        [self.backgroundTimer invalidate];
    }
    self.backgroundTimer = nil;
    self.backgroundTimeCount = 0;
    
    if (self.backgroundUpdateTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundUpdateTask];
        self.backgroundUpdateTask = UIBackgroundTaskInvalid;
    }
}

- (void)backgroundDataAction:(NSTimer *)timer
{
    self.backgroundTimeCount ++;
    if (self.backgroundTimeCount > 60) {   //1分之后处理数据
        self.backgroundTimeCount = 0;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KEY_LOGIN_OR_NOT];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self endBackgroundUpdateTask];
    } else {
        NSLog(@"backgroundDataAction(%lu):%ld", (unsigned long)self.backgroundUpdateTask, (long)self.backgroundTimeCount);
    }
}


@end
