//
//  PlannerViewController.swift
//  ParkCloud
//
//  Created by Dylan Maryk on 04/03/2017.
//  Copyright © 2017 ParkCloud. All rights reserved.
//

import Alamofire
import GoogleMaps
import UIKit

struct Route {
    let polyline: String
    let endAddress: String
    let duration: String
}

class PlannerViewController: UIViewController {
    
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var destinationLocation: (lat: Float, lng: Float)!
    var routes = [Route]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.animate(toLocation: CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050))
        self.mapView.animate(toZoom: 12)
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        let originGeocodingRequestURL = self.geocodingRequestURL(forAddress: self.originTextField.text!)
        let destinationGeocodingRequestURL = self.geocodingRequestURL(forAddress: self.destinationTextField.text!)
        
        Alamofire.request(destinationGeocodingRequestURL).responseJSON { response in
            self.destinationLocation = self.location(forGeocodingResponseJSON: response.result.value as! [String : Any])
            let randomLocations = self.randomLocations(aroundLocation: self.destinationLocation)
            let randomLocationsStrings = randomLocations.map { return "\($0.lat),\($0.lng)" }
            let randomLocationsString = randomLocationsStrings.joined(separator: "|").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            
            Alamofire.request("https://roads.googleapis.com/v1/nearestRoads?points=\(randomLocationsString)&key=AIzaSyCdLb3yrLG-6Y_XWFuOp1LwYWrTlsao18c").responseJSON { response in
                let parkingLocations = self.locations(forNearestRoadResponseJSON: response.result.value as! [String : Any])
                
                Alamofire.request(originGeocodingRequestURL).responseJSON { response in
                    let originLocation = self.location(forGeocodingResponseJSON: response.result.value as! [String : Any])
                    self.requestDirections(toParkingLocation: parkingLocations,
                                           fromOriginLocation: originLocation)
                }
            }
        }
    }
    
    private func geocodingRequestURL(forAddress address: String) -> String {
        return "https://maps.googleapis.com/maps/api/geocode/json?address=\(address.replacingOccurrences(of: " ", with: "%20"))&key=AIzaSyBkQwuhVwvSRnWVr1pbAd2qZfvRFZWtCH4"
    }
    
    private func location(forGeocodingResponseJSON json: [String : Any]) -> (lat: Float, lng: Float) {
        let results = json["results"] as! [[String : Any]]
        let geometry = results[0]["geometry"] as! [String : Any]
        let location = geometry["location"] as! [String : Float]
        
        return (lat: location["lat"]!, lng: location["lng"]!)
    }
    
    private func randomLocations(aroundLocation location: (lat: Float, lng: Float)) -> [(lat: Float, lng: Float)] {
        var randomLocations = [(lat: Float, lng: Float)]()
        
        let radius: Float = 500 / 111300
        
        for _ in 0 ..< 10 {
            let u = Float(arc4random()) / Float(UINT32_MAX)
            let v = Float(arc4random()) / Float(UINT32_MAX)
            let w = radius * sqrt(u)
            let t = 2 * .pi * v
            let x = w * cos(t)
            let y = w * sin(t)
            
            let lat = y + location.lat
            let lng = x + location.lng
            
            randomLocations.append((lat: lat, lng: lng))
        }
        
        return randomLocations
    }
    
    private func locations(forNearestRoadResponseJSON json: [String : Any]) -> [(lat: Float, lng: Float)] {
        var locations = [(lat: Float, lng: Float)]()
        
        var previousOriginalIndex = -1
        
        let snappedPoints = json["snappedPoints"] as! [[String : Any]]
        
        for snappedPoint in snappedPoints {
            let originalIndex = snappedPoint["originalIndex"] as! Int
            
            if originalIndex != previousOriginalIndex {
                let location = snappedPoint["location"] as! [String : Float]
                locations.append((lat: location["latitude"]!, lng: location["longitude"]!))
                
                previousOriginalIndex = originalIndex
            }
        }
        
        return locations
    }
    
    private func requestDirections(toParkingLocation parkingLocations: [(lat: Float, lng: Float)],
                                   fromOriginLocation originLocation: (lat: Float, lng: Float)) {
        if parkingLocations.isEmpty {
            self.performSegue(withIdentifier: "showRoutes", sender: self)
        } else {
            var parkingLocations = parkingLocations
            let parkingLocation = parkingLocations.removeFirst()
            
            Alamofire.request("https://maps.googleapis.com/maps/api/directions/json?origin=\(originLocation.lat),\(originLocation.lng)&destination=\(parkingLocation.lat),\(parkingLocation.lng)&key=AIzaSyDXHBInPM0n6zl7VNYs3VkXDpHQMj7BhoU").responseJSON { response in
                let polyline = self.polyline(forDirectionsResponseJSON: response.result.value as! [String : Any])
                let endAddress = self.endAddress(forDirectionsResponseJSON: response.result.value as! [String : Any])
                let duration = self.duration(forDirectionsResponseJSON: response.result.value as! [String : Any])
                let route = Route(polyline: polyline, endAddress: endAddress, duration: duration)
                self.routes.append(route)
                self.requestDirections(toParkingLocation: parkingLocations,
                                       fromOriginLocation: originLocation)
            }
        }
    }
    
    private func polyline(forDirectionsResponseJSON json: [String : Any]) -> String {
        let routes = json["routes"] as! [[String : Any]]
        let overviewPolyline = routes[0]["overview_polyline"] as! [String : String]
        
        return overviewPolyline["points"]!
    }
    
    private func endAddress(forDirectionsResponseJSON json: [String : Any]) -> String {
        let routes = json["routes"] as! [[String : Any]]
        let legs = routes[0]["legs"] as! [[String : Any]]
        
        return legs[0]["end_address"] as! String
    }
    
    private func duration(forDirectionsResponseJSON json: [String : Any]) -> String {
        let routes = json["routes"] as! [[String : Any]]
        let legs = routes[0]["legs"] as! [[String : Any]]
        let duration = legs[0]["duration"] as! [String : Any]
        
        return duration["text"] as! String
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRoutes" {
            let routeVC = segue.destination as! RouteViewController
            routeVC.destination = self.destinationTextField.text!
            routeVC.destinationLocation = self.destinationLocation
            routeVC.routes = self.routes
        }
    }
}
