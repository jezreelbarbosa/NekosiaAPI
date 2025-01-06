import Foundation

// MARK: -

public protocol NekosiaAPIServicing: AnyObject {
    typealias ImagesCompletion = (Result<NekosiaAPIModel, NekosiaAPIError>) -> Void
    typealias ImageCompletion = (Result<NekosiaImageItemModel, NekosiaAPIError>) -> Void
    typealias TagsCompletion = (Result<NekosiaTagsModel, NekosiaAPIError>) -> Void

    @discardableResult func fetchImages(category: String, query: Set<NekosiaQueryModel>?, completion: ImagesCompletion?) -> URLSessionDataTask?
    @discardableResult func fetchById(_ id: String, completion: ImageCompletion?) -> URLSessionDataTask?
    @discardableResult func fetchTags(completion: TagsCompletion?) -> URLSessionDataTask?
}

// MARK: -

public final class NekosiaAPI {
    // Static Properties

    public static let shared = NekosiaAPI()

    // Object Properties

    internal var dispatcher: Dispatching
    internal let jsonDecoder: JSONDecoder

    // Lifecycle

    public init() {
        var logger: DispatcherLogging? = nil
        if #available(iOS 14, macOS 11, watchOS 7, tvOS 14.0, *) {
            logger = DispatcherLogger()
        }
        let dispatcher = Dispatcher(urlSession: URLSession.shared, logger: logger)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.dispatcher = dispatcher
        self.jsonDecoder = decoder
    }

    internal init(dispatcher: Dispatching, jsonDecoder: JSONDecoder) {
        self.dispatcher = dispatcher
        self.jsonDecoder = jsonDecoder
    }

    // Make Requests

    internal typealias GenericCompletion<T> = ((Result<T, NekosiaAPIError>) -> Void)
    @discardableResult
    internal func makeRequest<T: Decodable>(endpoint: Endpointing, completion: GenericCompletion<T>?) -> URLSessionDataTask? {
        let task = dispatcher.call(endpoint: endpoint) { [weak self] result in
            guard let self = self else { return }
            let decodedResult: Result<T, NekosiaAPIError> = self.handleResult(result)
            completion?(decodedResult)
        }
        return task
    }

    // Supponting Functions

    internal func handleResult<T: Decodable>(_ result: DispatcherResult) -> Result<T, NekosiaAPIError> {
        switch result {
        case let .success((data, response)):
            do {
                let statusModel = try jsonDecoder.decode(NekosiaStatusModel.self, from: data)
                if statusModel.success {
                    let model = try jsonDecoder.decode(T.self, from: data)
                    return .success(model)
                } else {
                    return .failure(.apiMessageError(statusModel))
                }
            } catch let error {
                return .failure(.decodingError(data, response, error))
            }
        case let .failure(error):
            return .failure(error)
        }
    }
}

// MARK: - NekosiaAPIServicing Implementation

extension NekosiaAPI: NekosiaAPIServicing {
    @discardableResult
    public func fetchImages(category: String, query: Set<NekosiaQueryModel>?, completion: ImagesCompletion?) -> URLSessionDataTask? {
        let endpoint = NekosiaEndpoint(
            path: "/images/\(category)",
            parameters: query?.parameters
        )
        return makeRequest(endpoint: endpoint, completion: completion)
    }

    @discardableResult
    public func fetchById(_ id: String, completion: ImageCompletion?) -> URLSessionDataTask? {
        let endpoint = NekosiaEndpoint(path: "/getImageById/\(id)")
        return makeRequest(endpoint: endpoint, completion: completion)
    }

    @discardableResult
    public func fetchTags(completion: TagsCompletion?) -> URLSessionDataTask? {
        let endpoint = NekosiaEndpoint(path: "/tags")
        return makeRequest(endpoint: endpoint, completion: completion)
    }
}

// MARK: - Async Functions

