import MediaPlayer
import AVFoundation

class AVFoundationNowPlayingBuilder {

    let extendedLanguageTag = "und"
    let metadata: [String: Any]
    internal(set) var items: [AVMutableMetadataItem] = []

    init(metadata: [String: Any]) {
        self.metadata = metadata
        items = [getTitle(), getDescription(), getDate(), getContentIdentifier(), getWatchedTime()].flatMap({ $0 })
    }

    func getContentIdentifier() -> AVMutableMetadataItem? {
        guard let contentIdentifier = self.metadata[kMetaDataContentIdentifier] as? NSString else { return nil }

        let item = AVMutableMetadataItem()
        item.identifier = MPNowPlayingInfoPropertyExternalContentIdentifier
        item.value = contentIdentifier
        item.extendedLanguageTag = extendedLanguageTag
        return item
    }

    func getWatchedTime() -> AVMutableMetadataItem? {
        guard let watchedTime = self.metadata[kMetaDataWatchedTime] as? Double else { return nil }

        let item = AVMutableMetadataItem()
        item.identifier = MPNowPlayingInfoPropertyPlaybackProgress
        item.value = NSNumber(value: watchedTime)
        item.extendedLanguageTag = extendedLanguageTag
        return item
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

    func generateItem(for identifier: String, with value: (NSCopying & NSObjectProtocol)?) -> AVMutableMetadataItem {
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value
        item.extendedLanguageTag = extendedLanguageTag
        return item
    }
}
