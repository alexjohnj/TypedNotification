//
//  TypedNotificationCenter.swift
//  TypedNotification
//
//  Created by Alex Jackson on 2017-07-05.
//

import Foundation

public protocol TypedNotificationCenter {
    func post<T: TypedNotification>(_ notification: T)
    func addObserver<T: TypedNotification>(forType type: T.Type, object obj: T.Sender?,
                     queue: OperationQueue?, using block: @escaping (T) -> Void) -> NotificationObserver
    func removeObserver(_ observer: NotificationObserver)
}

extension NotificationCenter: TypedNotificationCenter {
    public func post<T: TypedNotification>(_ notification: T) {
        self.post(notification.notification)
    }

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

    public func removeObserver(_ observer: NotificationObserver) {
        self.removeObserver(observer.token)
    }
}
