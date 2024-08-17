//
//  MapManager.swift
//  Navigation
//
//  Created by Muhammed Elsayed on 16/08/2024.
//

import UIKit
import GoogleMaps

class MapManager {
    func displayRoute(on mapView: GMSMapView?, path: GMSPath) {
        mapView?.clear()
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 4.0
        polyline.map = mapView
        let bounds = GMSCoordinateBounds(path: path)
        mapView?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
    }
}
