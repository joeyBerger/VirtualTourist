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
//    var items = ["1", "2", "3"]
    
    var collectionImages: [UIImageView] = [];
    
    var myImagme: UIImage = UIImage(named:"placeholder.png")!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var PhotoCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("in viewDidLoad")
        for _ in self.items.enumerated() {
            let imageview: UIImageView = UIImageView(frame: CGRect(x: 25, y: 25, width: 50, height: 50));
            let img : UIImage = UIImage(named:"placeholder.png")!
            imageview.image = img
            collectionImages.append(imageview)
        }
    }
    
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.collectionImages[0].image = UIImage(data: data)
                self.myImagme = UIImage(data: data)!
//                self.collectionView.reloadRows(at: 0, with: .none)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("location \(location)")
        
        print("Begin of code")
        let url = URL(string: "https://cdn.arstechnica.net/wp-content/uploads/2018/06/macOS-Mojave-Dynamic-Wallpaper-transition.jpg")!
        downloadImage(from: url)
        print("End of code. The image will continue downloading in the background and it will be loaded when it ends.")
    }
    
    
    
    @IBAction func resetPhotos(_ sender: Any) {
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.lightGray
        let imageview: UIImageView = UIImageView(frame: CGRect(x: 25, y: 25, width: 50, height: 50));
        let img = self.myImagme //UIImage = UIImage(named:"placeholder.png")!
        print(self.myImagme)
        imageview.image = img
//        cell.contentView.addSubview(imageview)
        
        print("indexPath.item \(indexPath.item)")
        cell.contentView.addSubview(collectionImages[indexPath.item])
        
        
        
//        cell.awakeFromNib()
        
        
//        let imageview: UIImageView = UIImageView(frame: CGRect(x: 25, y: 25, width: 50, height: 50));
//        if cell.contentView.subviews.contains(collectionImages[indexPath.item]) {
////            self.myView.removeFromSuperview() // Remove it
//            print("has view")
//        } else {
//           // Do Nothing
//            print("does not has view")
//        }
        
        
//        cell.contentView.addSubview(collectionImages[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        items.remove(at: indexPath.item)
        collectionImages.remove(at: indexPath.item)
        
        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
//        cell.contentView.subviews.forEach({ $0.removeFromSuperview() })
        
        collectionView.deleteItems(at: [indexPath])
//        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width:(collectionView.frame.width/2), height: (collectionView.frame.width/2))
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets (top: 10, left: 10, bottom: 10, right: 10)
    }
}
