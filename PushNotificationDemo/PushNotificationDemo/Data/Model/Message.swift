//
//  Message.swift
//  PushNotificationDemo
//
//  Created by nguyen.duc.huyb on 6/11/19.
//  Copyright © 2019 nguyen.duc.huyb. All rights reserved.
//

import UIKit

class Message {
    var title: String
    var subtitle: String
    var body: String
    var dateInterval: Date
    
    init(title: String, subtitle: String, body: String, dateInterval: Date) {
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.dateInterval = dateInterval
    }
}
