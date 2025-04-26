//
//  LaunchDetailNetworkService.swift
//  SpaceXLaunch
//
//  Created by İhsan Akbay on 11.04.2025.
//

import Combine
import Foundation

protocol LaunchDetailNetworkServiceProtocol {
    func getDetail(id: String) -> AnyPublisher<Launch, NetworkRequestError>
}

class LaunchDetailNetworkService: LaunchDetailNetworkServiceProtocol {
    func getDetail(id: String) -> AnyPublisher<Launch, NetworkRequestError> {
        let request = NetworkRouter.getLaunch(id: id)
        return NetworkClient.dispatch(request)
    }
}
