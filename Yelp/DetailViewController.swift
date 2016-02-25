//
//  DetailViewController.swift
//  Yelp
//
//  Created by QingTian Chen on 2/24/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class DetailViewController: UIViewController, MKMapViewDelegate {
  
    var business: Business!
  
  @IBOutlet weak var photosWebView: UIWebView!
  @IBOutlet weak var ratingView: UIView!
  @IBOutlet weak var ratingLabel: UILabel!
  @IBOutlet weak var ratingCountLabel: UILabel!
  @IBOutlet weak var ratingBackView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var phoneLabel: UILabel!
  @IBOutlet weak var snippetTextLabel: UILabel!
  @IBOutlet weak var mapView: MKMapView!

  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      let businessLocation = CLLocation(latitude: business.coordinate.0! , longitude: business.coordinate.1! )
      self.goToLocation(businessLocation)
      let businessLoaction = CLLocationCoordinate2D(latitude: business.coordinate.0!, longitude: business.coordinate.1!)
      print(businessLoaction)
      addAnnotationAtCoordinate(businessLoaction)
      
      
      self.automaticallyAdjustsScrollViewInsets = false
      ratingView.backgroundColor = UIColor(red: 234.0/255.0, green: 46.0/255.0, blue: 73.0/255.0, alpha: 0.5)
      ratingView.layer.cornerRadius = 10
      ratingBackView.layer.cornerRadius = 10
      titleLabel.text = business.name
      titleLabel.sizeToFit()
      let rating = business.rating as! Double
      ratingLabel.text = ("\(Double(rating*2))")
      ratingLabel.sizeToFit()
      let review = business.reviewCount as! Int
      ratingCountLabel.text = ("Base on \(review) ratings")
      ratingCountLabel.sizeToFit()
      addressLabel.text = business.address
      addressLabel.sizeToFit()
      phoneLabel.text = business.display_phone
      phoneLabel.sizeToFit()
      snippetTextLabel.text = business.snippet_text
      snippetTextLabel.sizeToFit()
      let url = "http://www.yelp.com/biz_photos/\(business.id!)"
      let requestURL = NSURL(string: url)
      let request = NSURLRequest(URL: requestURL!)
      photosWebView.loadRequest(request)
      mapView.layer.cornerRadius = 121
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: - Location Manager
extension DetailViewController {
  
  func goToLocation(location: CLLocation) {
    let span = MKCoordinateSpanMake(0.005, 0.005)
    let region = MKCoordinateRegionMake(location.coordinate, span)
    mapView.setRegion(region, animated: false)
  }
  
  // add annotation with title to a point
  func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D) {
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate
    annotation.title = business.name
    mapView.addAnnotation(annotation)
    
  }
  
}
