import UIKit

class DoubleTapAnimation {
    private var backLabel = UILabel()
    private var fowardLabel = UILabel()
    private var core: Core?
    
    private var left1 = UIImageView(image: UIImage.fromName("play", for: PlayButton.self))
    private var left2 = UIImageView(image: UIImage.fromName("play", for: PlayButton.self))
    private var left3 = UIImageView(image: UIImage.fromName("play", for: PlayButton.self))
    
    private var right1 = UIImageView(image: UIImage.fromName("play", for: PlayButton.self))
    private var right2 = UIImageView(image: UIImage.fromName("play", for: PlayButton.self))
    private var right3 = UIImageView(image: UIImage.fromName("play", for: PlayButton.self))
    
    init(_ core: Core?) {
        self.core = core
        setupLabels(core)
    }
    
    func animateBackward() {
        guard let playback = core?.activePlayback,
            playback.position - 10 > 0.0 else { return }
        animateLeft()
    }
    
    func animateForward() {
        guard let playback = core?.activePlayback,
            playback.position + 10 < playback.duration else { return }
        animateRight()
    }
    
    private func animate(_ label: UILabel) {
        core?.view.bringSubview(toFront: label)
        UIView.animate(withDuration: 0.2, animations: {
            label.alpha = 1.0
            self.core?.view.layoutSubviews()
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0.6, animations: {
                label.alpha = 0.0
                self.core?.view.layoutSubviews()
            })
        })
    }
    
    private func animateRight() {
        animate(fowardLabel)
        animate(right1, delay: 0)
        animate(right2, delay: 0.2)
        animate(right3, delay: 0.4)
    }
    
    private func animateLeft() {
        animate(backLabel)
        animate(left3, delay: 0)
        animate(left2, delay: 0.2)
        animate(left1, delay: 0.4)
    }
    
    private func animate(_ image: UIImageView, delay: TimeInterval) {
        core?.view.bringSubview(toFront: image)
        UIView.animate(withDuration: 0.2, delay: delay, animations: {
            image.alpha = 1.0
            self.core?.view.layoutSubviews()
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0.15, animations: {
                image.alpha = 0.0
                self.core?.view.layoutSubviews()
            })
        })
    }
    
    private func setupLabels(_ core: Core?) {
        guard let view = core?.view else { return }
        
        setupLabel(view, label: fowardLabel, position: 1.5)
        setupLabel(view, label: backLabel, position: 0.5)
        
        left1.transform = CGAffineTransform(rotationAngle: (180.0 * .pi) / 180.0)
        left2.transform = CGAffineTransform(rotationAngle: (180.0 * .pi) / 180.0)
        left3.transform = CGAffineTransform(rotationAngle: (180.0 * .pi) / 180.0)
        
        setupImage(view, image: right1, label: fowardLabel, constX: -14)
        setupImage(view, image: right2, label: fowardLabel, constX: 0)
        setupImage(view, image: right3, label: fowardLabel, constX: 14)
        
        setupImage(view, image: left1, label: backLabel, constX: -14)
        setupImage(view, image: left2, label: backLabel, constX: 0)
        setupImage(view, image: left3, label: backLabel, constX: 14)
    }
    
    private func setupLabel(_ view: UIView, label: UILabel, position: CGFloat) {
        label.backgroundColor = UIColor(white: 0, alpha: 0.2)
        label.text = "10 segundos"
        label.addRoundedBorder(with: 4)
        label.textColor = .white
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
    
    private func setupImage(_ view: UIView, image: UIImageView, label: UILabel, constX: CGFloat) {
        image.alpha = 0.0
        
        view.addSubview(image)
        
        image.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: image,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .width,
                                              multiplier: 1,
                                              constant: 14))
        
        view.addConstraint(NSLayoutConstraint(item: image,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1,
                                              constant: 14))
        
        view.addConstraint(NSLayoutConstraint(item: image,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: label,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: constX))
        
        view.addConstraint(NSLayoutConstraint(item: image,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: label,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 36))
        
    }
}
