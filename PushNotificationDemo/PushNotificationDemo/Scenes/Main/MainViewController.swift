//
//  ViewController.swift
//  PushNotificationDemo
//
//  Created by nguyen.duc.huyb on 6/11/19.
//  Copyright © 2019 nguyen.duc.huyb. All rights reserved.
//

import UIKit
import UserNotifications
import FirebaseMessaging

final class MainViewController: UIViewController {
    @IBOutlet private weak var datePickerLabel: UILabel!
    @IBOutlet private weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    private func config() {
        datePickerLabel.text = setupDateFormatter()
        
        //Action when clicked local notification
        NotificationManager.shared.bind {
            print("Handling notifications with the Local Notification Identifier")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(displayFCMToken(notification:)),
                                               name: Notification.Name("FCMToken"), object: nil)
    }
    
    @objc func displayFCMToken(notification: NSNotification){
        guard let userInfo = notification.userInfo else {return}
        if let fcmToken = userInfo["token"] as? String {
            print("Received FCM token: \(fcmToken)")
        }
    }
    
    @IBAction func handleLocalNotiButtonTapped(_ sender: Any) {
        let message = Message(title: "Local Notification", subtitle: "Test message", body: "This is a test", dateInterval: datePicker.date)
        NotificationManager.shared.handleLocalNotification(message: message) { errDesc in
            print(errDesc)
        }
    }
    
    @IBAction private func handleDatePickerValueChanged(_ sender: Any) {
        datePickerLabel.text = setupDateFormatter()
    }
    
    @IBAction func handleSubscribeTopicButtonTapped(_ sender: Any) {
        Messaging.messaging().subscribe(toTopic: "weather") { error in
            print("Subscribed to weather topic")
        }
    }
    
    private func setupDateFormatter() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy  hh:mm a"
        let strDate: String! = dateFormatter.string(from: datePicker.date)
        return strDate
    }
}
