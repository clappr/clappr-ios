class OrientationObserver {
    weak var core: Core?
    private var previousDeviceOrientation: UIDeviceOrientation = UIDevice.current.orientation

    init(core: Core) {
        self.core = core

        addOrientationObserver()
    }

    private func addOrientationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil)
    }

    @objc private func orientationDidChange() {
        let currentOrientation = UIDevice.current.orientation
        guard currentOrientation != previousDeviceOrientation else { return }

        let description = currentOrientation.isPortrait ? "portrait" : "landscape"
        core?.trigger(.didChangeScreenOrientation, userInfo: ["orientation": description])
        previousDeviceOrientation = currentOrientation
    }
}
