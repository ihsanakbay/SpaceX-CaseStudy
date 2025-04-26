//
//  Core.swift
//  SpaceXLaunch
//
//  Created by İhsan Akbay on 11.04.2025.
//

import Foundation

struct Core: Codable {
    let core: String?
    let flight: Int?
    let gridfins: Bool?
    let legs: Bool?
    let reused: Bool?

    enum CodingKeys: String, CodingKey {
        case core
        case flight
        case gridfins
        case legs
        case reused
    }
}
