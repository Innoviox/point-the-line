//
//  ViewController.swift
//  point2
//
//  Created by Simon Chervenak on 10/6/22.
//

import UIKit
import CoreLocation
import MapKit

let selected = UIColor.red
let unselected = UIColor.red.withAlphaComponent(0.25)

class ViewController: UIViewController {
    private var lineView: LineView!
    private var locationManager = CLLocationManager()

    private var currentPlaceAnnotation = MKPointAnnotation()
    private var last_line: MKPolyline?
    private var line_length: Double = 0
    private var last_heading: CLLocationDirection = 0 // its a double
    private var polygons: [MKOverlay] = []
    private var annotations: [MKPointAnnotation] = []

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var resultsButton: UIButton!
    
    @IBOutlet weak var hint: UILabel!
    
    private var zoomed = false
    
    private var state = 0
    
    // dont set, its for simulator
    private var last_center: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 37.785834,
                                                                              longitude: -122.406417)
    
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
        
        // https://stackoverflow.com/questions/43778826/detecting-touches-on-mkoverlay
        let tap = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        self.map.addGestureRecognizer(tap)
        
        // manual simulator stuff cause my phone doesnt work
        let region = MKCoordinateRegion(center: last_center!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.map.setRegion(region, animated: false)
        
//        view.bringSubviewToFront(resultsButton)
        line_length = sqrt(pow(self.map.region.span.longitudeDelta, 2) + pow(self.map.region.span.latitudeDelta, 2))
        let next_point = last_center!.point(distance: line_length, angle: last_heading)
        
        last_line = MKPolyline(coordinates: [last_center!, next_point], count: 2)
        map.addOverlay(last_line!)
    }
    
    @IBAction func resultsButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toResults", sender: sender)
    }
    
    @IBAction func showPois(_ sender: Any) {
        if (state == 0) {
            makeSearches() { [self] results in
                print("RESULTS", results.count)
                for mapItem in results {
                    let annotation = MKPointAnnotation()
                    annotation.title = mapItem.name
                    annotation.coordinate = mapItem.placemark.coordinate
                    annotations.append(annotation)
                    map.addAnnotation(annotation)
                }
                hint.isHidden = false
                state = 1
            }
        } else if (state == 1) {
            
        }
    }
    
    private func makeSearches(completion: @escaping ([MKMapItem]) -> Void) {
        // request all pois on screen, then find the ones on the line is the current idea
        // searching along line is very slow dw
        
        let nSquares: Double = 10
        
        let mapSpan = map.region.span
        let span = MKCoordinateSpan(latitudeDelta: mapSpan.latitudeDelta / (nSquares * 2),
                                    longitudeDelta: mapSpan.longitudeDelta / (nSquares * 2))
        
        clearAnnotations()
        
        for i in 0..<Int(nSquares) {
            var region = MKCoordinateRegion()
            region.center = last_center!.point(distance: (Double(i) + 0.5) * line_length / nSquares, angle: last_heading)
            region.span = span
            
            render(region: region)
            
//            let request = MKLocalPointsOfInterestRequest(coordinateRegion: region)
//
//            let search = MKLocalSearch(request: request)
//            search.start { [unowned self] (response, error) in
//                guard error == nil else {
//                    print("plato search error", error!.localizedDescription)
//                    return
//                }
//
//                completion(response?.mapItems ?? [])
//            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResults" {
            if let rtvc = segue.destination as? ResultsTableViewController {
                rtvc.center = last_center
                rtvc.region = map.regionThatFits(map.region)
                rtvc.angle = last_heading
            }
        }
    }
    
    func render(region: MKCoordinateRegion) {
        let center = region.center
        let coordinates = [CLLocationCoordinate2D(latitude: center.latitude + region.span.latitudeDelta,
                                                  longitude: center.longitude + region.span.longitudeDelta),
                           CLLocationCoordinate2D(latitude: center.latitude + region.span.latitudeDelta,
                                                  longitude: center.longitude - region.span.longitudeDelta),
                           CLLocationCoordinate2D(latitude: center.latitude - region.span.latitudeDelta,
                                                  longitude: center.longitude - region.span.longitudeDelta),
                           CLLocationCoordinate2D(latitude: center.latitude - region.span.latitudeDelta,
                                                  longitude: center.longitude + region.span.longitudeDelta)]
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        
        print(center, region.span.latitudeDelta)
        let circle = MKCircle(center: center, radius: 100)
        polygons.append(circle)
//        polygons.append(polygon)
        map.addOverlay(circle)
//        map.addOverlay(polygon)
    }
    
    func clearAnnotations() {
        for polygon in polygons {
            map.removeOverlay(polygon)
        }
        for annotation in annotations {
            map.removeAnnotation(annotation)
        }
        annotations = []
        polygons = []
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
        last_heading = heading.magneticHeading
        
        guard let center = last_center else {
            return
        }
        
        if let line = last_line {
            map.removeOverlay(line)
        }
        
        line_length = sqrt(pow(self.map.region.span.longitudeDelta, 2) + pow(self.map.region.span.latitudeDelta, 2))
        let next_point = center.point(distance: line_length, angle: last_heading)
        
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
        } else if let polygon = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.fillColor = UIColor.blue.withAlphaComponent(0.25)
            return renderer
        } else if let circle = overlay as? MKCircle {
            let renderer = MKCircleRenderer(circle: circle)
            renderer.fillColor = unselected
            return renderer
        }
        
        fatalError("Something wrong...")
    }
    
    @objc func mapTapped(_ gesture: UITapGestureRecognizer){
        let point = gesture.location(in: self.map)
        let coordinate = self.map.convert(point, toCoordinateFrom: nil)
        let mappoint = MKMapPoint(coordinate)
        for overlay in self.map.overlays {
//            if let polygon = overlay as? MKPolygon {
//                guard let renderer = self.map.renderer(for: polygon) as? MKPolygonRenderer else { continue }
//                let tapPoint = renderer.point(for: mappoint)
//                if renderer.path.contains(tapPoint) {
//                    print("Tap was inside this polygon")
//                    break // If you have overlapping overlays then you'll need an array of overlays which the touch is in, so remove this line.
//                }
//                continue
//            }
            if let circle = overlay as? MKCircle {
                let centerMP = MKMapPoint(circle.coordinate)
                let distance = mappoint.distance(to: centerMP) // distance between the touch point and the center of the circle
                if distance <= circle.radius {
                    guard let renderer = self.map.renderer(for: circle) as? MKCircleRenderer else { continue }
                    renderer.fillColor = renderer.fillColor == unselected ? selected : unselected
                    print("Tap was inside this circle")
                    break // If you have overlapping overlays then you'll need an array of overlays which the touch is in, so remove this line.
                }
                continue
            }
        }
    }
}

extension CLLocationCoordinate2D {
    func point(distance: Double, angle preAngle: CLLocationDirection) -> CLLocationCoordinate2D {
        let angle = 90 - preAngle;
        let long_delta = distance * cos(angle * .pi / 180)
        let lat_delta  = distance * sin(angle * .pi / 180)
                
        return CLLocationCoordinate2D(latitude:   (latitude + lat_delta).clamped(to: -90...90),
                                      longitude: (longitude + long_delta).clamped(to: -180...180))
    }
    
    func distance(to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: latitude, longitude: longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
    
    // might do something? https://stackoverflow.com/questions/6924742/valid-way-to-calculate-angle-between-2-cllocations
    func heading(to: CLLocationCoordinate2D) -> Double {
        let lat1 = self.latitude * .pi / 180
        let lon1 = self.longitude * .pi / 180

        let lat2 = to.latitude * .pi / 180
        let lon2 = to.longitude * .pi / 180

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)

        let headingDegrees = atan2(y, x) * 180 / .pi
        if headingDegrees >= 0 {
            return headingDegrees
        } else {
            return headingDegrees + 360
        }
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
