//
//  PaginationRequest.swift
//  SpaceXLaunch
//
//  Created by İhsan Akbay on 12.04.2025.
//

import Foundation

struct PaginationRequest: Codable {
    let query: QueryOptions
    let options: PaginationOptions

    init(page: Int = 1, limit: Int = 20, upcoming: Bool? = nil) {
        var queryOptions = QueryOptions()
        if let upcoming = upcoming {
            queryOptions.upcoming = upcoming
        }

        self.query = queryOptions
        self.options = PaginationOptions(page: page, limit: limit)
    }
}

struct PaginationOptions: Codable {
    let page: Int
    let limit: Int
    let sort: SortOptions
    let populate: [String]

    init(page: Int, limit: Int) {
        self.page = page
        self.limit = limit
        self.sort = SortOptions(dateUnix: 1) // Sort by date ascending
        self.populate = []
    }
}

struct QueryOptions: Codable {
    var upcoming: Bool?

    init(upcoming: Bool? = nil) {
        self.upcoming = upcoming
    }
}

struct SortOptions: Codable {
    let dateUnix: Int

    enum CodingKeys: String, CodingKey {
        case dateUnix = "date_unix"
    }
}
