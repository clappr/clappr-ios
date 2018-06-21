import Quick
import Nimble
import AVFoundation

@testable import Clappr

class DVRPluginTests: QuickSpec {
    override func spec() {
        super.spec()

        fdescribe(".DVRPlugin") {
            
            context("when playback is live") {
                
                context("and playback triggers bufferUpdate") {
                    
                    context("and has position higher than 100") {
                        it("triggers enable dvr with true") {
                            let core = buildCore(position: 100, playbackType: .live)
                            var didHaveDvr = false
                            core.activePlayback?.on("enableDVR") { (userInfo: EventUserInfo) in
                                didHaveDvr = (userInfo?["enabled"] as? Bool) ?? false
                            }
                            
                            core.activePlayback!.trigger(Event.bufferUpdate.rawValue)
                            
                            expect(didHaveDvr).toEventually(beTrue())
                        }
                    }
                    
                    context("and has position less than 100") {
                        it("triggers enable dvr with false") {
                            let core = buildCore(position: 10, playbackType: .live)
                            var didHaveDvr = true
                            core.activePlayback?.on("enableDVR") { (userInfo: EventUserInfo) in
                                didHaveDvr = (userInfo?["enabled"] as? Bool) ?? false
                            }
                            
                            core.activePlayback!.trigger(Event.bufferUpdate.rawValue)
                            
                            expect(didHaveDvr).toEventually(beFalse())
                        }
                    }
                }
                
                context("and core triggers didChangeActivePlayback") {
                    
                    context("and has position higher than 100") {
                        
                        it("triggers enable dvr with true") {
                            let core = buildCore(position: 100, playbackType: .live)
                            var didHaveDvr = false
                            core.activePlayback!.on("enableDVR") { (userInfo: EventUserInfo) in
                                didHaveDvr = (userInfo?["enabled"] as? Bool) ?? false
                            }
                            
                            core.trigger(InternalEvent.didChangeActiveContainer.rawValue)
                            
                            expect(didHaveDvr).toEventually(beTrue())
                        }
                    }
                    
                    context("and has position less than 100") {
                        
                        it("triggers enable dvr with false") {
                            let core = buildCore(position: 10, playbackType: .live)
                            var didHaveDvr = true
                            core.activePlayback?.on("enableDVR") { (userInfo: EventUserInfo) in
                                didHaveDvr = (userInfo?["enabled"] as? Bool) ?? false
                            }
                            
                            core.trigger(InternalEvent.didChangeActiveContainer.rawValue)
                            
                            expect(didHaveDvr).toEventually(beFalse())
                        }
                    }
                }
            }
            
            context("when playback is vod") {
                
                context("and playback triggers bufferUpdate") {
                    it("triggers enable dvr with false") {
                        let core = buildCore(position: 10, playbackType: .vod)
                        var didHaveDvr = true
                        core.activePlayback?.on("enableDVR") { (userInfo: EventUserInfo) in
                            didHaveDvr = (userInfo?["enabled"] as? Bool) ?? false
                        }
                        
                        core.activePlayback!.trigger(Event.bufferUpdate.rawValue)
                        
                        expect(didHaveDvr).toEventually(beFalse())
                    }
                }
                
                context("and core triggers didChangeActivePlayback") {
                    it("triggers enable dvr with false") {
                        let core = buildCore(position: 10, playbackType: .vod)
                        var didHaveDvr = true
                        core.activePlayback?.on("enableDVR") { (userInfo: EventUserInfo) in
                            didHaveDvr = (userInfo?["enabled"] as? Bool) ?? false
                        }
                        
                        core.trigger(InternalEvent.didChangeActiveContainer.rawValue)
                        
                        expect(didHaveDvr).toEventually(beFalse())
                    }
                }
            }
            
            func buildCore(position seconds: Double, playbackType: PlaybackType) -> Core {
                
                let loader = Loader(externalPlugins: [DVRPlugin.self])
                let core = CoreStub(loader: loader)
                
                let playback = AVFoundationPlaybackStub()
                let player = AVPlayerStub()
                player.set(currentTime: CMTime(seconds: seconds, preferredTimescale: 1))
                playback.player = player
                playback.set(playbackType: playbackType)
                core.activeContainer?.playback = playback
                
                return core
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

class CoreStub: Core {
    
    override var activeContainer: Container? {
        get {
            return _container
        }
        
        set {
            _container = activeContainer
        }
    }
    
    private var _container: Container? = ContainerStub()
}

class ContainerStub: Container {
    override var playback: Playback? {
        get {
            return _playback
        }
        set {
            _playback = newValue
        }
    }
    
    private var _playback: Playback?
}
