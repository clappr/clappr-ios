public enum InternalEvent: String {
    case userRequestEnterInFullscreen = "Clappr:userRequestEnterInFullscreen"
    case userRequestExitFullscreen = "Clappr:userRequestExitFullscreen"
    case didTappedCore = "Clappr:didTappedCore"
    case willBeginScrubbing = "Clappr:willBeginScrubbing"
    case didFinishScrubbing = "Clappr:didFinishScrubbing"
    case didQuickSeek = "Clappr:didQuickSeek"
    case didDragDrawer = "Clappr:didDragDrawer"
    case requestDestroyPlayer = "Clappr:requestDestroyPlayer"
}
