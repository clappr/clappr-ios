class MediaControlView: UIView {
    @IBOutlet weak var contrastView: UIView!

    @IBOutlet weak var topPanel: UIView!
    @IBOutlet weak var centerPanel: UIView!
    @IBOutlet weak var bottomPanel: UIView!
    @IBOutlet weak var modalPanel: UIStackView!

    @IBOutlet weak var topLeft: UIStackView!
    @IBOutlet weak var topRight: UIStackView!
    @IBOutlet weak var topNone: UIStackView!

    @IBOutlet weak var centerLeft: UIStackView!
    @IBOutlet weak var centerRight: UIStackView!
    @IBOutlet weak var centerNone: UIView!

    @IBOutlet weak var bottomLeft: UIStackView!
    @IBOutlet weak var bottomRight: UIStackView!
    @IBOutlet weak var bottomNone: UIStackView!

    @IBOutlet weak var topPadding: NSLayoutConstraint!
    @IBOutlet weak var bottomPadding: NSLayoutConstraint?

    var panels: [MediaControlPanel: [MediaControlPosition: UIStackView]] {
        return [
            .top: [
                .left: topLeft,
                .right: topRight,
                .none: topNone
            ],
            .center: [
                .left: centerLeft,
                .right: centerRight
            ],
            .bottom: [
                .left: bottomLeft,
                .right: bottomRight,
                .none: bottomNone
            ],
            .modal: [
                .left: modalPanel,
                .right: modalPanel,
                .none: modalPanel
            ]
        ]
    }

    func addSubview(_ view: UIView, in panel: MediaControlPanel, at position: MediaControlPosition) {
        if position == .center {
            addSubviewAndCenter(view, in: panel)
        } else if panel == .center && position == .none {
            centerNone.addSubview(view)
        } else {
            panels[panel]![position]?.addArrangedSubview(view)
        }
    }

    private func addSubviewAndCenter(_ view: UIView, in panel: MediaControlPanel) {
        switch panel {
        case .top:
            topPanel.addSubview(view)
        case .center:
            centerPanel.addSubview(view)
        case .bottom:
            bottomPanel.addSubview(view)
        case .modal:
            modalPanel.addArrangedSubview(view)
        }
        view.anchorInCenter()
    }
}
