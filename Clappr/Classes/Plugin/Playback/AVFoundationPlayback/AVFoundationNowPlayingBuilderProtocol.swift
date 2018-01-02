import MediaPlayer
import AVKit
import AVFoundation

protocol AVFoundationNowPlayingBuilderProtocol {

    var items: [AVMetadataItem] { get }

    init(metadata: [String: Any])

    func getContentIdentifier() -> AVMutableMetadataItem?

    func getWatchedTime() -> AVMutableMetadataItem?

    func getTitle() -> AVMutableMetadataItem?

    func getDescription() -> AVMutableMetadataItem?

    func getDate() -> AVMutableMetadataItem?

    func getArtwork(with options: Options, completion: @escaping (AVMutableMetadataItem?) -> Void)

    func getArtwork(with image: UIImage) -> AVMutableMetadataItem?

    func setItems(to playerItem: AVPlayerItem, with options: Options)
}
