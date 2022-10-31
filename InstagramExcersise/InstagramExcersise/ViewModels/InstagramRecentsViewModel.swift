//
//  InstagramRecentsViewModel.swift
//  InstagramExcersise
//
//  Created by Peter Robert on 27.10.2022.
//

import Foundation
import Combine

class InstagramRecentsViewModel {
    
    //MARK: - IVars
    
    var coordinator: InstagramCoordinator
    var dataPersistingProvider: InstagramDataPersistingProviding
    var apiServiceProvider: InstagramAPIServiceProviding
    
    @Published private(set) var user: InstagramUser? {
        didSet {
            dataPersistingProvider.store(user: user)
            morePagesAvailable = user?.media.paging?.next?.isEmpty == false
        }
    }
    @Published private(set) var loadError: Error?
    @Published private(set) var isReloading = false
    @Published private(set) var isLoadingNextPage = false
    @Published private(set) var morePagesAvailable = false
    
    private var cancellables = [AnyCancellable]()
    
    //MARK: - Lifecycle
    
    init(
        coordinator: InstagramCoordinator,
        dataPersistingProvider: InstagramDataPersistingProviding,
        apiServiceProvider: InstagramAPIServiceProviding
    ) {
        self.coordinator = coordinator
        self.dataPersistingProvider = dataPersistingProvider
        self.apiServiceProvider = apiServiceProvider
    }
    
    //MARK: - Public
    
    func loadStoredUser() {
        user = dataPersistingProvider.loadExistingUser()
    }
    
    func getRecentPosts() async {
        
        if isReloading {
            return
        }
        
        loadError = nil
        isReloading = true
        
        do {
            var user = try await apiServiceProvider.fetchInstagramUser()
            let mediaResponse = try await apiServiceProvider.fetchInstagramUserMedia(userId: user.id)
            user.media = mediaResponse
            
            self.user = user
            loadError = nil
            isReloading = false
        } catch {
            loadError = error
            isReloading = false
        }
    }
    
    func itemTapped(item: InstagramMediaItem) {
        if let urlString = item.mediaURLString {
            coordinator.showImagePreviewFor(urlString: urlString)
        }
    }
    
    func loadNextPage() async {
        if isLoadingNextPage {
            return
        }
        
        if let paging = user?.media.paging {
            isLoadingNextPage = true
            do {
                let mediaResponse = try await apiServiceProvider.fetchNextPageFor(paging: paging)
                
                try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                
                user?.media.paging = mediaResponse?.paging
                if let newItems = mediaResponse?.mediaItems {
                    user?.media.mediaItems.append(contentsOf: newItems)
                }
                
            } catch {
                print("Failed to load next page")
            }
            
            isLoadingNextPage = false
        }
    }
}
