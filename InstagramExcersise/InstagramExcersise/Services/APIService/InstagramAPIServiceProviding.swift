//
//  InstagramAPIServiceProviding.swift
//  InstagramExcersise
//
//  Created by Peter Robert on 27.10.2022.
//

import Foundation

protocol InstagramAPIServiceProviding {
    func fetchInstagramUser() async throws -> InstagramUser
    func fetchInstagramUserMedia(userId: String) async throws -> InstagramMediaResponse
    func fetchMediaItem(id: String, child: Bool) async throws -> InstagramMediaItem
    func fetchMediaItemsWith(ids: [String], child: Bool) async throws -> [InstagramMediaItem]
    
    func fetchNextPageFor(paging: InstagramMediaResponsePaging) async throws -> InstagramMediaResponse?
}
