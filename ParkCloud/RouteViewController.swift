//
//  RouteViewController.swift
//  ParkCloud
//
//  Created by Dylan Maryk on 04/03/2017.
//  Copyright © 2017 ParkCloud. All rights reserved.
//

import GoogleMaps
import UIKit

class RouteCell: UITableViewCell {
    @IBOutlet weak var endAddressLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
}

class RouteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var drivingToLabel: UILabel!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var destination: String!
    var destinationLocation: (lat: Float, lng: Float)!
    var routes: [Route]!
    var routeSelected: Route!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.drivingToLabel.text = "Driving to \(self.destination!)"
        
        self.mapView.animate(toLocation: CLLocationCoordinate2D(latitude: CLLocationDegrees(self.destinationLocation.lat),
                                                                longitude: CLLocationDegrees(self.destinationLocation.lng)))
        self.mapView.animate(toZoom: 14)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier: String
        
        if indexPath.row == 0 {
            identifier = "RouteCell"
        } else if indexPath.row == 1 {
            identifier = "RouteCell2"
        } else {
            identifier = "RouteCell3"
        }
        
        let routeCell = self.tableView.dequeueReusableCell(withIdentifier: identifier) as! RouteCell
        routeCell.selectionStyle = .none
        
        let route = routes[indexPath.row]
        routeCell.endAddressLabel.text = route.endAddress
        routeCell.durationLabel.text = route.duration
        
        return routeCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.routeSelected = self.routes[indexPath.row]
        self.performSegue(withIdentifier: "showAlert", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let alertVC = segue.destination as! AlertViewController
        alertVC.destination = self.destination
        alertVC.polylineString = self.routeSelected.polyline
    }
}
