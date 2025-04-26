//
//  Launch.swift
//  SpaceXLaunch
//
//  Created by İhsan Akbay on 11.04.2025.
//

import Foundation

struct Launch: Codable {
    let links: Links?
    let net: Bool?
    let launchpad: String?
    let flightNumber: Int?
    let name: String?
    let dateUtc: String?
    let dateUnix: Int?
    let dateLocal: String?
    let datePrecision: String?
    let upcoming: Bool?
    let cores: [Core]?
    let autoUpdate: Bool?
    let tbd: Bool?
    let launchLibraryId: String?
    let id: String?

    enum CodingKeys: String, CodingKey {
        case links
        case net
        case launchpad
        case flightNumber = "flight_number"
        case name
        case dateUtc = "date_utc"
        case dateUnix = "date_unix"
        case dateLocal = "date_local"
        case datePrecision = "date_precision"
        case upcoming
        case cores
        case autoUpdate = "auto_update"
        case tbd
        case launchLibraryId = "launch_library_id"
        case id
    }
}
