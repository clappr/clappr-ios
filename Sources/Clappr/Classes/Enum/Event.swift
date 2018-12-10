public enum Event: String {
    case didUpdateBuffer
    case didUpdatePosition
    case ready
    case stalling
    case didFindAudio
    case didFindSubtitle
    case didSelectAudio
    case didSelectSubtitle
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
    case didUpdateAirPlayStatus
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
    case willDestroy
    case didDestroy
    case willLoadSource
    case didLoadSource
    case didNotLoadSource
    case willChangePlayback
    case didChangePlayback
    case willChangeActiveContainer
    case didChangeActiveContainer
    case willChangeActivePlayback
    case didChangeActivePlayback
    case willEnterFullscreen
    case didEnterFullscreen
    case willExitFullscreen
    case didExitFullscreen
    case didUpdateDuration

    @available(*, deprecated, message: "Update to stalling")
    case stalled
    @available(*, deprecated, message: "Update to didUpdatePosition")
    case positionUpdate
    @available(*, deprecated, message: "Update to didUpdateBuffer")
    case bufferUpdate
    @available(*, deprecated, message: "Update to didUpdateAirPlayStatus")
    case airPlayStatusUpdate
    @available(*, deprecated, message: "Update to didFindSubtitle")
    case subtitleAvailable
    @available(*, deprecated, message: "Update to didFindAudio")
    case audioAvailable
    @available(*, deprecated, message: "Update to didSelectSubtitle")
    case subtitleSelected
    @available(*, deprecated, message: "Update to didSelectAudio")
    case audioSelected
    
    public static var allCases: [Event] {
        return [.didUpdateBuffer, .didUpdatePosition, .ready, .stalling, .didFindAudio, .didFindSubtitle, .didSelectAudio, .didSelectSubtitle, .disableMediaControl, .enableMediaControl, .didComplete, .willPlay, .playing, .willPause, .didPause, .willStop, .didStop, .error, .didUpdateAirPlayStatus, .requestFullscreen, .exitFullscreen, .requestPosterUpdate, .willUpdatePoster, .didUpdatePoster, .willSeek, .didSeek, .didChangeDvrStatus, .seekableUpdate, .didChangeDvrAvailability, .didUpdateOptions, .willShowMediaControl, .didShowMediaControl, .willHideMediaControl, .didHideMediaControl, .willDestroy, .didDestroy, .willLoadSource, .didLoadSource, .didNotLoadSource, .willChangePlayback, .didChangePlayback, .willChangeActivePlayback, .didChangeActivePlayback, .willChangeActiveContainer, .didChangeActiveContainer, .willEnterFullscreen, .didEnterFullscreen, .willExitFullscreen, .didExitFullscreen, .didUpdateDuration]
    }
}
