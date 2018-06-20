import Quick
import Nimble

class DVRPluginTests: QuickSpec {
    override func spec() {
        super.spec()

        describe(".DVRPlugin") {
            context("when playback is Live") {
                context("and has position higher than 100") {
                    it("should trigger enable dvr with true") {
                        
                    }
                }
                context("and has position less than 100") {
                    it("should trigger enable dvr with false") {
                        
                    }
                }
            }
            context("when playback is VOD") {
                context("and has position higher than 100") {
                    it("should trigger enable dvr with false") {
                        
                    }
                }
                context("and has position less than 100") {
                    it("should trigger enable dvr with false") {
                        
                    }
                }
            }
        }
    }
}
