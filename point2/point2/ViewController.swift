//
//  ViewController.swift
//  point2
//
//  Created by Simon Chervenak on 10/6/22.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    private var lineView: LineView!
    private var locationManager = CLLocationManager()

    private var currentPlaceAnnotation = MKPointAnnotation()
    private var last_line: MKPolyline?
    
    @IBOutlet weak var map: MKMapView!
    
    private var zoomed = false
//    private var addedLine = false
    
    private var last_center: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (CLLocationManager.headingAvailable()) {
            locationManager.headingFilter = 1
            locationManager.startUpdatingHeading()
            locationManager.delegate = self
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.startUpdatingLocation()
        }
        
        map.showsUserLocation = true
        map.delegate = self
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
//        direction.text = "Direction: \(heading.magneticHeading)"
        
        guard let center = last_center else {
            return
        }
        
        if let line = last_line {
            map.removeOverlay(line)
        }
        
        let dist = sqrt(pow(self.map.region.span.longitudeDelta, 2) + pow(self.map.region.span.latitudeDelta, 2))
        print(dist)
        let next_point = center.point(distance: dist, angle: heading.magneticHeading)
        
        last_line = MKPolyline(coordinates: [center, next_point], count: 2)
        map.addOverlay(last_line!)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            if (!zoomed) {
                zoomed = true
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.map.setRegion(region, animated: false)
            } else {
                self.map.setCenter(center, animated: true)
            }
            
            last_center = center
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            testlineRenderer.strokeColor = .blue
            testlineRenderer.lineWidth = 2.0
            return testlineRenderer
        }
        
        fatalError("Something wrong...")
    }
}

extension CLLocationCoordinate2D {
    func point(distance: Double, angle: CLLocationDirection) -> CLLocationCoordinate2D {
        let long_delta = distance * cos(angle * .pi / 180)
        let lat_delta  = distance * sin(angle * .pi / 180)
                
        return CLLocationCoordinate2D(latitude:  (latitude + lat_delta).clamped(to: -90...90),
                                      longitude: (longitude + long_delta).clamped(to: -180...180))
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
