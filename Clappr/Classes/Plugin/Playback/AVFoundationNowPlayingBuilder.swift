import MediaPlayer
import AVFoundation

class AVFoundationNowPlayingBuilder {

    let metadata: [String: Any]

    lazy var items: [AVMutableMetadataItem] = {
        return [self.title, self.description, self.date, self.contentIdentifier, self.watchedTime].flatMap({ $0 })
    }()

    lazy var title: AVMutableMetadataItem? = {
        guard let title = self.metadata[kMetaDataTitle] as? NSString else { return nil }

        let item = AVMutableMetadataItem()
        item.identifier = AVMetadataCommonIdentifierTitle
        item.value = title
        item.extendedLanguageTag = "und"
        return item
    }()

    lazy var description: AVMutableMetadataItem? = {
        guard let description = self.metadata[kMetaDataDescription] as? NSString else { return nil }

        let item = AVMutableMetadataItem()
        item.identifier = AVMetadataCommonIdentifierDescription
        item.value = description
        item.extendedLanguageTag = "und"
        return item
    }()

    lazy var contentIdentifier: AVMutableMetadataItem? = {
        guard let contentIdentifier = self.metadata[kMetaDataContentIdentifier] as? NSString else { return nil }

        let item = AVMutableMetadataItem()
        item.identifier = MPNowPlayingInfoPropertyExternalContentIdentifier
        item.value = contentIdentifier
        item.extendedLanguageTag = "und"
        return item
    }()

    lazy var watchedTime: AVMutableMetadataItem? = {
        guard let watchedTime = self.metadata[kMetaDataWatchedTime] as? Float else { return nil }

        let item = AVMutableMetadataItem()
        item.identifier = MPNowPlayingInfoPropertyPlaybackProgress
        item.value = watchedTime as NSCopying & NSObjectProtocol
        item.extendedLanguageTag = "und"
        return item
    }()

    lazy var date: AVMutableMetadataItem? = {
        guard let date = self.metadata[kMetaDataDate] as? Date else { return nil }

        let metadataDateFormatter = DateFormatter()
        metadataDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        let item = AVMutableMetadataItem()
        item.identifier = AVMetadataCommonIdentifierCreationDate
        item.value = metadataDateFormatter.string(from: date) as NSString
        item.extendedLanguageTag = "und"
        return item
    }()

    init(metadata: [String: Any]) {
        self.metadata = metadata
    }
}
