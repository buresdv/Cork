//
//  Send Notification.swift
//  Cork
//
//  Created by David Bureš on 13.08.2023.
//

import Foundation
import SwiftUI
import UserNotifications

func sendNotification(title: String, body: String? = nil, subtitle: String? = nil, sensitivity: UNNotificationInterruptionLevel = .timeSensitive)
{
    // Get whether we can send notifications
    let notificationsAreEnabled: Bool = UserDefaults.standard.bool(forKey: "areNotificationsEnabled")

    if notificationsAreEnabled
    {
        let notification: UNMutableNotificationContent = .init()

        notification.title = title

        if let body
        {
            notification.body = body
        }

        if let subtitle
        {
            notification.subtitle = subtitle
        }

        notification.sound = .default
        notification.interruptionLevel = sensitivity

        let request: UNNotificationRequest = .init(identifier: UUID().uuidString, content: notification, trigger: nil)

        AppConstants.notificationCenter.add(request)
    }
    else
    {
        AppConstants.logger.info("Will not send notification because they're disabled")
    }
}
