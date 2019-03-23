//
//  TypedNotification.swift
//  TypedNotification
//
//  Created by Alex Jackson on 2017-07-03.
//

import struct Foundation.Notification
import class Foundation.NotificationCenter
import class Foundation.OperationQueue

// MARK: - TypedNotification Definition

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

// MARK: - NotificationObserver Definition

/// A reference type storing a `Notification` observer (an `NSObjectProtocol` conforming type). The observer is
/// automatically deregistered when deallocated.
public final class NotificationObserver {
    let token: Any
    let center: TypedNotificationCenter

    public init(_ token: Any, notiCenter: TypedNotificationCenter = NotificationCenter.default) {
        self.token = token
        self.center = notiCenter
    }

    deinit {
        center.removeObserver(observer: self)
    }
}

// MARK: - TypedNotificationCenter Definition

/// A notification center that supports posting and observing `TypedNotification`s. The API mimics Foundation's
/// block-based notification API.
///
public protocol TypedNotificationCenter {

    /// Post a `TypedNotification`
    func post<T: TypedNotification>(_ notification: T)

    /// Register a block to be executed when a `TypedNotification` is posted.
    func addObserver<T: TypedNotification>(forType type: T.Type, object obj: T.Sender?,
                                           queue: OperationQueue?, using block: @escaping (T) -> Void) -> NotificationObserver

    /// Deregister a `NotificationObserver`.
    func removeObserver(observer: NotificationObserver)
}

// MARK: - NSNotificationCenter + TypedNotificationCenter

extension NotificationCenter: TypedNotificationCenter {
    /// Post a `TypedNotification`
    public func post<T: TypedNotification>(_ notification: T) {
        self.post(notification.notification)
    }

    /**
     Register a block to be executed when a notification is posted.

     - Parameters:
        - type: The type of notification to register for.
        - obj: The object from which you want to receive notifications. Pass `nil` to receive all notifications.
        - queue: The queue on which to execute the block.  See `NotificationCenter`'s documentation for what happens
            when `nil` is passed.
        - block: A block to execute when a matching notification is posted. The block takes a single instance of `type`
            as an  argument.

     - Returns: A `NotificationObserver` that acts as the observer for the block. The observer is automatically
     deregistered when deallocated so  be sure to keep a reference to it.

     - SeeAlso:  NotificationCenter
     */
    public func addObserver<T: TypedNotification>(forType type: T.Type,
                                                  object obj: T.Sender?,
                                                  queue: OperationQueue?,
                                                  using block: @escaping (T) -> Void)
        -> NotificationObserver {
        let token = self.addObserver(forName: T.notificationName, object: obj, queue: queue) { (untypedNoti) in
            guard let typedNoti = untypedNoti.userInfo?["noti"] as? T else {
                print("Typed notification could not be constructed from Notification \(untypedNoti.name)")
                return
            }
            block(typedNoti)
        }

        return NotificationObserver(token, notiCenter: self)
    }

    /// Deregister an observer for notifications.
    public func removeObserver(observer: NotificationObserver) {
        self.removeObserver(observer.token)
    }
}
