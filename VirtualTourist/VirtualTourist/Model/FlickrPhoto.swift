//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Joey Berger on 4/14/20.
//  Copyright © 2020 Joey Berger. All rights reserved.
//

import UIKit

class FlickrPhoto {
  var thumbnail: UIImage?
  let photoID: String
  let farm: Int
  let server: String
  let secret: String
  
  init (photoID: String, farm: Int, server: String, secret: String) {
    self.photoID = photoID
    self.farm = farm
    self.server = server
    self.secret = secret
  }
  
  func flickrImageURL(_ size: String = "m") -> URL? {
    if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg") {
      return url
    }
    return nil
  }
  
  enum Error: Swift.Error {
    case invalidURL
    case noData
  }
}
