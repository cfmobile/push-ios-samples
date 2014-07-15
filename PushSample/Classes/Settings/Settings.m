//
//  Settings.m
//  MSSPush
//
//  Created by Rob Szumlakowski on 2014-01-31.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "Settings.h"
#import <MSSPush/MSSParameters.h>

static NSString *const BACK_END_REQUEST_URL = @"http://cfms-push-service-dev.main.vchs.cfms-apps.com/v1/";

static NSString *const DEFAULT_VARIANT_UUID   = @"288866db-f631-4da2-8508-8385fc9c4880";
static NSString *const DEFAULT_RELEASE_SECRET = @"1b1a4163-5ee5-4b69-813b-5530c9fcd395";
static NSString *const DEFAULT_DEVICE_ALIAS   = @"Default Device Alias";

static NSString *const KEY_VARIANT_UUID    = @"KEY_VARIANT_UUID";
static NSString *const KEY_RELEASE_SECRET  = @"KEY_RELEASE_SECRET";
static NSString *const KEY_DEVICE_ALIAS    = @"KEY_DEVICE_ALIAS";

@implementation Settings

+ (NSString *)variantUUID {
  return [[NSUserDefaults standardUserDefaults] stringForKey:KEY_VARIANT_UUID];
}

+ (void)setVariantUUID:(NSString *)variantUUID
{
    [[NSUserDefaults standardUserDefaults] setObject:variantUUID forKey:KEY_VARIANT_UUID];
}

+ (NSString *)releaseSecret
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:KEY_RELEASE_SECRET];
}

+ (void)setReleaseSecret:(NSString *)releaseSecret
{
    [[NSUserDefaults standardUserDefaults] setObject:releaseSecret forKey:KEY_RELEASE_SECRET];
}

+ (NSString *)deviceAlias
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:KEY_DEVICE_ALIAS];
}

+ (void)setDeviceAlias:(NSString *)deviceAlias
{
    [[NSUserDefaults standardUserDefaults] setObject:deviceAlias forKey:KEY_DEVICE_ALIAS];
}

+ (void)resetToDefaults
{
    [self setVariantUUID:DEFAULT_VARIANT_UUID];
    [self setReleaseSecret:DEFAULT_RELEASE_SECRET];
    [self setDeviceAlias:DEFAULT_DEVICE_ALIAS];
}

+ (MSSParameters *)registrationParameters
{
    MSSParameters *params = [MSSParameters parameters];
    [params setPushAPIURL:BACK_END_REQUEST_URL];
    [params setDevelopmentPushVariantUUID:[Settings variantUUID]];
    [params setDevelopmentPushReleaseSecret:[Settings releaseSecret]];
    [params setPushDeviceAlias:[Settings deviceAlias]];
    return params;
}

+ (NSDictionary *)defaults
{
	NSDictionary *defaults = @{
		KEY_VARIANT_UUID : DEFAULT_VARIANT_UUID,
		KEY_RELEASE_SECRET : DEFAULT_RELEASE_SECRET,
		KEY_DEVICE_ALIAS : DEFAULT_DEVICE_ALIAS,
	};
	return defaults;
}

@end
