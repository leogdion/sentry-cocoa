@testable import Sentry
import XCTest

final class NSLockTests: XCTestCase {

    func testLockForIncrement() throws {
        let lock = NSLock()
        
        var value = 0
        
        testConcurrentModifications(asyncWorkItems: 10, writeLoopCount: 9, writeWork: { _ in
            let returnValue: Int = lock.synchronized {
                value += 1
                return 10
            }
            XCTAssertEqual(returnValue, 10)
            
            lock.synchronized {
                value += 1
            }
        })
        
        XCTAssertEqual(value, 200)
    }
    
    func testUnlockWhenThrowing() throws {
        let lock = NSLock()
        
        let errorMessage = "It's broken"
        do {
            try lock.synchronized {
                throw NSLockError.runtimeError(errorMessage)
            }
        } catch NSLockError.runtimeError(let actualErrorMessage) {
            XCTAssertEqual(actualErrorMessage, errorMessage)
        }
        
        let expectation = expectation(description: "Lock should be non blocking")
        
        DispatchQueue.global().async {
            lock.synchronized {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }

    func testRecursiveLockForIncrement() throws {
        let lock = NSRecursiveLock()

        var value = 0

        testConcurrentModifications(asyncWorkItems: 10, writeLoopCount: 9, writeWork: { _ in
            let returnValue: Int = lock.synchronized {
                // NSLock would deadlock here, but NSRecursiveLock allows re-entrance
                lock.synchronized {
                    value += 1
                }
                return 10
            }
            XCTAssertEqual(returnValue, 10)

            lock.synchronized {
                value += 1
            }
        })

        XCTAssertEqual(value, 200)
    }

    func testRecursiveUnlockWhenThrowing() throws {
        let lock = NSRecursiveLock()

        let errorMessage = "It's broken"
        do {
            try lock.synchronized {
                // NSLock would deadlock here, but NSRecursiveLock allows re-entrance
                try lock.synchronized {
                    throw NSLockError.runtimeError(errorMessage)
                }
            }
        } catch NSLockError.runtimeError(let actualErrorMessage) {
            XCTAssertEqual(actualErrorMessage, errorMessage)
        }

        let expectation = expectation(description: "Lock should be non blocking")

        DispatchQueue.global().async {
            lock.synchronized {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 0.1)
    }

    private enum NSLockError: Error {
        case runtimeError(String)
    }
}
