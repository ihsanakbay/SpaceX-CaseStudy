//
//  LaunchListNetworkService.swift
//  SpaceXLaunch
//
//  Created by İhsan Akbay on 11.04.2025.
//

import Combine
import Foundation

protocol LaunchListNetworkServiceProtocol {
    func getAllPastLaunches() -> AnyPublisher<[Launch], NetworkRequestError>
    func getAllUpcomingLaunches() -> AnyPublisher<[Launch], NetworkRequestError>
    func queryLaunches(with request: PaginationRequest) -> AnyPublisher<QueryResponseModel, NetworkRequestError>
}

class LaunchListNetworkService: LaunchListNetworkServiceProtocol {
    func getAllPastLaunches() -> AnyPublisher<[Launch], NetworkRequestError> {
        let request = NetworkRouter.getAllPastLaunches()
        return NetworkClient.dispatch(request)
    }

    func getAllUpcomingLaunches() -> AnyPublisher<[Launch], NetworkRequestError> {
        let request = NetworkRouter.getAllUpcomingLaunches()
        return NetworkClient.dispatch(request)
    }

    func queryLaunches(with request: PaginationRequest) -> AnyPublisher<QueryResponseModel, NetworkRequestError> {
        let request = NetworkRouter.queryLaunches(body: request)
        return NetworkClient.dispatch(request)
    }
}
