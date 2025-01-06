import Foundation

public struct NekosiaAPIModel: Decodable, Equatable {
    public let count: Int
    public let images: [NekosiaImageItemModel]

    public init(count: Int, images: [NekosiaImageItemModel]) {
        self.count = count
        self.images = images
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.count = try container.decode(Int.self, forKey: .count)
        if let image = try? NekosiaImageItemModel(from: decoder) {
            self.images = [image]
            return
        }
        self.images = try container.decode([NekosiaImageItemModel].self, forKey: .images)
    }

    enum CodingKeys: String, CodingKey {
        case count, images
    }
}

public struct NekosiaImageItemModel: Decodable, Equatable {
    public let id: String
    public let colors: NekosiaColorModel
    public let image: NekosiaImageModel
    public let metadata: NekosiaMetadataModel
    public let category: String
    public let tags: [String]
    public let rating: NekosiaRatingType
    public let anime: NekosiaAnimeModel
    public let source: NekosiaSourceModel
    public let attribution: NekosiaAttributionModel

    public init(
        id: String,
        colors: NekosiaColorModel,
        image: NekosiaImageModel,
        metadata: NekosiaMetadataModel,
        category: String,
        tags: [String],
        rating: NekosiaRatingType,
        anime: NekosiaAnimeModel,
        source: NekosiaSourceModel,
        attribution: NekosiaAttributionModel
    ) {
        self.id = id
        self.colors = colors
        self.image = image
        self.metadata = metadata
        self.category = category
        self.tags = tags
        self.rating = rating
        self.anime = anime
        self.source = source
        self.attribution = attribution
    }

}

public struct NekosiaColorModel: Decodable, Equatable {
    public let main: String
    public let palette: [String]

    public init(main: String, palette: [String]) {
        self.main = main
        self.palette = palette
    }
}

public struct NekosiaImageModel: Decodable, Equatable {
    public let original: NekosiaImageURLModel
    public let compressed: NekosiaImageURLModel

    public init(original: NekosiaImageURLModel, compressed: NekosiaImageURLModel) {
        self.original = original
        self.compressed = compressed
    }
}

public struct NekosiaImageURLModel: Decodable, Equatable {
    public let url: URL
    public let `extension`: String

    public init(url: URL, `extension`: String) {
        self.url = url
        self.`extension` = `extension`
    }
}

public struct NekosiaMetadataModel: Decodable, Equatable {
    public let original: NekosiaMetadataDataModel
    public let compressed: NekosiaMetadataDataModel

    public init(original: NekosiaMetadataDataModel, compressed: NekosiaMetadataDataModel) {
        self.original = original
        self.compressed = compressed
    }
}

public struct NekosiaMetadataDataModel: Decodable, Equatable {
    public let width: Int
    public let height: Int
    public let size: Int
    public let `extension`: String

    public init(width: Int, height: Int, size: Int, `extension`: String) {
        self.width = width
        self.height = height
        self.size = size
        self.`extension` = `extension`
    }
}

public enum NekosiaRatingType: Decodable, Equatable {
    case string(String)
    case model(NekosiaRatingModel)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
            return
        }
        let model = try container.decode(NekosiaRatingModel.self)
        self = .model(model)
    }
}

public struct NekosiaRatingModel: Decodable, Equatable {
    public let rating: String
    public let available: Bool
    public let neutral: Double
    public let drawing: Double
    public let sexy: Double
    public let porn: Double
    public let hentai: Double

    public init(
        rating: String,
        available: Bool,
        neutral: Double,
        drawing: Double,
        sexy: Double,
        porn: Double,
        hentai: Double
    ) {
        self.rating = rating
        self.available = available
        self.neutral = neutral
        self.drawing = drawing
        self.sexy = sexy
        self.porn = porn
        self.hentai = hentai
    }
}

public struct NekosiaAnimeModel: Decodable, Equatable {
    public let title: String?
    public let character: String?

    public init(title: String? = nil, character: String? = nil) {
        self.title = title
        self.character = character
    }
}

public struct NekosiaSourceModel: Decodable, Equatable {
    public let url: URL?
    public let direct: URL?

    public init(url: URL? = nil, direct: URL? = nil) {
        self.url = url
        self.direct = direct
    }
}

public struct NekosiaAttributionModel: Decodable, Equatable {
    public let artist: NekosiaArtistModel
    public let copyright: String?

    public init(artist: NekosiaArtistModel, copyright: String? = nil) {
        self.artist = artist
        self.copyright = copyright
    }
}

public struct NekosiaArtistModel: Decodable, Equatable {
    public let username: String?
    public let profile: URL?

    public init(username: String? = nil, profile: URL? = nil) {
        self.username = username
        self.profile = profile
    }
}

public struct NekosiaTagsModel: Decodable, Equatable {
    public let tags: [String]
    public let anime: [String]
    public let characters: [String]

    public init(tags: [String], anime: [String], characters: [String]) {
        self.tags = tags
        self.anime = anime
        self.characters = characters
    }
}
