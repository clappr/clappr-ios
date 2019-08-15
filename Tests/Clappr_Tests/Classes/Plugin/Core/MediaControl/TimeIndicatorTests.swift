import Quick
import Nimble

@testable import Clappr

class TimeIndicatorTests: QuickSpec {
    override func spec() {
        var timeIndicator: TimeIndicator!
        var coreStub: CoreStub!

        beforeEach {
            coreStub = CoreStub()
            timeIndicator = TimeIndicator(context: coreStub)
        }

        describe(".TimeIndicatorTests") {
            it("is a MediaControlPlugin") {
                expect(timeIndicator).to(beAKindOf(MediaControl.Element.self))
            }

            describe("#pluginName") {
                it("is TimeIndicator") {
                    expect(timeIndicator.pluginName).to(equal("TimeIndicator"))
                }
            }

            describe("#panel") {
                it("is positioned in the bottom panel") {
                    expect(timeIndicator.panel).to(equal(MediaControlPanel.bottom))
                }
            }

            describe("#position") {
                it("is positioned in the left side") {
                    expect(timeIndicator.position).to(equal(MediaControlPosition.left))
                }
            }

            describe("#render") {
                beforeEach {
                    timeIndicator.render()
                }

                describe("time indicator") {
                    it("creates it as a UIStackView") {
                        expect(timeIndicator.indicator).to(beAKindOf(UIStackView.self))
                    }

                    it("sets the acessibilityIdentifier") {
                        expect(timeIndicator.indicator.accessibilityIdentifier).to(equal("timeIndicator"))
                    }
                }

                describe("elapsedTime") {
                    it("is a UILabel") {
                        expect(timeIndicator.elapsedTimeLabel).to(beAKindOf(UILabel.self))
                    }

                    it("has white color") {
                        expect(timeIndicator.elapsedTimeLabel.textColor).to(equal(UIColor.white))
                    }

                    it("has '00:00' as initial text") {
                        expect(timeIndicator.elapsedTimeLabel.text).to(equal("00:00"))
                    }

                    it("has Bold size 14") {
                        expect(timeIndicator.elapsedTimeLabel.font).to(equal(UIFont.boldSystemFont(ofSize:  14)))
                    }
                }

                describe("separator") {
                    it("is a UILabel") {
                        expect(timeIndicator.separatorLabel).to(beAKindOf(UILabel.self))
                    }

                    it("has white color") {
                        expect(timeIndicator.separatorLabel.textColor).to(equal(UIColor.white))
                    }

                    it("has ' / ' as initial text") {
                        expect(timeIndicator.separatorLabel.text).to(equal(" / "))
                    }

                    it("has OpenSans Bold size 14") {
                        expect(timeIndicator.separatorLabel.font).to(equal(UIFont.boldSystemFont(ofSize: 14)))
                    }
                }

                describe("durationTime") {
                    it("is a UILabel") {
                        expect(timeIndicator.durationTimeLabel).to(beAKindOf(UILabel.self))
                    }

                    it("has white color") {
                        expect(timeIndicator.durationTimeLabel.textColor).to(equal(UIColor.white))
                    }

                    it("has '00:00' as initial text") {
                        expect(timeIndicator.durationTimeLabel.text).to(equal("00:00"))
                    }

                    it("has OpenSans Bold size 14") {
                        expect(timeIndicator.durationTimeLabel.font).to(equal(UIFont.boldSystemFont(ofSize: 14)))
                    }
                }


                describe("leftMargin") {
                    it("is a UIView") {
                        expect(timeIndicator.leftMargin).to(beAKindOf(UIView.self))
                    }

                    it("is the first view in the time indicator") {
                        expect(timeIndicator.indicator.subviews.first).to(equal(timeIndicator.leftMargin))
                    }
                }
            }

            describe("when playback receives didUpdateDuration event") {
                beforeEach {
                    timeIndicator.render()
                }

                context("duration time of video") {
                    it("updates the video label when event is triggered") {
                        coreStub.playbackMock?.videoDuration = 138.505

                        coreStub.activePlayback?.trigger(.didUpdateDuration, userInfo: ["duration": 138.505])

                        expect(timeIndicator.durationTimeLabel.text).to(equal("02:18"))
                    }

                    it("doesnt update the video label when there is no userInfo on event") {
                        coreStub.playbackMock?.videoDuration = 138.505

                        coreStub.activePlayback?.trigger(.didUpdateDuration, userInfo: [:])

                        expect(timeIndicator.durationTimeLabel.text).to(equal("00:00"))
                        expect(timeIndicator.view.isHidden).to(beTrue())
                    }
                }
            }

            describe("when a position update event is triggered") {
                it("updates the elapsed time label") {
                    let coreStub = CoreStub()
                    let timeIndicator = TimeIndicator(context: coreStub)
                    timeIndicator.render()
                    let userInfo: EventUserInfo = ["position": TimeInterval(50)]

                    coreStub.activePlayback?.trigger(Event.didUpdatePosition, userInfo: userInfo)

                    expect(timeIndicator.elapsedTimeLabel.text).to(equal("00:50"))
                }
            }

            describe("Fullscreen") {
                beforeEach {
                    Loader.shared.resetPlugins()
                    timeIndicator.render()
                }

                context("when user enters in fullscreen") {
                    it("update layout constants for medium screen") {
                        coreStub.activeContainer?.view.frame = CGRect(x: 0, y: 0, width: 500, height: 0)

                        coreStub.trigger(Event.didEnterFullscreen.rawValue)

                        expect(timeIndicator.leftMarginSize?.constant).to(equal(16))
                        expect(timeIndicator.marginBottom).to(equal(10))
                    }
                }

                context("when user leaves fullscreen") {
                    it("update layout constants for small screen") {
                        coreStub.activeContainer?.view.frame = CGRect(x: 0, y: 0, width: 200, height: 0)

                        coreStub.trigger(Event.didExitFullscreen.rawValue)

                        expect(timeIndicator.leftMarginSize?.constant).to(equal(16))
                        expect(timeIndicator.marginBottom).to(equal(10))
                    }
                }
            }
        }
    }
}
