import AVFoundation
import AVKit

extension AVFoundationPlayback: AVPlayerViewControllerDelegate {
    public func playerViewController(_ playerViewController: AVPlayerViewController, timeToSeekAfterUserNavigatedFrom oldTime: CMTime, to targetTime: CMTime) -> CMTime {
        trigger(.willSeek)
        return targetTime
    }

    public func playerViewController(_ playerViewController: AVPlayerViewController, willResumePlaybackAfterUserNavigatedFrom oldTime: CMTime, to targetTime: CMTime) {
        trigger(.seek)
        trigger(.didSeek)
    }

    public func playerViewController(_ playerViewController: AVPlayerViewController, didSelect mediaSelectionOption: AVMediaSelectionOption?, in mediaSelectionGroup: AVMediaSelectionGroup) {
        guard let mediaType = mediaSelectionGroup.options.first?.mediaType else { return }
        if mediaType == AVMediaType.subtitle.rawValue {
            triggerMediaOptionSelectedEvent(option: selectedSubtitle, event: Event.subtitleSelected)
        }

        if mediaType == AVMediaType.audio.rawValue {
            triggerMediaOptionSelectedEvent(option: selectedAudioSource, event: Event.audioSelected)
        }
    }
}
