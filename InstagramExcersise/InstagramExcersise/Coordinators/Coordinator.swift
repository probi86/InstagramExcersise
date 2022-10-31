//
//  Coordinator.swift
//  InstagramExcersise
//
//  Created by Peter Robert on 27.10.2022.
//

import UIKit

protocol Coordinator {
    var parentCoordinator: Coordinator? { get set }
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}
