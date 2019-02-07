class SeekBubble: UIView {
    private let playImage = UIImage.fromName("play", for: PlayButton.self)
    private var label = UILabel()
    private var images: [UIImageView] = []
    
    private var parentView: UIView!
    
    var bubbleHeight = NSLayoutConstraint()
    var bubbleWidth = NSLayoutConstraint()
    var bubbleSide: SeekBubbleSide!
    
    func animate() {
        animateBubble()
        animateLabel()
        animateImages()
    }
    
    private func animateImages() {
        var delay: TimeInterval = 0
        let orderedImages = bubbleSide == .left ? images.reversed() : images
        for index in 0..<orderedImages.count {
            let image = orderedImages[index]
            animate(image, delay: delay)
            delay = delay + 0.2
        }
    }
    
    private func animateBubble() {
        parentView.bringSubview(toFront: self)
        bubbleWidth.constant = parentView.frame.width
        bubbleHeight.constant = parentView.frame.height * 1.8
        
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = 1.0
            self.addRoundedBorder(with: self.bubbleHeight.constant / 2)
            self.parentView.layoutSubviews()
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0.3, animations: {
                self.alpha = 0.0
                self.parentView.layoutSubviews()
            }, completion: { _ in
                self.bubbleHeight.constant = 0
                self.bubbleWidth.constant = 0
                self.parentView.layoutSubviews()
            })
        })
    }
    
    private func animateLabel() {
        parentView.bringSubview(toFront: label)
        UIView.animate(withDuration: 0.2, animations: {
            self.label.alpha = 1.0
            self.parentView.layoutSubviews()
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0.5, animations: {
                self.label.alpha = 0.0
                self.parentView.layoutSubviews()
            })
        })
    }
    
    private func animate(_ image: UIImageView, delay: TimeInterval) {
        parentView.bringSubview(toFront: image)
        UIView.animate(withDuration: 0.15, delay: delay, animations: {
            image.alpha = 1.0
            self.parentView.layoutSubviews()
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0.15, animations: {
                image.alpha = 0.0
                self.parentView.layoutSubviews()
            })
        })
    }
    
    func setup(within parentView: UIView, bubbleSide: SeekBubbleSide, numberOfIndicators: Int = 3) {
        self.parentView = parentView
        self.bubbleSide = bubbleSide
        parentView.clipsToBounds = true
        
        setupBubble(within: parentView, heightConstraint: &bubbleHeight, widthConstraint: &bubbleWidth, position: bubbleSide.position())
        setupLabel(parentView, position: bubbleSide.positionConstant())
        setupImages(numberOfIndicators)
    }
    
    private func setupImages(_ numberOfIndicators: Int) {
        let positionModifier: CGFloat = -14.0
        var currentPosition = positionModifier
        for _ in 0..<numberOfIndicators {
            let image = bubbleSide.image()
            setupImage(parentView, image: image, constX: currentPosition)
            currentPosition = currentPosition - positionModifier
            images.append(image)
        }
    }
    
    private func setupBubble(within view: UIView, heightConstraint: inout NSLayoutConstraint, widthConstraint: inout NSLayoutConstraint, position: NSLayoutAttribute) {
        
        backgroundColor = UIColor(white: 0, alpha: 0.2)
        view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .centerY,
                                              multiplier: 1,
                                              constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: self,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: position,
                                              multiplier: 1,
                                              constant: 0))
        
        widthConstraint = NSLayoutConstraint(item: self,
                                             attribute: .width,
                                             relatedBy: .equal,
                                             toItem: nil,
                                             attribute: .width,
                                             multiplier: 1,
                                             constant: 0)
        
        heightConstraint = NSLayoutConstraint(item: self,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1,
                                              constant: 0)
        
        let constraints = [widthConstraint, heightConstraint]
        constraints.forEach { $0.isActive = true }
        self.addConstraints(constraints)
    }
    
    private func setupLabel(_ view: UIView, position: CGFloat) {
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
    
    private func setupImage(_ view: UIView, image: UIImageView, constX: CGFloat) {
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
