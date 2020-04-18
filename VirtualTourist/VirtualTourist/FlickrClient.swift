/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
    
import UIKit

let apiKey = "adff54e787e668b58ca1b231a21629ac"  //TODO: update api key

class Flickr {
  enum Error: Swift.Error {
    case unknownAPIResponse
    case generic
  }
  
  func searchFlickrForArray(for searchTerm: String, complettion: @escaping ([[Any]]) -> Void) {
    guard let searchURL = flickrSearchURL(for: searchTerm) else {
//      completion(Result.error(Error.unknownAPIResponse))
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
        
        complettion(array)
        
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
        
        print("can process image")
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
  
  private func flickrSearchURL(for searchTerm:String) -> URL? {
    guard let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
      return nil
    }
    
    let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&per_page=20&lat=40.7128&lon=74.0060&format=json&nojsoncallback=1"
    return URL(string:URLString)
  }
}
