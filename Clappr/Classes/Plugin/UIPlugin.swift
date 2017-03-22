open class UIPlugin: UIBaseObject {
    
    open var enabled = true {
        didSet {
            isHidden = !enabled
            if !enabled {
                stopListening()
            }
        }
    }
}
