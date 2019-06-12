//
//  NotificationService.swift
//  PushNotificationDemoExtension
//
//  Created by nguyen.duc.huyb on 6/12/19.
//  Copyright © 2019 nguyen.duc.huyb. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            return
        }
        
        if let attachment = request.content.userInfo["url"] as? String,
            let attachmentUrl = URL(string: attachment){
            
            downloadImageFrom(url: attachmentUrl) { (attachment) in
                if let attachment = attachment {
                    bestAttemptContent.attachments = [attachment]
                    contentHandler(bestAttemptContent)
                }
            }
        } else {
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

extension NotificationService {
    func downloadImageFrom(url: URL, with completionHandler: @escaping (UNNotificationAttachment?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { (downloadUrl, response, error) in
            // Step 1: Test URL and escape if URL not OK
            guard let downloadUrl = downloadUrl else {
                completionHandler(nil)
                return
            }
            
            // Step 2: Get current's user temporary directory path
            var urlPath = URL(fileURLWithPath: NSTemporaryDirectory())
            
            // Step 3: Add proper ending to url path, in the case .jpg
            let uniqueURLEnding = ProcessInfo.processInfo.globallyUniqueString + ".jpg"
            urlPath = urlPath.appendingPathComponent(uniqueURLEnding)
            
            // Step 4: Move downloadUrl to newly created urlPath
            try? FileManager.default.moveItem(at: downloadUrl, to: urlPath)
            
            // Step 5: Try adding image to notification and pass it to the completion handler
            do {
                let attachment = try UNNotificationAttachment(identifier: "imageId", url: urlPath, options: nil)
                completionHandler(attachment)
            } catch {
                completionHandler(nil)
            }
        }
        
        task.resume()
    }
}
