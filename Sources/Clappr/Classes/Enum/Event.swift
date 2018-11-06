public enum Event: String, CaseIterable {
    case bufferUpdate
    case positionUpdate
    case ready
    case stalled
    case audioAvailable
    case subtitleAvailable
    case audioSelected
    case subtitleSelected
    case disableMediaControl
    case enableMediaControl
    case didComplete
    case willPlay
    case playing
    case willPause
    case didPause
    case willStop
    case didStop
    case error
    case airPlayStatusUpdate
    case requestFullscreen
    case exitFullscreen
    case requestPosterUpdate
    case willUpdatePoster
    case didUpdatePoster
    case willSeek
    case didSeek
    case didChangeDvrStatus
    case seekableUpdate
    case didChangeDvrAvailability
    case didUpdateOptions
    case willShowMediaControl
    case didShowMediaControl
    case willHideMediaControl
    case didHideMediaControl
    @available(*, deprecated, message: "Update to willSeek")
    case seek
}
