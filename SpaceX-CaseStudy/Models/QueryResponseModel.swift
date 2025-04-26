//
//  QueryResponseModel.swift
//  SpaceXLaunch
//
//  Created by İhsan Akbay on 12.04.2025.
//

import Foundation

struct QueryResponseModel: Codable {
    let docs: [Launch]?
    let totalDocs: Int?
    let limit: Int?
    let totalPages: Int?
    let page: Int?
    let pagingCounter: Int?
    let hasPrevPage: Bool?
    let hasNextPage: Bool?
    let prevPage: Int?
    let nextPage: Int?

    enum CodingKeys: String, CodingKey {
        case docs
        case totalDocs
        case limit
        case totalPages
        case page
        case pagingCounter
        case hasPrevPage
        case hasNextPage
        case prevPage
        case nextPage
    }
}
