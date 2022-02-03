//
//  Models.swift
//  photohunt
//
//  Created by Sunny Hardasani on 1/31/22.
//

import Foundation

struct ImgurResultDataImage: Codable {
    var type: String
    var link: String
}

struct ImgurResultData : Codable {
    var images: [ImgurResultDataImage]?
}

struct ImgurResult: Codable {
    var data = [ImgurResultData]()
}
