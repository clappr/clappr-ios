public class NoOpPlayback: Playback {
    private var errorLabel = UILabel(frame: CGRectZero)
    
    public override var pluginName: String {
        return "NoOp"
    }
    
    public required init(options: Options) {
        super.init(options: options)
        setupLabel("Could not play video")
        self.trigger(.Ready)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public required init() {
        super.init()
    }
    
    public override class func canPlay(options: Options) -> Bool {
        return true
    }
    
    public override func render() {
        addSubviewMatchingConstraints(errorLabel)
        trigger(.Ready)
    }
    
    private func setupLabel(text: String) {
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.text = text
        errorLabel.textAlignment = .Center
        errorLabel.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        errorLabel.textColor = UIColor.whiteColor()
    }
}