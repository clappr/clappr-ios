import Foundation
import XCTest

extension XCTWaiter {

    func waitFor(element: XCUIElement, timeout: TimeInterval = 20) -> Bool {
        let existsPredicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: element)
        let result = self.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}
