import Foundation

public protocol NekosiaAPIServicing {
    @available(iOS 13, macOS 10.15, *) func fetchImages(category: String) async throws -> NekosiaAPIModel
    @available(iOS 13, macOS 10.15, *) func fetchShadowImages(query: Set<NekosiaQueryModel>) async throws -> NekosiaAPIModel
    @available(iOS 13, macOS 10.15, *) func fetchImages(category: String, query: Set<NekosiaQueryModel>?) async throws -> NekosiaAPIModel
    @available(iOS 13, macOS 10.15, *) func fetchById(_ id: String) async throws -> NekosiaImageItemModel

    @discardableResult func fetchImages(category: String, completion: @escaping NekosiaAPI.ImagesCompletion) -> URLSessionDataTask?
    @discardableResult func fetchShadowImages(query: Set<NekosiaQueryModel>, completion: @escaping NekosiaAPI.ImagesCompletion) -> URLSessionDataTask?
    @discardableResult func fetchImages(category: String, query: Set<NekosiaQueryModel>?, completion: @escaping NekosiaAPI.ImagesCompletion) -> URLSessionDataTask?
    @discardableResult func fetchById(_ id: String, completion: @escaping NekosiaAPI.ImageCompletion) -> URLSessionDataTask?
}

public final class NekosiaAPI: NekosiaAPIServicing {
    public typealias ImagesCompletion = (Result<NekosiaAPIModel, NekosiaAPIError>) -> Void
    public typealias ImageCompletion = (Result<NekosiaImageItemModel, NekosiaAPIError>) -> Void

    // Static Properties

    public static let shared = NekosiaAPI()

    // Class Properties

    internal let dispacher: Dispatching
    internal let jsonDecoder: JSONDecoder

    // Lifecycle

    public convenience init() {
        self.init(dispacher: Dispatcher(urlSession: URLSession.shared), jsonDecoder: JSONDecoder())
    }

    internal init(dispacher: Dispatching, jsonDecoder: JSONDecoder) {
        self.dispacher = dispacher
        self.jsonDecoder = jsonDecoder
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    // Override

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
        if let query = query, query.contains(.count(1)) {
            let image: NekosiaImageItemModel = try await makeRequest(endpoint: endpoint)
            return NekosiaAPIModel(count: 1, images: [image])
        } else {
            return try await makeRequest(endpoint: endpoint)
        }
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
        if let query = query, query.contains(.count(1)) {
            let newCompletion: ImageCompletion = { result in
                let newResult = result.map({ NekosiaAPIModel(count: 1, images: [$0]) })
                completion(newResult)
            }
            return makeRequest(endpoint: endpoint, completion: newCompletion)
        } else {
            return makeRequest(endpoint: endpoint, completion: completion)
        }
    }

    @discardableResult
    public func fetchById(_ id: String, completion: @escaping ImageCompletion) -> URLSessionDataTask? {
        let endpoint = NekosiaEndpoint(path: "/getImageById/\(id)")
        return makeRequest(endpoint: endpoint, completion: completion)
    }
}
