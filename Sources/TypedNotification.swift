//
//  TypedNotification.swift
//  TypedNotification
//
//  Created by Alex Jackson on 2017-07-03.
//

import Foundation

/// A notification that can be posted by a `TypedNotification` instance.
///
public protocol TypedNotification {

    associatedtype Sender

    /// The name of the notification used as an identifier.
    static var name: String { get }

    /// The object sending the notification.
    var sender: Sender { get }
}

extension TypedNotification {

    static var name: String {
        return "AJJ" + String(describing: Self.self)
    }

    /// The notification's name as required for the Foundation methods.
    static var notificationName: Notification.Name {
        return Notification.Name("\(Self.name)")
    }

    /// The Foundation representation of the notification.
    var notification: Notification {
        return Notification(name: Self.notificationName,
                            object: sender,
                            userInfo: ["noti": self])
    }
}
