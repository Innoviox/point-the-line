//
//  LineView.swift
//  point2
//
//  Created by Simon Chervenak on 10/6/22.
//

import Foundation
import UIKit

class LineView: UIView {
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        
        self.layer.borderWidth = 5;
        self.layer.borderColor = UIColor.blue.cgColor;
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
