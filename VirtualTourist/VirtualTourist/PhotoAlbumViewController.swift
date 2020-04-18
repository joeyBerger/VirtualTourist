//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Joey Berger on 4/14/20.
//  Copyright © 2020 Joey Berger. All rights reserved.
//

import Foundation
import UIKit
class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var location = ""
    let reuseIdentifier = "ImageCell"
    var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    
    var collectionImages: [UIImageView] = [];
    
    var myImagme: UIImage = UIImage(named:"placeholder.png")!
    
    var thumbnails: [UIImage] = []
    
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    let totalThumbnails = 20
    var searchInitiated = false
    var canRemoveThumbnails = false
    
    var searchCriteria : SearchCriteria? = nil
    
    private let flickr = Flickr()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var PhotoCollectionView: UICollectionView!
     private let itemsPerRow: CGFloat = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetThumbnails()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if searchCriteria != nil {
            downloadImagesReal()
        }
    }
    
    @IBAction func resetPhotos(_ sender: Any) {
        searchCriteria?.page += 1
        downloadImagesReal()
    }
    
    func resetThumbnails() {
        thumbnails.removeAll()
        for _ in 0..<totalThumbnails {
          let imageName = "placeholder.png"
          let image = UIImage(named: imageName)
          thumbnails.append(image!)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnails.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        cell.backgroundColor = UIColor.lightGray
        cell.imageView.image = thumbnails[indexPath.item]
        
        if (searchInitiated) {
            cell.imageView.frame = cell.contentView.frame
            cell.imageView.contentMode = .scaleAspectFill
        } else {
            cell.imageView.frame = CGRect(x: cell.contentView.frame.width/2+50/4,
                                          y: cell.contentView.frame.height/2+50/4,
                                          width: 50,
                                          height: 50)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !canRemoveThumbnails {return}
        thumbnails.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

      let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
      let availableWidth = view.frame.width - paddingSpace
      let widthPerItem = availableWidth / itemsPerRow
      return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
      return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return sectionInsets.left
    }
    
  func downloadImagesReal() {
    searchInitiated = true
    resetThumbnails()
    canRemoveThumbnails = false
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    self.view.addSubview(activityIndicator)
    activityIndicator.frame = self.view.bounds
    activityIndicator.startAnimating()
    
    flickr.searchFlickrForArray(for: searchCriteria!) { searchResults in
      
      for (i,_) in searchResults.enumerated() {
        self.flickr.downloadImageAndReturnImage(imageInfo: searchResults[i]) { image in
            self.thumbnails[i] = image
            if (self.thumbnails.count == searchResults.count) {
              activityIndicator.removeFromSuperview()
                self.canRemoveThumbnails = true
//                self.searchInitiated = false
            }
            self.collectionView?.reloadData()
        }
      }
    }
  }
}


struct SearchCriteria {
    let latitude: Double
    let longitude: Double
    var page: Int = 1
    let perPage: Int = PhotoAlbumViewController().totalThumbnails
}
