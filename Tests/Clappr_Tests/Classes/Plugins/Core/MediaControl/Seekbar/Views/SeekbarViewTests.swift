import Quick
import Nimble

@testable import Clappr

class SeekbarViewTests: QuickSpec {
    override func spec() {
        describe("Seekbar View") {

            describe("touchview") {
                it("is a DragDetectorView") {
                    let seekbarView: SeekbarView = .fromNib()

                    expect(seekbarView.seekBarContainerView).to(beAKindOf(DragDetectorView.self))
                }

                it("has SeekbarView as target") {
                    let seekbarView: SeekbarView = .fromNib()

                    expect(seekbarView.seekBarContainerView.target as? SeekbarView).to(equal(seekbarView))
                }

                it("has handleSeekbarViewTouch as selector") {
                    let seekbarView: SeekbarView = .fromNib()

                    expect(seekbarView.seekBarContainerView.selector).to(equal(#selector(seekbarView.handleSeekbarViewTouch(_:))))
                }
            }

            describe("updateScrubber") {
                it("sets the scrubber in the correct position in the timeline") {
                    let seekbarView: SeekbarView = .fromNib()
                    seekbarView.videoDuration = 100

                    seekbarView.updateScrubber(time: 50)

                    expect(seekbarView.scrubberPosition.constant).to(equal(169.0))
                }

                it("doesn't move the scrubber if it's a live video") {
                    let scrubberAtTheEnd: CGFloat = 355
                    let seekbarView: SeekbarView = .fromNib()
                    seekbarView.videoDuration = 100
                    seekbarView.scrubberPosition.constant = 0
                    seekbarView.isLive = true

                    seekbarView.updateScrubber(time: 50)

                    expect(seekbarView.scrubberPosition.constant).to(equal(scrubberAtTheEnd))
                }

                it("goes to position zero if the end value is negative") {
                    let seekbarView: SeekbarView = .fromNib()
                    seekbarView.videoDuration = 100
                    seekbarView.scrubberPosition.constant = 0

                    seekbarView.updateScrubber(time: -50)

                    expect(seekbarView.scrubberPosition.constant).to(equal(0))
                }

                it("goes to the end if the end value is bigger than duration") {
                    let scrubberAtTheEnd: CGFloat = 355
                    let seekbarView: SeekbarView = .fromNib()
                    seekbarView.videoDuration = 100
                    seekbarView.scrubberPosition.constant = 0

                    seekbarView.updateScrubber(time: 5000)

                    expect(seekbarView.scrubberPosition.constant).to(equal(scrubberAtTheEnd))
                }
            }

            describe("updateBuffer") {
                it("updates the buffer bar position") {
                    let seekbarView: SeekbarView = .fromNib()
                    seekbarView.videoDuration = 100
                    seekbarView.bufferWidth.constant = 0

                    seekbarView.updateBuffer(time: 44)

                    expect(seekbarView.bufferWidth.constant).to(equal(165))
                }
            }

            context("when is live") {
                it("has the scrubber with red color") {
                    let seekbarView: SeekbarView = .fromNib()

                    seekbarView.isLive = true

                    expect(seekbarView.scrubber.backgroundColor).to(equal(UIColor.red))
                }

                it("has the progress bar with red color") {
                    let seekbarView: SeekbarView = .fromNib()

                    seekbarView.isLive = true

                    expect(seekbarView.progressBar.backgroundColor).to(equal(UIColor.red))
                }

                it("doesn't has user interaction enabled") {
                    let seekbarView: SeekbarView = .fromNib()

                    seekbarView.isLive = true

                    expect(seekbarView.isUserInteractionEnabled).to(equal(false))
                }

                it("positions the scrubber at the end of the seekbar") {
                    let seekbarView: SeekbarView = .fromNib()

                    seekbarView.isLive = true

                    expect(seekbarView.scrubberPosition.constant).to(equal(355))
                }
            }

            context("when is VOD") {
                it("has the scrubber with red color") {
                    let seekbarView: SeekbarView = .fromNib()

                    seekbarView.isLive = false

                    expect(seekbarView.scrubber.backgroundColor).to(equal(UIColor.white))
                }

                it("has the progress bar with red color") {
                    let seekbarView: SeekbarView = .fromNib()

                    seekbarView.isLive = false

                    expect(seekbarView.progressBar.backgroundColor).to(equal(UIColor.white))
                }

                it("doesn't has user interaction enabled") {
                    let seekbarView: SeekbarView = .fromNib()

                    seekbarView.isLive = false

                    expect(seekbarView.isUserInteractionEnabled).to(equal(true))
                }
            }

            describe("handleSeekbarViewTouch") {
                context("when tapped in the beginning") {
                    it("sets scrubber position at the beginning") {
                        let seekbarView: SeekbarView = .fromNib()
                        let dragDetectorStub = DragDetectorViewStub()

                        dragDetectorStub.touch(x: 5, y: 0)
                        seekbarView.handleSeekbarViewTouch(dragDetectorStub)

                        expect(seekbarView.scrubberPosition.constant).to(equal(0))
                    }
                }

                context("when tapped near the end of seekbar") {
                    it("sets scrubber position at the end") {
                        let seekbarView: SeekbarView = .fromNib()
                        let dragDetectorStub = DragDetectorViewStub()
                        let seekbarEnd = seekbarView.frame.width

                        dragDetectorStub.touch(x: seekbarEnd, y: 0)
                        seekbarView.handleSeekbarViewTouch(dragDetectorStub)

                        expect(seekbarView.scrubberPosition.constant).to(equal(355))
                    }
                }

                context("when tapped anywhere but the beginning or end") {
                    it("sets scrubber position to center relative to that point") {
                        let seekbarView: SeekbarView = .fromNib()
                        let dragDetectorStub = DragDetectorViewStub()

                        dragDetectorStub.touch(x: 40, y: 0)
                        seekbarView.handleSeekbarViewTouch(dragDetectorStub)

                        expect(seekbarView.scrubberPosition.constant).to(equal(30))
                    }
                }

                context("when moving") {
                    it("sets isSeeking property to true") {
                        let seekbarView: SeekbarView = .fromNib()
                        let dragDetectorStub = DragDetectorViewStub()

                        dragDetectorStub.touch(x: 100, y: 0)
                        seekbarView.handleSeekbarViewTouch(dragDetectorStub)

                        expect(seekbarView.isSeeking).to(beTrue())
                    }

                    it("calls delegate when begin scrubbing") {
                        let seekbarView: SeekbarView = .fromNib()
                        let dragDetectorStub = DragDetectorViewStub()
                        let seekBarDelegate = SeekbarDelegateMock()
                        seekbarView.delegate = seekBarDelegate

                        dragDetectorStub.touch(x: 45.5, y: 0)
                        dragDetectorStub.touch(state: .began)
                        seekbarView.handleSeekbarViewTouch(dragDetectorStub)

                        expect(seekBarDelegate.didCallWillBeginScrubbing).to(beTrue())
                    }
                }

                context("when stops moving") {
                    context("when ended") {
                        it("sets isSeeking property to false") {
                            let seekbarView: SeekbarView = .fromNib()
                            let dragDetectorStub = DragDetectorViewStub()

                            dragDetectorStub.touch(x: 100, y: 0)
                            dragDetectorStub.touch(state: .ended)
                            seekbarView.handleSeekbarViewTouch(dragDetectorStub)

                            expect(seekbarView.isSeeking).to(beFalse())
                        }

                        it("calls the delegate with the correct value") {
                            let seekbarView: SeekbarView = .fromNib()
                            let dragDetectorStub = DragDetectorViewStub()
                            let seekBarDelegate = SeekbarDelegateMock()
                            seekbarView.videoDuration = 100
                            seekbarView.delegate = seekBarDelegate

                            dragDetectorStub.touch(x: 45.5, y: 0)
                            dragDetectorStub.touch(state: .ended)
                            seekbarView.handleSeekbarViewTouch(dragDetectorStub)

                            expect(seekBarDelegate.didCallSeek).to(beTrue())
                            expect(seekBarDelegate.didCallSeekWithValue).to(equal(10))
                        }
                    }

                    context("when canceled") {
                        it("sets isSeeking property to false") {
                            let seekbarView: SeekbarView = .fromNib()
                            let dragDetectorStub = DragDetectorViewStub()

                            dragDetectorStub.touch(x: 100, y: 0)
                            dragDetectorStub.touch(state: .canceled)
                            seekbarView.handleSeekbarViewTouch(dragDetectorStub)

                            expect(seekbarView.isSeeking).to(beFalse())
                        }
                    }
                }
            }

            describe("layoutSubviews") {

                it("sets the seekbarWidth") {
                    let seekbarView: SeekbarView = .fromNib()
                    seekbarView.seekBarContainerView.frame = CGRect(x: 0, y: 0, width: 100, height: 0)

                    seekbarView.layoutSubviews()

                    expect(seekbarView.seekBarContainerView.frame.width).to(equal(100))
                }

                context("when is live") {
                    context("when dvr is disabled") {
                        it("puts the scrubber at the end") {
                            let seekbarView: SeekbarView = .fromNib()
                            seekbarView.isLive = true
                            seekbarView.seekBarContainerView.frame = CGRect(x: 0, y: 0, width: 200, height: 0)
                            seekbarView.scrubber.frame = CGRect(x: 0, y: 0, width: 10, height: 0)
                            seekbarView.scrubberPosition.constant = 50

                            seekbarView.layoutSubviews()

                            expect(seekbarView.scrubberPosition.constant).to(equal(190))
                        }
                    }
                }

                context("when is vod") {
                    it("updates the position of the scrubber") {
                        let seekbarView: SeekbarView = .fromNib()
                        seekbarView.isLive = false
                        seekbarView.videoDuration = 100
                        seekbarView.seekBarContainerView.frame = CGRect.init(x: 0, y: 0, width: 100, height: 0)
                        seekbarView.layoutSubviews()
                        seekbarView.updateScrubber(time: CGFloat(50))

                        seekbarView.seekBarContainerView.frame = CGRect.init(x: 0, y: 0, width: 150, height: 0)
                        seekbarView.layoutSubviews()

                        expect(seekbarView.scrubberPosition.constant).to(equal(65))
                    }

                    it("updates the position of the buffer") {
                        let seekbarView: SeekbarView = .fromNib()
                        seekbarView.isLive = false
                        seekbarView.videoDuration = 100
                        seekbarView.seekBarContainerView.frame = CGRect.init(x: 0, y: 0, width: 50, height: 0)
                        seekbarView.layoutSubviews()
                        seekbarView.updateBuffer(time: CGFloat(49))

                        seekbarView.seekBarContainerView.frame = CGRect.init(x: 0, y: 0, width: 100, height: 0)
                        seekbarView.layoutSubviews()

                        expect(seekbarView.bufferWidth.constant).to(equal(49))
                    }
                }
            }
        }
    }

    class DragDetectorViewStub: DragDetectorView {
        override var currentTouch: UITouch? {
            return uiTouchStub
        }

        override var touchState: DragDetectorView.State {
            return _touchState
        }

        var uiTouchStub = UITouchStub()

        var _touchState: DragDetectorView.State = .idle

        func touch(x: CGFloat, y: CGFloat) {
            uiTouchStub.x = x
            uiTouchStub.y = y
        }

        func touch(state: DragDetectorView.State) {
            _touchState = state
        }
    }

    class UITouchStub: UITouch {
        var x: CGFloat = 0
        var y: CGFloat = 0

        override func location(in view: UIView?) -> CGPoint {
            return CGPoint(x: x, y: y)
        }
    }

    class SeekbarDelegateMock: NSObject, SeekbarDelegate {
        var didCallSeek = false
        var didCallSeekWithValue: TimeInterval = 0
        var didCallWillBeginScrubbing = false
        var didCallDidFinishScrubbing = false
        var didCallIsScrubbing = false

        func seek(_ time: TimeInterval) {
            didCallSeek = true
            didCallSeekWithValue = time
        }

        func willBeginScrubbing() {
            didCallWillBeginScrubbing = true
        }

        func didFinishScrubbing() {
            didCallDidFinishScrubbing = true
        }

        func isScrubbing(scrubberFrame: CGRect, currentSecond: Int) {
            didCallIsScrubbing = true
        }
    }
}
