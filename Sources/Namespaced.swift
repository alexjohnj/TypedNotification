//
//  Namespaced.swift
//  TypedNotification
//
//  Created by Alex Jackson on 2017-07-05.
//

import Foundation

public protocol Namespaced {
    static var namespace: String { get }
}
