import Foundation
/*:
 # TypedNotification

This is a demo of using `TypedNotification` in your code. It contains a single
notification `ExampleNotification` and an `ExampleClass` which will be used
to manage posting notifications on the default `NotificationCenter`.
*/
import TypedNotification

/*:
 The `TypedNotification` protocol conforms to the `Namespaced` protocol. This
 provides a crude sort of namespacing for notification names. When implementing
 a `TypedNotification` you can provide a `namespace` that is unique to that
 notification. Alternatively, you can create a global namespace using a protocol
 extension on `Namespaced` as we have here.
 */

extension Namespaced {
    static var namespace: String { return "org.alexj" }
}

/*:
Now we create a type that conforms to the `TypedNotification` protocol. Note
 that all we need to do to conform is provide a type for the `sender` property.
 The String name of the notification is taken care of by a protocol extension
 and defaults to `namespace.TypeName` (`org.alexj.ExampleNotification` here).
 If you need to, you can provide a custom name in the implementation to override
 the extension.
 */
struct ExampleNotification: TypedNotification {
/*:
In this demo, only instances of `ExampleClass` can post `ExampleNotifications`
so we can strongly type the `sender` property. If multiple types can post
notifications, consider constraining the `sender` property by a protocol
before falling back to `Any?`.
*/
    let sender: ExampleClass

/*:
Rather than using a `userInfo` dictionary, any data that needs to be
delivered by the notification can now be declared as a property with
proper types.
*/
    let newValue: Double
}

class ExampleClass {
    private let center = NotificationCenter.default

/*:
Here we register a block to be executed whenever an `ExampleNotification` is
posted by `self`. The block will be executed on the posting queue (main in this demo).
Note that the argument to the closure, `noti`, is an instance of `ExampleNotification`
so we can access its properties without any downcasting or optional chaining of
dictionaries.

If we wanted to receive notifications when any object posts an `ExampleNotification`,
we could pass `nil` for the `object` argument.
*/
    init() {
        _valueObserver = center.addObserver(forType: ExampleNotification.self, object: self, queue: nil) { (noti) in
            print("New value: \(noti.newValue)")
        }
    }

/*:
The `TypedNotificationCenter` `addObserver` method returns a `NotificationObserver`
that functions as the observer for a block. `NotificationObserver`s
automatically deregister themselves when deallocated. Storing a reference to the
observer as a property therefore ties the observer to the lifetime of `ExampleClass`.
No more worrying about calling `removeObserver`!

Note we set the initial value to `nil` here so that notifications from `self`
can be registered in `init`.
*/
    private var _valueObserver: NotificationObservation? = nil

/*:
Finally, this is how we post a `TypedNotification`. Just configure a new instance
and call `post(_:)` on any `TypedNotificationCenter` conforming type.
*/
    var value = 0.0 {
        didSet {
            center.post(ExampleNotification(sender: self, newValue: value))
        }
    }
}

//: And here's everything in action. Check the console!
let example = ExampleClass()
example.value = 42
example.value = -42
