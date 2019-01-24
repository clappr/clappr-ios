extension Core {
    
    func addTapRecognizer() {
        #if os(iOS)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
        #endif
    }

    @objc func didTap() {
        trigger(InternalEvent.didTappedCore.rawValue)
    }
}
