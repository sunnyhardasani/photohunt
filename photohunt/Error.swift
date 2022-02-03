//
//  Error.swift
//  photohunt
//
//  Created by Sunny Hardasani on 1/31/22.
//

import Foundation

enum APIError: Error {
    case invalidData
    case badAuthorization
    case unknown
    case urlRequestError
    case emptyResponse
}
