//
//  Token.swift
//  TypedNotification
//
//  Created by Alex Jackson on 2017-07-03.
//

import Foundation

/// The `TypedNotification` protocol defines the properties of a strongly typed
/// notification. As a minimum, conforming types must specify a type for the
/// `sender` property. The `name` property will be automatically generated from
/// the `namespace` property and the type's name but can be modified if needed.
///
/// As an example, here is a `TypedNotification` that's designed to mimic the
/// Foundation `Notification` type.
/// ```
/// struct Notification: TypedNotification {
///    static var namespace: String { return "Foundation" } // Conform to `Namespaced` protocol
///    var sender: Any?
///    var userInfo: [AnyHashable: Any]?
/// }
public protocol TypedNotification: Namespaced {
    associatedtype Sender
    /// The name of the notification used as an identifier.
    static var name: String { get }
    /// The object sending the notification.
    var sender: Sender { get }
}

extension TypedNotification {
    /// The name of the notification used as an identifier defaulting to
    /// "Namespace.TypeName".
    public static var name: String {
        return "\(Self.namespace).\(Self.self)"
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
