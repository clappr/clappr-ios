import UIKit

public class QuickSeekMediaControlPlugin: QuickSeekPlugin {
    
    open class override var name: String {
        return "QuickSeekMediaControlPlugin"
    }
    
    private var mediaControl: MediaControl? {
        return core?.plugins.first(where: { $0.pluginName == MediaControl.name }) as? MediaControl
    }
    
    override func removeGesture() {
        guard let doubleTapGesture = doubleTapGesture else { return }
        
        mediaControl?.mediaControlView.removeGestureRecognizer(doubleTapGesture)
    }
    
    override func addGesture() {
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        doubleTapGesture.numberOfTapsRequired = 2
        
        mediaControl?.tapGesture?.require(toFail: doubleTapGesture)
        mediaControl?.mediaControlView.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc private func didTap(gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            let point = gestureRecognizer.location(in: mediaControl?.mediaControlView)
            if shouldSeek(point: point) {
                mediaControl?.hide()
                quickSeek(xPosition: point.x)
            }
        }
    }
    
    private func filteredOutPlugins() -> [UICorePlugin]? {
        let pluginsWithoutMediaControl = core?.plugins.filter({ $0.pluginName != MediaControl.name })
        
        return pluginsWithoutMediaControl?
            .compactMap({ $0 as? UICorePlugin })
            .filter({ ($0 as? MediaControl.Element)?.panel != .modal
                && !$0.isKind(of: OverlayPlugin.self) })
    }
    
    override func shouldSeek(point: CGPoint) -> Bool {
        guard let mediaControlView = mediaControl?.mediaControlView else { return false }
        
        let pluginColidingWithGesture = filteredOutPlugins()?.first(where: {
            $0.view.alpha != 0.0 && $0.view.point(inside: mediaControlView.convert(point, to: $0.view), with: nil)
        })
        
        return pluginColidingWithGesture == nil
    }
}
