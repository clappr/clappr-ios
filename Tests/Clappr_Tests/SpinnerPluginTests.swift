import Quick
import Nimble

@testable import Clappr

class SpinnerPluginTests: QuickSpec {
    override func spec() {
        describe("#init") {
            let spinnerPlugin = SpinnerPlugin(context: Container())

            expect(spinnerPlugin.accessibilityIdentifier).to(equal("SpinnerPlugin"))
        }
    }
}
