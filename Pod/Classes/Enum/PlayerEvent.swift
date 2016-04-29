public enum PlayerEvent: String {
    case Ready
    case Ended
    case Play = "clappr:player:play"
    case Pause
    case Error
    case Stop
}