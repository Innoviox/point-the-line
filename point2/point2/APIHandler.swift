//
//  APIHandler.swift
//  point2
//
//  Created by Simon Chervenak on 11/15/23.
//

import Foundation
import CoreLocation

class APIHandler {
    static let shared = APIHandler()
    
    let GMAK: String
    let OAAK: String
    
    init() {
        GMAK = Bundle.main.infoDictionary!["GOOGLE_MAPS_API_KEY"] as! String
        OAAK = Bundle.main.infoDictionary!["OPENAI_API_KEY"] as! String
    }
    
    func nearbyPlaces(center: CLLocationCoordinate2D, radius: Int = 100, url: String = "https://places.googleapis.com/v1/places:searchNearby") {
        let body: [String : Any] = [
            "maxResultCount": 10,
            "rankPreference": "DISTANCE",
            "locationRestriction": [
                "circle": [
                    "center": [
                        "latitude": center.latitude,
                        "longitude": center.longitude
                    ],
                    "radius": radius
                ]
            ]
        ]

        let headers = [
            "X-Goog-Api-Key": GMAK,
            "X-Goog-FieldMask": "places.displayName,places.photos"
        ]
        
        AF.request(url,
                   method: .post,
                   headers: headers,
                   parameters: body,
                   encoder: JSONParameterEncoder.default)
        .responseDecodable(of: DecodableType.self) { response in
            print(response)
        }
    }
    
//    def get_photo(name, size=512, url="https://places.googleapis.com/v1/{name}/media?key={key}&maxHeightPx={size}&maxWidthPx={size}"):
//        r = requests.get(url.format(name=name, key=API_KEY, size=size), stream=True)
//        return r.content
    
    func photos(name: String, size: Int = 512) {
        let url = "https://places.googleapis.com/v1/\(name)/media?key=\(GMAK)&maxHeightPx=\(size)&maxWidthPx=\(size)"
        
        AF.request(url).responseData { response in
            debugPrint("Response: \(response)")
        }
    }
}
