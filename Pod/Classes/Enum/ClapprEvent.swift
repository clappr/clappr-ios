public enum ClapprEvent: String {
    case Ready = "clappr:playback:ready"
    case Ended = "clappr:playback:ended"
    case Play = "clappr:playback:play"
    case Pause = "clappr:playback:pause"
    case Error = "clappr:playback:error"
    case Stop = "clappr:playback:stop"
}