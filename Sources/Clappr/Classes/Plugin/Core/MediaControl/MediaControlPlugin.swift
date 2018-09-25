protocol MediaControlPluginType {
    var panel: MediaControlPanel { get }
    var position: MediaControlPosition { get }
}

enum MediaControlPanel {
    case top
    case center
    case bottom
    case modal
}

enum MediaControlPosition {
    case left
    case center
    case right
    case none
}

class MediaControlPlugin: UICorePlugin, MediaControlPluginType {
    open var panel: MediaControlPanel {
        return .center
    }
    
    open var position: MediaControlPosition {
        return .left
    }
}
