import Foundation

public struct NekosiaStatusModel: Decodable, Equatable {
    public let success: Bool
    public let status: Int
    public let message: String?
    public let docs: URL?
    public let release: Int?
}
