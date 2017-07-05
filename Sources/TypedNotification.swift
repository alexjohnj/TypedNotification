//
//  Token.swift
//  TypedNotification
//
//  Created by Alex Jackson on 2017-07-03.
//

import Foundation

public protocol TypedNotification: Namespaced {
    associatedtype Sender
    static var name: String { get }
    var sender: Sender { get }
}

extension TypedNotification {
    public static var name: String {
        return "\(Self.namespace).\(Self.self)"
    }

    static var notificationName: Notification.Name {
        return Notification.Name("\(Self.name)")
    }

    var notification: Notification {
        return Notification(name: Self.notificationName,
                            object: sender,
                            userInfo: ["noti": self])
    }
}

