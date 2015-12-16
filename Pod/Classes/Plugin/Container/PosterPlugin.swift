public class PosterPlugin: UIContainerPlugin {
    private var poster: UIImageView!
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init() {
        super.init(frame: CGRectZero)
    }
    
    public override func wasInstalled() {
        guard let urlString = container!.options[posterUrl] as? String else {
            removeFromSuperview()
            return
        }
        print(urlString)
        poster = UIImageView()
        addConstraints()
    }
    
    private func addConstraints() {
        container!.addMatchingConstraints(self)
        addSubviewMatchingContraints(poster)
    }
}