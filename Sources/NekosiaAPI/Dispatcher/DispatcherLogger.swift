import Foundation
import os

internal protocol DispatcherLogging {
    func logRequest(_ request: URLRequest)
    func logResponse(_ response: URLResponse?, data: Data?, error: Error?)
}

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
internal final class DispatcherLogger: DispatcherLogging {
    // Properties

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DispatcherLogger",
                                category: String(reflecting: DispatcherLogger.self))

    // Log Functions

    internal func logRequest(_ request: URLRequest) {
        var logDetails = "Request: \n"
        logDetails += formatRequestMethod(request.httpMethod)
        logDetails += formatRequestURL(request.url)
        logDetails += formatRequestHeaders(request.allHTTPHeaderFields)
        logDetails += formatRequestBody(request.httpBody)
        logger.info("\(logDetails)")
    }

    internal func logResponse(_ response: URLResponse?, data: Data?, error: Error?) {
        var logDetails = "Response: \n"
        logDetails += formatResponseStatusCode(response)
        logDetails += formatResponseHeaders(response)
        logDetails += formatResponseData(data)
        logDetails += formatResponseError(error)
        logger.info("\(logDetails)")
    }

    // Format Functions

    private func formatRequestMethod(_ method: String?) -> String {
        guard let method = method else { return "" }
        return "HTTP Method: \(method)\n"
    }

    private func formatRequestURL(_ url: URL?) -> String {
        guard let url = url else { return "" }
        return "URL: \(url)\n"
    }

    private func formatRequestHeaders(_ headers: [String: String]?) -> String {
        guard let headers = headers else { return "" }
        return "Headers: \(headers)\n"
    }

    private func formatRequestBody(_ body: Data?) -> String {
        guard let body = formatData(body) else { return "" }
        return "Body: \(body)"
    }

    private func formatResponseStatusCode(_ response: URLResponse?) -> String {
        guard let httpResponse = response as? HTTPURLResponse else { return "" }
        return "Status Code: \(httpResponse.statusCode)\n"
    }

    private func formatResponseHeaders(_ response: URLResponse?) -> String {
        guard let httpResponse = response as? HTTPURLResponse else { return "" }
        var headerDetails: [String] = []
        for (key, value) in httpResponse.allHeaderFields {
            headerDetails.append("\"\(key)\": \(value)")
        }
        return "Headers: [" + headerDetails.joined(separator: ", ") + "]\n"
    }

    private func formatResponseData(_ data: Data?) -> String {
        return "Data:\n\(formatData(data) ?? "No Data")"
    }

    private func formatData(_ data: Data?) -> String? {
        guard let data = data else { return nil }
        let string: String?
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            string = String(data: prettyData, encoding: .utf8)
        } catch {
            string = String(data: data, encoding: .utf8)
        }
        return string ?? "\(data)"
    }

    private func formatResponseError(_ error: Error?) -> String {
        guard let error = error else { return "" }
        return "Error: \(dump(error))\n"
    }
}
