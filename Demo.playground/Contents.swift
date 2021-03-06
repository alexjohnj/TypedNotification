import Foundation
/*:
 # TypedNotification

 This is a demo of using _TypedNotification_ in your code. It contains a single notification `ExampleNotification` and an
 `ExampleClass` that posts notifications to the default `NotificationCenter`.
 */
import TypedNotification

/*:
 For each notification in your application, create a new type that conforms to `TypedNotification`. To conform, all you
 need to do is specify the type of `Object` that can be attached to the notification. A notification name is
 automatically generated by the protocol.

 Any extra data that you'd normally put in the `userInfo` dictionary can be declared as properties in the notification
 instead.
 */
struct ExampleNotification: TypedNotification {

    // In this demo, instances of `ExampleNotification` will always have their sender (`ExampleClass`) attached as the
    // `object`.
    let object: ExampleClass

    // Rather than using a `userInfo` dictionary, any additional data that needs to be delivered by the notification can
    // now be declared as a property with proper types.
    let newValue: Double
}

final class ExampleClass {

    private let notificationCenter: TypedNotificationCenter = NotificationCenter.default

/*:
When you add an observer of a `TypedNotification`, the notification center returns a `NotificationObservation`
object. This object manages the lifetime of the observer. As long as the returned `NotificationObservation` is alive,
the observer will be notified of notifications. When the observation is deallocated, the observer is automatically
removed from the notification center.

`TypedNotification` provides a `NotificationObservationBag` type that stores multiple notification observations and
handles disposing of them when the bag is deallocated.
*/
    private let observationBag = NotificationObservationBag()

/*:
Adding an observer for a `TypedNotification` is similar to adding a normal block-based notification observer. The two
differences are:

1. You provide the type of `TypedNotification` to observe rather than a name.
2. The block you provide takes an instance of the `TypedNotification` rather than a `Notification` object.

Otherwise everything works the same as the Foundation `NotificationCenter` APIs.
*/
    init() {
        notificationCenter.addObserver(forType: ExampleNotification.self, object: self, queue: nil) { note in
            print("New value: \(note.newValue)")
        }
        .stored(in: observationBag)
    }

/*:
Finally, this is how we post a `TypedNotification`. Just configure a new instance
and call `post(_:)` on any `TypedNotificationCenter` conforming type.
*/
    var value = 0.0 {
        didSet {
            notificationCenter.post(ExampleNotification(object: self, newValue: value))
        }
    }
}

//: And here's everything in action. Check the console!
let example = ExampleClass()
example.value = 42
example.value = -42
