//
//  TypedNotification.swift
//  TypedNotification
//
//  Created by Alex Jackson on 2017-07-03.
//

import struct Foundation.Notification
import class Foundation.NotificationCenter
import class Foundation.OperationQueue

/// The `userInfo` dictionary key that a `TypedNotification` instance is stored under in a Foundation `Notification`
/// object.
private let kTypedNotificationUserInfoKey = "_AJJTypedNotificationUserInfoKey"

// MARK: - TypedNotification Definition

/// A notification that can be posted by a `TypedNotificationCenter` instance.
///
/// `TypedNotification` provides a type-safe alternative to Foundation's `Notification` type. All conforming types must
/// specify the type of the `object` attached to the notification. Conforming types can attach additional data to the
/// notification as properties. This replaces stringly typed `userInfo` dictionary attached to Foundation
/// `Notification`s
///
/// ## Conforming to `TypedNotification`
///
/// Conforming types must declare the type of the object attached to the notification and provide storage for it. For
/// example, a notification posted by a `DataStore` object might look like this:
///
/// ```
/// struct DataStoreDidSaveNotification: TypedNotification {
///     /// The data store posting the notification.
///     let object: DataStore
/// }
/// ```
///
/// ## Customising the Notification Name
///
/// A default notification name for conforming types is generated in a protocol extension. The name consists of the name
/// of the notification type prefixed by `AJJ`. You can specify a different name by implementing the static `name`
/// property on your notification types:
///
/// ```
/// struct DataStoreDidSaveNotification: TypedNotification {
///
///     static let name = Notification.Name("XYZDataStoreDidSave")
///
///     /// The data store posting the notification.
///     let object: DataStore
/// }
/// ```
///
public protocol TypedNotification {

    /// The type of an object attached to the notification.
    associatedtype Object

    /// The name of the notification that identifies it.
    ///
    /// The default implementation returns the name of `Self` prefixed with `AJJ`.
    ///
    static var name: Notification.Name { get }

    /// An object attached to the notification.
    var object: Object { get }
}

extension TypedNotification {

    static var name: Notification.Name {
        let rawName = "AJJ" + String(describing: Self.self)
        return Notification.Name(rawName)
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
    func addObserver<T: TypedNotification>(forType type: T.Type, object obj: T.Object?,
                                           queue: OperationQueue?, using block: @escaping (T) -> Void) -> NotificationObserver

    /// Deregister a `NotificationObserver`.
    func removeObserver(observer: NotificationObserver)
}

// MARK: - NSNotificationCenter + TypedNotificationCenter

extension NotificationCenter: TypedNotificationCenter {

    /// Posts a `TypedNotification`
    public func post<T: TypedNotification>(_ notification: T) {
        let nsNotification = Notification(name: T.name, object: notification.object,
                                          userInfo: [kTypedNotificationUserInfoKey: notification])
        self.post(nsNotification)
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
                                                  object obj: T.Object?,
                                                  queue: OperationQueue?,
                                                  using block: @escaping (T) -> Void)
        -> NotificationObserver {
        let token = self.addObserver(forName: T.name, object: obj, queue: queue) { (untypedNoti) in
            guard let typedNoti = untypedNoti.userInfo?[kTypedNotificationUserInfoKey] as? T else {
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
