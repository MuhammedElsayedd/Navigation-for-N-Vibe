//
//  MapViewController.swift
//  Navigation
//
//  Created by Muhammed Elsayed on 16/08/2024.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class MapViewController: UIViewController, UITextFieldDelegate {

    var mapView: GMSMapView!
    var startTextField: UITextField!
    var destinationTextField: UITextField!
    var routeButton: UIButton!
    
    let routeService = RouteService()
    let mapManager = MapManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the map and store it in the class property
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let options = GMSMapViewOptions()
        mapView = GMSMapView(options: options)
        mapView.camera = camera
        mapView.frame = self.view.frame
        self.view.addSubview(mapView)
        
        // Setup UI for address input
        setupTextFields()
        setupButton()
    }

    func setupTextFields() {
        startTextField = createTextField(placeholder: "Enter starting address")
        destinationTextField = createTextField(placeholder: "Enter destination address")
        
        // Define the frame for both text fields
        let textFieldWidth = self.view.frame.width - 40
        let textFieldHeight: CGFloat = 40
        startTextField.frame = CGRect(x: 20, y: 100, width: textFieldWidth, height: textFieldHeight)
        destinationTextField.frame = CGRect(x: 20, y: startTextField.frame.maxY + 10, width: textFieldWidth, height: textFieldHeight)
        
        self.view.addSubview(startTextField)
        self.view.addSubview(destinationTextField)
    }
    
    func setupButton() {
        routeButton = UIButton(type: .system)
        routeButton.setTitle("Show Route", for: .normal)
        
        // Set button style
        routeButton.backgroundColor = UIColor.systemBlue
        routeButton.setTitleColor(.white, for: .normal)
        routeButton.layer.cornerRadius = 10
        routeButton.clipsToBounds = true
        
        // Set button frame
        let buttonWidth = self.view.frame.width - 40
        let buttonHeight: CGFloat = 40
        routeButton.frame = CGRect(x: 20, y: destinationTextField.frame.maxY + 20, width: buttonWidth, height: buttonHeight)
        
        routeButton.addTarget(self, action: #selector(calculateRoute), for: .touchUpInside)
        self.view.addSubview(routeButton)
    }

    func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        textField.delegate = self
        return textField
    }

    @objc func calculateRoute() {
        guard let startAddress = startTextField.text, !startAddress.isEmpty,
              let destinationAddress = destinationTextField.text, !destinationAddress.isEmpty else {
            print("Please enter both addresses")
            return
        }
        
        geocodeAddress(address: startAddress) { [weak self] startCoordinate in
            guard let startCoordinate = startCoordinate else { return }
            
            self?.geocodeAddress(address: destinationAddress) { [weak self] destinationCoordinate in
                guard let destinationCoordinate = destinationCoordinate else { return }
                
                self?.showRouteOnMap(from: startCoordinate, to: destinationCoordinate)
            }
        }
    }
    
    func geocodeAddress(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard let placemark = placemarks?.first, let location = placemark.location else {
                print("Geocoding failed: \(String(describing: error))")
                completion(nil)
                return
            }
            completion(location.coordinate)
        }
    }
    
    func showRouteOnMap(from start: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        routeService.fetchRoute(from: start, to: destination) { [weak self] path in
            guard let path = path else { return }
            DispatchQueue.main.async {
                self?.mapManager.displayRoute(on: self?.mapView, path: path)
            }
        }
    }
}
