//
//  MSSParameters.h
//  MSSPush
//
//  Created by Rob Szumlakowski on 2014-01-21.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Defines the set of parameters used while registering the device for push notifications or analyitcs.
 * Pass to one of the `register` methods in the `MSSPush` class.
 */
@interface MSSParameters : NSObject

/**
 * Push Parameters
 */
@property BOOL pushAutoRegistrationEnabled;
@property (copy) NSString *pushDeviceAlias;
@property (copy) NSString *pushAPIURL;
@property (copy) NSString *developmentPushVariantUUID;
@property (copy) NSString *developmentPushReleaseSecret;
@property (copy) NSString *productionPushVariantUUID;
@property (copy) NSString *productionPushReleaseSecret;
@property (copy) NSArray *tags;

/**
 * Analytics Parameters
 */
@property (copy) NSString *analyticsAPIURL;
@property (copy) NSString *developmentAnalyticsKey;
@property (copy) NSString *productionAnalyticsKey;



/**
 * Creates an instance using the values set in the `MSSParameters.plist` file.
 */
+ (MSSParameters *)defaultParameters;

/**
 * Creates an instance using the values found in the specified `.plist` file.
 * @param path The path of the specified file.
 */
+ (MSSParameters *)parametersWithContentsOfFile:(NSString *)path;

/**
 * Creates an instance with empty values.
 */
+ (MSSParameters *)parameters;

/**
 * Validate Push Parameter properties
 */
- (BOOL)pushParametersValid;

/**
 * Validate Analytics Parameter properties
 */
- (BOOL)analyticsParametersValid;

/**
 * The Debug state of the application
 */
- (BOOL)inDebugMode;

/**
 * The variant UUID (resolved using the inProduction flag).
 */
- (NSString *)variantUUID;

/**
 * The release Secret (resolved using the inProduction flag).
 */
#pragma warning - rename this property to be 'variantSecret'
- (NSString *)releaseSecret;

/**
 * The analytics key (resolved using the inProduction flag).
 */
- (NSString *)analyticsKey;

@end
