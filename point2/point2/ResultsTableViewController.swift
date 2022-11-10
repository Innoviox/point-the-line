//
//  ResultsTableViewController.swift
//  point2
//
//  Created by Simon Chervenak on 11/9/22.
//

import Foundation
import UIKit
import MapKit

class ResultsTableViewController: UITableViewController {
    public var center: CLLocationCoordinate2D?
    public var line_length: Double = 0
    public var angle: CLLocationDirection = 0
    
    private var results: [MKMapItem] = []
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // (optional) include this line if you want to remove the extra empty cell divider lines
        // self.tableView.tableFooterView = UIView()

        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        makeSearches()
    }
    
    // number of rows in table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    // create a cell for each table view row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell: UITableViewCell = (self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?)!
        
        // set the text from the data model
        cell.textLabel?.text = self.results[indexPath.row].name
        
        return cell
    }
    
    // method to run when table view cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    private func makeSearches() {
        var length = 0.0
        
        print("MAKING SEARCHES")

        while length <= line_length {
            let point = center!.point(distance: length, angle: angle)
            
            let request = MKLocalPointsOfInterestRequest(center: point, radius: 0.1)
            let search = MKLocalSearch(request: request)
            search.start { [unowned self] (response, error) in
                guard error == nil else {
                    print("plato search error", error)
                    return
                }
                
                for i in response?.mapItems ?? [] {
                    print(results)
                    results.append(i)
                }
            }
            
            length += 0.1
        }
    }
}
