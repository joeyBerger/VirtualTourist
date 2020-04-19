//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Joey Berger on 4/14/20.
//  Copyright © 2020 Joey Berger. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var location = ""
    let reuseIdentifier = "ImageCell"
    
    var collectionImages: [UIImageView] = [];
    
    var myImagme: UIImage = UIImage(named:"placeholder.png")!
    
    var thumbnails: [UIImage] = []
    
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    let totalThumbnails = 20
    var searchInitiated = false
    var canRemoveThumbnails = false
    var totalImagesDownloaded = 0
    
    var searchCriteria : SearchCriteria? = nil
    
    private let flickr = Flickr()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var PhotoCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    var noImagesLabel: UILabel = UILabel()
    
    var dataController: DataController!
    
    private let itemsPerRow: CGFloat = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)
        collectionView.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)
        resetThumbnails()
        setupNoImagesLabel()
        collectionView.contentInset = UIEdgeInsets(top: -50, left: 0, bottom: 0, right: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if searchCriteria != nil {
            downloadImagesReal()
            setMapPin()
            noImagesLabel.isHidden = true
        }
    }
    
    @IBAction func resetPhotos(_ sender: Any) {
        if searchCriteria != nil {
            searchCriteria?.page += 1
            downloadImagesReal()
        }
    }
    
    func setupNoImagesLabel() {
        let height: CGFloat = 40
        let testFrame = CGRect(x: 0, y: 0, width: view.frame.width/1.2, height: height)
        noImagesLabel = UILabel(frame: testFrame)
        noImagesLabel.center = CGPoint(x: view.frame.size.width/2, y: mapView.frame.maxY+height/2)
        noImagesLabel.text = "NO IMAGES TO DISPLAY"
        noImagesLabel.backgroundColor = UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
        noImagesLabel.alpha = 1
        noImagesLabel.textColor = UIColor.white
        noImagesLabel.textAlignment = .center
        self.view.addSubview(noImagesLabel)
    }
    
    func resetThumbnails() {
        thumbnails.removeAll()
        for _ in 0..<totalThumbnails {
          let imageName = "placeholder.png"
          let image = UIImage(named: imageName)
          thumbnails.append(image!)
        }
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnails.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        cell.backgroundColor = UIColor.lightGray
        cell.imageView.image = thumbnails[indexPath.item]
        
        if (cell.imageView.image?.accessibilityIdentifier) != nil {
            cell.imageView.frame = CGRect(x: 0,
                                          y: 0,
                                          width: 50,
                                          height: 50)
        } else {
            cell.imageView.frame = cell.contentView.frame
            cell.imageView.contentMode = .scaleAspectFill
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
    
    func setMapPin() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: searchCriteria!.latitude, longitude: searchCriteria!.longitude)
        let viewRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(viewRegion, animated: true)
        mapView.addAnnotations([annotation])
    }
    
    func saveImage(data: Data) {
        let imageInstance = Image(context: self.dataController.viewContext)
        imageInstance.img = data
        do {
            try self.dataController.viewContext.save()
               print("Image is saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func downloadImagesReal() {
        searchInitiated = true
        print("resetting thumbnails")
        resetThumbnails()
        canRemoveThumbnails = false
        let activityIndicator = UIActivityIndicatorView(style: .gray)
//        self.view.addSubview(activityIndicator)
        activityIndicator.frame = self.view.bounds
        activityIndicator.startAnimating()

        flickr.searchFlickrForArray(for: searchCriteria!) { searchResults in
//        self.totalImagesDownloaded = searchResults.count  //TODO: might not need
        if searchResults.count == 0 {
            DispatchQueue.main.async {
              activityIndicator.removeFromSuperview()
                self.noImagesLabel.isHidden = false
            }
        } else {
            for (i,_) in searchResults.enumerated() {
                self.flickr.downloadImageAndReturnImage(imageInfo: searchResults[i]) { image in
                    self.thumbnails[i] = image
                    if (i == searchResults.count-1) {
                      activityIndicator.removeFromSuperview()
                        self.canRemoveThumbnails = true
                    }
                    self.collectionView?.reloadData()
                }
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
