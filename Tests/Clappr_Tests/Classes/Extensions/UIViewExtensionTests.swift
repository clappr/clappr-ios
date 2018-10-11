import Quick
import Nimble

@testable import Clappr

class UIViewExtensionTests: QuickSpec {
    override func spec() {
        describe(".UIView") {
            describe("#fromNib") {
                it("loads from nib") {
                    let mediaControlView: MediaControlView = .fromNib()
                    
                    expect(mediaControlView).to(beAKindOf(MediaControlView.self))
                }
            }
        }
    }
}
