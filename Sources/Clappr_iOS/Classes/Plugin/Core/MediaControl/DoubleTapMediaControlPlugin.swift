import UIKit

public class DoubleTapMediaControlPlugin: DoubleTapPlugin {
    
    override open var pluginName: String {
        return String(describing: "DoubleTapMediaControlPlugin")
    }
    
    private var mediaControl: MediaControl? {
        return core?.plugins.first(where: { $0.pluginName == MediaControl.name }) as? MediaControl
    }
    
    override func removeDoubleTapGesture() {
        mediaControl?.mediaControlView.removeGestureRecognizer(doubleTapGesture)
    }
    
    override func addDoubleTapGesture() {
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        
        mediaControl?.tapGesture?.require(toFail: doubleTapGesture)
        mediaControl?.mediaControlView.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc private func doubleTap(gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            let point = gestureRecognizer.location(in: view)
            if shouldSeek(point: point) {
                mediaControl?.hide()
                doubleTapSeek(xPosition: point.x)
            }
        }
    }
    
    private func filteredOutModalPlugins() -> [UICorePlugin]? {
        let pluginsWithoutMediaControl = core?.plugins.filter({ $0.pluginName != MediaControl.name })
        return pluginsWithoutMediaControl?.filter({ ($0 as? MediaControlPlugin)?.panel != .modal })
    }
    
    func shouldSeek(point: CGPoint) -> Bool {
        guard let mediaControlView = mediaControl?.mediaControlView else { return false }
        
        let pluginColidingWithGesture = filteredOutModalPlugins()?.first(where: {
            $0.view.point(inside: mediaControlView.convert(point, to: $0.view), with: nil)
        })
        
        return pluginColidingWithGesture == nil
    }
}
