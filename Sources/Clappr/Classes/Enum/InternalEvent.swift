public enum InternalEvent: String {
    case userRequestEnterInFullscreen = "Clappr:userRequestEnterInFullscreen"
    case userRequestExitFullscreen = "Clappr:userRequestExitFullscreen"
    case didTappedCore = "Clappr:didTappedCore"
    case willBeginScrubbing = "Clappr:willBeginScrubbing"
    case didFinishScrubbing = "Clappr:didFinishScrubbing"
    case didTapQuickSeek = "Clappr:didTapQuickSeek"
}
