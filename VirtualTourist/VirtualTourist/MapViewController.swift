//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Joey Berger on 4/14/20.
//  Copyright © 2020 Joey Berger. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("getting to here")
        
        mapView.delegate = self
        
        let myLongPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        myLongPress.addTarget(self, action: #selector(recognizeLongPress(_:)))
        mapView.addGestureRecognizer(myLongPress)
        
    }
    
    @objc private func recognizeLongPress(_ sender: UILongPressGestureRecognizer) {
        //https://stackoverflow.com/questions/27735835/convert-coordinates-to-city-name
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: mapView)
            let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            
            mapView.addAnnotation(annotation) //drops the pin
            print("lat:  \(touchCoordinate.latitude)")
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

                    var title = ""
                    // Place details
                    guard let placeMark = placemarks?.first else { return }

                    // Location name
                    if let locationName = placeMark.location {
                        print(locationName)
                    }
                    // Street address
                    if let street = placeMark.thoroughfare {
                        print(street)
                    }
                    // City
                    if let city = placeMark.subAdministrativeArea {
                        print(city)
                        title = "\(city), "
                        
                    }
                    // Zip code
                    if let zip = placeMark.isoCountryCode {
                        print(zip)
                    }
                    // Country
                    if let country = placeMark.country {
                        print(country)
                        title += country
                    }
                    
                    annotation.title = title
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
        
        print("latitude: \(annotation.coordinate.latitude), longitude: \(annotation.coordinate.longitude)")
        
        myPinView.canShowCallout = true
        myPinView.calloutOffset = CGPoint(x: -5, y: 5)
        myPinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return myPinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view:  MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("map view button")
        guard let placemark = view.annotation as? MKPointAnnotation else { return }
        
        let photoAlbumViewController = self.tabBarController?.viewControllers?[1] as! PhotoAlbumViewController
        photoAlbumViewController.location = placemark.title!
        tabBarController!.selectedIndex = 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToYourTabBarController" {
            if let destVC = segue.destination as? PhotoAlbumViewController {
                destVC.location = "butt"
                tabBarController!.selectedIndex = 1
            }
        }
    }
    
    func switchToDataTabCont(){
        tabBarController!.selectedIndex = 1
    }
}

