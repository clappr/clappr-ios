extension UIPanGestureRecognizer {
    var translation: CGPoint {
        return translation(in: view)
    }

    var newYCoordinate: CGFloat {
        guard let view = view else { return .zero }
        return view.center.y + translation.y
    }
}
