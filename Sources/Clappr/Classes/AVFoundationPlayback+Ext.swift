import AVFoundation

extension AVFoundationPlayback {
    public func getBitrate() -> Double? {
        guard let logEvent = lastLogEvent() else { return nil }
        if (logEvent.segmentsDownloadedDuration ) > 0 {
            return logEvent.indicatedBitrate
        }
        return logEvent.observedBitrate
    }

    public func getAvgBitrate() -> Double? {
        guard let logEvent = lastLogEvent() else { return nil }
        return logEvent.averageVideoBitrate
    }

    private func lastLogEvent() -> AVPlayerItemAccessLogEvent? {
        return player?.currentItem?.accessLog()?.events.last
    }
}

public extension Playback {
    func waitVideoAssetLoad(then completion: @escaping () -> Void) {
        if let playback = self as? AVFoundationPlayback {
            playback.player?.currentItem?.asset.wait(for: AVAssetProperty.allCases, then: completion)
        } else {
            completion()
        }
    }

    func wait(for keypath: PartialKeyPath<Playback>, then completion: @escaping () -> Void) {
        if let playback = self as? AVFoundationPlayback, let property = Playback.waitKeypaths[keypath] {
            playback.player?.currentItem?.asset.wait(for: property, then: completion)
        } else {
            completion()
        }
    }

    private static let  waitKeypaths: [PartialKeyPath<Playback>: AVAssetProperty]  = [
            \Playback.playbackType: AVAssetProperty.duration,
            \Playback.duration: AVAssetProperty.duration,
            \Playback.position: AVAssetProperty.duration,
            \Playback.isDvrAvailable: AVAssetProperty.duration,
            \Playback.isDvrInUse: AVAssetProperty.duration,
            \Playback.canPause: AVAssetProperty.duration,
            \Playback.audioSources: AVAssetProperty.characteristics,
            \Playback.subtitles: AVAssetProperty.characteristics,
            \Playback.selectedAudioSource: AVAssetProperty.characteristics,
            \Playback.selectedSubtitle: AVAssetProperty.characteristics,
        ]
}
