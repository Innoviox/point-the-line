//
//  ViewController.swift
//  point2
//
//  Created by Simon Chervenak on 10/6/22.
//

import UIKit

class ViewController: UIViewController {
    private var lineView: LineView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lineView = LineView(x: self.view.frame.width / 2, y: self.view.frame.origin.y, width: 10, height: self.view.frame.height)
        self.view.addSubview(self.lineView)
    }


}

