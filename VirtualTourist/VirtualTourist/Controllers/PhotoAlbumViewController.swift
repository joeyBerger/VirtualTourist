//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Joey Berger on 4/14/20.
//  Copyright © 2020 Joey Berger. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let flickr = Flickr()
    var searchCriteria : SearchCriteria? = nil
    var dataController: DataController!
    var pinInfo : PinInfo? = nil
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    var thumbnails: [UIImage] = []
    var thumbnailName : [String] = []
    let thumbnailPlaceholder = "placeholder.png"
    let totalThumbnails = 20
    var canRemoveThumbnails = false
    
    let reuseIdentifier = "ImageCell"
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    private let itemsPerRow: CGFloat = 2
            
    var noImagesLabel: UILabel = UILabel()
    var storedImages: [Image] = []
    var appearedViaPin = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BackgroundColor().color
        collectionView.backgroundColor = BackgroundColor().color
        resetThumbnails()
        setupNoImagesLabel()
        collectionView.contentInset = UIEdgeInsets(top: -50, left: 0, bottom: 0, right: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (!appearedViaPin) {return}
        if searchCriteria != nil {
            //new pin dropped
            downloadImages()
            setMapPin(searchCriteria!)
            noImagesLabel.isHidden = true
        } else if pinInfo != nil  {
            //old pin referenced, retrieve data
            let fetchRequest:NSFetchRequest<Image> = Image.fetchRequest()
            let predicate = NSPredicate(format: "pinInfo == %@",pinInfo!)
            fetchRequest.predicate = predicate
            if let result = try? dataController.viewContext.fetch(fetchRequest) {
                onSuccessfulRetrievedImageData(result)
                searchCriteria = SearchCriteria(latitude: pinInfo!.latitude, longitude: pinInfo!.longitude)
            }
        }
        appearedViaPin = false
    }
    
    func onSuccessfulRetrievedImageData(_ imageResults: [Image]) {
        let mapInput = SearchCriteria(latitude: pinInfo!.latitude, longitude: pinInfo!.longitude)
        setMapPin(mapInput)
        noImagesLabel.isHidden = imageResults.count > 0
        canRemoveThumbnails = true
        storedImages = imageResults
        thumbnails.removeAll()
        thumbnailName.removeAll()
        for (_,image) in imageResults.enumerated() {
            thumbnails.append(UIImage(data: image.img!)!)
            thumbnailName.append("")
        }
        self.collectionView.reloadData()
    }
    
    @IBAction func resetPhotos(_ sender: Any) {
        if searchCriteria != nil {
            pinInfo!.page += 1
            try? self.dataController.viewContext.save()
            searchCriteria?.page = Int(pinInfo!.page)
            deleteStoredImages(storedImages)
            downloadImages()
        }
    }
    
    func deleteStoredImages(_ images: [Image]) {
        for (i,_) in images.enumerated() {
            let image = storedImages[i]
            dataController.viewContext.delete(image)
        }
        do {
            try self.dataController.viewContext.save()
        } catch {
            print(error.localizedDescription)
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
        thumbnailName.removeAll()
        for _ in 0..<totalThumbnails {
          thumbnailName.append(thumbnailPlaceholder)
          let imageName = thumbnailPlaceholder
          let image = UIImage(named: imageName)
          thumbnails.append(image!)
        }
        collectionView.reloadData()
    }

    func setMapPin(_ input: SearchCriteria) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: input.latitude, longitude: input.longitude)
        let viewRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 30000, longitudinalMeters: 30000)
        mapView.setRegion(viewRegion, animated: true)
        mapView.addAnnotations([annotation])
    }
    
    func saveImage(data: Data) {
        let imageInstance = Image(context: self.dataController.viewContext)
        imageInstance.img = data
        imageInstance.pinInfo = pinInfo
        do {
            try self.dataController.viewContext.save()
            storedImages.append(imageInstance)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func downloadImages() {
        resetThumbnails()
        canRemoveThumbnails = false
        flickr.searchFlickrForArray(for: searchCriteria!) { searchResults, error in
            if error != nil {
                print("An error occured downloading images")
                return
            }
            
            if searchResults!.count == 0 {
                DispatchQueue.main.async {
                    self.noImagesLabel.isHidden = false
                }
            } else {
                for (i,_) in searchResults!.enumerated() {
                    self.flickr.downloadAndReturnImage(imageInfo: searchResults![i]) { image in
                        self.thumbnails[i] = image
                        self.thumbnailName[i] = ""
                        self.saveImage(data: image.pngData()!)
                        if (i == searchResults!.count-1) {
                            self.canRemoveThumbnails = true
                        }
                        self.collectionView?.reloadData()
                    }
                  }
               }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnails.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        cell.backgroundColor = UIColor.lightGray
        cell.imageView.image = thumbnails[indexPath.item]
        
        if (thumbnailName[indexPath.item]) == thumbnailPlaceholder {
            cell.imageView.frame = CGRect(x: 0,y: 0,width: 50,height: 50)
            cell.imageView.contentMode = .scaleAspectFit
        } else {
            cell.imageView.frame = cell.contentView.frame
            cell.imageView.contentMode = .scaleAspectFill
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !canRemoveThumbnails {return}
        thumbnails.remove(at: indexPath.item)
        thumbnailName.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
        let image = storedImages[indexPath.item]
        deleteStoredImages([image])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
      let availableWidth = view.frame.width - paddingSpace
      let widthPerItem = availableWidth / itemsPerRow
      return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
      return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return sectionInsets.left
    }
}
