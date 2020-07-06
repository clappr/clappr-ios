import Quick
import Nimble

@testable import Clappr

class PlayButtonTests: QuickSpec {
    override func spec() {
        describe(".PlayButton") {
            var coreStub: CoreStub!
            var playButton: PlayButton!

            beforeEach {
                coreStub = CoreStub()
                playButton = PlayButton(context: coreStub)
                playButton.render()
            }

            describe("Plugin structure") {
                context("#init") {
                    it("is an MediaControlPlugin type") {
                        expect(playButton).to(beAKindOf(MediaControl.Element.self))
                    }
                }

                context("pluginName") {
                    it("has a name") {
                        expect(playButton.pluginName).to(equal("PlayButton"))
                    }
                }

                context("panel") {
                    it("is positioned in the center panel") {
                        expect(playButton.panel).to(equal(.center))
                    }
                }

                context("position") {
                    it("is aligned in the center") {
                        expect(playButton.position).to(equal(.center))
                    }
                }
            }

            describe("when a video is loaded") {
                context("and video is vod") {
                    it("shows button") {
                        coreStub.activeContainer?.trigger(.stalling)

                        expect(playButton.view.isHidden).to(beFalse())
                    }
                }
            }

            context("when clicked") {
                context("and enters in background and receive a didPause event") {
                    it("shows play button") {
                        coreStub.activePlayback?.trigger(.didPause)

                        expect(playButton.view.isHidden).toEventually(beFalse())
                    }
                }
                
                context("and a video is idle") {
                    beforeEach {
                        coreStub.playbackMock?.set(state: .idle)
                    }

                    it("calls the playback play") {
                        playButton.button?.sendActions(for: .touchUpInside)

                        expect(coreStub.playbackMock?.didCallPlay).to(beTrue())
                    }

                    it("shows play button") {
                        playButton.button?.sendActions(for: .touchUpInside)

                        expect(playButton.view.isHidden).toEventually(beFalse())
                    }
                }
            }

            context("when clicked during playback") {
                context("and video is playing") {
                    beforeEach {
                        coreStub.playbackMock?.set(state: .playing)
                    }

                    it("calls the playback pause") {
                        playButton.button?.sendActions(for: .touchUpInside)

                        expect(coreStub.playbackMock?.didCallPause).to(beTrue())
                    }

                    it("changes the icon to play") {
                        let playIcon = UIImage.fromName("play", for: PlayButton.self)!

                        playButton.button?.sendActions(for: .touchUpInside)

                        let currentButtonIcon = (playButton.button?.imageView?.image)!
                        expect(currentButtonIcon.isEqual(playIcon)).toEventually(beTrue())
                    }

                    context("and video is vod") {
                        it("shows button") {
                            playButton.view.isHidden = true

                            coreStub.activePlayback?.trigger(.playing)

                            expect(playButton.view.isHidden).to(beFalse())
                        }
                    }
                }

                context("and video is paused") {
                    beforeEach {
                        coreStub.playbackMock?.set(state: .paused)
                    }

                    it("calls the playback play") {
                        playButton.button?.sendActions(for: .touchUpInside)

                        expect(coreStub.playbackMock?.didCallPlay).to(beTrue())
                    }

                    it("changes the icon to pause") {
                        let pauseIcon = UIImage.fromName("pause", for: PlayButton.self)!

                        playButton.button?.sendActions(for: .touchUpInside)

                        let currentButtonIcon = (playButton.button?.imageView?.image)!
                        expect(currentButtonIcon.isEqual(pauseIcon)).toEventually(beTrue())
                    }

                    context("and video is vod") {
                        it("shows button") {
                            playButton.view.isHidden = true

                            coreStub.activePlayback?.trigger(.didPause)

                            expect(playButton.view.isHidden).to(beFalse())
                        }
                    }
                }
                
                context("and the video has ended") {
                    it("restarts the video") {
                        coreStub.playbackMock?.set(state: .idle)
                        coreStub.playbackMock?.trigger(.didComplete)
                        coreStub.playbackMock?.set(position: 20.0)
                        coreStub.playbackMock?.videoDuration = 20.0
                        
                        playButton.button?.sendActions(for: .touchUpInside)
                        
                        expect(coreStub.playbackMock?.didCallSeek).to(beTrue())
                        expect(coreStub.playbackMock?.didCallSeekWithValue).to(equal(0))
                    }
                }
            }

            describe("render") {
                it("set's acessibilityIdentifier to button") {
                    expect(playButton.button?.accessibilityIdentifier).to(equal("PlayPauseButton"))
                }

                describe("button") {
                    it("adds it in the view") {
                        expect(playButton.view.subviews).to(contain(playButton.button))
                    }

                    it("has scaleAspectFit content mode") {
                        expect(playButton.button?.imageView?.contentMode).to(equal(UIView.ContentMode.scaleAspectFit))
                    }
                }
            }

            context("when stalling") {
                it("hides the plugin") {
                    coreStub.activePlayback?.trigger(.stalling)

                    expect(playButton.view.isHidden).to(beTrue())
                }

                it("hides the plugin") {
                    coreStub.activePlayback?.trigger(.playing)

                    expect(playButton.view.isHidden).to(beFalse())
                }
            }
            
            describe("#events") {
                context("didStop") {
                    it("shows button view") {
                        playButton.hide()
                        
                        coreStub.activePlayback?.trigger(.didStop)
                        
                        expect(playButton.view.isHidden).to(beFalse())
                    }
                    
                    it("changes icon to play") {
                        let playIcon = UIImage.fromName("play", for: PlayButton.self)
                        
                        coreStub.activePlayback?.trigger(.didStop)
                        
                        expect(playButton.button?.imageView?.image).to(equal(playIcon))
                    }
                }
                
                context("didComplete") {
                    it("shows button view") {
                        playButton.hide()
                        
                        coreStub.activePlayback?.trigger(.didComplete)
                        
                        expect(playButton.view.isHidden).to(beFalse())
                    }
                    
                    it("changes icon to replay") {
                        let replayIcon = UIImage.fromName("replay", for: PlayButton.self)
                        
                        coreStub.activePlayback?.trigger(.didComplete)
                        
                        expect(playButton.button?.imageView?.image).to(equal(replayIcon))
                    }
                }
                
                context("willSeek") {
                    var info: EventUserInfo!
                    beforeEach {
                        coreStub.playbackMock?.state = .idle
                        coreStub.playbackMock?.videoDuration = 20.0
                        coreStub.playbackMock?.set(position: 20.0)
                        info = ["position": 10.0]

                    }
                    
                    it("shows button view") {
                        playButton.hide()

                        coreStub.activePlayback?.trigger(.willSeek, userInfo: info)
                        
                        expect(playButton.view.isHidden).to(beFalse())
                    }
                    
                    context("from the end to another point of the video") {
                        it("changes icon to play") {
                            let playIcon = UIImage.fromName("play", for: PlayButton.self)
                            coreStub.playbackMock?.trigger(.didComplete)
                            
                            coreStub.playbackMock?.trigger(.willSeek, userInfo: info)
                            
                            expect(playButton.button?.imageView?.image).to(equal(playIcon))
                        }
                    }
                    
                    context("to any point other than the end") {
                        context("when playing") {
                            it("keeps the pause icon") {
                                coreStub.playbackMock?.state = .playing
                                let playIcon = UIImage.fromName("pause", for: PlayButton.self)
                                
                                coreStub.playbackMock?.trigger(.willSeek, userInfo: info)
                                
                                expect(playButton.button?.imageView?.image).to(equal(playIcon))
                            }
                        }
                        
                        context("when paused") {
                            it("keeps the play icon") {
                                coreStub.playbackMock?.state = .paused
                                let playIcon = UIImage.fromName("play", for: PlayButton.self)
                                
                                coreStub.playbackMock?.trigger(.willSeek, userInfo: info)
                                
                                expect(playButton.button?.imageView?.image).to(equal(playIcon))
                            }
                        }
                    }
                }
            }
        }
    }
}
