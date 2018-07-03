public enum InternalEvent: String {
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
    case willLoadSource
    case didLoadSource
    case didNotLoadSource
    case willDestroy
    case didDestroy
    case userRequestEnterInFullscreen
    case userRequestExitFullscreen
    case supportDVR
    case usingDVR
}
