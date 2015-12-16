import Haneke

public class PosterPlugin: UIContainerPlugin {
    private var poster = UIImageView(frame: CGRectZero)
    private var url: NSURL!
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init() {
        super.init(frame: CGRectZero)
        translatesAutoresizingMaskIntoConstraints = false
        userInteractionEnabled = false
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        poster.hnk_setImageFromURL(url)
    }
    
    public override func wasInstalled() {
        guard let urlString = container!.options[posterUrl] as? String  else {
            removeFromSuperview()
            return
        }
        
        url = NSURL(string: urlString)!
        addConstraints()   
    }
    
    private func addConstraints() {
        container!.addMatchingConstraints(self)
        addSubviewMatchingConstraints(poster)
    }
}