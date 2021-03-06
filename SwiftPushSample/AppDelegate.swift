//
//  AppDelegate.swift
//  SwiftPushSample
//
//  Created by DX173-XL on 2015-09-23.
//  Copyright © 2015 DX123-XL. All rights reserved.
//

import UIKit
import PCFPush
import CoreLocation

let kNotificationCategoryIdent = "ACTIONABLE"
let kNotificationActionOneIdent = "ACTION_ONE"
let kNotificationActionTwoIdent = "ACTION_TWO"

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // In order to monitor geofences you will need to authorize location services.  This request will use the text in the
        // 'NSLocationAlwaysUsageDescription' key in your Info.plist file.
        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()

        // Register for remote notifications with APNS.  After the registration either the 'application:didRegisterForRemoteNotificationsWithDeviceToken'
        // or the 'application:didFailToRegisterForRemoteNotificationsWithError' methods below will be called.
        application.registerUserNotificationSettings(getUserNotificationSettings())
        application.registerForRemoteNotifications()

        return true
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {

        ViewController.addLogMessage("Registering for PCF Push...")

        // After successfully registering for remote notifications with APNS you will need to register for remote
        // notifications with the PCF Push Notification Service here.
        PCFPush.registerForPCFPushNotificationsWithDeviceToken(deviceToken,
            tags: nil,
            deviceAlias: UIDevice.currentDevice().name,
            areGeofencesEnabled: true,
            success: {
                ViewController.addLogMessage("CF registration succeeded.")
                ViewController.addLogMessage("The device UUID is  \(PCFPush.deviceUuid()) ") },
            failure: { error in
                ViewController.addLogMessage("CF registration failed: \(error)") })
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        ViewController.addLogMessage("APNS registration failed: \(error)")
    }
    
    // This method is called whenever the application receives a remote notification.  As long as the remote
    // notification has the "content-available" key set to "1" and the application has configured the "background
    // fetch" capability in the Info.plist file them this method will be called even if the application
    // is in the background.
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: UIBackgroundFetchResult -> Void) {
        
        // Make sure to pass all the received push notifications to the PCF Push Notification service here:
        PCFPush.didReceiveRemoteNotification(userInfo) { wasIgnored, fetchResult, error in
            completionHandler(fetchResult)
        }
        
        ViewController.addLogMessage("Received push message: \(userInfo)")
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if let userInfo = notification.userInfo {
            
            // Any local notifications with the "pivotal.push.geofence_trigger_condition" key are PCF Push Notification Service
            // geofences that have been triggered.  The "pivotal.push.geofence_trigger_condition" value can be either "enter"
            // or "exit".
            if let condition = userInfo["pivotal.push.geofence_trigger_condition"] {
                if let alertBody = notification.alertBody {
                    ViewController.addLogMessage("Received \(condition) geofence '\(alertBody)'.")
                } else {
                    ViewController.addLogMessage("Received \(condition) geofence.")
                }
            }
        }
    }
    
    // This method returns the custom remote notification settings.
    func getUserNotificationSettings() -> UIUserNotificationSettings {
        let action1 = UIMutableUserNotificationAction()
        action1.activationMode = .Background
        action1.title = "Action 1"
        action1.identifier = kNotificationActionOneIdent
        action1.destructive = false
        action1.authenticationRequired = false
        
        let action2 = UIMutableUserNotificationAction()
        action2.activationMode = .Background
        action2.title = "Action 2"
        action2.identifier = kNotificationActionTwoIdent
        action2.destructive = false
        action2.authenticationRequired = false
        
        let actionCategory = UIMutableUserNotificationCategory()
        actionCategory.identifier = kNotificationCategoryIdent
        actionCategory.setActions([action1, action2], forContext: .Default)
        
        return UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: Set([actionCategory]))
    }
}

