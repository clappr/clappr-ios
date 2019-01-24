extension Core {
    
    func addTapGestures() {
        #if os(iOS)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self

        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delegate = self
        
        tapRecognizer.require(toFail: doubleTapRecognizer)
        view.addGestureRecognizer(tapRecognizer)
        view.addGestureRecognizer(doubleTapRecognizer)
        #endif
    }

    @objc func didTap() {
        trigger(InternalEvent.didTappedCore.rawValue)
    }
    
    @objc func didDoubleTap(gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            let location = gestureRecognizer.location(in: view)
            trigger(InternalEvent.didDoubleTappedCore.rawValue, userInfo: ["viewLocation": location.x])
        }
    }
}
