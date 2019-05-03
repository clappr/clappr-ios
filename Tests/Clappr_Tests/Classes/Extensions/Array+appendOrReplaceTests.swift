import Quick
import Nimble

@testable import Clappr

class ArrayAppendOrReplaceTests: QuickSpec {
    override func spec() {
        describe("Array") {
            describe("#appendOrReplace") {
                context("plugin") {
                    it("replaces a plugin that has the same name") {
                        var array: [Plugin.Type] = [PluginA.self, PluginB.self]
                        
                        array.appendOrReplace(contentsOf: [PluginAReplace.self])
                        
                        expect(array.first).to(be(PluginB.self))
                        expect(array[1]).to(be(PluginAReplace.self))
                    }
                    
                    it("just append if there's no equal names") {
                        var array: [Plugin.Type] = [PluginA.self]
                        
                        array.appendOrReplace(contentsOf: [PluginB.self])
                        
                        expect(array.first).toEventually(be(PluginA.self))
                        expect(array[1]).toEventually(be(PluginB.self))
                    }
                }
                
                context("playback") {
                    it("replaces a playback that has the same name") {
                        var array: [Playback.Type] = [PlaybackA.self, PlaybackB.self]
                        
                        array.appendOrReplace(contentsOf: [PlaybackAReplace.self])

                        expect(array.first).toEventually(be(PlaybackB.self))
                        expect(array[1]).toEventually(be(PlaybackAReplace.self))
                    }
                    
                    it("just append if there's no equal names") {
                        var array: [Playback.Type] = [PlaybackA.self]
                        
                        array.appendOrReplace(contentsOf: [PlaybackB.self])
                        
                        expect(array.first).to(be(PlaybackA.self))
                        expect(array[1]).to(be(PlaybackB.self))
                    }
                }
            }
        }
    }
}

class PluginA: UIContainerPlugin {
    override class var name: String {
        return "pluginA"
    }
}

class PluginB: UIContainerPlugin {
    override class var name: String {
        return "pluginB"
    }
}

class PluginAReplace: UIContainerPlugin {
    override class var name: String {
        return "pluginA"
    }
}

class PlaybackA: Playback {
    override class var name: String {
        return "playbackA"
    }
}

class PlaybackB: Playback {
    override class var name: String {
        return "playbackB"
    }
}

class PlaybackAReplace: Playback {
    override class var name: String {
        return "playbackA"
    }
}
