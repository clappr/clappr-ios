public enum PlayerEvent: String {
    case ready = "clappr:playback:ready"
    case ended = "clappr:playback:ended"
    case play = "clappr:playback:play"
    case pause = "clappr:playback:pause"
    case error = "clappr:playback:error"
    case stop = "clappr:playback:stop"
    case mediaControlShow = "clappr:core:mediacontrol:show"
    case mediaControlHide = "clappr:core:mediacontrol:hide"
    case enterFullscreen = "player:enterfullscreen"
    case exitFullscreen = "player:exitfullscreen"
}
