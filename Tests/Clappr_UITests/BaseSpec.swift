import Foundation
import XCTest
import Quick
import Nimble

class BaseSpec: QuickSpec {

    var app: XCUIApplication!
    var dashboard: DashboardViewInteractor!
    var player: PlayerViewInteractor!

    override func spec() {
        beforeEach {
            self.app = XCUIApplication()
            self.app.launch()

            self.dashboard = DashboardViewInteractor(app: self.app)
            self.player = PlayerViewInteractor(app: self.app)
        }

        afterEach {
            self.app.terminate()
        }
    }

    func waitVOD(timeout: TimeInterval = 20, action: @escaping (@escaping () -> Void) -> Void) {
        waitUntil(timeout: timeout) { done in
            var timer: Timer!
            timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
                if self.app.staticTexts["ClapprElapsedTime"].exists" {
                    timer.invalidate()
                    action(done)
                }
            }
        }
    }
}
