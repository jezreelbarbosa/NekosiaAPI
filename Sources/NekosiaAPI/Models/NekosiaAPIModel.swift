import Foundation

public struct NekosiaAPIModel: Decodable, Equatable {
    public let count: Int
    public let images: [NekosiaImageItemModel]

    enum CodingKeys: String, CodingKey {
        case count, images
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
}

public struct NekosiaColorModel: Decodable, Equatable {
    public let main: String
    public let palette: [String]
}

public struct NekosiaImageModel: Decodable, Equatable {
    public let original: NekosiaImageURLModel
    public let compressed: NekosiaImageURLModel
}

public struct NekosiaImageURLModel: Decodable, Equatable {
    public let url: URL
    public let `extension`: String
}

public struct NekosiaMetadataModel: Decodable, Equatable {
    public let original: NekosiaMetadataDataModel
    public let compressed: NekosiaMetadataDataModel
}

public struct NekosiaMetadataDataModel: Decodable, Equatable {
    public let width: Int
    public let height: Int
    public let size: Int
    public let `extension`: String
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
}

public struct NekosiaAnimeModel: Decodable, Equatable {
    public let title: String?
    public let character: String?
}

public struct NekosiaSourceModel: Decodable, Equatable {
    public let url: URL?
    public let direct: URL?
}

public struct NekosiaAttributionModel: Decodable, Equatable {
    public let artist: NekosiaArtistModel
    public let copyright: String?
}

public struct NekosiaArtistModel: Decodable, Equatable {
    public let username: String?
    public let profile: URL?
}
