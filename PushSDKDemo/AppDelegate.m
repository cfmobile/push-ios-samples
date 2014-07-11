//
//  AppDelegate.m
//  DemoApp
//
//  Created by Rob Szumlakowski on 2013-12-13.
//  Copyright (c) 2013 Pivotal. All rights reserved.
//

#import "AppDelegate.h"
#import "Settings.h"
#import <Push/MSSPushSDK.h>
#import <Push/MSSSDK.h>
#import <Push/MSSParameters.h>
#import <Push/MSSPersistentStorage+Push.h>
#import <Push/MSSPushDebug.h>

@interface AppDelegate ()

@property (nonatomic) BOOL registered;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:[Settings defaults]];
    
    [self initializeSDK];
    return YES;
}

- (void)initializeSDK
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    static BOOL usePlist = YES;
    MSSParameters *parameters;
    if (usePlist) {
        parameters = [MSSParameters defaultParameters];
        
    } else {
        //MSSParameters configured in code
        parameters = [Settings registrationParameters];
        NSString *message = [NSString stringWithFormat:@"Initializing library with parameters: releaseUUID: \"%@\" releaseSecret: \"%@\" deviceAlias: \"%@\".",
                             parameters.variantUUID,
                             parameters.releaseSecret,
                             parameters.pushDeviceAlias];
        MSSPushLog(message);
    }
    
    [MSSPushSDK setRegistrationParameters:parameters];
#warning - TODO integrate analytics into demo app
    [MSSPushSDK setCompletionBlockWithSuccess:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        MSSPushLog(@"Application received callback \"registrationSucceeded\".");
        
    } failure:^(NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        MSSPushLog(@"Application received callback \"registrationFailedWithError:\". Error: \"%@\"", error.localizedDescription);
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    MSSPushLog(@"Received message: %@", userInfo[@"aps"][@"alert"]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    MSSPushLog(@"FetchCompletionHandler Received message:");
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
}

#pragma mark - UIApplicationDelegate Push Notification Callback

- (void) application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    MSSPushLog(@"Received message: didRegisterForRemoteNotificationsWithDeviceToken:");
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    MSSPushLog(@"Received message: didFailToRegisterForRemoteNotificationsWithError:");
}

@end
