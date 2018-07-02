import Quick
import Nimble
import AVFoundation

@testable import Clappr

class DVRPluginTests: QuickSpec {
    
    var container: Container!
    var core: Core!
    
    override func spec() {
        super.spec()

        describe(".DVRPlugin") {
            
            describe("#minDvrSize") {
                it("returns 60") {
                    let plugin = DVRPlugin()
                    
                    expect(plugin.minDvrSize).to(equal(60))
                }
            }
            
            context("when the activeContainer triggers didChangePlayback") {
                it("triggers detectDVR event") {
                    let dvrPlugin = buildPlugin(duration: getMinDvrSize(), playbackType: .live)
                    var didTriggerDetectDvr = false
                    var expectedDuration: Double?
                    dvrPlugin.core?.activePlayback?.on(InternalEvent.detectDVR.rawValue) { (userInfo: EventUserInfo) in
                        didTriggerDetectDvr = true
                        expectedDuration = userInfo?["duration"] as? Double
                    }
                    
                    dvrPlugin.core?.activeContainer?.trigger(InternalEvent.didChangePlayback.rawValue)
                    
                    expect(didTriggerDetectDvr).toEventually(beTrue())
                    expect(expectedDuration).toEventually(equal(getMinDvrSize()))
                }
            }
            
            context("when playback is live") {
                
                context("and playback triggers bufferUpdate") {
                    
                    context("and has position higher or equal than minDvrSize") {
                        it("triggers detectDVR with enabled true") {
                            let dvrPlugin = buildPlugin(duration: getMinDvrSize(), playbackType: .live)
                            var didHaveDvr = false
                            var expectedDuration: Double?
                            dvrPlugin.core?.activePlayback?.on(InternalEvent.detectDVR.rawValue) { (userInfo: EventUserInfo) in
                                didHaveDvr = (userInfo?["dvrEnabled"] as? Bool) ?? false
                                expectedDuration = userInfo?["duration"] as? Double
                            }
                            
                            dvrPlugin.core?.activePlayback?.trigger(Event.bufferUpdate.rawValue)
                            
                            expect(didHaveDvr).toEventually(beTrue())
                            expect(expectedDuration).toEventually(equal(getMinDvrSize()))
                        }
                    }
                    
                    context("and has position less than minDvrSize") {
                        it("triggers detectDVR with enabled false") {
                            let duration = getMinDvrSize() - 10
                            let plugin = buildPlugin(duration: getMinDvrSize() - 10, playbackType: .live)
                            var didHaveDvr = true
                            var expectedDuration: Double?
                            plugin.core?.activePlayback?.on(InternalEvent.detectDVR.rawValue) { (userInfo: EventUserInfo) in
                                didHaveDvr = (userInfo?["dvrEnabled"] as? Bool) ?? false
                                expectedDuration = userInfo?["duration"] as? Double
                            }
                            
                            plugin.core?.activePlayback?.trigger(Event.bufferUpdate.rawValue)
                            
                            expect(didHaveDvr).toEventually(beFalse())
                            expect(expectedDuration).toEventually(equal(duration))
                        }
                    }
                    
                    context("and has position less than current time") {
                        it("triggers dvrUsage with enabled true") {
                            let dvrPlugin = buildPlugin(duration: getMinDvrSize(),position: -10, playbackType: .live)
                            var didTriggerUsingDVR = false
                            var expectedUsingDvr: Bool? = false
                            dvrPlugin.core?.activePlayback?.on(InternalEvent.usingDVR.rawValue) { (userInfo: EventUserInfo) in
                                didTriggerUsingDVR = true
                                expectedUsingDvr = userInfo?["dvrUsage"] as? Bool
                            }
                            
                            dvrPlugin.core?.activePlayback?.trigger(Event.didSeek.rawValue)

                            expect(didTriggerUsingDVR).toEventually(beTrue())
                            expect(expectedUsingDvr).toEventually(beTrue())
                        }
                    }
                    context("and has position more or equal to the current time") {
                        it("triggers dvrUsage with enabled false") {
                            let dvrPlugin = buildPlugin(duration: getMinDvrSize(),position: 60, playbackType: .live)
                            var didTriggerUsingDVR = true
                            var expectedUsingDvr: Bool? = true
                            dvrPlugin.core?.activePlayback?.on(InternalEvent.usingDVR.rawValue) { (userInfo: EventUserInfo) in
                                didTriggerUsingDVR = true
                                expectedUsingDvr = userInfo?["dvrUsage"] as? Bool
                            }
                            
                            dvrPlugin.core?.activePlayback?.trigger(Event.didSeek.rawValue)
                            
                            expect(didTriggerUsingDVR).toEventually(beFalse())
                            expect(expectedUsingDvr).toEventually(beFalse())
                        }
                    }
                }
                
                context("and core triggers didChangeActivePlayback") {
                    
                    context("and has position higher or equal than minDvrSize") {
                        
                        it("triggers detectDVR with enabled true") {
                            let plugin = buildPlugin(duration: getMinDvrSize(), playbackType: .live)
                            var didHaveDvr = false
                            var expectedDuration: Double?
                            plugin.core?.activePlayback?.on(InternalEvent.detectDVR.rawValue) { (userInfo: EventUserInfo) in
                                didHaveDvr = (userInfo?["dvrEnabled"] as? Bool) ?? false
                                expectedDuration = userInfo?["duration"] as? Double
                            }
                            
                            plugin.core?.trigger(InternalEvent.didChangeActiveContainer.rawValue)
                            
                            expect(didHaveDvr).toEventually(beTrue())
                            expect(expectedDuration).toEventually(equal(getMinDvrSize()))
                        }
                    }
                    
                    context("and has position less than minDvrSize") {
                        
                        it("triggers detectDVR with enabled false") {
                            let duration = getMinDvrSize() - 10
                            let plugin = buildPlugin(duration: duration, playbackType: .live)
                            var didHaveDvr = true
                            var expectedDuration: Double?
                            plugin.core?.activePlayback?.on(InternalEvent.detectDVR.rawValue) { (userInfo: EventUserInfo) in
                                didHaveDvr = (userInfo?["dvrEnabled"] as? Bool) ?? false
                                expectedDuration = userInfo?["duration"] as? Double
                            }
                            
                            plugin.core?.trigger(InternalEvent.didChangeActiveContainer.rawValue)
                            
                            expect(didHaveDvr).toEventually(beFalse())
                            expect(expectedDuration).toEventually(equal(duration))
                        }
                    }
                }
            }
            
            context("when playback is vod") {
                
                context("and playback triggers bufferUpdate") {
                    it("triggers detectDVR with enabled false") {
                        let plugin = buildPlugin(duration: getMinDvrSize(), playbackType: .vod)
                        var didHaveDvr = true
                        var expectedDuration: Double?
                        plugin.core?.activePlayback?.on(InternalEvent.detectDVR.rawValue) { (userInfo: EventUserInfo) in
                            didHaveDvr = (userInfo?["dvrEnabled"] as? Bool) ?? false
                            expectedDuration = userInfo?["duration"] as? Double
                        }
                        
                        plugin.core?.activePlayback?.trigger(Event.bufferUpdate.rawValue)
                        
                        expect(didHaveDvr).toEventually(beFalse())
                        expect(expectedDuration).toEventually(equal(getMinDvrSize()))
                    }
                }
                
                context("and core triggers didChangeActivePlayback") {
                    it("triggers detectDVR with enabled false") {
                        let plugin = buildPlugin(duration: getMinDvrSize(), playbackType: .vod)
                        var didHaveDvr = true
                        var expectedDuration: Double?
                        plugin.core?.activePlayback?.on(InternalEvent.detectDVR.rawValue) { (userInfo: EventUserInfo) in
                            didHaveDvr = (userInfo?["dvrEnabled"] as? Bool) ?? false
                            expectedDuration = userInfo?["duration"] as? Double
                        }
                        
                        plugin.core?.trigger(InternalEvent.didChangeActiveContainer.rawValue)
                        
                        expect(didHaveDvr).toEventually(beFalse())
                        expect(expectedDuration).toEventually(equal(getMinDvrSize()))
                    }
                }
            }
            
            func getMinDvrSize() -> Double {
                return DVRPlugin().minDvrSize
            }
            
            func buildPlugin(duration seconds: Double, position: Double = 0, playbackType: PlaybackType) -> DVRPlugin {
                core = Core()
                container = Container()
                core.activeContainer = container
                
                let playback = AVFoundationPlaybackStub()
                let player = AVPlayerStub()
                player.set(currentTime: CMTime(seconds: seconds, preferredTimescale: 1))
                playback.player = player
                playback.set(playbackType: playbackType)
                playback.set(position: position)
                core.activeContainer?.playback = playback
                
                return DVRPlugin(context: core)
            }
        }
    }
}

class AVFoundationPlaybackStub: AVFoundationPlayback {
    override var playbackType: PlaybackType {
        return _playbackType
    }
    
    override var position: Double {
        return _position
    }
    
    private var _playbackType: PlaybackType = .vod
    private var _position: Double = 0
    
    func set(playbackType: PlaybackType) {
        _playbackType = playbackType
    }
    
    func set(position: Double) {
        _position = position
    }
}
