//
//  InstagramDataPersistingProviding.swift
//  InstagramExcersise
//
//  Created by Peter Robert on 27.10.2022.
//

import Foundation

protocol InstagramDataPersistingProviding {
    func store(user: InstagramUser?)
    func loadExistingUser() -> InstagramUser?
}
