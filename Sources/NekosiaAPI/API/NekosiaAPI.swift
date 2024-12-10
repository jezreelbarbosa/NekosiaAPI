import Foundation

// MARK: -

public protocol NekosiaAPIServicing {
    @available(iOS 13, macOS 10.15, *) func fetchImages(category: String) async throws -> NekosiaAPIModel
    @available(iOS 13, macOS 10.15, *) func fetchShadowImages(query: Set<NekosiaQueryModel>) async throws -> NekosiaAPIModel
    @available(iOS 13, macOS 10.15, *) func fetchImages(category: String, query: Set<NekosiaQueryModel>?) async throws -> NekosiaAPIModel
    @available(iOS 13, macOS 10.15, *) func fetchById(_ id: String) async throws -> NekosiaImageItemModel

    typealias ImagesCompletion = (Result<NekosiaAPIModel, NekosiaAPIError>) -> Void
    typealias ImageCompletion = (Result<NekosiaImageItemModel, NekosiaAPIError>) -> Void

    @discardableResult func fetchImages(category: String, completion: @escaping ImagesCompletion) -> URLSessionDataTask?
    @discardableResult func fetchShadowImages(query: Set<NekosiaQueryModel>, completion: @escaping ImagesCompletion) -> URLSessionDataTask?
    @discardableResult func fetchImages(category: String, query: Set<NekosiaQueryModel>?, completion: @escaping ImagesCompletion) -> URLSessionDataTask?
    @discardableResult func fetchById(_ id: String, completion: @escaping ImageCompletion) -> URLSessionDataTask?
}

// MARK: -

public final class NekosiaAPI {
    // Static Properties

    public static let shared = NekosiaAPI()

    // Object Properties

    internal let dispacher: Dispatching
    internal let jsonDecoder: JSONDecoder

    // Lifecycle

    public init() {
        let dispacher = Dispatcher(urlSession: URLSession.shared)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.dispacher = dispacher
        self.jsonDecoder = decoder
    }

    internal init(dispacher: Dispatching, jsonDecoder: JSONDecoder) {
        self.dispacher = dispacher
        self.jsonDecoder = jsonDecoder
    }

    // Make Requests

    @available(iOS 13, macOS 10.15, *)
    internal func makeRequest<T: Decodable>(endpoint: Endpointing) async throws -> T {
        let response = try await dispacher.call(endpoint: endpoint)
        let statusModel = try jsonDecoder.decode(NekosiaStatusModel.self, from: response.data)
        guard statusModel.success else {
            throw NekosiaAPIError.apiMessageError(statusModel)
        }
        let model = try jsonDecoder.decode(T.self, from: response.data)
        return model
    }

    @discardableResult
    internal func makeRequest<T: Decodable>(endpoint: Endpointing, completion: @escaping (Result<T, NekosiaAPIError>) -> Void) -> URLSessionDataTask? {
        dispacher.call(endpoint: endpoint) { [weak jsonDecoder] result in
            guard let jsonDecoder = jsonDecoder else { return }
            switch result {
            case let .success((data, response)):
                do {
                    let statusModel = try jsonDecoder.decode(NekosiaStatusModel.self, from: data)
                    if statusModel.success {
                        let model = try jsonDecoder.decode(T.self, from: data)
                        completion(.success(model))
                    } else {
                        completion(.failure(.apiMessageError(statusModel)))
                    }
                } catch let error {
                    completion(.failure(.decodingError(data, response, error)))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: -

extension NekosiaAPI: NekosiaAPIServicing {
    // Async Functions

    @available(iOS 13, macOS 10.15, *)
    public func fetchImages(category: String) async throws -> NekosiaAPIModel {
        return try await fetchImages(category: category, query: nil)
    }

    @available(iOS 13, macOS 10.15, *)
    public func fetchShadowImages(query: Set<NekosiaQueryModel>) async throws -> NekosiaAPIModel {
        return try await fetchImages(category: "nothing", query: query)
    }

    @available(iOS 13, macOS 10.15, *)
    public func fetchImages(category: String, query: Set<NekosiaQueryModel>?) async throws -> NekosiaAPIModel {
        let endpoint = NekosiaEndpoint(
            path: "/images/\(category)",
            parameters: query?.parameters
        )
        return try await makeRequest(endpoint: endpoint)
    }

    @available(iOS 13, macOS 10.15, *)
    public func fetchById(_ id: String) async throws -> NekosiaImageItemModel {
        let endpoint = NekosiaEndpoint(path: "/getImageById/\(id)")
        return try await makeRequest(endpoint: endpoint)
    }

    // Completion Functions

    @discardableResult
    public func fetchImages(category: String, completion: @escaping ImagesCompletion) -> URLSessionDataTask? {
        return fetchImages(category: category, query: nil, completion: completion)
    }

    @discardableResult
    public func fetchShadowImages(query: Set<NekosiaQueryModel>, completion: @escaping ImagesCompletion) -> URLSessionDataTask? {
        return fetchImages(category: "nothing", query: query, completion: completion)
    }

    @discardableResult
    public func fetchImages(category: String, query: Set<NekosiaQueryModel>?, completion: @escaping ImagesCompletion) -> URLSessionDataTask? {
        let endpoint = NekosiaEndpoint(
            path: "/images/\(category)",
            parameters: query?.parameters
        )
        return makeRequest(endpoint: endpoint, completion: completion)
    }

    @discardableResult
    public func fetchById(_ id: String, completion: @escaping ImageCompletion) -> URLSessionDataTask? {
        let endpoint = NekosiaEndpoint(path: "/getImageById/\(id)")
        return makeRequest(endpoint: endpoint, completion: completion)
    }
}
