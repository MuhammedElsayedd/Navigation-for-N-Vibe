//
//  RouteService.swift
//  Navigation
//
//  Created by Muhammed Elsayed on 16/08/2024.
//

import UIKit
import GoogleMaps

class RouteService {
    let googleApiKey = "AIzaSyD_BCeQhmiiZ6VGJ8oX36ybWO8kLSijHjU"

    func fetchRoute(from start: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping (GMSPath?) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(start.latitude),\(start.longitude)&destination=\(destination.latitude),\(destination.longitude)&mode=walking&key=\(googleApiKey)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let routes = json["routes"] as? [[String: Any]],
                   let route = routes.first,
                   let overviewPolyline = route["overview_polyline"] as? [String: Any],
                   let points = overviewPolyline["points"] as? String {
                    let path = GMSPath(fromEncodedPath: points)
                    completion(path)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
}
