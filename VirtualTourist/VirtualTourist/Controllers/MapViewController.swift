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

    let dataController = DataController(modelName: "VirtualTouristModel")
    var pinInfo: [PinInfo] = []
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataController.load()
        
        mapView.delegate = self
        
        let myLongPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        myLongPress.addTarget(self, action: #selector(recognizeLongPress(_:)))
        mapView.addGestureRecognizer(myLongPress)
        
        view.backgroundColor = BackgroundColor().color
        
        let fetchRequest:NSFetchRequest<PinInfo> = PinInfo.fetchRequest()
        if let result =  try? dataController.viewContext.fetch(fetchRequest) {
            pinInfo = result
            setupPinsWithData()
            
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
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: mapView)
            let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            
            mapView.addAnnotation(annotation)

            let num = touchCoordinate.latitude as NSNumber
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 4
            formatter.minimumFractionDigits = 4
            _ = formatter.string(from: num)
            let num1 = touchCoordinate.longitude as NSNumber
            let formatter1 = NumberFormatter()
            formatter1.maximumFractionDigits = 4
            formatter1.minimumFractionDigits = 4
            _ = formatter1.string(from: num1)

            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
            geoCoder.reverseGeocodeLocation(location, completionHandler:
                {
                    placemarks, error -> Void in
                    var title = "Location"
                    guard let placeMark = placemarks?.first else { return }
      
                    if let city = placeMark.subAdministrativeArea {
                        title = "\(city), "
                    }

                    if let country = placeMark.country {
                        title = title != "Location" ? title + country : country
                    }
                    
                    annotation.title = title
                    
                    let newPin = PinInfo(context: self.dataController.viewContext)
                    newPin.latitude = touchCoordinate.latitude
                    newPin.longitude = touchCoordinate.longitude
                    newPin.title = title
                    newPin.page = 1
                    try? self.dataController.viewContext.save()
                    self.pinInfo.append(newPin)
            })
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinIdentifier = "PinAnnotationIdentifier"
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdentifier)
        pinView.animatesDrop = true
        pinView.canShowCallout = true
        pinView.annotation = annotation
        
        pinView.canShowCallout = true
        pinView.calloutOffset = CGPoint(x: -5, y: 5)
        pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view:  MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let placemark = view.annotation as? MKPointAnnotation else { return }
        
        let photoAlbumViewController = self.tabBarController?.viewControllers?[1] as! PhotoAlbumViewController
        
        photoAlbumViewController.searchCriteria = SearchCriteria(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude)
        
        photoAlbumViewController.appearedViaPin = true
        
        for info in pinInfo {
            if (placemark.coordinate.latitude == info.latitude &&
                placemark.coordinate.longitude == info.longitude
                ) {
                let fetchRequest:NSFetchRequest<Image> = Image.fetchRequest()
                let predicate = NSPredicate(format: "pinInfo == %@",info)
                fetchRequest.predicate = predicate
                if let result = try? dataController.viewContext.fetch(fetchRequest) {
                    if result.count > 0 {
                        photoAlbumViewController.searchCriteria = nil
                    }
                }
                photoAlbumViewController.pinInfo = info
                break
            }
        }
        tabBarController!.selectedIndex = 1
    }
}

