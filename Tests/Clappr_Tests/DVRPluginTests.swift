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
            
            context("when playback is live") {
                
                context("and playback triggers bufferUpdate") {
                    
                    context("and has position higher than 100") {
                        it("triggers enable dvr with true") {
                            let dvrPlugin = buildPlugin(position: 100, playbackType: .live)
                            var didHaveDvr = false
                            dvrPlugin.core?.activePlayback?.on("enableDVR") { (userInfo: EventUserInfo) in
                                didHaveDvr = (userInfo?["enabled"] as? Bool) ?? false
                            }
                            
                            dvrPlugin.core?.activePlayback?.trigger(Event.bufferUpdate.rawValue)
                            
                            expect(didHaveDvr).toEventually(beTrue())
                        }
                    }
                    
                    context("and has position less than 100") {
                        it("triggers enable dvr with false") {
                            let plugin = buildPlugin(position: 10, playbackType: .live)
                            var didHaveDvr = true
                            plugin.core?.activePlayback?.on("enableDVR") { (userInfo: EventUserInfo) in
                                didHaveDvr = (userInfo?["enabled"] as? Bool) ?? false
                            }
                            
                            plugin.core?.activePlayback?.trigger(Event.bufferUpdate.rawValue)
                            
                            expect(didHaveDvr).toEventually(beFalse())
                        }
                    }
                }
                
                context("and core triggers didChangeActivePlayback") {
                    
                    context("and has position higher than 100") {
                        
                        it("triggers enable dvr with true") {
                            let plugin = buildPlugin(position: 100, playbackType: .live)
                            var didHaveDvr = false
                            plugin.core?.activePlayback?.on("enableDVR") { (userInfo: EventUserInfo) in
                                didHaveDvr = (userInfo?["enabled"] as? Bool) ?? false
                            }
                            
                            plugin.core?.trigger(InternalEvent.didChangeActiveContainer.rawValue)
                            
                            expect(didHaveDvr).toEventually(beTrue())
                        }
                    }
                    
                    context("and has position less than 100") {
                        
                        it("triggers enable dvr with false") {
                            let plugin = buildPlugin(position: 10, playbackType: .live)
                            var didHaveDvr = true
                            plugin.core?.activePlayback?.on("enableDVR") { (userInfo: EventUserInfo) in
                                didHaveDvr = (userInfo?["enabled"] as? Bool) ?? false
                            }
                            
                            plugin.core?.trigger(InternalEvent.didChangeActiveContainer.rawValue)
                            
                            expect(didHaveDvr).toEventually(beFalse())
                        }
                    }
                }
            }
            
            context("when playback is vod") {
                
                context("and playback triggers bufferUpdate") {
                    it("triggers enable dvr with false") {
                        let plugin = buildPlugin(position: 10, playbackType: .vod)
                        var didHaveDvr = true
                        plugin.core?.activePlayback?.on("enableDVR") { (userInfo: EventUserInfo) in
                            didHaveDvr = (userInfo?["enabled"] as? Bool) ?? false
                        }
                        
                        plugin.core?.activePlayback?.trigger(Event.bufferUpdate.rawValue)
                        
                        expect(didHaveDvr).toEventually(beFalse())
                    }
                }
                
                context("and core triggers didChangeActivePlayback") {
                    it("triggers enable dvr with false") {
                        let plugin = buildPlugin(position: 10, playbackType: .vod)
                        var didHaveDvr = true
                        plugin.core?.activePlayback?.on("enableDVR") { (userInfo: EventUserInfo) in
                            didHaveDvr = (userInfo?["enabled"] as? Bool) ?? false
                        }
                        
                        plugin.core?.trigger(InternalEvent.didChangeActiveContainer.rawValue)
                        
                        expect(didHaveDvr).toEventually(beFalse())
                    }
                }
            }
            
            func buildPlugin(position seconds: Double, playbackType: PlaybackType) -> DVRPlugin {
                core = Core()
                container = Container()
                core.activeContainer = container
                
                let playback = AVFoundationPlaybackStub()
                let player = AVPlayerStub()
                player.set(currentTime: CMTime(seconds: seconds, preferredTimescale: 1))
                playback.player = player
                playback.set(playbackType: playbackType)
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
    
    private var _playbackType: PlaybackType = .vod
    
    func set(playbackType: PlaybackType) {
        _playbackType = playbackType
    }
}
