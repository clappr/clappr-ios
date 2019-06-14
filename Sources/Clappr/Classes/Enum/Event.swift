public enum Event: String, CaseIterable {
    case didUpdateBuffer = "Clappr:didUpdateBuffer"
    case didUpdatePosition = "Clappr:didUpdatePosition"
    case ready = "Clappr:ready"
    case stalling = "Clappr:stalling"
    case didFindAudio = "Clappr:didFindAudio"
    case didFindSubtitle = "Clappr:didFindSubtitle"
    case didSelectAudio = "Clappr:didSelectAudio"
    case didSelectSubtitle = "Clappr:didSelectSubtitle"
    case disableMediaControl = "Clappr:disableMediaControl"
    case enableMediaControl = "Clappr:enableMediaControl"
    case didComplete = "Clappr:didComplete"
    case willPlay = "Clappr:willPlay"
    case playing = "Clappr:playing"
    case willPause = "Clappr:willPause"
    case didPause = "Clappr:didPause"
    case willStop = "Clappr:willStop"
    case didStop = "Clappr:didStop"
    case didLoop = "Clappr:didLoop"
    case error = "Clappr:error"
    case didUpdateAirPlayStatus = "Clappr:didUpdateAirPlayStatus"
    case requestFullscreen = "Clappr:requestFullscreen"
    case exitFullscreen = "Clappr:exitFullscreen"
    case requestPosterUpdate = "Clappr:requestPosterUpdate"
    case willUpdatePoster = "Clappr:willUpdatePoster"
    case didUpdatePoster = "Clappr:didUpdatePoster"
    case willSeek = "Clappr:willSeek"
    case didSeek = "Clappr:didSeek"
    case didChangeDvrStatus = "Clappr:didChangeDvrStatus"
    case seekableUpdate = "Clappr:seekableUpdate"
    case didChangeDvrAvailability = "Clappr:didChangeDvrAvailability"
    case didUpdateOptions = "Clappr:didUpdateOptions"
    case willShowMediaControl = "Clappr:willShowMediaControl"
    case didShowMediaControl = "Clappr:didShowMediaControl"
    case willHideMediaControl = "Clappr:willHideMediaControl"
    case didHideMediaControl = "Clappr:didHideMediaControl"
    case willDestroy = "Clappr:willDestroy"
    case didDestroy = "Clappr:didDestroy"
    case willLoadSource = "Clappr:willLoadSource"
    case didLoadSource = "Clappr:didLoadSource"
    case didNotLoadSource = "Clappr:didNotLoadSource"
    case willChangePlayback = "Clappr:willChangePlayback"
    case didChangePlayback = "Clappr:didChangePlayback"
    case willChangeActiveContainer = "Clappr:willChangeActiveContainer"
    case didChangeActiveContainer = "Clappr:didChangeActiveContainer"
    case willChangeActivePlayback = "Clappr:willChangeActivePlayback"
    case didChangeActivePlayback = "Clappr:didChangeActivePlayback"
    case willEnterFullscreen = "Clappr:willEnterFullscreen"
    case didEnterFullscreen = "Clappr:didEnterFullscreen"
    case willExitFullscreen = "Clappr:willExitFullscreen"
    case didExitFullscreen = "Clappr:didExitFullscreen"
    case didUpdateDuration = "Clappr:didUpdateDuration"
    case didShowModal = "Clappr:didShowModal"
    case didHideModal = "Clappr:didHideModal"
    case willShowModal = "Clappr:willShowModal"
    case willHideModal = "Clappr:willHideModal"
    case didResize = "Clappr:didResize"
}
