import Haneke

public class PosterPlugin: UIContainerPlugin {
    private var poster = UIImageView(frame: CGRectZero)
    private var url: NSURL!
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init() {
        super.init(frame: CGRectZero)
        userInteractionEnabled = false
    }
    
    public override func wasInstalled() {
        guard let urlString = container!.options[posterUrl] as? String  else {
            removeFromSuperview()
            return
        }
        
        url = NSURL(string: urlString)!
        addConstraints()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        poster.hnk_setImageFromURL(url)
    }
    
    private func addConstraints() {
        removeFromSuperview()
        container!.addSubviewMatchingConstraints(self)
        addSubviewMatchingConstraints(poster)
    }
}