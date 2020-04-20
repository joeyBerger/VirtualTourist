//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Joey Berger on 4/18/20.
//  Copyright © 2020 Joey Berger. All rights reserved.
//
    
import UIKit

let apiKey = "adff54e787e668b58ca1b231a21629ac"

class Flickr {
  enum Error: Swift.Error {
    case generic
  }
  
  func searchFlickrForArray(for searchCriteria: SearchCriteria, complettion: @escaping ([[Any]]?, Error?) -> Void) {
    guard let searchURL = flickrSearchURL(for: searchCriteria) else {
        complettion(nil, Error.generic)
      return
    }
    
    let searchRequest = URLRequest(url: searchURL)
    
    URLSession.shared.dataTask(with: searchRequest) { (data, response, error) in
        if error != nil {
        DispatchQueue.main.async {
          complettion(nil, Error.generic)
        }
        return
      }
      
      guard
        let _ = response as? HTTPURLResponse,
        let data = data
        else {
          DispatchQueue.main.async {
            complettion(nil, Error.generic)
          }
          return
      }
      
      do {
        guard
          let resultsDictionary = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject]
          else {
            DispatchQueue.main.async {
                complettion(nil, Error.generic)
            }
            return
        }
        
        guard
           let photosContainer = resultsDictionary["photos"] as? [String: AnyObject],
           let photosReceived = photosContainer["photo"] as? [[String: AnyObject]]
           else {
             DispatchQueue.main.async {
                complettion(nil, Error.generic)
             }
             return
         }
        
        let array: [[Any]] = photosReceived.compactMap { photoObject in
           let photoID = photoObject["id"] as? String
           let farm = photoObject["farm"] as? Int
           let server = photoObject["server"] as? String
           let secret = photoObject["secret"] as? String
          
           let returnArr: [Any] = [photoID!,farm!,server!,secret!]
           return returnArr
        }
        
        complettion(array, nil)
        
      } catch {
        complettion(nil, Error.generic)
        return
      }
    }.resume()
  }
  
  func downloadAndReturnImage(imageInfo: [Any], completion: @escaping (UIImage) -> Void) {
      let flickrPhoto = FlickrPhoto(photoID: imageInfo[0] as! String, farm: imageInfo[1] as! Int, server: imageInfo[2] as! String, secret: imageInfo[3] as! String)
        
        guard
          let url = flickrPhoto.flickrImageURL(),
          let imageData = try? Data(contentsOf: url as URL)
          else {
            return
        }

        if let image = UIImage(data: imageData) {
          flickrPhoto.thumbnail = image
           DispatchQueue.main.async {
            completion(flickrPhoto.thumbnail!)
          }
        } else {
            return
        }
    }
  
  private func flickrSearchURL(for searchCriteria: SearchCriteria) -> URL? {
    let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&per_page=20&lat=\(searchCriteria.latitude)&lon=\(searchCriteria.longitude)&page=\(searchCriteria.page)&format=json&nojsoncallback=1"
    return URL(string:URLString)
  }
}
