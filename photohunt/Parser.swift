//
//  Parser.swift
//  photohunt
//
//  Created by Sunny Hardasani on 1/31/22.
//

import Foundation

class Parser {
    public static func parse(_ data: Data) -> Result<ImgurResult, Error> {
        var imgurResults : ImgurResult
        
        do {
            imgurResults = try JSONDecoder().decode(ImgurResult.self, from: data)
            return .success(imgurResults)
        } catch let error {
            return .failure(error)
        }
    }
}
