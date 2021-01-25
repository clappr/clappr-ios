import Quick
import Nimble

@testable import Clappr

class AVFoundationPlaybackStopActionTests: QuickSpec {
    override func spec() {
        describe(".AVFoundationPlaybackStopActionTests") {
            describe("when stop is called") {
                it("updates state to idle") {
                    let avfoundationPlayback = AVFoundationPlayback(options: [:])
                    avfoundationPlayback.player = PlayerMock()
                    avfoundationPlayback.state = .playing
                    
                    avfoundationPlayback.stop()
                    
                    expect(avfoundationPlayback.state).to(equal(.idle))
                }

                context("#events") {
                    it("triggers willStop event") {
                        var didCallWillStop = false
                        let baseObject = BaseObject()
                        let avfoundationPlayback = AVFoundationPlayback(options: [:])
                        avfoundationPlayback.player = PlayerMock()
                        avfoundationPlayback.state = .playing
                        baseObject.listenTo(avfoundationPlayback, event: .willStop) { _ in
                            didCallWillStop = true
                        }
                        
                        avfoundationPlayback.stop()
                        
                        expect(didCallWillStop).to(beTrue())
                    }

                    it("triggers didStop event") {
                        var didCallDidStop = false
                        let baseObject = BaseObject()
                        let avfoundationPlayback = AVFoundationPlayback(options: [:])
                        avfoundationPlayback.player = PlayerMock()
                        avfoundationPlayback.state = .playing
                        baseObject.listenTo(avfoundationPlayback, event: .didStop) { _ in
                            didCallDidStop = true
                        }

                        avfoundationPlayback.stop()

                        expect(didCallDidStop).to(beTrue())
                    }
                }
            }
        }
    }
}
