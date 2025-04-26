//
//  NetworkRequest.swift
//  SpaceXLaunch
//
//  Created by İhsan Akbay on 11.04.2025.
//

import Foundation

protocol NetworkRequest {
    var path: String { get }
    var method: HttpMethod { get }
    var contentType: String { get }
    var body: [String: Any]? { get set }
    var queryParams: [String: Any]? { get }
    var headers: [String: String]? { get }
    associatedtype ReturnType: Codable
}

extension NetworkRequest {
    var method: HttpMethod { return .get }
    var contentType: String { return "application/json" }
    var queryParams: [String: Any]? { return nil }
    var body: [String: Any]? { return nil }
    var headers: [String: String]? { return nil }

    private func requestBodyFrom(params: [String: Any]?) -> Data? {
        guard let params = params else { return nil }
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return nil
        }
        return httpBody
    }

    func addQueryItems(queryParams: [String: Any]?) -> [URLQueryItem]? {
        guard let queryParams = queryParams else {
            return nil
        }
        return queryParams.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
    }

    func asURLRequest(baseURL: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: baseURL) else { return nil }
        urlComponents.path = "\(urlComponents.path)\(path)"
        urlComponents.queryItems = addQueryItems(queryParams: queryParams)
        guard let finalURL = urlComponents.url else { return nil }
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.httpBody = requestBodyFrom(params: body)
        request.allHTTPHeaderFields = headers

        request.setValue("Bearer \(ENV.API_KEY)", forHTTPHeaderField: HTTPHeaderField.authorization.rawValue)
        request.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        request.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)

        return request
    }
}
