class SeekBubble: UIView {
    private var label = UILabel()
    private var images: [UIImageView] = []
    private var text: String!
    
    private weak var parentView: UIView!
    
    var bubbleHeight = NSLayoutConstraint()
    var bubbleWidth = NSLayoutConstraint()
    var bubbleSide: SeekBubbleSide!
    
    func setup(within parentView: UIView, bubbleSide: SeekBubbleSide, text: String = "10 segundos", numberOfIndicators: Int = 3) {
        self.parentView = parentView
        self.bubbleSide = bubbleSide
        self.text = text
        parentView.clipsToBounds = true
        
        setupBubble(within: parentView, position: bubbleSide.position())
        setupLabel(parentView, position: bubbleSide.positionConstant())
        setupImages(numberOfIndicators)
    }
    
    func animate() {
        animateBubble()
        animateLabel()
        animateImages()
    }
    
    private func animateBubble() {
        parentView.bringSubviewToFront(self)
        bubbleWidth.constant = parentView.frame.width
        bubbleHeight.constant = parentView.frame.height * 1.8
        
        UIView.animate(withDuration: ClapprAnimationDuration.seekBubbleShow, animations: {
            self.alpha = 1.0
            self.addRoundedBorder(with: self.bubbleHeight.constant / 2)
            self.parentView.layoutSubviews()
        }, completion: { _ in
            UIView.animate(withDuration: ClapprAnimationDuration.seekBubbleHide, delay: ClapprAnimationDuration.seekBubbleVisibility, animations: {
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
        parentView.bringSubviewToFront(label)
        UIView.animate(withDuration: ClapprAnimationDuration.seekLabelShow, animations: {
            self.label.alpha = 1.0
            self.parentView.layoutSubviews()
        }, completion: { _ in
            UIView.animate(withDuration: ClapprAnimationDuration.seekLabelHide, delay: ClapprAnimationDuration.seekLabelVisibility, animations: {
                self.label.alpha = 0.0
                self.parentView.layoutSubviews()
            })
        })
    }
    
    private func animateImages() {
        var delay: TimeInterval = 0
        let orderedImages = bubbleSide == .left ? images.reversed() : images
        for index in 0..<orderedImages.count {
            let image = orderedImages[index]
            animate(image, delay: delay)
            delay += 0.2
        }
    }
    
    private func animate(_ image: UIImageView, delay: TimeInterval) {
        parentView.bringSubviewToFront(image)
        UIView.animate(withDuration: ClapprAnimationDuration.seekImageShow, delay: delay, animations: {
            image.alpha = 1.0
            self.parentView.layoutSubviews()
        }, completion: { _ in
            UIView.animate(withDuration: ClapprAnimationDuration.seekImageHide, delay: ClapprAnimationDuration.seekImageVisibility, animations: {
                image.alpha = 0.0
                self.parentView.layoutSubviews()
            })
        })
    }
    
    private func setupImages(_ numberOfIndicators: Int) {
        let positionModifier: CGFloat = -14.0
        var currentPosition = positionModifier
        for _ in 0..<numberOfIndicators {
            let image = bubbleSide.image()
            setupImage(parentView, image: image, constX: currentPosition)
            currentPosition -= positionModifier
            images.append(image)
        }
    }
    
    private func setupBubble(within view: UIView, position: NSLayoutConstraint.Attribute) {
        
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
        
        bubbleWidth = NSLayoutConstraint(item: self,
                                             attribute: .width,
                                             relatedBy: .equal,
                                             toItem: nil,
                                             attribute: .width,
                                             multiplier: 1,
                                             constant: 0)
        
        bubbleHeight = NSLayoutConstraint(item: self,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1,
                                              constant: 0)
        
        let constraints = [bubbleWidth, bubbleHeight]
        constraints.forEach { $0.isActive = true }
        self.addConstraints(constraints)
    }
    
    private func setupLabel(_ view: UIView, position: CGFloat) {
        label.text = text
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
