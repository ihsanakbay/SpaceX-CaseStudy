//
//  NetworkRouter.swift
//  SpaceXLaunch
//
//  Created by İhsan Akbay on 11.04.2025.
//

import Foundation

class NetworkRouter {
    struct getAllPastLaunches: NetworkRequest {
        typealias ReturnType = [Launch]
        var path: String = "/v5/launches/past"
        var method: HttpMethod = .get
        var body: [String : Any]?
        var queryParams: [String : Any]?
    }

    struct getAllUpcomingLaunches: NetworkRequest {
        typealias ReturnType = [Launch]
        var path: String = "/v5/launches/upcoming"
        var method: HttpMethod = .get
        var body: [String : Any]?
        var queryParams: [String : Any]?
    }

    struct queryLaunches: NetworkRequest {
        typealias ReturnType = QueryResponseModel
        var path: String = "/v5/launches/query"
        var method: HttpMethod = .post
        var body: [String : Any]?
        var queryParams: [String : Any]?

        init(body: PaginationRequest) {
            self.body = body.asDictionary
        }
    }

    struct getLaunch: NetworkRequest {
        typealias ReturnType = Launch
        var path: String
        var method: HttpMethod = .get
        var body: [String : Any]?
        var queryParams: [String : Any]?

        init(id: String) {
            self.path = "/v5/launches/\(id)"
        }
    }
}
