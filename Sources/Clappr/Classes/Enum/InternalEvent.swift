public enum InternalEvent: String {
    case userRequestEnterInFullscreen = "Clappr:userRequestEnterInFullscreen"
    case userRequestExitFullscreen = "Clappr:userRequestExitFullscreen"
    case didTappedCore = "Clappr:didTappedCore"
    case didDoubleTappedCore = "Clappr:didDoubleTappedCore"
    case willBeginScrubbing = "Clappr:willBeginScrubbing"
    case didFinishScrubbing = "Clappr:didFinishScrubbing"
}
