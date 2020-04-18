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
    private let flickr = Flickr()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var PhotoCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("in viewDidLoad")
//        for _ in self.items.enumerated() {
//            let imageview: UIImageView = UIImageView(frame: CGRect(x: 25, y: 25, width: 50, height: 50));
//            let img : UIImage = UIImage(named:"placeholder.png")!
//            imageview.image = img
//            collectionImages.append(imageview)
//        }
        
        for index in 0..<20 {
           let imageName = "placeholder.png"
           let image = UIImage(named: imageName)
           thumbnails.append(image!)
         }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("location \(location)")
    }
    
    
    
    @IBAction func resetPhotos(_ sender: Any) {
        downloadImagesReal()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnails.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

//       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        cell.backgroundColor = UIColor.lightGray
        cell.imageView.image = thumbnails[indexPath.item]
//        let imageview: UIImageView = UIImageView(frame: CGRect(x: 25, y: 25, width: 50, height: 50));
//        let img = self.myImagme
//        print(self.myImagme)
//        imageview.image = img
//        print("indexPath.item \(indexPath.item)")
//        cell.contentView.addSubview(collectionImages[indexPath.item])
        
        
//        cell.imageView.image = thumbnails[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        thumbnails.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width:(collectionView.frame.width/2), height: (collectionView.frame.width/2))
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets (top: 10, left: 10, bottom: 10, right: 10)
    }
    
  func downloadImagesReal() {
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    self.view.addSubview(activityIndicator)
    activityIndicator.frame = self.view.bounds
    activityIndicator.startAnimating()
    
    
    
    flickr.searchFlickrForArray(for: "bs") { searchResults in
      print("searchResults \(searchResults)")
      
      for (i,_) in searchResults.enumerated() {
        self.flickr.downloadImageAndReturnImage(imageInfo: searchResults[i]) { image in
//            self.thumbnails.append(image)
            self.thumbnails[i] = image
            if (self.thumbnails.count == searchResults.count) {
              activityIndicator.removeFromSuperview()
            }
            self.collectionView?.reloadData()
        }
      }
    }
  }
}
