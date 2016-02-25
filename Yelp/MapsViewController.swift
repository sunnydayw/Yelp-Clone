//
//  MapsViewController.swift
//  Yelp
//
//  Created by QingTian Chen on 2/21/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//


import UIKit
import CoreLocation
import MapKit

class MapsViewController: UIViewController, MKMapViewDelegate {

  @IBOutlet var mapView: MKMapView!
  var locationManager : CLLocationManager!
  var businesses: [Business]!
  
  
    override func viewDidLoad() {
      super.viewDidLoad()
      locationManager = CLLocationManager()
      mapView.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.distanceFilter = 200
      locationManager.requestWhenInUseAuthorization()
      // display current location
      /*
      // draw circular overlay centered in my coordinate
      let coordinate = CLLocationCoordinate2D(latitude: 37.7833, longitude: -122.4167)
      let circleOverlay: MKCircle = MKCircle(centerCoordinate: coordinate, radius: 1000)
      mapView.addOverlay(circleOverlay)
      // Start puting annotation for businesses
      */
      //let centerLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
      //goToLocation(myLocation!)
      Dispatch.async( delay: 0.5) { () -> () in
        if self.locationManager.location != nil {
          let lat = self.locationManager.location!.coordinate.latitude
          let lon = self.locationManager.location!.coordinate.longitude
          let myLocation = CLLocation(latitude: lat, longitude: lon)
          self.goToLocation(myLocation)
        }
      }
      
      for business in businesses {
      let businessLoaction = CLLocationCoordinate2D(latitude: business.coordinate.0!, longitude: business.coordinate.1!)
      let title = business.name! as String
      addAnnotationAtCoordinate(businessLoaction,title: title)
      }
      
    }
  
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
/*
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
*/
  
}

// MARK: - Location Manager
extension MapsViewController {
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == CLAuthorizationStatus.AuthorizedWhenInUse {
      locationManager.startUpdatingLocation()
    }
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      let span = MKCoordinateSpanMake(0.1, 0.1)
      let region = MKCoordinateRegionMake(location.coordinate, span)
      mapView.setRegion(region, animated: false)

    }
  }
  func goToLocation(location: CLLocation) {
    let span = MKCoordinateSpanMake(0.015, 0.015)
    let region = MKCoordinateRegionMake(location.coordinate, span)
    mapView.setRegion(region, animated: false)
  }
  
}


//MARK: - Map Annotation
extension MapsViewController {
  // add annotation with title to a point
  func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D, title: String) {
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate
    annotation.title = title
    mapView.addAnnotation(annotation)
    
  }
  /*
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    let identifier = "customAnnotationView"
    
    // custom image annotation
    var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)  as? MKPinAnnotationView
    
    if (annotationView == nil) {
      annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
    }
    else {
      annotationView!.annotation = annotation
    }
    annotationView!.image = UIImage(named: "logo")
    if #available(iOS 9.0, *) {
        //annotationView!.pinTintColor = UIColor.greenColor()
    } else {
        // Fallback on earlier versions
    }
    
    return annotationView
  }
  */

}

//MARK: - Map Overlays

extension MapsViewController {
  
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    let circleView = MKCircleRenderer(overlay: overlay)
    circleView.strokeColor = UIColor.redColor()
    circleView.lineWidth = 1
    return circleView
  }
  
}


