import MediaPlayer
import AVKit
import AVFoundation

struct AVFoundationNowPlayingBuilder {

    struct Keys {
        static var contentIdentifier: String {
            if #available(tvOS 10.1, *) {
                return AVKitMetadataIdentifierExternalContentIdentifier
            } else {
                return "NPI/_MPNowPlayingInfoPropertyExternalContentIdentifier"
            }
        }

        static var playbackProgress: String {
            if #available(tvOS 10.1, *) {
                return AVKitMetadataIdentifierPlaybackProgress
            } else {
                return "NPI/_MPNowPlayingInfoPropertyPlaybackProgress"
            }
        }
    }

    let metadata: [String: Any]

    init(metadata: [String: Any] = [:]) {
        self.metadata = metadata
    }

    func getContentIdentifier() -> AVMutableMetadataItem? {
        guard let contentIdentifier = self.metadata[kMetaDataContentIdentifier] as? NSString else { return nil }
        return generateItem(for: Keys.contentIdentifier, with: contentIdentifier)
    }

    func getWatchedTime() -> AVMutableMetadataItem? {
        guard let watchedTime = self.metadata[kMetaDataWatchedTime] as? (NSCopying & NSObjectProtocol) else { return nil }
        return generateItem(for: Keys.playbackProgress, with: watchedTime)
    }

    func getTitle() -> AVMutableMetadataItem? {
        guard let title = self.metadata[kMetaDataTitle] as? NSString else { return nil }
        return generateItem(for: AVMetadataIdentifier.commonIdentifierTitle.rawValue, with: title)
    }

    func getDescription() -> AVMutableMetadataItem? {
        guard let description = self.metadata[kMetaDataDescription] as? NSString else { return nil }
        return generateItem(for: AVMetadataIdentifier.commonIdentifierDescription.rawValue, with: description)
    }

    func getDate() -> AVMutableMetadataItem? {
        guard let date = self.metadata[kMetaDataDate] as? Date else { return nil }

        let metadataDateFormatter = DateFormatter()
        metadataDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let value = metadataDateFormatter.string(from: date) as NSString

        return generateItem(for: AVMetadataIdentifier.commonIdentifierCreationDate.rawValue, with: value)
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
        guard let data = image.jpegData(compressionQuality: 1) as (NSCopying & NSObjectProtocol)? else { return nil }
        let item = generateItem(for: AVMetadataIdentifier.commonIdentifierArtwork.rawValue, with: data)
        item.dataType = kCMMetadataBaseDataType_JPEG as String
        return item
    }

    func generateItem(for identifier: String, with value: (NSCopying & NSObjectProtocol)?) -> AVMutableMetadataItem {
        let item = AVMutableMetadataItem()
        item.identifier = AVMetadataIdentifier(rawValue: identifier)
        item.value = value
        item.extendedLanguageTag = "und"
        return item
    }

    func build() -> [AVMetadataItem] {
        return [getTitle(), getDescription(), getDate(), getContentIdentifier(), getWatchedTime()].compactMap({ $0 })
    }
}
