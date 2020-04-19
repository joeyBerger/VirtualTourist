//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Joey Berger on 4/18/20.
//  Copyright © 2020 Joey Berger. All rights reserved.
//
    
import UIKit

let apiKey = "adff54e787e668b58ca1b231a21629ac"  //TODO: update api key

class Flickr {
  enum Error: Swift.Error {
    case unknownAPIResponse
    case generic
  }
  
  func searchFlickrForArray(for searchCriteria: SearchCriteria, complettion: @escaping ([[Any]]?, Error?) -> Void) {
    guard let searchURL = flickrSearchURL(for: searchCriteria) else {
//      completion(Result.error(Error.unknownAPIResponse))
        complettion(nil, Error.generic)
      return
    }
    
    let searchRequest = URLRequest(url: searchURL)
    
    URLSession.shared.dataTask(with: searchRequest) { (data, response, error) in
      if let error = error {
        DispatchQueue.main.async {
//          completion(Result.error(error))
        }
        return
      }
      
      guard
        let _ = response as? HTTPURLResponse,
        let data = data
        else {
          DispatchQueue.main.async {
//            completion(Result.error(Error.unknownAPIResponse))
          }
          return
      }
      
      do {
          let tempthing = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject]
//          print(tempthing)
          let tempthing1 = tempthing!["photos"] as? [String: AnyObject]
          print(tempthing1)
        
          
        
        guard
          let resultsDictionary = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject],
          let stat = resultsDictionary["stat"] as? String
          else {
            DispatchQueue.main.async {
//              completion(Result.error(Error.unknownAPIResponse))
            }
            return
            
        }
        
        guard
           let photosContainer = resultsDictionary["photos"] as? [String: AnyObject],
           let photosReceived = photosContainer["photo"] as? [[String: AnyObject]]
           else {
             DispatchQueue.main.async {
//               completion(Result.error(Error.unknownAPIResponse))
             }
             return
         }
        
        let array: [[Any]] = photosReceived.compactMap { photoObject in
           let photoID = photoObject["id"] as? String
           let farm = photoObject["farm"] as? Int
           let server = photoObject["server"] as? String
           let secret = photoObject["secret"] as? String
          
           var returnArr: [Any] = [photoID!,farm!,server!,secret!]
           return returnArr
        }
        
        complettion(array, nil)
        
      } catch {
//        completion(Result.error(error))
        return
      }
    }.resume()
  }
  
  func downloadImageAndReturnImage(imageInfo: [Any], completion: @escaping (UIImage) -> Void) {
      let flickrPhoto = FlickrPhoto(photoID: imageInfo[0] as! String, farm: imageInfo[1] as! Int, server: imageInfo[2] as! String, secret: imageInfo[3] as! String)
        
        guard
          let url = flickrPhoto.flickrImageURL(),
          let imageData = try? Data(contentsOf: url as URL)
          else {
  //          return nil
            return
        }

        if let image = UIImage(data: imageData) {
          flickrPhoto.thumbnail = image
          let searchResults = FlickrSearchResults(searchTerm: "", searchResults: [flickrPhoto])
           DispatchQueue.main.async {
            completion(flickrPhoto.thumbnail!)
          }
  //        return flickrPhoto
        } else {
  //        return nil
        }
    }
  
  private func flickrSearchURL(for searchCriteria: SearchCriteria) -> URL? {
//    guard let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
//      return nil
//    }
    
    
    
    let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&per_page=20&lat=\(searchCriteria.latitude)&lon=\(searchCriteria.longitude)&page=\(searchCriteria.page)&format=json&nojsoncallback=1"
    return URL(string:URLString)
  }
}
