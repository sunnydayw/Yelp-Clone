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

class MapsViewController: UIViewController {

  @IBOutlet var mapView: MKMapView!
  var locationManager : CLLocationManager!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      /*
      // set the region to display, this also sets a correct zoom level
      // set starting center location in San Francisco
      let centerLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
      goToLocation(centerLocation)
      */
      locationManager = CLLocationManager()
      //locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.distanceFilter = 200
      locationManager.requestWhenInUseAuthorization()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
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
    /*
  func goToLocation(location: CLLocation) {
    let span = MKCoordinateSpanMake(0.1, 0.1)
    let region = MKCoordinateRegionMake(location.coordinate, span)
    mapView.setRegion(region, animated: false)
  }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
