//
//  RouteViewController.swift
//  ParkCloud
//
//  Created by Dylan Maryk on 04/03/2017.
//  Copyright © 2017 ParkCloud. All rights reserved.
//

import GoogleMaps
import UIKit

class RouteViewController: UIViewController {
    @IBOutlet weak var drivingToLabel: UILabel!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var destination: String!
    var destinationLocation: (lat: Float, lng: Float)!
    var routes: [Route]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.drivingToLabel.text = "Driving to \(self.destination!)"
        
        self.mapView.animate(toLocation: CLLocationCoordinate2D(latitude: CLLocationDegrees(self.destinationLocation.lat),
                                                                longitude: CLLocationDegrees(self.destinationLocation.lng)))
        self.mapView.animate(toZoom: 14)
    }
}
