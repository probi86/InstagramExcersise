//
//  InstagramItemTableViewCell.swift
//  InstagramExcersise
//
//  Created by Peter Robert on 28.10.2022.
//

import UIKit
import Kingfisher
import AVFoundation

protocol InstagramItemTableViewCellDelegate: AnyObject {
    func instagramItemTableViewCellItemTapped(_ item: InstagramMediaItem)
}

class InstagramItemTableViewCell: UITableViewCell {
    
    //MARK: - IVars
    
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var delegate: InstagramItemTableViewCellDelegate?
    
    var instagramMediaItem: InstagramMediaItem? {
        didSet {
            
            mediaCollectionView.reloadData()
            
            //Update UI
            if let item = instagramMediaItem {
                captionLabel.text = item.caption
                if let d = item.date {
                    Utils.dateFormatter.dateStyle = .short
                    Utils.dateFormatter.timeStyle = .short
                    dateLabel.text = Utils.dateFormatter.string(from: d)
                } else {
                    dateLabel.text = ""
                }
                
                if let childItems = item.children?.mediaItems, childItems.count > 0 {
                    pageControl.currentPage = 0
                    pageControl.numberOfPages = childItems.count
                    pageControl.isHidden = false
                } else {
                    pageControl.isHidden = true
                }
                
            }
        }
    }
    
    //MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mediaCollectionView.dataSource = self
        mediaCollectionView.delegate = self
        mediaCollectionView.register(UINib(nibName: "InstagramItemCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "InstagramItemCollectionViewCell")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        instagramMediaItem = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let flowLayout = mediaCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = mediaCollectionView.bounds.size
        }
    }
    
    //MARK: Actions
    
    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
        mediaCollectionView.setContentOffset(
            CGPoint(
                x: CGFloat(sender.currentPage) * mediaCollectionView.frame.size.width,
                y: 0.0
            ), animated: true)
    }
    
}

extension InstagramItemTableViewCell: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }
}

extension InstagramItemTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return instagramMediaItem?.itemsToShow.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InstagramItemCollectionViewCell", for: indexPath) as! InstagramItemCollectionViewCell
        cell.instagramItem = instagramMediaItem?.itemsToShow[indexPath.row] ?? nil
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = instagramMediaItem {
            delegate?.instagramItemTableViewCellItemTapped(item)
        }
    }
    
}
