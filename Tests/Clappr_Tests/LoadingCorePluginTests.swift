import Quick
import Nimble

@testable import Clappr

class LoadingCorePluginTests: QuickSpec {

    override func spec() {
        super.spec()

        describe(".LoadingCorePlugin") {
            describe("init") {
                it("sets the accessibilityIdentifier") {
                    let loading = LoadingCorePlugin(context: Core())

                    expect(loading.accessibilityIdentifier).to(equal("LoadingCorePlugin"))
                }
            }
        }
    }

}

