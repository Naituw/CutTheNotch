//
//  AppDelegate.m
//  HideNotch
//
//  Created by 吴天 on 2017/11/10.
//  Copyright © 2017年 Weibo. All rights reserved.
//

#import "AppDelegate.h"
#import "Preferences.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (![Preferences recordModeEnabled]) {
        if ([Preferences deviceNotCapable]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            _window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"NotCapable"];
        } else {
            _window.transform = CGAffineTransformMakeRotation(-M_PI / 2);
        }
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        _window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[storyboard instantiateViewControllerWithIdentifier:@"ViewController"]];
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    if (![Preferences recordModeEnabled]) {
        if (_window.rootViewController.presentedViewController) {
            [_window.rootViewController dismissViewControllerAnimated:NO completion:NULL];
        }
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([Preferences recordModeEnabled] != [[NSUserDefaults standardUserDefaults] boolForKey:@"record_mode_enabled"]) {
        UIViewController * viewController = self.window.rootViewController;
        while (viewController.presentedViewController) {
            viewController = viewController.presentedViewController;
        }
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Restart Required" message:[NSString stringWithFormat:@"You've %@ the Record Mode, Press \"Exit\" and relaunch to take effect", [Preferences recordModeEnabled] ? @"disabled" : @"enabled"] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Exit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            exit(0);
        }]];
        [viewController presentViewController:alert animated:YES completion:NULL];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
