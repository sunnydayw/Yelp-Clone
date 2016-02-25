//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import MBProgressHUD

class BusinessesViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, FiltersViewControllerDelegate, UIScrollViewDelegate, MKMapViewDelegate {
  // MARK: - Object
  var businesses: [Business]!
  var filteredBusinesses: [Business]!
  var searchController: UISearchController!
  var isMoreDataLoading = false
  var loadingMoreView:InfiniteScrollActivityView?
  var loadMoreOffset = 20
  var timer: dispatch_source_t!
  var locationManager : CLLocationManager!
  var mylocation: String = ""
  var selectedCategiors: String = "Restaurants"
  
  
  
  @IBOutlet weak var categiors: UIView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var mapMiniView: MKMapView!
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
      super.viewDidLoad()
      // set up for table view
      categiors.backgroundColor = UIColor(red: 234.0/255.0, green: 46.0/255.0, blue: 73.0/255.0, alpha: 0.9)
      self.automaticallyAdjustsScrollViewInsets = false
      self.tableView.separatorInset = UIEdgeInsetsZero
      tableView.dataSource = self
      tableView.delegate = self
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 120
      // set up for search bar
      searchController = UISearchController(searchResultsController: nil)
      searchController.searchResultsUpdater = self
      searchController.searchBar.sizeToFit()
      navigationItem.titleView = searchController.searchBar
      searchController.hidesNavigationBarDuringPresentation = false
      searchController.dimsBackgroundDuringPresentation = false
      definesPresentationContext = true
      //Mini Map Setup
      locationManager = CLLocationManager()
      mapMiniView.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.distanceFilter = 200
      locationManager.requestWhenInUseAuthorization()
      
      let latitude = locationManager.location?.coordinate.latitude
      let longitude = locationManager.location?.coordinate.longitude
      mylocation = "\(latitude!)" + "," + "\(longitude!)"
      let goTolocation = CLLocation(latitude: latitude!, longitude: longitude!)
      
      goToLocation(goTolocation)

      // Search on API Using my Location
      businesses = []
      Business.searchWithTerm(selectedCategiors, location: mylocation, completion: { (businesses: [Business]!, error: NSError!) -> Void in
        self.businesses = businesses
        self.tableView.reloadData()
        /*for business in businesses {
          print(business.name!)
          print(business.address!)
        }*/
      })
      
      // Set up Infinite Scroll loading indicator
      let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
      loadingMoreView = InfiniteScrollActivityView(frame: frame)
      loadingMoreView!.hidden = true
      tableView.addSubview(loadingMoreView!)
      var insets = tableView.contentInset;
      insets.bottom += InfiniteScrollActivityView.defaultHeight;
      tableView.contentInset = insets
    
/* Example of Yelp search with more search options specified
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        }
*/
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      if segue.identifier == "filtersView" {
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
      } else if segue.identifier == "pushToDetail" {
        let cell = sender as! UITableViewCell
        let index = tableView.indexPathForCell(cell)
        let business = businesses[(index?.row)!]
        let detailViewController = segue.destinationViewController as! DetailViewController
          detailViewController.business = business
      } else {
        let mapViewController = segue.destinationViewController as! MapsViewController
        mapViewController.businesses = self.businesses
      }
    }
  
  // MARK: - Search Filter
  func filtersviewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
    let categories = filters["categories"] as? [String]
    Business.searchWithTerm(selectedCategiors,location: mylocation, sort: nil, categories: categories, deals: nil) { (businesses: [Business]!, error: NSError!) -> Void in
      if businesses != nil {
        self.businesses = businesses
      } else {
        self.businesses = []
        
      }
      self.tableView.reloadData()
    }
  }
  
}


// MARK: - TableView Updater
extension BusinessesViewController {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchController.active && searchController.searchBar.text != "" {
      return filteredBusinesses.count
    } else if(businesses != nil){
      return businesses.count
    } else {
      return 0
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
    
    if searchController.active && searchController.searchBar.text != "" {
      cell.business = filteredBusinesses[indexPath.row]
    } else {
      cell.business = businesses[indexPath.row]
    }
    if cell.business.coordinate.0 != nil {
      let businessLoaction = CLLocationCoordinate2D(latitude: cell.business.coordinate.0!, longitude: cell.business.coordinate.1!)
      addAnnotationAtCoordinate(businessLoaction, title: cell.business.name!)
      let goToBusinessLocation = CLLocation(latitude: cell.business.coordinate.0!, longitude: cell.business.coordinate.1!)
      goToLocation(goToBusinessLocation)
    } else {
      print("no location find")
    }
    return cell
  }
  
}


