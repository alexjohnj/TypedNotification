//
//  TypedNotification.swift
//  TypedNotification
//
//  Created by Alex Jackson on 2017-07-03.
//

import struct Foundation.Notification
import class Foundation.NotificationCenter
import class Foundation.OperationQueue
import os.lock

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

// MARK: - NotificationObservation Definition

/// An opaque reference type that manages the lifetime of a notification observer.
///
/// A `NotificationObservation` is initialized with a dispose block that is executed when the observer is deallocated.
/// Inside the dispose block, you should run whatever actions are needed to remove the observer.
///
public final class NotificationObservation {

    private let disposeBlock: () -> Void

    /// Initializes a new observation that runs a provided block when it is deallocated.
    ///
    /// - parameter disposeBlock: A block to evaluate when the token is deallocated.
    ///
    public init(_ disposeBlock: @escaping () -> Void) {
        self.disposeBlock = disposeBlock
    }

    public func stored<C: RangeReplaceableCollection>(in observationStore: inout C) where C.Element == NotificationObservation {
        observationStore.append(self)
    }

    deinit {
        disposeBlock()
    }
}

// MARK: - TypedNotificationCenter Definition

/// A type that can post `TypedNotification`s and add notification observers.
///
public protocol TypedNotificationCenter {

    /// Posts a `TypedNotification`
    ///
    /// - parameter notification: The notification to post.
    ///
    func post<T: TypedNotification>(_ notification: T)

    /// Registers a block to be executed when a matching notification is posted.
    ///
    /// - Parameters:
    ///   - type: The type of notification to observe.
    ///   - object: An object to filter notifications by. Only notifications whose object is `object` will be delivered
    ///   to the observer. Pass `nil` to receive notifications from all objects.
    ///   - queue: An OperationQueue to run `block` on. Pass `nil` to have `block` evaluated synchronously on the
    ///   posting thread.
    ///   - block: A block to execute when a matching notification is posted. The block takes the matching notification
    ///   as an argument.
    ///
    /// - Returns: A notification observation that manages the lifetime of the observer. When the observation is
    /// deallocated, the notification observer is removed.
    ///
    func addObserver<T: TypedNotification>(forType type: T.Type, object obj: T.Object?,
                                           queue: OperationQueue?, using block: @escaping (T) -> Void) -> NotificationObservation
}

// MARK: - NSNotificationCenter + TypedNotificationCenter

extension NotificationCenter: TypedNotificationCenter {

    public func post<T: TypedNotification>(_ notification: T) {
        let nsNotification = Notification(name: T.name, object: notification.object,
                                          userInfo: [kTypedNotificationUserInfoKey: notification])
        self.post(nsNotification)
    }

    public func addObserver<T: TypedNotification>(forType type: T.Type,
                                                  object obj: T.Object?,
                                                  queue: OperationQueue?,
                                                  using block: @escaping (T) -> Void)
        -> NotificationObservation {
        let observer = self.addObserver(forName: T.name, object: obj, queue: queue) { (untypedNoti) in
            guard let typedNoti = untypedNoti.userInfo?[kTypedNotificationUserInfoKey] as? T else {
                print("Typed notification could not be constructed from Notification \(untypedNoti.name)")
                return
            }
            block(typedNoti)
        }

        return NotificationObservation { self.removeObserver(observer) }
    }
}
