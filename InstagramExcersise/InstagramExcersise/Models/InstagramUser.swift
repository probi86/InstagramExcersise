//
//  InstagramMeResponse.swift
//  InstagramExcersise
//
//  Created by Peter Robert on 27.10.2022.
//

import Foundation

struct InstagramUser: Codable {
    var id: String
    var username: String
    var mediaCount: Int
    var accountType: String
    var media: InstagramMediaResponse
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case mediaCount = "media_count"
        case accountType = "account_type"
        case media
    }
}
