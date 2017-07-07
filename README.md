# TypedNotification

_TypedNotification_ provides a set of protocols that define a stronger type
system for notifications in Swift. The protocols help eliminate bugs arising
from the stringly typed Foundation notification APIs and provide type safety and
self-documentation for data attached to notifications. An additional lightweight
class that automatically manages observer removal helps reduce run time errors.

## Installation

_TypedNotification_ can be installed using the Swift Package Manager or
Carthage.

## Usage

This repository contains a small demo playground (`Demo.playground`) that
explains how to use _TypedNotification_ by example. There's also
a [blog post][typednotification-blog-post] which goes into some more detail on
the implementation of _TypedNotification_.

[typednotification-blog-post]: https://alexj.org/07/swift-typed-notifications/

## License

MIT
