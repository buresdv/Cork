//
//  Send Notification.swift
//  Cork
//
//  Created by David Bureš on 13.08.2023.
//

import Foundation
import SwiftUI
import UserNotifications

func sendNotification(title: String.LocalizationValue, body: String.LocalizationValue?, subtitle: String.LocalizationValue?) -> Void
{
    let notification = UNMutableNotificationContent()
    
    notification.title = String(localized: title)
    
    if let body
    {
        notification.body = String(localized: body)
    }
    
    if let subtitle
    {
        notification.subtitle = String(localized: subtitle)
    }
    
    notification.sound = .default
    
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: notification, trigger: nil)
}
