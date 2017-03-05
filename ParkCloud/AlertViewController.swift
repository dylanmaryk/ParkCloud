//
//  AlertViewController.swift
//  ParkCloud
//
//  Created by Dylan Maryk on 05/03/2017.
//  Copyright © 2017 ParkCloud. All rights reserved.
//

import GoogleMaps
import UIKit

class AlertViewController: UIViewController {
    @IBOutlet weak var drivingToLabel: UILabel!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var destination: String!
    var polylineString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.drivingToLabel.text = "Driving to \(self.destination!)"
        
        let polyline = GMSPolyline(path: GMSPath(fromEncodedPath: polylineString))
        polyline.map = self.mapView
        
        self.mapView.animate(toLocation: polyline.path!.coordinate(at: 0))
        self.mapView.animate(toZoom: 13)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mapVC = segue.destination as! MapViewController
        mapVC.destination = self.destination
        mapVC.polylineString = polylineString
    }
}
