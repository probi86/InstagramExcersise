//
//  InstagramItemCollectionViewCell.swift
//  InstagramExcersise
//
//  Created by Peter Robert on 30.10.2022.
//

import UIKit
import AVFoundation

class InstagramItemCollectionViewCell: UICollectionViewCell {
    
    //MARK: - IVars
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    
    var avQueuePlayer: AVQueuePlayer?
    var avPlayerLooper: AVPlayerLooper?
    var playerLayer: AVPlayerLayer?
    
    var instagramItem: InstagramMediaItem? {
        didSet {
            //Image
            if let item = instagramItem {
                if let thumbnailUrlString = item.thumbnailUrlString, let url = URL(string: thumbnailUrlString) {
                    imageView.kf.setImage(with: url, options: .optionsForFadeIn())
                } else if let imageUrlString = item.mediaURLString, let url = URL(string: imageUrlString) {
                    imageView.kf.setImage(with: url, options: .optionsForFadeIn())
                }
                
                //Video
                if item.mediaType == "VIDEO" || item.mediaType == nil,
                    let urlString = item.mediaURLString, let url = URL(string: urlString),
                    let _ = item.thumbnailUrlString
                {
                    imageView.isHidden = true
                    playButton.isHidden = false
                    let playerItem = AVPlayerItem(url: url)
                    avQueuePlayer = AVQueuePlayer(playerItem: playerItem)
                    avPlayerLooper = AVPlayerLooper(player: avQueuePlayer!, templateItem: playerItem)
                    playerLayer = AVPlayerLayer(player: avQueuePlayer!)
                    contentView.layer.insertSublayer(playerLayer!, below: playButton.layer)
                    return
                } else {
                    imageView.isHidden = false
                    playButton.isHidden = true
                }
                
            } else {
                imageView.image = nil
            }
        }
    }
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        avQueuePlayer?.pause()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        avQueuePlayer = nil
        avPlayerLooper = nil
        instagramItem = nil
    }
    
    //MARK: - Overriden
    
    override var isHighlighted: Bool {
        didSet {
            contentView.alpha = isHighlighted ? 0.5 : 1.0
        }
    }
    
    //MARK: - Actions
    
    @IBAction func playButtonTapped(_ sender: Any) {
        avQueuePlayer?.play()
        playButton.isHidden = true
    }
    
    //MARK: - Overridden
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    //MARK: - Private
    

}
