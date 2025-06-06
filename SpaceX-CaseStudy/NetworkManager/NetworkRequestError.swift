//
//  NetworkRequestError.swift
//  SpaceXLaunch
//
//  Created by İhsan Akbay on 11.04.2025.
//

import Foundation

enum NetworkRequestError: LocalizedError, Equatable {
    case invalidRequest
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case error4xx(_ code: Int)
    case serverError
    case error5xx(_ code: Int)
    case decodingError(_ description: String)
    case urlSessionFailed(_ error: URLError)
    case timeOut
    case unknownError
    case customError(_ message: String)
}
