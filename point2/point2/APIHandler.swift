//
//  APIHandler.swift
//  point2
//
//  Created by Simon Chervenak on 11/15/23.
//

import Foundation

class APIHandler {
    static let shared = APIHandler()
    
    let GMAK: String
    let OAAK: String
    
    init() {
        GMAK = Bundle.main.infoDictionary!["GOOGLE_MAPS_API_KEY"]
    }
    
}
