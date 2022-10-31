//
//  Kingfisher+Extensions.swift
//  InstagramExcersise
//
//  Created by Peter Robert on 28.10.2022.
//

import Foundation
import UIKit
import Kingfisher

extension KingfisherOptionsInfo {
    
    static func optionsForFadeIn() -> KingfisherOptionsInfo {
        return [
            .transition(.fade(0.2)),
            .loadDiskFileSynchronously
        ]
    }
    
}
