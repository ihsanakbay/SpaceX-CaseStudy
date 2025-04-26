//
//  Links.swift
//  SpaceXLaunch
//
//  Created by İhsan Akbay on 11.04.2025.
//

import Foundation

struct Links: Codable {
    let patch: Patch?
    let webcast: String?
    let youtubeId: String?

    enum CodingKeys: String, CodingKey {
        case patch
        case webcast
        case youtubeId = "youtube_id"
    }
}
