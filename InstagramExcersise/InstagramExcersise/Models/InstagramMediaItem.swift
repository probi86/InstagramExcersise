//
//  InstagramMediaItem.swift
//  InstagramExcersise
//
//  Created by Peter Robert on 28.10.2022.
//

import Foundation

struct InstagramMediaItem: Codable, Equatable {
    var id: String
    var caption: String?
    var mediaType: String?
    var mediaURLString: String?
    var thumbnailUrlString: String?
    var children: InstagramMediaResponse?
    var date: Date?
    var loadErrorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case caption
        case mediaType = "media_type"
        case mediaURLString = "media_url"
        case thumbnailUrlString = "thumbnail_url"
        case children
        case date = "timestamp"
    }
    
    var itemsToShow: [InstagramMediaItem] {
        if let childItems = children?.mediaItems, childItems.isEmpty == false {
            return childItems
        } else {
            return [self]
        }
    }
}
