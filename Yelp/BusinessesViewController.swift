//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, FiltersViewControllerDelegate {

  var businesses: [Business]!
  var filteredBusinesses: [Business]!
  var searchController: UISearchController!
  
  @IBOutlet weak var tableView: UITableView!
  
    override func viewDidLoad() {
      super.viewDidLoad()
      
      // set up for table view
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
      // Search on API
      businesses = []
      Business.searchWithTerm("Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
        print("Search for Thai")
        self.businesses = businesses
        self.tableView.reloadData()
        /*for business in businesses {
          print(business.name!)
          print(business.address!)
        }*/
      })
    
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
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      let navigationController = segue.destinationViewController as! UINavigationController
      let filtersViewController = navigationController.topViewController as! FiltersViewController
      filtersViewController.delegate = self
    }
  
  // MARK: - Search Filter
  func filtersviewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
    let categories = filters["categories"] as? [String]
    Business.searchWithTerm("Restaruants", sort: nil, categories: categories, deals: nil) { (businesses: [Business]!, error: NSError!) -> Void in
      print("search for Restaruants")
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
    } else {
      return businesses.count
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
    if searchController.active && searchController.searchBar.text != "" {
      cell.business = filteredBusinesses[indexPath.row]
    } else {
      cell.business = businesses[indexPath.row]
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
    }
  }
  
}

