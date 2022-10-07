//
//  ViewController.swift
//  point2
//
//  Created by Simon Chervenak on 10/6/22.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    private var lineView: LineView!
    private var locationManager = CLLocationManager()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.lineView = LineView(x: self.view.frame.width / 2, y: self.view.frame.origin.y, width: 10, height: self.view.frame.height)
//        self.view.addSubview(self.lineView)
        
        if (CLLocationManager.headingAvailable()) {
            locationManager.headingFilter = 1
            locationManager.startUpdatingHeading()
            locationManager.delegate = self
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
//        direction.text = "Direction: \(heading.magneticHeading)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

