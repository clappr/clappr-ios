import Quick
import Nimble

@testable import Clappr

class ArrayAppendOrReplaceTests: QuickSpec {
    override func spec() {
        describe("Array") {
            describe("#appendOrReplace") {
                it("replaces a plugin that has the same name") {
                    var array: [Plugin.Type] = [PluginA.self, PluginB.self]
                    
                    array.appendOrReplace(contentsOf: [PluginAReplace.self])
                    
                    expect(array.first).to(be(PluginB.self))
                    expect(array[1]).to(be(PluginAReplace.self))
                }
                
                it("just append if there's no equal names") {
                    var array: [Plugin.Type] = [PluginA.self]
                    
                    array.appendOrReplace(contentsOf: [PluginB.self])
                    
                    expect(array.first).to(be(PluginA.self))
                    expect(array[1]).to(be(PluginB.self))
                }
            }
        }
    }
}

class PluginA: UIContainerPlugin {
    override static var name: String {
        return "pluginA"
    }
}

class PluginB: UIContainerPlugin {
    override static var name: String {
        return "pluginB"
    }
}

class PluginAReplace: UIContainerPlugin {
    override static var name: String {
        return "pluginA"
    }
}