// MARK: - Search Results Updater
extension BusinessesViewController {
  
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    if let searchText = searchController.searchBar.text {
      filteredBusinesses = searchText.isEmpty ? businesses : businesses?.filter({ (business:Business) -> Bool in
        if business.name!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
          return true
        } else {
          return false
        }
      })
      tableView.reloadData()
      //remove all annotation
      let annotationsToRemove = mapMiniView.annotations.filter { $0 !== mapMiniView.userLocation }
      mapMiniView.removeAnnotations( annotationsToRemove )
    }
  }
  
}

// MARK: - Infinite ScrollView
extension BusinessesViewController {
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if (!isMoreDataLoading) {
      // Calculate the position of one screen length before the bottom of the results
      let scrollViewContentHeight = tableView.contentSize.height
      let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
      
      // When the user has scrolled past the threshold, start requesting
      if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
        isMoreDataLoading = true
        // Update position of loadingMoreView, and start loading indicator
        let frame = CGRectMake(0, self.tableView.contentSize.height, self.tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        self.loadingMoreView?.frame = frame
        self.loadingMoreView!.startAnimating()
        loadMoreData()
      }
      
    }
  }
  
  func loadMoreData() {
    Business.searchWithTerm(selectedCategiors, location: mylocation, offset: loadMoreOffset, sort: nil, categories: [], deals: nil, completion: { (let businesses: [Business]!, error: NSError!) -> Void in
      if error != nil {
        self.loadingMoreView?.stopAnimating()
      } else {
        Dispatch.async(delay: 0.5, block: { () -> () in
          self.loadMoreOffset += 20
          self.businesses.appendContentsOf(businesses)
          self.tableView.reloadData()
          self.loadingMoreView?.stopAnimating()
          self.isMoreDataLoading = false
        })
      }
    })
  }
  
}

// MARK: - Map View Mini
extension BusinessesViewController {
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == CLAuthorizationStatus.AuthorizedWhenInUse {
      locationManager.startUpdatingLocation()
    }
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      let span = MKCoordinateSpanMake(0.1, 0.1)
      let region = MKCoordinateRegionMake(location.coordinate, span)
      mapMiniView.setRegion(region, animated: true)
      
    }
  }
  func goToLocation(location: CLLocation) {
    let span = MKCoordinateSpanMake(0.01, 0.01)
    let region = MKCoordinateRegionMake(location.coordinate, span)
    mapMiniView.setRegion(region, animated: true)
  }
  
  func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D, title: String) {
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate
    annotation.title = title
    mapMiniView.addAnnotation(annotation)
  }
  
  func cleanAnnotation() {
    
  }

}
// MARK: - Button
extension BusinessesViewController {
  
  @IBAction func onFoodPressed(sender: AnyObject) {
    loadingView()
    selectedCategiors = "Restaurants"
    search()
    
  }
  
  @IBAction func onBarPressed(sender: AnyObject) {
    loadingView()
    selectedCategiors = "Bar"
    search()
  }
  @IBAction func onCoffeePressed(sender: AnyObject) {
    loadingView()
    selectedCategiors = "Coffee"
    search()
  }
  @IBAction func onDessertPressed(sender: AnyObject) {
    loadingView()
    selectedCategiors = "Dessert"
    search()
  }
  @IBAction func onMorePressed(sender: AnyObject) {
    loadingView()
    selectedCategiors = "Food"
    search()
  }
  func search() {
    Business.searchWithTerm(selectedCategiors, location: mylocation, completion: { (businesses: [Business]!, error: NSError!) -> Void in
      self.businesses = businesses
      self.tableView.reloadData()
      /*for business in businesses {
      print(business.name!)
      print(business.address!)
      }*/
    })
    MBProgressHUD.hideHUDForView(self.view, animated: true)
  }
  func loadingView() {
    let spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    spinningActivity.labelText = "Loading..."
    let annotationsToRemove = mapMiniView.annotations.filter { $0 !== mapMiniView.userLocation }
    mapMiniView.removeAnnotations( annotationsToRemove )

  }
  
}