@available(iOS 13, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public extension NekosiaAPIServicing {
    func fetchImages(category: String) async throws -> NekosiaAPIModel {
        return try await fetchImages(category: category, query: nil)
    }

    func fetchShadowImages(query: Set<NekosiaQueryModel>) async throws -> NekosiaAPIModel {
        return try await fetchImages(category: "nothing", query: query)
    }

    func fetchImages(category: String, query: Set<NekosiaQueryModel>?) async throws -> NekosiaAPIModel {
        return try await withCheckedThrowingContinuation { continuation in
            fetchImages(category: category, query: query) { result in
                switch result {
                case let .success(model):
                    continuation.resume(returning: model)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func fetchById(_ id: String) async throws -> NekosiaImageItemModel {
        return try await withCheckedThrowingContinuation { continuation in
            fetchById(id) { result in
                switch result {
                case let .success(model):
                    continuation.resume(returning: model)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func fetchTags() async throws -> NekosiaTagsModel {
        return try await withCheckedThrowingContinuation { continuation in
            fetchTags { result in
                switch result {
                case let .success(model):
                    continuation.resume(returning: model)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Completion functions

public extension NekosiaAPIServicing {
    @discardableResult
    func fetchImages(category: String, completion: ImagesCompletion?) -> URLSessionDataTask? {
        return fetchImages(category: category, query: nil, completion: completion)
    }

    @discardableResult
    func fetchShadowImages(query: Set<NekosiaQueryModel>, completion: ImagesCompletion?) -> URLSessionDataTask? {
        return fetchImages(category: "nothing", query: query, completion: completion)
    }
}

// MARK: - Double completion functions

public extension NekosiaAPIServicing {
    typealias ImagesSuccessCompletion = (_ model: NekosiaAPIModel) -> Void
    typealias ImageSuccessCompletion = (_ model: NekosiaImageItemModel) -> Void
    typealias TagsSuccessCompletion = (_ model: NekosiaTagsModel) -> Void
    typealias APIErrorCompletion = (_ error: NekosiaAPIError) -> Void

    private func completion<T, U>(s: ((T) -> Void)?, f: ((U) -> Void)?) -> (Result<T, U>) -> Void {
        return { result in
            switch result {
            case let .success(model): s?(model)
            case let .failure(error): f?(error)
            }
        }
    }

    @discardableResult
    func fetchImages(category: String,
                     onSuccess: ImagesSuccessCompletion?,
                     onFailure: APIErrorCompletion?) -> URLSessionDataTask? {
        return fetchImages(category: category, completion: completion(s: onSuccess, f: onFailure))
    }

    @discardableResult
    func fetchShadowImages(query: Set<NekosiaQueryModel>,
                           onSuccess: ImagesSuccessCompletion?,
                           onFailure: APIErrorCompletion?) -> URLSessionDataTask? {
        return fetchShadowImages(query: query, completion: completion(s: onSuccess, f: onFailure))
    }

    @discardableResult
    func fetchImages(category: String, query: Set<NekosiaQueryModel>?,
                     onSuccess: ImagesSuccessCompletion?,
                     onFailure: APIErrorCompletion?) -> URLSessionDataTask? {
        return fetchImages(category: category, query: query, completion: completion(s: onSuccess, f: onFailure))
    }

    @discardableResult
    func fetchById(_ id: String,
                   onSuccess: ImageSuccessCompletion?,
                   onFailure: APIErrorCompletion?) -> URLSessionDataTask? {
        return fetchById(id, completion: completion(s: onSuccess, f: onFailure))
    }

    @discardableResult
    func fetchTags(onSuccess: TagsSuccessCompletion?,
                   onFailure: APIErrorCompletion?) -> URLSessionDataTask? {
        return fetchTags(completion: completion(s: onSuccess, f: onFailure))
    }
}

// MARK: - Logger helper

public extension NekosiaAPIServicing {
    private var dispatcher: Dispatcher? {
        return self as? Dispatcher
    }

    var isLoggerEnabled: Bool {
        get { return dispatcher?.isLoggerEnabled ?? false }
        set { dispatcher?.isLoggerEnabled = newValue }
    }
}
