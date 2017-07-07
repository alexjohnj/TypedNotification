//
//  TypedNotificationCenter.swift
//  TypedNotification
//
//  Created by Alex Jackson on 2017-07-05.
//

import Foundation

/// A notification center that supports posting and observing
/// `TypedNotification`s. The API mimics Foundation's block-based
/// notification API.
public protocol TypedNotificationCenter {
    /// Post a `TypedNotification`
    func post<T: TypedNotification>(_ notification: T)
    /// Register a block to be executed when a `TypedNotification` is posted.
    func addObserver<T: TypedNotification>(forType type: T.Type, object obj: T.Sender?,
                     queue: OperationQueue?, using block: @escaping (T) -> Void) -> NotificationObserver
    /// Deregister a `NotificationObserver`.
    func removeObserver(observer: NotificationObserver)
}

extension NotificationCenter: TypedNotificationCenter {
    /// Post a `TypedNotification`
    public func post<T: TypedNotification>(_ notification: T) {
        self.post(notification.notification)
    }

    /**
     Register a block to be executed when a notification is posted.

     - Parameters:
        - type: The type of notification to register for.
        - obj: The object from which you want to receive   notifications. Pass
          `nil` to receive all notifications.
        - queue: The queue on which to execute the block.  See `NotificationCenter`'s
          documentation for what happens when `nil` is passed.
        - block: A block to execute when a matching notification is posted. The
          block takes a single instance of `type` as an  argument.

     - Returns:
     A `NotificationObserver` that acts as the observer for the block. The
     observer is automatically deregistered when deallocated so  be sure
     to keep a reference to it.

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
