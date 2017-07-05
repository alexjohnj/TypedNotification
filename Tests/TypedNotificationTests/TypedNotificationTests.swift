import XCTest
@testable import TypedNotification

extension Namespaced {
    static var namespace: String { return "org.alexj.TypedNotificationTests" }
}

struct TestNotification: TypedNotification {
    let associatedValue: Int
    let sender: TestObserver
}

class MockNotifcationCenter: TypedNotificationCenter {
    static let shared = MockNotifcationCenter()
    var removedObserversCount = 0 // The number of times an observer has been removed from the notification center

    func removeObserver(_ observer: NotificationObserver) {
        removedObserversCount += 1
    }

    func post<T: TypedNotification>(_ notification: T) {
        return
    }

    func addObserver<T: TypedNotification>(forType type: T.Type, object obj: T.Sender?, queue: OperationQueue?, using block: @escaping (T) -> Void) -> NotificationObserver {
        return NotificationObserver(NSObject(), notiCenter: self)
    }
}

class TestObserver {
    let center: TypedNotificationCenter
    let observeSelf: Bool

    var _valueObserver: NotificationObserver?
    var value = Int(arc4random()) {
        didSet {
            center.post(TestNotification(associatedValue: value, sender: self))
        }
    }

    var block: ((TestNotification) -> Void)? = nil {
        didSet {
            if let block = block {
                _valueObserver = nil
                let obj = observeSelf ? self : nil
                _valueObserver = center.addObserver(forType: TestNotification.self, object: obj, queue: nil, using: block)
            }
        }
    }

    func refreshValue() {
        value = Int(arc4random())
    }

    init(observeSelf: Bool, center: TypedNotificationCenter) {
        self.observeSelf = observeSelf
        self.center = center
    }
}

class TypedNotificationTests: XCTestCase {
    func testNotificationName() {
        XCTAssertEqual(TestNotification.name, "org.alexj.TypedNotificationTests.TestNotification")
    }

    func testTokenDeinit() {
        weak var observerToken: NotificationObserver? = {
            let observer = TestObserver(observeSelf: true, center: MockNotifcationCenter.shared)
            observer.block = { _ in return }
            return observer._valueObserver
        }()

        XCTAssertNil(observerToken)
        XCTAssertEqual(MockNotifcationCenter.shared.removedObserversCount, 1)
    }

    func testObserveNotificationsFromSender() {
        let observer1 = TestObserver(observeSelf: true, center: NotificationCenter.default)
        let observer2 = TestObserver(observeSelf: true, center: NotificationCenter.default)
        var blockCallCount = 0

        observer1.block = { (noti: TestNotification) -> Void in
            XCTAssertTrue(noti.sender === observer1)
            blockCallCount += 1
        }

        observer2.block = { (noti: TestNotification) -> Void in
            XCTAssertTrue(noti.sender === observer2)
            blockCallCount += 1
        }

        observer1.refreshValue()
        observer2.refreshValue()

        XCTAssertEqual(blockCallCount, 2)
    }

    func testObserveNotificationsFromAny() {
        let observer1 = TestObserver(observeSelf: false, center: NotificationCenter.default)
        let observer2 = TestObserver(observeSelf: false, center: NotificationCenter.default)
        let observer3 = TestObserver(observeSelf: true, center: NotificationCenter.default)
        var blockCallCount = 0

        observer1.block = { (noti: TestNotification) -> Void in
            blockCallCount += 1
        }

        observer2.block = { (noti: TestNotification) -> Void in
            blockCallCount += 1
        }

        observer3.block = { (noti: TestNotification) -> Void in
            XCTAssertTrue(noti.sender === observer3)
            blockCallCount += 1
        }

        observer1.refreshValue()
        observer2.refreshValue()
        observer3.refreshValue()

        XCTAssertEqual(blockCallCount, 7)
    }
}
