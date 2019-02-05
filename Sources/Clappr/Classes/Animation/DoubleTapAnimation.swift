import UIKit

class DoubleTapAnimation {
    private var backLabel = UILabel()
    private var fowardLabel = UILabel()
    private var core: Core?
    
    private let playImage = UIImage.fromName("play", for: PlayButton.self)
    
    private lazy var backIcon1 = mirrorImage(UIImageView(image: playImage))
    private lazy var backIcon2 = mirrorImage(UIImageView(image: playImage))
    private lazy var backIcon3 = mirrorImage(UIImageView(image: playImage))
    
    private lazy var fowardIcon1 = UIImageView(image: playImage)
    private lazy var fowardIcon2 = UIImageView(image: playImage)
    private lazy var fowardIcon3 = UIImageView(image: playImage)
    
    private var leftBubbleView = UIView()
    private var rightBubbleView = UIView()
    
    private var leftBubbleHeight = NSLayoutConstraint()
    private var leftBubbleWidth = NSLayoutConstraint()
    
    private var rightBubbleHeight = NSLayoutConstraint()
    private var rightBubbleWidth = NSLayoutConstraint()
    
    init(_ core: Core?) {
        self.core = core
        setup(core)
    }
    
    func animateBackward() {
        guard let playback = core?.activePlayback,
            playback.position - 10 > 0.0, let view = core?.view else { return }
        animate(leftBubbleView, parentView: view, widthConstraint: leftBubbleWidth, heightConstraint: leftBubbleHeight)
        animate(backLabel)
        animate(backIcon3, delay: 0)
        animate(backIcon2, delay: 0.2)
        animate(backIcon1, delay: 0.4)
    }
    
    func animateForward() {
        guard let playback = core?.activePlayback,
            playback.position + 10 < playback.duration,
            let view = core?.view else { return }
        animate(rightBubbleView, parentView: view, widthConstraint: rightBubbleWidth, heightConstraint: rightBubbleHeight)
        animate(fowardLabel)
        animate(fowardIcon1, delay: 0)
        animate(fowardIcon2, delay: 0.2)
        animate(fowardIcon3, delay: 0.4)
    }
    
    private func animate(_ bubbleView: UIView, parentView: UIView, widthConstraint: NSLayoutConstraint, heightConstraint: NSLayoutConstraint) {
        core?.view.bringSubview(toFront: bubbleView)
        
        widthConstraint.constant = parentView.frame.width
        heightConstraint.constant = parentView.frame.height * 1.8
        
        UIView.animate(withDuration: 0.4, animations: {
            bubbleView.alpha = 1.0
            bubbleView.addRoundedBorder(with: heightConstraint.constant / 2)
            self.core?.view.layoutSubviews()
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0.3, animations: {
                bubbleView.alpha = 0.0
                self.core?.view.layoutSubviews()
            }, completion: { _ in
                heightConstraint.constant = 0
                widthConstraint.constant = 0
                self.core?.view.layoutSubviews()
            })
        })
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
    
    private func animate(_ image: UIImageView, delay: TimeInterval) {
        core?.view.bringSubview(toFront: image)
        UIView.animate(withDuration: 0.15, delay: delay, animations: {
            image.alpha = 1.0
            self.core?.view.layoutSubviews()
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0.15, animations: {
                image.alpha = 0.0
                self.core?.view.layoutSubviews()
            })
        })
    }
    
    private func setup(_ core: Core?) {
        guard let view = core?.view else { return }
        
        view.clipsToBounds = true
        
        setupBubble(leftBubbleView, within: view, heightConstraint: &leftBubbleHeight, widthConstraint: &leftBubbleWidth, position: .leading)
        setupBubble(rightBubbleView, within: view, heightConstraint: &rightBubbleHeight, widthConstraint: &rightBubbleWidth, position: .trailing)
        
        setupLabel(view, label: fowardLabel, position: 1.5)
        setupLabel(view, label: backLabel, position: 0.5)
        
        setupImage(view, image: fowardIcon1, label: fowardLabel, constX: -14)
        setupImage(view, image: fowardIcon2, label: fowardLabel, constX: 0)
        setupImage(view, image: fowardIcon3, label: fowardLabel, constX: 14)
        
        setupImage(view, image: backIcon1, label: backLabel, constX: -14)
        setupImage(view, image: backIcon2, label: backLabel, constX: 0)
        setupImage(view, image: backIcon3, label: backLabel, constX: 14)
    }
    
    private func mirrorImage(_ view: UIImageView) -> UIImageView {
        view.transform = CGAffineTransform(rotationAngle: (180.0 * .pi) / 180.0)
        return view
    }
    
    private func setupBubble(_ bubble: UIView, within view: UIView, heightConstraint: inout NSLayoutConstraint, widthConstraint: inout NSLayoutConstraint, position: NSLayoutAttribute) {
        
        bubble.backgroundColor = UIColor(white: 0, alpha: 0.2)
        view.addSubview(bubble)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: bubble,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .centerY,
                                              multiplier: 1,
                                              constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: bubble,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: position,
                                              multiplier: 1,
                                              constant: 0))
        
        widthConstraint = NSLayoutConstraint(item: bubble,
                                             attribute: .width,
                                             relatedBy: .equal,
                                             toItem: nil,
                                             attribute: .width,
                                             multiplier: 1,
                                             constant: 0)
        
        heightConstraint = NSLayoutConstraint(item: bubble,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1,
                                              constant: 0)
        
        let constraints = [widthConstraint, heightConstraint]
        constraints.forEach { $0.isActive = true }
        bubble.addConstraints(constraints)
    }
    
    private func setupLabel(_ view: UIView, label: UILabel, position: CGFloat) {
        label.text = "10 segundos"
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
