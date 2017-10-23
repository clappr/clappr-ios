import XCTest

class DashboardViewInteractor {

    private var elements: DashboardViewElements

    var startAsFullscreen: Bool {
        didSet {
            elements.startAsFullscreen.changeTo(state: startAsFullscreen)
        }
    }

    var fullscreenControledByApp: Bool {
        didSet {
            elements.fullscreenControledByApp.changeTo(state: fullscreenControledByApp)
        }
    }

    init(app: XCUIApplication) {
        elements = DashboardViewElements(app: app)

        startAsFullscreen = true
        fullscreenControledByApp = true

        elements.startAsFullscreen.changeTo(state: true)
        elements.fullscreenControledByApp.changeTo(state: true)
    }

    func startVideo() {
        elements.playButton.tap()
    }
}

fileprivate extension XCUIElement {
    func changeTo(state newState: Bool) {
        guard let currentStateString = value as? String, let currentState = currentStateString.boolValue else { return }
        if currentState != newState {
            tap()
        }
    }
}

fileprivate extension String {
    var boolValue: Bool? {
        switch self {
        case "0":
            return false
        case "1":
            return true
        default:
            return nil
        }
    }
}
