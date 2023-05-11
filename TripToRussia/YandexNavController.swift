//
//  YandexNavController.swift
//  TripToRussia
//
//  Created by Рузаль Назмутдинов on 19.04.2023.
//

import UIKit
import YandexMapsMobile
import CoreLocation



class YandexNavController: UIViewController {
   
    var tempLonPoint: Double = 0
    var tempLatPoint: Double = 0
    var useLon: Double = 0
    var useLat: Double = 0
    var userLocation: YMKPoint?
    var drivingSession: YMKDrivingSession?
    var ROUTE_START_POINT:YMKPoint!
    var ROUTE_END_POINT: YMKPoint!
    var CAMERA_TARGET: YMKPoint!
    private let locationManager = CLLocationManager()
    @IBOutlet var mapView: YMKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
              locationManager.delegate = self
              locationManager.requestWhenInUseAuthorization()
              locationManager.requestLocation()
        let button = UIButton(type: .system)
        let buttonSize: CGFloat = 40
        let mapViewWidth = mapView.frame.width
        let mapViewHeight = mapView.frame.height
        button.frame = CGRect(x: mapViewWidth - buttonSize - 20, y: mapViewHeight / 2 - buttonSize / 2, width: buttonSize, height: buttonSize)
        button.frame = button.frame.offsetBy(dx: 0, dy: 300)
        button.layer.cornerRadius = buttonSize / 2
        button.backgroundColor = .red
        button.setTitle("Я", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        mapView.addSubview(button)


    }
    
}

//MARK: - EXTENSION. CLLocationManagerDelegate
extension YandexNavController: CLLocationManagerDelegate {
    //SetUp location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let requestPoints : [YMKRequestPoint] = [
                YMKRequestPoint(point: YMKPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), type: .waypoint, pointContext: nil),
                        YMKRequestPoint(point: YMKPoint(latitude: tempLatPoint, longitude: tempLonPoint), type: .waypoint, pointContext: nil),
                        ]
            let responseHandler = {(routesResponse: [YMKDrivingRoute]?, error: Error?) -> Void in
                        if let routes = routesResponse {
                            self.onRoutesReceived(routes: routes)
                        } else {
                            self.onRoutesError(error: error!)
                        }
                    }
            useLon = location.coordinate.longitude
            useLat = location.coordinate.latitude
            setUpMap(location: YMKPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
            let drivingOptions = YMKDrivingDrivingOptions(initialAzimuth: 0.0, routesCount: 1, avoidTolls: true, avoidUnpaved: false, avoidPoorConditions: false, departureTime: Date(),  annotationLanguage: 1)
                    let drivingRouter = YMKDirections.sharedInstance().createDrivingRouter()
                    drivingSession = drivingRouter.requestRoutes(
                        with: requestPoints,
                        drivingOptions: drivingOptions,
                        vehicleOptions: YMKDrivingVehicleOptions(),
                        routeHandler: responseHandler)
               
        }
    }
    @objc func buttonTapped() {
        setUpMap(location: YMKPoint(latitude: useLat, longitude: useLon))
       
    }

    func onRoutesReceived( routes: [YMKDrivingRoute]) {
            let mapObjects = mapView.mapWindow.map.mapObjects
            for route in routes {
                mapObjects.addPolyline(with: route.geometry)
            }
        }

        func onRoutesError( error: Error) {
            let routingError = (error as NSError).userInfo[YRTUnderlyingErrorKey] as! YRTError
            var errorMessage = "Unknown error"
            if routingError.isKind(of: YRTNetworkError.self) {
                errorMessage = "Network error"
            } else if routingError.isKind(of: YRTRemoteError.self) {
                errorMessage = "Remote server error"
            }

            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            present(alert, animated: true, completion: nil)
        }
    //Error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    //Zooming camera
    private func setUpMap(location: YMKPoint) {
        
        mapView.mapWindow.map.mapObjects.addPlacemark(with: location)
        mapView.mapWindow.map.move(
            with: YMKCameraPosition.init(target: location, zoom: 17, azimuth: 0, tilt: 0),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 1.6),
            cameraCallback: nil)
    }
    
   
    
}
