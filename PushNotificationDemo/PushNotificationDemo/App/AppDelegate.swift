//
//  AppDelegate.swift
//  PushNotificationDemo
//
//  Created by nguyen.duc.huyb on 6/11/19.
//  Copyright © 2019 nguyen.duc.huyb. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Step 1: Setup push notification
        configRemoteNotification(application)
        config()
        return true
    }
    
    private func config() {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure User Notification Center
        NotificationManager.shared.notificationCenter.delegate = self
        
        // Configure Firebase Messaging
        Messaging.messaging().delegate = self
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

extension AppDelegate {
    // Step 2: Register app to APNs to receive token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Send deviceToken to Firebase
        Messaging.messaging().apnsToken = deviceToken
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("token: \(token)")
    }
    
    // Fail registration
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func configRemoteNotification(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            // Request Authorization
            NotificationManager.shared.notificationCenter.requestAuthorization(options: authOptions) { (success, error) in
                if success {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                } else {
                    print("Request Authorization Failed \(error?.localizedDescription ?? "error")")
                }
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // called when the application is in the foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    // used to select an action for a notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if let category = response.notification.request.content.userInfo["category"] as? String,
            category == "rich.notification" {
            print("Handle Tap Rich Notification")
        }
        
        if response.notification.request.identifier == Constant.identifier.rawValue {
            NotificationManager.shared.didChange?()      
        }
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    // Step 3: Setup Firebase Messaging
    // Should save fcmToken and send it to backend in reality
    // Note: This callback is fired at each app startup and whenever a new token is generated.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
}

