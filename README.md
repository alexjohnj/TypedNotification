# TypedNotification

_TypedNotification_ is a Swift library that adds some type-safety to
Foundation's `NotificationCenter`. The library is small and can be added to your
project either as a static framework or by directly including the single source
file.

## Usage

### Playground

This repository includes an annotated playground that demonstrates the features
of _TypedNotification_. To use it:

1. Clone the repository.
2. Open `TypedNotification.xcworkspace`
3. Build the _TypedNotification (Playground)_ scheme.
4. Open the _Demo_ playground and run it.

### Overview

For each notification in your application, create a new type that conforms to
the `TypedNotification` protocol:

``` swift
struct DataStoreDidSaveNotification: TypedNotification {

    /// The data store posting the notification.
    let object: DataStore // <- This property is required by the protocol.

    let insertedObjects: Set<Model>
}
```

When conforming, you must provide a type and the storage for an object attached
to the notification. Additional data that would normally be included in a
notification's `userInfo` dictionary can be provided as properties on the
notification.

To post a notification, create an instance of the notification and call post(_:)
on a `NotificationCenter`:

``` swift
NotificationCenter.default.post(DataStoreDidSaveNotification(object: dataStore, insertedObjects: insertedObjects))
```

To observe a notification use the `addObserver(forType:object:queue:using)`
method on `NotificationCenter`. This is similar to the Foundation method but
takes a type of notification to observe instead of the name and returns a
`NotificationObservation` to manage the observation:

``` swift
let observation = NotificationCenter.default.addObserver(forType: DataStoreDidSaveNotification.self, object: nil, queue: nil) { note in
    print(note.insertedObjects)
}
```

Note that the type of `note` passed to the callback block is a
`DataStoreDidSaveNotification`.

The returned `NotificationObservation` instance manages the lifetime of the
observation. When the instance is deallocated, the observation stops.

### Notification Observation Bags

_TypedNotification_ provides a convenient type for working with
`NotificationObservation`s. A `NotificationObservationBag` stores multiple
observation instances and removes them all when deallocated. You can use this to
tie the lifetime of an observation to another object:

``` swift
class ViewController: UIViewController {

    let notificationBag = NotificationObservationBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forType: DataStoreDidSaveNotification.self, object: nil, queue: nil) { [unowned self] note in
              self.doSomething(with: note.insertedObjects)
          }
          .stored(in: notificationBag)
    }
}
```

Here, when a `ViewController` is deallocated, so to is its notification bag and
the observation set up in `viewDidLoad()` goes away.

This is really useful behaviour so _TypedNotification_ includes a variant of
`addObserver` for normal `Notification`s that also returns a
`NotificationObservation`:

``` swift
func setUpKeyboardObservation() {
    NotificationCenter.default.addObserver(forNotificationNamed: UIWindow.keyboardWillShowNotification, object: nil, queue: nil) { note in
            print(note.userInfo?[UIWindow.keyboardFrameEndUserInfoKey])
        }
        .stored(in: notificationBag)
}
```

## Requirements & Installation

_TypedNotification_ requires a version of Xcode that can compile Swift 5
code. Additionally it requires a deployment target targeting iOS 10+ or macOS
10.12+ because of a dependency on `os.lock`.

You've got four options for installation.

### Manual Installation

Copy `TypedNotification.swift` from the `Sources` directory.

### CocoaPods

Add the following to your `Podfile`:

```
pod 'AJJTypedNotification', '~> 2.0'
```

Note that the name of the module (i.e., what you `import`) is
_TypedNotification_ but the pod is _AJJTypedNotification_.

### Carthage

Add the following to your `Cartfile`:

```
github "alexjohnj/TypedNotification" ~> 2.0
```

_TypedNotification_ builds as a static framework so you'll find the output in
`Build/$PLATFORM/Static`. Remember not to embed the framework in your
application, just link against it.

### Swift Package Manager

Add the following to your `Package.swift` file's dependencies:

``` swift
dependencies: [
    .package(url: "https://github.com/alexjohnj/TypedNotification.git", .upToNextMinor(from: "2.0.0"))
]
```

## License

MIT
