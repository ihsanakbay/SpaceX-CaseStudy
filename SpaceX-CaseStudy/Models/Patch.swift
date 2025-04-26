//
//  Patch.swift
//  SpaceXLaunch
//
//  Created by İhsan Akbay on 11.04.2025.
//

import Foundation

struct Patch: Codable {
    let small: String?
    let large: String?

    enum CodingKeys: String, CodingKey {
        case small
        case large
    }
}
