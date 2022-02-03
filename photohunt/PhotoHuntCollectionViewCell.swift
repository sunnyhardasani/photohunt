//
//  PhotoHuntCollectionViewCell.swift
//  photohunt
//
//  Created by Sunny Hardasani on 1/31/22.
//

import UIKit

class PhotoHuntCollectionViewCell: UICollectionViewCell {
        
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var onReuse: () -> Void = {}

    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
        imageView.image = nil
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
}
