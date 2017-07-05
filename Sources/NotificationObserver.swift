//
//  Token.swift
//  TypedNotification
//
//  Created by Alex Jackson on 2017-07-05.
//

import Foundation

public final class NotificationObserver {
    let token: NSObjectProtocol
    let center: TypedNotificationCenter

    public init(_ token: NSObjectProtocol, notiCenter: TypedNotificationCenter = NotificationCenter.default) {
        self.token = token
        self.center = notiCenter
    }

    deinit {
        center.removeObserver(self)
    }
}
