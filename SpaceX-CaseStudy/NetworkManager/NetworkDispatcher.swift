//
//  NetworkDispatcher.swift
//  SpaceXLaunch
//
//  Created by İhsan Akbay on 11.04.2025.
//

import Combine
import Foundation
import os

struct NetworkDispatcher {
    let urlSession: URLSession
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "network")

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func dispatch<ReturnType: Codable>(request: URLRequest) -> AnyPublisher<ReturnType, NetworkRequestError> {
        logger.info("[\(request.httpMethod?.uppercased() ?? "")] '\(request.url!)'")
        return urlSession
            .dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .tryMap { data, response in
                guard let response = response as? HTTPURLResponse else {
                    throw httpError(0)
                }

                logger.log("[\(response.statusCode)] '\(request.url!)'")

                if !(200...299).contains(response.statusCode) {
                    throw httpError(response.statusCode)
                }
                return data
            }
            .receive(on: DispatchQueue.main)
            .decode(type: ReturnType.self, decoder: JSONDecoder())
            .mapError { error in
                logger.error("\(error)'")
                return handleError(error)
            }
            .eraseToAnyPublisher()
    }

    private func httpError(_ statusCode: Int) -> NetworkRequestError {
        switch statusCode {
        case 400: return .badRequest
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 402, 405...499: return .error4xx(statusCode)
        case 500: return .serverError
        case 501...599: return .error5xx(statusCode)
        default: return .unknownError
        }
    }

    private func handleError(_ error: Error) -> NetworkRequestError {
        switch error {
        case is Swift.DecodingError:
            return .decodingError(error.localizedDescription)
        case let urlError as URLError:
            return .urlSessionFailed(urlError)
        case let error as NetworkRequestError:
            return error
        default:
            return .unknownError
        }
    }
}
