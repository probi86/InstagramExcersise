//
//  InstagramRecentsCoordinator.swift
//  InstagramExcersise
//
//  Created by Peter Robert on 27.10.2022.
//

import UIKit
import AVKit

class InstagramCoordinator: Coordinator {
    
    //MARK: - IVars
    
    var dataPersistingProvider: InstagramDataPersistingProviding
    var apiServiceProvider: InstagramAPIServiceProviding
    static var dateFormatter = DateFormatter()
    
    //MARK: - Coordinator
    
    var parentCoordinator: Coordinator?
    
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    func start() {
        let instagramRecentsViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "InstagramRecentsViewController") as! InstagramRecentsViewController
        
        let viewModel = InstagramRecentsViewModel(
            coordinator: self,
            dataPersistingProvider: dataPersistingProvider,
            apiServiceProvider: apiServiceProvider
        )
        
        instagramRecentsViewController.viewModel = viewModel
        
        navigationController.setViewControllers([instagramRecentsViewController], animated: false)
    }
    
    //MARK: - Lifecycle
    
    init(
        navigationController: UINavigationController,
        dataPersistingProvider: InstagramDataPersistingProviding,
        apiServiceProvider: InstagramAPIServiceProviding
    ) {
        self.navigationController = navigationController
        self.dataPersistingProvider = dataPersistingProvider
        self.apiServiceProvider = apiServiceProvider
    }
    
    //MARK: - Public
    
    func showImagePreviewFor(urlString: String) {
        let imagePreviewViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController
        imagePreviewViewController.imageUrlString = urlString
        let navController = UINavigationController(rootViewController: imagePreviewViewController)
        navController.modalPresentationStyle = .fullScreen
        self.navigationController.present(navController, animated: true)
    }
    
    func showVideoPlayerFor(urlString: String) {
        if let url = URL(string: urlString) {
            let player = AVPlayer(url: url)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            
            navigationController.present(playerViewController, animated: true) {
                player.play()
            }
        }
    }
    
}
