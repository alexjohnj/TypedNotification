import class Foundation.NotificationCenter
import XCTest
@testable import TypedNotification

class TypedNotificationTests: XCTestCase {

    private class TestObject { }
    private struct TestNotification: TypedNotification {
        let object: TestObject
        let testValue: Int
    }

    func test_notificationObserver_invokesDisposeBlockOnDeinit() {
        // Given
        var disposeBlockCalled = false
        var token: NotificationObserver? = NotificationObserver { disposeBlockCalled = true }

        // When
        token = nil

        // Then
        XCTAssertTrue(disposeBlockCalled)
    }

    func test_notificationObserver_storedIn_addsObserverToStore() {
        // Given
        var observerStore: [NotificationObserver] = []

        // When
        NotificationObserver({ }).stored(in: &observerStore)

        // Then
        XCTAssertEqual(observerStore.count, 1)
    }

    func test_notificationCenter_works() {
        // Given
        let exp = expectation(description: "The test notification is delivered")
        let notificationCenter = NotificationCenter()
        let testNote = TestNotification(object: TestObject(), testValue: 2)
        var receivedNote: TestNotification?
        let observer = notificationCenter.addObserver(forType: TestNotification.self, object: testNote.object, queue: nil) { note in
            receivedNote = note
            exp.fulfill()
        }

        // When
        notificationCenter.post(testNote)
        waitForExpectations(timeout: 0.1)

        // Then
        XCTAssertNotNil(receivedNote)
        XCTAssertEqual(receivedNote?.testValue, testNote.testValue)
        XCTAssert(receivedNote!.object === testNote.object,
                  "Received notification's object should be identical to the posting notification's object")
    }

    func test_notificationCenter_removesObserverWhenObserverIsDeallocated() {
        // Given
        let exp = expectation(description: "The test notification is not delivered")
        exp.isInverted = true
        let notificationCenter = NotificationCenter()
        var observer: NotificationObserver? = notificationCenter.addObserver(forType: TestNotification.self, object: nil, queue: nil) { _ in
            exp.fulfill()
        }

        // When
        observer = nil
        notificationCenter.post(TestNotification(object: TestObject(), testValue: 2))
        waitForExpectations(timeout: 0.1)

        // Then
        // The expectation should not have been fulfilled
    }
}
