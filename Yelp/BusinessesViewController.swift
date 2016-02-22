//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, FiltersViewControllerDelegate, UIScrollViewDelegate {

  var businesses: [Business]!
  var filteredBusinesses: [Business]!
  var searchController: UISearchController!
  var isMoreDataLoading = false
  var loadingMoreView:InfiniteScrollActivityView?
  var loadMoreOffset = 20
  var timer: dispatch_source_t!
  
  @IBOutlet weak var tableView: UITableView!
  
    override func viewDidLoad() {
      super.viewDidLoad()
      
      self.tableView.separatorInset = UIEdgeInsetsZero
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
      Business.searchWithTerm("Restaurants", completion: { (businesses: [Business]!, error: NSError!) -> Void in
        print("Search for Thai")
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
    Business.searchWithTerm("Restaurants", sort: nil, categories: categories, deals: nil) { (businesses: [Business]!, error: NSError!) -> Void in
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

// Mark: - Infinite ScrollView
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
    Business.searchWithTerm("Restaurants", offset: loadMoreOffset, sort: nil, categories: ["asianfusion", "burgers"], deals: nil, completion: { (let businesses: [Business]!, error: NSError!) -> Void in
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

