import MediaPlayer
import AVKit
import AVFoundation

class AVFoundationNowPlayingBuilder {

    let metadata: [String: Any]
    internal(set) lazy var items: [AVMutableMetadataItem] = {
        return [self.getTitle(), self.getDescription(), self.getDate(), self.getContentIdentifier(), self.getWatchedTime()].flatMap({ $0 })
    }()

    var contentIdentifierKey: String {
        if #available(tvOS 10.1, *) {
            return AVKitMetadataIdentifierExternalContentIdentifier
        } else {
            return "NPI/_MPNowPlayingInfoPropertyExternalContentIdentifier"
        }
    }

    var playbackProgressKey: String {
        if #available(tvOS 10.1, *) {
            return AVKitMetadataIdentifierPlaybackProgress
        } else {
            return "NPI/_MPNowPlayingInfoPropertyPlaybackProgress"
        }
    }

    init(metadata: [String: Any] = [:]) {
        self.metadata = metadata
    }

    func getContentIdentifier() -> AVMutableMetadataItem? {
        guard let contentIdentifier = self.metadata[kMetaDataContentIdentifier] as? NSString else { return nil }
        return generateItem(for: contentIdentifierKey, with: contentIdentifier)
    }

    func getWatchedTime() -> AVMutableMetadataItem? {
        guard let watchedTime = self.metadata[kMetaDataWatchedTime] as? (NSCopying & NSObjectProtocol) else { return nil }
        return generateItem(for: playbackProgressKey, with: watchedTime)
    }

    func getTitle() -> AVMutableMetadataItem? {
        guard let title = self.metadata[kMetaDataTitle] as? NSString else { return nil }
        return generateItem(for: AVMetadataCommonIdentifierTitle, with: title)
    }

    func getDescription() -> AVMutableMetadataItem? {
        guard let description = self.metadata[kMetaDataDescription] as? NSString else { return nil }
        return generateItem(for: AVMetadataCommonIdentifierDescription, with: description)
    }

    func getDate() -> AVMutableMetadataItem? {
        guard let date = self.metadata[kMetaDataDate] as? Date else { return nil }

        let metadataDateFormatter = DateFormatter()
        metadataDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let value = metadataDateFormatter.string(from: date) as NSString

        return generateItem(for: AVMetadataCommonIdentifierCreationDate, with: value)
    }

    func getArtwork(with options: Options, completion: @escaping (AVMutableMetadataItem?) -> Void) {
        if let image = metadata[kMetaDataArtwork] as? UIImage {
            completion(getArtwork(with: image))
        } else if let poster = options[kPosterUrl] as? String, let url = URL(string: poster) {
            let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    completion(self.getArtwork(with: image))
                } else {
                    completion(nil)
                }
            }
            task.resume()
        }
    }

    func getArtwork(with image: UIImage) -> AVMutableMetadataItem? {
        guard let data = UIImageJPEGRepresentation(image, 1) as (NSCopying & NSObjectProtocol)? else { return nil }
        let item = generateItem(for: AVMetadataCommonIdentifierArtwork, with: data)
        item.dataType = kCMMetadataBaseDataType_JPEG as String
        return item
    }

    func generateItem(for identifier: String, with value: (NSCopying & NSObjectProtocol)?) -> AVMutableMetadataItem {
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value
        item.extendedLanguageTag = "und"
        return item
    }
}
