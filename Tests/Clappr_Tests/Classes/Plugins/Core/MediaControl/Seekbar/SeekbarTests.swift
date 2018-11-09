import Quick
import Nimble
import CoreMedia

@testable import Clappr

class SeekbarTests: QuickSpec {
    override func spec() {
        describe("Seekbar") {
            it("is a MediaControlPlugin") {
                let seekbar = Seekbar()

                expect(seekbar).to(beAKindOf(MediaControlPlugin.self))
            }
        }

        describe("#pluginName") {
            it("is Seekbar") {
                let seekbar = Seekbar()

                expect(seekbar.pluginName).to(equal("Seekbar"))
            }
        }

        describe("#panel") {
            it("is positioned in the bottom panel") {
                let seekbar = Seekbar()

                expect(seekbar.panel).to(equal(MediaControlPanel.bottom))
            }
        }

        describe("#position") {
            it("is positioned in the left side") {
                let seekbar = Seekbar()

                expect(seekbar.position).to(equal(MediaControlPosition.none))
            }
        }

        describe("#seek") {
            context("when VOD") {
                it("calls activePlayback seek with the correct value") {
                    let coreStub = CoreStub()
                    let seekbar = Seekbar(context: coreStub)

                    seekbar.seek(10)

                    expect(coreStub.playbackMock?.didCallSeek).to(beTrue())
                    expect(coreStub.playbackMock?.didCallSeekWithValue).to(equal(10))
                }
            }

            context("when LIVE and the user seeks to the end") {
                it("seeks to infinity to resync live broadcast") {
                    let coreStub = CoreStub()
                    let seekbar = Seekbar(context: coreStub)
                    coreStub.playbackMock?.videoDuration = 10
                    coreStub.playbackMock?.set(isDvrInUse: true)

                    seekbar.seek(10)

                    expect(coreStub.playbackMock?.didCallSeekToLivePosition).to(beTrue())
                }
            }
        }

        describe("#render") {

            var seekbar: Seekbar!

            beforeEach {
                seekbar = Seekbar()

                seekbar.render()
            }

            it("sets height constraint in view") {
                let heightConstraint = seekbar.view.constraints.first(where: { $0.firstAttribute == NSLayoutAttribute.height })
                expect(heightConstraint?.constant).to(equal(38))
            }

            describe("container") {
                it("is a UIStackView") {
                    expect(seekbar.containerView).to(beAKindOf(UIStackView.self))
                }

                it("has seekbar as it's second view") {
                    expect(seekbar.containerView.arrangedSubviews[0]).to(equal(seekbar.seekbarView))
                }

                it("sets self as SeekbarView delegate") {
                    expect(seekbar.seekbarView.delegate).to(beAKindOf(Seekbar.self))
                }
            }

            describe("when a video is playing") {

                it("sets the SeekbarView to live") {
                    let coreStub = CoreStub()
                    let seekbar = Seekbar(context: coreStub)
                    seekbar.seekbarView.isLive = true

                    seekbar.render()

                    expect(seekbar.seekbarView.progressBar.backgroundColor).to(equal(.red))
                    expect(seekbar.seekbarView.timeLabelView.isHidden).to(beTrue())
                    expect(seekbar.seekbarView.timeLabel.isHidden).to(beTrue())
                    expect(seekbar.seekbarView.bufferBar.isHidden).to(beTrue())
                    expect(seekbar.seekbarView.isUserInteractionEnabled).to(beFalse())
                }

                it("sets the SeekbarView to VOD") {
                    let coreStub = CoreStub()
                    let seekbar = Seekbar(context: coreStub)
                    seekbar.seekbarView.isLive = false

                    seekbar.render()

                    expect(seekbar.seekbarView.progressBar.backgroundColor).to(equal(.blue))
                    expect(seekbar.seekbarView.timeLabelView.isHidden).to(beFalse())
                    expect(seekbar.seekbarView.timeLabel.isHidden).to(beFalse())
                    expect(seekbar.seekbarView.bufferBar.isHidden).to(beFalse())
                    expect(seekbar.seekbarView.bufferBar.backgroundColor).to(equal(.gray))
                    expect(seekbar.seekbarView.isUserInteractionEnabled).to(beTrue())
                }
            }

            describe("Events") {
                var coreStub: CoreStub!
                var seekbar: Seekbar!
                var seekbarViewMock: SeekbarViewMock!

                beforeEach {
                    coreStub = CoreStub()
                    seekbar = Seekbar(context: coreStub)

                    seekbar.render()
                }

                context("when a video loads") {
                    context("and it is VOD") {
                        it("sets the video duration in the seekbarView") {
                            coreStub.playbackMock?.videoDuration = 100

                            coreStub.activePlayback?.trigger(Event.ready.rawValue)

                            expect(seekbar.seekbarView.videoDuration).to(equal(100))
                        }
                    }
                    context("and it is Live") {
                        it("sets the video duration in the seekbarView") {
                            seekbar.seekbarView.videoDuration = 20
                            seekbar.seekbarView.isLive = true
                            coreStub.playbackMock?.videoDuration = 100

                            coreStub.activePlayback?.trigger(Event.ready.rawValue)

                            expect(seekbar.seekbarView.videoDuration).to(equal(100))
                        }
                    }
                }

                context("when a video plays") {
                    context("and the video is VOD") {
                        it("sets the video duration in the seekbarView") {
                            coreStub.playbackMock?.videoDuration = 100

                            coreStub.activePlayback?.trigger(Event.playing.rawValue)

                            expect(seekbar.seekbarView.videoDuration).to(equal(100))
                        }
                    }

                    context("and the video is LIVE") {
                        it("sets the video duration in the seekbarView") {
                            seekbar.seekbarView.videoDuration = 0
                            seekbar.seekbarView.isLive = true
                            coreStub.playbackMock?.videoDuration = 100

                            coreStub.activePlayback?.trigger(Event.playing.rawValue)

                            expect(seekbar.seekbarView.videoDuration).to(equal(100))
                        }
                    }
                }

                context("when a video position updates") {
                    context("and it's a VOD") {
                        it("informs the position to the seekbarView") {
                            seekbarViewMock = SeekbarViewMock()
                            seekbar.seekbarView = seekbarViewMock
                            coreStub.playbackMock?.videoPosition = 50

                            coreStub.activePlayback?.trigger(Event.positionUpdate, userInfo: nil)

                            expect(seekbarViewMock.didCallUpdateScrubberWithValue).to(equal(50))
                        }
                    }

                    context("and it's a LIVE in DVR mode") {
                        it("informs the position to the seekbarView") {
                            seekbarViewMock = SeekbarViewMock()
                            seekbar.seekbarView = seekbarViewMock
                            coreStub.playbackMock?.set(position: 100)
                            coreStub.playbackMock?.set(isDvrInUse: true)

                            coreStub.activePlayback?.trigger(Event.positionUpdate, userInfo: nil)

                            expect(seekbarViewMock.didCallUpdateScrubberWithValue).to(equal(100))
                        }
                    }
                }

                context("when receives a buffer update event with valid time") {
                    it("informs the duration to seekbarview") {
                        seekbarViewMock = SeekbarViewMock()
                        seekbar.seekbarView = seekbarViewMock
                        seekbar.seekbarView.videoDuration = 100
                        let bufferEndTime = CMTimeGetSeconds(CMTimeMakeWithSeconds(50, Int32(NSEC_PER_SEC)))
                        let userInfo: EventUserInfo = ["end_position": bufferEndTime]

                        coreStub.activePlayback?.trigger(Event.bufferUpdate, userInfo: userInfo)

                        expect(seekbarViewMock.didCallUpdateBufferWithValue).to(equal(CGFloat(bufferEndTime)))
                    }

                    context("and the position time is higher than the videoDuration") {
                        it("sets the videoDuration to seekbarview") {
                            seekbarViewMock = SeekbarViewMock()
                            seekbar.seekbarView = seekbarViewMock
                            seekbar.seekbarView.videoDuration = 100
                            let bufferEndTime = CMTimeGetSeconds(CMTimeMakeWithSeconds(150, Int32(NSEC_PER_SEC)))
                            let userInfo: EventUserInfo = ["end_position": bufferEndTime]

                            coreStub.activePlayback?.trigger(Event.bufferUpdate, userInfo: userInfo)

                            expect(seekbarViewMock.didCallUpdateBufferWithValue).to(equal(seekbar.seekbarView.videoDuration))
                        }
                    }
                }

                context("when receives a buffer update event with invalid time") {
                    it("doesn't inform the duration to seekbarview") {
                        seekbarViewMock = SeekbarViewMock()
                        seekbar.seekbarView = seekbarViewMock
                        let bufferEndTime = CMTimeGetSeconds(CMTimeMakeWithSeconds(50, Int32(NSEC_PER_SEC))) + Float64.nan
                        let userInfo: EventUserInfo = ["end_position": bufferEndTime]

                        coreStub.activePlayback?.trigger(Event.bufferUpdate, userInfo: userInfo)

                        expect(seekbarViewMock.didCallUpdateBufferWithValue).to(beNil())
                    }
                }

                context("when a seek is started") {
                    it("informs seekbarview") {
                        seekbarViewMock = SeekbarViewMock()
                        seekbar.seekbarView = seekbarViewMock

                        coreStub.activePlayback?.trigger(Event.willSeek)

                        expect(seekbarViewMock.isSeeking).to(beTrue())
                    }
                }

                context("when a seekable time is updated in DVR mode") {
                    it("updates the seekbarview position") {
                        seekbarViewMock = SeekbarViewMock()
                        seekbar.seekbarView = seekbarViewMock
                        coreStub.playbackMock?.set(position: 100)
                        coreStub.playbackMock?.set(isDvrInUse: true)

                        coreStub.activePlayback?.trigger(Event.seekableUpdate, userInfo: nil)

                        expect(seekbarViewMock.didCallUpdateScrubberWithValue).to(equal(100))
                    }
                }

                context("when a seek is completed") {
                    it("informs seekbarview") {
                        seekbarViewMock = SeekbarViewMock()
                        seekbar.seekbarView = seekbarViewMock
                        seekbarViewMock.isSeeking = true

                        coreStub.activePlayback?.trigger(Event.didSeek)

                        expect(seekbarViewMock.isSeeking).to(beFalse())
                    }
                }
            }
        }
    }

    class SeekbarViewMock: SeekbarView {
        var didCallUpdateBufferWithValue: CGFloat?
        var didCallUpdateScrubberWithValue: CGFloat?

        override func updateBuffer(time: CGFloat) {
            didCallUpdateBufferWithValue = time
        }

        override func updateScrubber(time: CGFloat) {
            didCallUpdateScrubberWithValue = time
        }
    }
}
