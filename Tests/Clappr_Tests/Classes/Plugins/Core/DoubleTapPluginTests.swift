import Quick
import Nimble

@testable import Clappr

class DoubleTapPluginTests: QuickSpec {

    override func spec() {
        describe(".DoubleTapPlugin") {
            var doubleTapPlugin: DoubleTapPlugin!
            let core = CoreStub()
            
            beforeEach {
                doubleTapPlugin = DoubleTapPlugin(context: core)
                core.view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            }
            
            describe("pluginName") {
                it("has a name") {
                    let pluginName = String(describing: DoubleTapPlugin.self)
                    expect(doubleTapPlugin.pluginName).to(equal(pluginName))
                }
            }
            
            describe("when double tap is triggered") {
                context("and its position is less than half of the view (left)") {
                    it("seeks back 10 seconds") {
                        let leftTapViewLocation: EventUserInfo = ["viewLocation": CGFloat(0.0)]
                        core.playbackMock?.set(position: 20.0)
                        
                        core.trigger(InternalEvent.didDoubleTappedCore.rawValue, userInfo: leftTapViewLocation)
                        
                        expect(core.playbackMock?.didCallSeek).to(beTrue())
                        expect(core.playbackMock?.didCallSeekWithValue).to(equal(10))
                    }
                }
                
                context("and its position is higher than half of the view (right)") {
                    it("seeks forward 10 seconds") {
                        let leftTapViewLocation: EventUserInfo = ["viewLocation": CGFloat(100.0)]
                        core.playbackMock?.set(position: 20.0)
                        
                        core.trigger(InternalEvent.didDoubleTappedCore.rawValue, userInfo: leftTapViewLocation)
                        
                        expect(core.playbackMock?.didCallSeek).to(beTrue())
                        expect(core.playbackMock?.didCallSeekWithValue).to(equal(30))
                    }
                }
            }
        }
    }
}
