public typealias Options = [String: Any]

public let kPosterUrl = "posterUrl"
public let kSourceUrl = "sourceUrl"
public let kMediaControl = "mediaControl"
public let kFullscreen = "fullscreen"
public let kFullscreenDisabled = "fullscreenDisabled"
public let kFullscreenByApp = "fullscreenByApp"
public let kStartAt = "startAt"
public let kPlaybackNotSupportedMessage = "playbackNotSupportedMessage"
public let kMimeType = "mimeType"
public let kDefaultSubtitle = "defaultSubtitle"
public let kDefaultAudioSource = "defaultAudioSource"
public let kMinDvrSize = "minDvrSize"
public let kMediaControlAlwaysVisible = "mediaControlAlwaysVisible"

// List of MediaControl Plugins
public let kMediaControlPlugins = "mediaControlPlugins"


// Disable default plugins
public let kDisableDefaultPlugins = "disableDefaultPlugins"

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

    var fullscreenControledByApp: Bool {
        return options[kFullscreenByApp] as? Bool ?? false
    }

    var fullscreen: Bool {
        return options[kFullscreen] as? Bool ?? false
    }
}
