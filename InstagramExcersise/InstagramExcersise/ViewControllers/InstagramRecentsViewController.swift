//
//  InstagramRecentsViewController.swift
//  InstagramExcersise
//
//  Created by Peter Robert on 27.10.2022.
//

import UIKit
import Combine
import Kingfisher

class InstagramRecentsViewController: UIViewController {
    
    //MARK: - IVars
    
    var viewModel: InstagramRecentsViewModel?
    
    private var cancellables = [AnyCancellable]()
    
    @IBOutlet weak var recentsTableView: UITableView!
    private var refreshControl = UIRefreshControl()
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Test
        KingfisherManager.shared.cache.clearCache()
        
        recentsTableView.dataSource = self
        recentsTableView.delegate = self
        recentsTableView.addSubview(refreshControl)
        recentsTableView.register(UINib(nibName: "InstagramItemTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "InstagramItemTableViewCell")
        
        refreshControl.addTarget(self, action: #selector(tableViewRefreshed), for: UIControl.Event.valueChanged)
        
        setupBindings()

        viewModel?.loadStoredUser()
        Task { [weak self] in
            await self?.viewModel?.getRecentPosts()
        }
    }
    
    //MARK: - Actions
    
    @objc func tableViewRefreshed() {
        Task { [weak self] in
            await self?.viewModel?.getRecentPosts()
        }
    }
    
    //MARK: - Private
    
    private func setupBindings() {
        viewModel?.$user
            .receive(on: OperationQueue.main)
            .sink(receiveValue: {[weak self] user in
                self?.navigationItem.title = user?.username
                self?.recentsTableView.reloadData()
            })
            .store(in: &cancellables)
        
        viewModel?.$isReloading
            .receive(on: OperationQueue.main)
            .sink(receiveValue: { [weak self] reloading in
                
                if reloading {
                    self?.errorLabel.text = nil
                    if (self?.refreshControl.isRefreshing == false && self?.viewModel?.user?.media.mediaItems.count == 0) {
                        self?.activityIndicatorView.startAnimating()
                        self?.loadingLabel.isHidden = false
                    }
                } else {
                    if self?.viewModel?.user == nil || self?.viewModel?.user?.media.mediaItems.count == 0 {
                        self?.errorLabel.text = self?.viewModel?.loadError?.localizedDescription
                    }
                    self?.refreshControl.endRefreshing()
                    self?.activityIndicatorView.stopAnimating()
                    self?.loadingLabel.isHidden = true
                }
            })
            .store(in: &cancellables)
        
        viewModel?.$morePagesAvailable
            .receive(on: OperationQueue.main)
            .sink(receiveValue: { [weak self] available in
                if available {
                    let activityIndicatorView = UIActivityIndicatorView()
                    activityIndicatorView.frame.size.height = 50.0
                    activityIndicatorView.startAnimating()
                    self?.recentsTableView.tableFooterView = activityIndicatorView
                } else {
                    self?.recentsTableView.tableFooterView = nil
                }
            })
            .store(in: &cancellables)
    }

}

//MARK: - UIScrollViewDelegate

extension InstagramRecentsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.height > scrollView.frame.size.height && scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            Task { [weak self] in
                await self?.viewModel?.loadNextPage()
            }
        }
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate

extension InstagramRecentsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.user?.media.mediaItems.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstagramItemTableViewCell", for: indexPath) as! InstagramItemTableViewCell
        cell.instagramMediaItem = viewModel?.user?.media.mediaItems[indexPath.row]
        cell.delegate = self
        return cell
    }
}

//MARK: - InstagramItemTableViewCellDelegate

extension InstagramRecentsViewController: InstagramItemTableViewCellDelegate {
    func instagramItemTableViewCellItemTapped(_ item: InstagramMediaItem) {
        viewModel?.itemTapped(item: item)
    }
}
