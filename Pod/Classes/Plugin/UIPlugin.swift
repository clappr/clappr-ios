public class UIPlugin: UIBaseObject {
    public var enabled = true {
        didSet {
            hidden = !enabled
            if !enabled {
                stopListening()
            }
        }
    }
}