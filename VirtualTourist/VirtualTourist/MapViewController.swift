//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Joey Berger on 4/14/20.
//  Copyright © 2020 Joey Berger. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let dataController = DataController(modelName: "VirtualTouristModel")
    
    var pinInfo: [PinInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)
        mapView.delegate = self
        
        let myLongPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        myLongPress.addTarget(self, action: #selector(recognizeLongPress(_:)))
        mapView.addGestureRecognizer(myLongPress)
        
        dataController.load()
        
        let fetchRequest:NSFetchRequest<PinInfo> = PinInfo.fetchRequest()
        if let result =  try? dataController.viewContext.fetch(fetchRequest) {
            pinInfo = result
            setupPinsWithData()
            print(pinInfo[0].images)
            
            
            
            let photoAlbumViewController = self.tabBarController?.viewControllers?[1] as! PhotoAlbumViewController
            photoAlbumViewController.dataController = dataController
        }
    }
    
    func setupPinsWithData() {
           var annotations = [MKPointAnnotation]()
           for info in pinInfo {
              let lat = CLLocationDegrees(info.latitude)
              let long = CLLocationDegrees(info.longitude)
              let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
             
              let annotation = MKPointAnnotation()
              annotation.coordinate = coordinate
              annotation.title = info.title
              annotations.append(annotation)
           }
           self.mapView.addAnnotations(annotations)
       }
    
    @objc private func recognizeLongPress(_ sender: UILongPressGestureRecognizer) {
        //https://stackoverflow.com/questions/27735835/convert-coordinates-to-city-name
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: mapView)
            let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            
            mapView.addAnnotation(annotation) //drops the pin

            let num = touchCoordinate.latitude as NSNumber
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 4
            formatter.minimumFractionDigits = 4
            _ = formatter.string(from: num)
            print("long: \(touchCoordinate.longitude)")
            let num1 = touchCoordinate.longitude as NSNumber
            let formatter1 = NumberFormatter()
            formatter1.maximumFractionDigits = 4
            formatter1.minimumFractionDigits = 4
            _ = formatter1.string(from: num1)
//            self.adressLoLa.text = "\(num),\(num1)"

            // Add below code to get address for touch coordinates.
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
            geoCoder.reverseGeocodeLocation(location, completionHandler:
                {
                    placemarks, error -> Void in

                    var title = "Location"
                    // Place details
                    guard let placeMark = placemarks?.first else { return }
      
                    if let city = placeMark.subAdministrativeArea {
                        print(city)
                        title = "\(city), "
                        
                    }

                    if let country = placeMark.country {
                        print(country)
                        title = title != "Location" ? title + country : country
                    }
                    
                    annotation.title = title
                    
                    let newPin = PinInfo(context: self.dataController.viewContext)
                    newPin.latitude = touchCoordinate.latitude
                    newPin.longitude = touchCoordinate.longitude
                    newPin.title = title
                    try? self.dataController.viewContext.save()
            })
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let myPinIdentifier = "PinAnnotationIdentifier"
        
        // Generate pins.
        let myPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: myPinIdentifier)
        
        // Add animation.
        myPinView.animatesDrop = true
        
        // Display callouts.
        myPinView.canShowCallout = true
        
        // Set annotation.
        myPinView.annotation = annotation
        
        myPinView.canShowCallout = true
        myPinView.calloutOffset = CGPoint(x: -5, y: 5)
        myPinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return myPinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view:  MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("map view button")
        guard let placemark = view.annotation as? MKPointAnnotation else { return }
        
        let photoAlbumViewController = self.tabBarController?.viewControllers?[1] as! PhotoAlbumViewController
//        photoAlbumViewController.location = placemark.title!
        
        print(placemark.coordinate)
        
        photoAlbumViewController.searchCriteria = SearchCriteria(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude, page: 0)
        
        for info in pinInfo {
            if (placemark.coordinate.latitude == info.latitude &&
                placemark.coordinate.longitude == info.longitude &&
                info.images != nil
                ) {
                photoAlbumViewController.searchCriteria = nil
                print("resseting search criteria")
//                photoAlbumViewController.storedImages = info.images
//                photoAlbumViewController.thumbnails = info.images
                break
            }
        }
        
        
        
        tabBarController!.selectedIndex = 1
    }
       
    func switchToDataTabCont(){
        tabBarController!.selectedIndex = 1
    }
}

