import UIKit

class DoubleTapAnimation {
    private var backLabel = UILabel()
    private var fowardLabel = UILabel()
    private var core: Core?
    
    init(_ core: Core?) {
        self.core = core
        setupLabels(core)
    }
    
    func animateBackward() {
        guard let playback = core?.activePlayback,
            playback.position - 10 > 0.0 else { return }
        animate(backLabel)
    }
    
    func animateForward() {
        guard let playback = core?.activePlayback,
            playback.position + 10 < playback.duration else { return }
        animate(fowardLabel)
    }
    
    private func animate(_ label: UILabel) {
        core?.view.bringSubview(toFront: label)
        UIView.animate(withDuration: 0.2, animations: {
            label.alpha = 1.0
            self.core?.view.layoutSubviews()
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0.5, animations: {
                label.alpha = 0.0
                self.core?.view.layoutSubviews()
            })
        })
    }
    
    private func setupLabels(_ core: Core?) {
        guard let view = core?.view else { return }
        
        setupLabel(view, label: fowardLabel, position: 1.5, text: "10 segundos >>>")
        setupLabel(view, label: backLabel, position: 0.5, text: "<<< 10 segundos")
    }
    
    private func setupLabel(_ view: UIView, label: UILabel, position: CGFloat, text: String) {
        label.backgroundColor = UIColor(white: 0, alpha: 0.2)
        label.addRoundedBorder(with: 4)
        label.textColor = .white
        label.text = text
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.alpha = 0.0
        
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: label,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .width,
                                              multiplier: 1,
                                              constant: 128))
        
        view.addConstraint(NSLayoutConstraint(item: label,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1,
                                              constant: 32))
        
        view.addConstraint(NSLayoutConstraint(item: label,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .centerX,
                                              multiplier: position,
                                              constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: label,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .centerY,
                                              multiplier: 1,
                                              constant: 0))
    }
}
