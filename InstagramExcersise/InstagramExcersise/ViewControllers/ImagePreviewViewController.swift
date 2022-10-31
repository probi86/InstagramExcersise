//
//  ImagePreviewViewController.swift
//  InstagramExcersise
//
//  Created by Peter Robert on 31.10.2022.
//

import UIKit

class ImagePreviewViewController: UIViewController {
    
    //MARK: - IVars
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var imageUrlString: String?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Image Preview"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(ImagePreviewViewController.doneTapped))

        scrollView.maximumZoomScale = 4.0
        scrollView.minimumZoomScale = 1.0
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.bouncesZoom = false
        scrollView.delegate = self
        
        if let urlString = imageUrlString {
            if let url = URL(string: urlString) {
                imageView.kf.setImage(with: url, placeholder: nil, options: .optionsForFadeIn()) { [weak self] result in
                    
                    guard let self = self else {
                        return
                    }
                    
                    switch result {
                    case .success(let result):
                        self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: result.image.size.height / result.image.size.width).isActive = true
                        self.scrollView.setNeedsLayout()
                        self.scrollView.layoutIfNeeded()
                        self.scrollView.zoomScale = 1.01
                        DispatchQueue.main.async {
                            self.scrollView.setZoomScale(1.0, animated: true)
                        }
                    case .failure(let err):
                        print("Failed to fetch photo: \(err)")
                    }
                }
            }
        }
    }
    
    //MARK: - Actions
    
    @objc func doneTapped() {
        dismiss(animated: true)
    }
}

extension ImagePreviewViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
}
