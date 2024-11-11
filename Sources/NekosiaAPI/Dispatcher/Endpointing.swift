import Foundation

internal protocol Endpointing {
    var baseURL: String { get }
    var path: String { get }
    var parameters: [String: String]? { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    var method: String { get }
    var body: Data? { get }
    var headers: [String: String]? { get }
}
