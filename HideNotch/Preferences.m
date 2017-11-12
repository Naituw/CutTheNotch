//
//  Preferences.m
//  HideNotch
//
//  Created by wutian on 2017/11/12.
//  Copyright © 2017年 Weibo. All rights reserved.
//

#import "Preferences.h"

@implementation Preferences

+ (BOOL)recordModeEnabled
{
    static BOOL enabled = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"record_mode_enabled"];
    });
    return enabled;
}

@end
