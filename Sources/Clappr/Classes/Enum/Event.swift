public enum Event: String, CaseIterable {
    case didUpdateBuffer
    case didUpdatePosition
    case ready
    case stalling
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
    @available(*, deprecated, message: "Update to stalling")
    case stalled
    @available(*, deprecated, message: "Update to didUpdatePosition")
    case positionUpdate
    @available(*, deprecated, message: "Update to didUpdateBuffer")
    case bufferUpdate
}
