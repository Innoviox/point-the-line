//
//  APIHandler.swift
//  point2
//
//  Created by Simon Chervenak on 11/15/23.
//

import Foundation
import CoreLocation
import Alamofire

struct Circle: Encodable {
    let center: [String: CLLocationDegrees]
    let radius: Int
}

struct LocationRestriction: Encodable {
    let circle: Circle
}

struct NearbyPlacesBody: Encodable {
    let maxResultCount: Int
    let rankPreference: String
    let locationRestriction: LocationRestriction
}

class APIHandler {
    static let shared = APIHandler()
    
    let GMAK: String
    let OAAK: String
    
    init() {
        GMAK = Bundle.main.infoDictionary!["GOOGLE_MAPS_API_KEY"] as! String
        OAAK = Bundle.main.infoDictionary!["OPENAI_API_KEY"] as! String
    }
    
    func nearbyPlaces(center: CLLocationCoordinate2D, radius: Int = 100, url: String = "https://places.googleapis.com/v1/places:searchNearby") async {
        let body = NearbyPlacesBody(
            maxResultCount: 10,
            rankPreference: "DISTANCE",
            locationRestriction: LocationRestriction(
                circle: Circle(center: [
                    "latitude": center.latitude,
                    "longitude": center.longitude
                ],
                radius: radius)
            )
        )

        let headers: [String: String] = [
            "X-Goog-Api-Key": GMAK,
            "X-Goog-FieldMask": "places.displayName,places.photos"
        ]
        
        do {
            let url = URL(string: url)!
            var request = URLRequest(url: url)
            for (header, value) in headers {
                request.setValue(value, forHTTPHeaderField: header)
            }
            request.httpMethod = "POST"
            let encoder = JSONEncoder()
            let data = try encoder.encode(body)
            request.httpBody = data

            let (responseData, response) = try await URLSession.shared.upload(for: request, from: data, delegate: self)
        } catch {
            
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
