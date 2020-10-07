@testable import Clappr

class UICorePluginStub: UICorePlugin {
    var didCallRender = false

    override class var name: String { "UICorePluginStub" }
    override func bindEvents() { }

    override func render() {
        didCallRender = true
    }
}
