import Foundation

public enum NekosiaQueryModel: Hashable, Equatable {
    case count(Int)
    case session(String)
    case id(String)
    case additionalTags([String])
    case blacklistedTags([String])
    case rating(Rating)

    public enum Rating: String, Hashable, Equatable {
        case safe
        case questionable
    }
}

extension Set where Element == NekosiaQueryModel {
    internal var parameters: [String: String] {
        var parameters: [String: String] = [:]
        for element in self {
            switch element {
            case .count(let count):
                parameters["count"] = String(count)
            case .session(let session):
                parameters["session"] = session
            case .id(let id):
                parameters["id"] = id
            case .additionalTags(let additionalTags):
                parameters["additionalTags"] = additionalTags.joined(separator: ",")
            case .blacklistedTags(let blacklistedTags):
                parameters["blacklistedTags"] = blacklistedTags.joined(separator: ",")
            case .rating(let rating):
                parameters["rating"] = rating.rawValue
            }
        }
        return parameters
    }
}
