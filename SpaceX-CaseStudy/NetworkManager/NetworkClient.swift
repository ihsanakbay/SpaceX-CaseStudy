//
//  NetworkClient.swift
//  SpaceXLaunch
//
//  Created by İhsan Akbay on 11.04.2025.
//

import Combine
import Foundation

struct NetworkClient {
    static var networkDispatcher: NetworkDispatcher = .init()

    static func dispatch<R: NetworkRequest>(_ request: R) -> AnyPublisher<R.ReturnType, NetworkRequestError> {
        guard let urlRequest = request.asURLRequest(baseURL: NetworkConstants.baseURL) else {
            return Fail(outputType: R.ReturnType.self, failure: NetworkRequestError.badRequest)
                .eraseToAnyPublisher()
        }
        typealias RequestPublisher = AnyPublisher<R.ReturnType, NetworkRequestError>
        let requestPublisher: RequestPublisher = networkDispatcher.dispatch(request: urlRequest)

        return requestPublisher.eraseToAnyPublisher()
    }
}
