public enum ClapprEvent: String {
    case Ready = "clappr:playback:ready"
    case Ended = "clappr:playback:ended"
    case Play = "clappr:playback:play"
    case Pause = "clappr:playback:pause"
    case Error = "clappr:playback:error"
    case Stop = "clappr:playback:stop"
    case MediaControlShow = "clappr:core:mediacontrol:show"
    case MediaControlHide = "clappr:core:mediacontrol:hide"
    case EnterFullscreen = "player:enterfullscreen"
    case ExitFullscreen = "player:exitfullscreen"
}