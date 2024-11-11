import Foundation

public struct NekosiaEndpoint: Endpointing {
    public var baseURL: String = "https://api.nekosia.cat" + "/api/v1"
    public var body: Data? = nil
    public var headers: [String : String]? = [
        "accept": "application/json",
        "Content-Type": "application/json",
        "Connection": "keep-alive",
    ]
    public var cachePolicy: URLRequest.CachePolicy = .reloadRevalidatingCacheData
    public var method: String = "GET"

    public var path: String
    public var parameters: [String : String]?

    public init(
        path: String,
        parameters: [String : String]? = nil
    ) {
        self.path = path
        self.parameters = parameters
    }
}
