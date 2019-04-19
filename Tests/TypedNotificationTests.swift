import class Foundation.NotificationCenter
import XCTest
@testable import TypedNotification

class TypedNotificationTests: XCTestCase {

    private class TestObject { }
    private struct TestNotification: TypedNotification {
        let object: TestObject
        let testValue: Int
    }

    func test_notificationObservation_invokesDisposeBlockOnDeinit() {
        // Given
        var disposeBlockCalled = false
        _ = NotificationObservation { disposeBlockCalled = true }

        // Then
        XCTAssertTrue(disposeBlockCalled)
    }

    func test_notificationObservation_storedIn_addsObservationToStore() {
        // Given
        let bag = NotificationObservationBag()

        // When
        NotificationObservation({ }).stored(in: bag)

        // Then
        XCTAssertEqual(bag._count, 1)
    }

    func test_notificationObservationBag_add_addsObservationToStore() {
        // Given
        let bag = NotificationObservationBag()
        let observation = NotificationObservation({ })

        // When
        bag.add(observation)

        // Then
        XCTAssertEqual(bag._count, 1)
    }

    func test_notificationObservationBag_disposesObservationsWhenEmptied() {
        // Given
        let bag = NotificationObservationBag()
        var disposeCalled = false

        // When
        NotificationObservation({ disposeCalled = true }).stored(in: bag)
        bag.empty()

        // Then
        XCTAssertTrue(disposeCalled)
    }

    func test_notificationObservationBag_disposesObservationsWhenDeallocated() {
        // Given
        var disposeCalled = false

        // When
        NotificationObservation({ disposeCalled = true }).stored(in: NotificationObservationBag())

        // Then
        XCTAssertTrue(disposeCalled)
    }

    func test_notificationCenter_works() {
        // Given
        let exp = expectation(description: "The test notification is delivered")
        let notificationCenter = NotificationCenter()
        let testNote = TestNotification(object: TestObject(), testValue: 2)
        var receivedNote: TestNotification?
        let observation = notificationCenter.addObserver(forType: TestNotification.self, object: testNote.object, queue: nil) { note in
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

    func test_notificationCenter_removesObserverWhenObservationIsDeallocated() {
        // Given
        let exp = expectation(description: "The test notification is not delivered")
        exp.isInverted = true
        let notificationCenter = NotificationCenter()
        var observation: NotificationObservation? = notificationCenter.addObserver(forType: TestNotification.self, object: nil, queue: nil) { _ in
            exp.fulfill()
        }

        // When
        observation = nil
        notificationCenter.post(TestNotification(object: TestObject(), testValue: 2))
        waitForExpectations(timeout: 0.1)

        // Then
        // The expectation should not have been fulfilled
    }
}
