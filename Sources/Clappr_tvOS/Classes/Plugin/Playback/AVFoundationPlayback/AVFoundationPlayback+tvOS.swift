import AVFoundation
import AVKit

extension AVFoundationPlayback: AVPlayerViewControllerDelegate {
    public func playerViewController(_ playerViewController: AVPlayerViewController, timeToSeekAfterUserNavigatedFrom oldTime: CMTime, to targetTime: CMTime) -> CMTime {
        trigger(.willSeek)
        return targetTime
    }

    public func playerViewController(_ playerViewController: AVPlayerViewController, willResumePlaybackAfterUserNavigatedFrom oldTime: CMTime, to targetTime: CMTime) {
        trigger(.didSeek)
    }

    public func playerViewController(_ playerViewController: AVPlayerViewController, didSelect mediaSelectionOption: AVMediaSelectionOption?, in mediaSelectionGroup: AVMediaSelectionGroup) {
        guard let mediaType = mediaSelectionGroup.options.first?.mediaType else { return }

        if [.closedCaption, .subtitle].contains(mediaType) {
            selectedSubtitle = MediaOptionFactory.subtitle(from: mediaSelectionOption)
        }

        if mediaType.rawValue == AVMediaType.audio.rawValue {
            triggerMediaOptionSelectedEvent(option: selectedAudioSource, event: Event.didSelectAudio)
        }
    }
}
