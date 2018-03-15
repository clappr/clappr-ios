import Foundation

protocol AppStateManagerDelegate: class {
    func didChange(state: UIApplicationState)
}

class AppStateManager: NSObject {

    private weak var delegate: AppStateManagerDelegate?

    @discardableResult
    init(delegate: AppStateManagerDelegate) {
        self.delegate = delegate
        super.init()
    }

    deinit {
        stopMonitoring()
    }

    @objc func startMonitoring() {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeState), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeState), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    @objc func stopMonitoring() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    @objc private func didChangeState() {
        delegate?.didChange(state: UIApplication.shared.applicationState)
    }
}
