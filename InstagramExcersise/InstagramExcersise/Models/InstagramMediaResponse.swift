//
//  InstagramUserMediaResponse.swift
//  InstagramExcersise
//
//  Created by Peter Robert on 28.10.2022.
//

import Foundation

struct InstagramMediaResponsePagingCursors: Codable, Equatable {
    var before: String
    var after: String
}

struct InstagramMediaResponsePaging: Codable, Equatable {
    var cursors: InstagramMediaResponsePagingCursors?
    var next: String?
}

struct InstagramMediaResponse: Codable, Equatable {
    var mediaItems: [InstagramMediaItem]
    var paging: InstagramMediaResponsePaging?
    
    enum CodingKeys: String, CodingKey {
        case mediaItems = "data"
        case paging
    }
}
