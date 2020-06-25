public typealias Options = [String: Any]

public let kPosterUrl = "posterUrl"
public let kSourceUrl = "sourceUrl"
public let kFullscreen = "fullscreen"
public let kFullscreenDisabled = "fullscreenDisabled"
public let kFullscreenByApp = "fullscreenByApp"
public let kStartAt = "startAt"
public let kLiveStartTime = "liveStartTime"
public let kPlaybackNotSupportedMessage = "playbackNotSupportedMessage"
public let kMimeType = "mimeType"
public let kDefaultSubtitle = "defaultSubtitle"
public let kDefaultAudioSource = "defaultAudioSource"
public let kMinDvrSize = "minDvrSize"
public let kMediaControl = "mediaControl"
public let kMediaControlAlwaysVisible = "mediaControlAlwaysVisible"
public let kChromeless = "chromeless"

// List of MediaControl Elements
public let kMediaControlElements = "mediaControlElements"
// Order of MediaControl Elements
public let kMediaControlElementsOrder = "mediaControlElementsOrder"

public let kLoop = "loop"
public let kMetaData = "metadata"
public let kMetaDataContentIdentifier = "mdContentIdentifier"
public let kMetaDataWatchedTime = "mdWatchedTime"
public let kMetaDataTitle = "mdTitle"
public let kMetaDataDescription = "mdDescription"
public let kMetaDataDate = "mdDate"
public let kMetaDataArtwork = "mdArtwork"

struct OptionsUnboxer {
    let options: Options

    var fullscreenControledByApp: Bool { options.bool(kFullscreenByApp, orElse: false)}
    var fullscreen: Bool { options.bool(kFullscreen, orElse: false) }
    var fullscreenDisabled: Bool { options.bool(kFullscreenDisabled, orElse: false) }
}
