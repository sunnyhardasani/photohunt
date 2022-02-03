//
//  PhotoHuntViewController.swift
//  photohunt
//
//  Created by Sunny Hardasani on 1/31/22.
//

import Foundation
import UIKit

enum PhotoHuntConstant {
    static let cellIdentifier = "PhotoCell"
}

class PhotoHuntViewController: UICollectionViewController {
    
    var images = [String]()
    var loader = ImageLoader()
    var client = Client()
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        title = NSLocalizedString("SEARCH_IMAGES", comment:"Search Images")
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    // rusty implementation of cleaning image cache
    override func didReceiveMemoryWarning() {
        loader.cleanCache()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // this will present the detail view on controler on the tap of the cell
    @IBSegueAction func showImage(_ coder: NSCoder, sender: Any?) -> PhotoHuntDetailsViewController? {
        guard let cell = sender as? PhotoHuntCollectionViewCell else {
            return nil
        }
        
        if let image = cell.imageView.image {
            return PhotoHuntDetailsViewController(coder: coder, image: image)
        }
        
        return nil
    }
    
    func didReceiveMemoryWarning(notification: NSNotification) {
        
    }
}

// MARK: UICollectionViewDataSource
extension PhotoHuntViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoHuntConstant.cellIdentifier, for: indexPath) as? PhotoHuntCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if indexPath.row < images.count, let url = URL(string: images[indexPath.row]) {
            
            // load cell image along with the token to
            // cancel the request if the cell is reused
            let token = loader.loadImage(url) { result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        cell.activityIndicator.stopAnimating()
                        cell.imageView.image = image
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        cell.activityIndicator.stopAnimating()
                    }
                }
            }
            
            cell.onReuse = { [weak self] in
                if let token = token {
                    self?.loader.cancelLoad(token)
                }
            }
        }    
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension PhotoHuntViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.orientation.isLandscape {
            return CGSize(width: collectionView.frame.size.width / 2, height: collectionView.frame.size.height / 2)
        } else {
            return CGSize(width: collectionView.frame.size.width / 2, height: collectionView.frame.size.height / 4)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

// MARK: UISearchBarDelegate
extension PhotoHuntViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            // clean the old set of images
            self.images = []
            
            // prepare for the new one
            client.searchImages(text) { result in
                switch result {
                case .success(let imgurResult):
                    
                    // TODO: replace with map and move to parser
                    for data in imgurResult.data {
                        if let dataImages = data.images {
                            for image in dataImages {
                                if image.type.starts(with: "image/") {
                                    self.images.append(image.link)
                                }
                            }
                        }
                    }
                    
                    // in case if the no images can be fetched show no results
                    if self.images.isEmpty {
                        DispatchQueue.main.async {
                            self.collectionView.setEmptyMessage(NSLocalizedString("NO_RESULTS", comment:"No results"))
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.collectionView.restore()
                        }
                    }
                    
                    // on refresh of the new images bring reload
                    // data and bring collection view to top
                    DispatchQueue.main.async {
                        self.collectionView.setContentOffset(.zero, animated: false)
                        self.collectionView.reloadData()
                    }
                
                case .failure(_):
                    DispatchQueue.main.async {
                        self.collectionView.setEmptyMessage(NSLocalizedString("NO_RESULTS", comment:"No results"))
                    }
                }
            }
        }
    }
}
