import Foundation

internal typealias DispatcherResponse = (data: Data, response: HTTPURLResponse)
internal typealias DispatcherCompletion = (Result<DispatcherResponse, NekosiaAPIError>) -> Void

internal protocol Dispatching {
    @available(iOS 13, macOS 10.15, *) func call(endpoint: Endpointing) async throws -> DispatcherResponse
    @discardableResult func call(endpoint: Endpointing, completion: @escaping DispatcherCompletion) -> URLSessionDataTask?
}

internal final class Dispatcher: Dispatching {
    // Propeties

    internal let urlSession: URLSession

    internal init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    // Functions

    @available(iOS 13, macOS 10.15, *)
    internal func call(endpoint: Endpointing) async throws -> DispatcherResponse {
        return try await withCheckedThrowingContinuation { continuation in
            call(endpoint: endpoint) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    @discardableResult
    internal func call(endpoint: Endpointing, completion: @escaping DispatcherCompletion) -> URLSessionDataTask? {
        guard let request = makeURLRequest(endpoint: endpoint) else {
            completion(.failure(.urlError))
            return nil
        }

        let task = makeDataTask(request: request, completion: completion)
        task.resume()
        return task
    }

    internal func makeURLRequest(endpoint: Endpointing) -> URLRequest? {
        let fullPath = endpoint.baseURL + endpoint.path + joinedParameters(from: endpoint.parameters)
        guard let urlString = fullPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: urlString)
        else { return nil }

        var request = URLRequest(url: url, cachePolicy: endpoint.cachePolicy)
        request.httpMethod = endpoint.method
        request.httpBody = endpoint.body
        if let headers = endpoint.headers {
            headers.forEach { header in
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        return request
    }

    internal func makeDataTask(request: URLRequest, completion: @escaping DispatcherCompletion) -> URLSessionDataTask {
        urlSession.dataTask(with: request) { [weak self] data, response, error in
            self?.handle(data: data, response: response, error: error, completion: completion)
        }
    }

    internal func handle(data: Data?, response: URLResponse?, error: Error?, completion: @escaping DispatcherCompletion) {
        if let error = error {
            completion(.failure(.requestError(data, response, error)))
            return
        }

        guard let data = data, let response = response as? HTTPURLResponse else {
            completion(.failure(.unknowError(data, response, error)))
            return
        }

        switch response.statusCode {
        case 200...299:
            completion(.success((data, response)))
        case 300...399:
            completion(.success((data, response)))
        case 400...499:
            completion(.failure(.clientError(data, response)))
        case 500...599:
            completion(.failure(.serverError(data, response)))
        default:
            completion(.failure(.unknowError(data, response, error)))
        }
    }

    internal func joinedParameters(from parameters: [String: Any]?) -> String {
        guard let parameters = parameters else { return "" }
        return "?" + parameters.map({ $0.key + "=" + "\($0.value)" }).joined(separator: "&")
    }
}
