import XCTest

@testable import Clappr

class FakeAppStateHandler: AppStateManagerDelegate {
    var state: UIApplicationState?
    let expectation: XCTestExpectation

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func didChange(state: UIApplicationState) {
        self.state = state
        expectation.fulfill()
    }
}

class AppStateManagerTests: XCTestCase {

    @available(iOS 9.0, *)
    func testAppDidEnterInBackground() {
        let expect = expectation(description: "Wait for app enter in background")
        let fakeHandler = FakeAppStateHandler(expectation: expect)
        let stateManagerDelegate = AppStateManager(delegate: fakeHandler)
        stateManagerDelegate.startMonitoring()

        XCUIDevice.shared.press(XCUIDevice.Button.home)

        waitForExpectations(timeout: 20) { error in
            if error != nil {
                XCTFail()
            }
            XCTAssertEqual(fakeHandler.state?.rawValue, UIApplicationState.background.rawValue)
        }
    }
}
