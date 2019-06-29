//
//  ViewController.swift
//  Next v1
//
//  Created by Andrew Brown on 10/6/19.
//  Copyright © 2019 Andrew Brown. All rights reserved.
//


// https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.667677,151.305951&radius=1000&type=bar&key=AIzaSyCsafByyASM6N5ZqmgJyHBttYpCZn0R4Mk

import UIKit
import GoogleMaps
import GooglePlaces

var APIKEY = "AIzaSyCsafByyASM6N5ZqmgJyHBttYpCZn0R4Mk"

struct place {
    let name: String
    let lat: Double
    let lng: Double
    let address: String
    
    init(n: String, lt: Double, lg: Double, a: String) {
        name = n
        lat = lt
        lng = lg
        address = a
    }
}

class MapViewController: UIViewController, GMSMapViewDelegate {
 
    // setup location manager
    var locationManager = CLLocationManager()
    
    // set current location to default mona street
    var currentLocation = CLLocation(latitude: -33.667677, longitude: 151.305951)
    
    // set mapview variable
    var mapView: GMSMapView!
    
    // set places client
    var placesClient: GMSPlacesClient!
    
    // set zoom level
    var zoomLevel: Float = 15
    
    // arrays for holding nearby places
    var nearbyBars: [place] = []
    var nearbyNightClubs: [place] = []
    
    // A default location to use when location permission is not granted.
    let defaultLocation = CLLocation(latitude: -33.667677, longitude: 151.305951)
    
    // let searchNearbyPlacesArray : [(MapViewController) -> () -> ()] = [nearbyBars, nearbyNightClubs, nearbyAll]
    
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        // initialize places client
        placesClient = GMSPlacesClient.shared()
        
        // set up the views
        setupMenuBar()
        setupMapView()
    
    }
    
    let menuBar: MenuBar = {
        let mb = MenuBar()
        return mb
    }()
    
    private func setupMenuBar() {
        view.addSubview(menuBar)
        view.addConstraintsWithFormat("H:|[v0]|", views: menuBar)
        view.addConstraintsWithFormat("V:|-50-[v0(50)]", views: menuBar)
    }
    
    //func
    
    func setupMapView() {
        
        // Create first camera view
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        // create map
        mapView = GMSMapView.map(withFrame: CGRect(x: 10, y: 110, width: self.view.bounds.width - 20, height: self.view.bounds.height - 205), camera: camera)
        
        // round the edges
        mapView.layer.cornerRadius = 25
        
        // not sure what this does
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
        
        // this section is for adding the json style sheet
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
    }
    
    // function for searching nearby places
    func searchNearbyPlaces(location: CLLocation) {
        
        // clear the array
        nearbyBars.removeAll()
        nearbyNightClubs.removeAll()
        
        // string for holding google places api url
        var googleString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location.coordinate.latitude),\(location.coordinate.longitude)&radius=1000&type=bar&key=\(APIKEY)"
        
        googleString = googleString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        // convert url string to url
        var urlRequest = URLRequest(url: URL(string: googleString)!)
        
        // set url method to get request
        urlRequest.httpMethod = "GET"
        
        dispatchGroup.enter()
        
        // send the get request
        let task = URLSession.shared.dataTask(with: urlRequest) {
            (data, response, error) in
            
            // if there is no error
            if error == nil {
                
                // get the json response object
                let jsonObject = try? JSONSerialization.jsonObject(with: data! as Data, options: [])
                
                // print the json object
                //print("Json == \(jsonObject)")
                
                // convert json object to string
                if let jsonArray = jsonObject as? [String: Any] {
                    
                    // this will decode all the results into new variables
                    if let results = jsonArray["results"] as! [Any]? {
                        for result in results {
                            if let locationDictionary = result as? [String : Any] {
                                let geometry = locationDictionary["geometry"]! as! [String : Any]
                                let name = locationDictionary["name"] as! String
                                let address = locationDictionary["vicinity"] as! String
                                let location = geometry["location"]! as! [String : Any]
                                let lat = location["lat"] as! Double
                                let long = location["lng"] as! Double
                                let types = locationDictionary["types"] as! [String]
                                
                                // create new place with variables
                                let newVenue = place(n:name, lt:lat, lg:long, a:address)
                                
                                // add place to neary places array
                                if types.contains("night_club") {
                                    self.nearbyNightClubs.append(newVenue)
                                }
                                
                                if types.contains("bar") && !(types.contains("night_club")) {
                                    self.nearbyBars.append(newVenue)
                                }
                            }
                        }
                    }
                }
                
                // print count of nearby places
                print("NEARBY Night clubs: \(self.nearbyNightClubs.count)")
                print("NEARBY Bars: \(self.nearbyBars.count)")
                self.dispatchGroup.leave()
                
            } else {
                // error handle
            }
            }.resume()
        
    }
    
    func drawNearbyBars() {
        
        print("drawing bars")
        // if there is at least one bar
        if nearbyBars.count != 0 {
            
            // loop through bars and add them to the screen
            for p in nearbyBars {
                let position = CLLocationCoordinate2D(latitude: p.lat, longitude: p.lng)
                let marker = GMSMarker(position: position)
                marker.title = p.name
                marker.snippet = p.address
                let img = UIImage(named: "cocktail.png")
                marker.icon = img
                marker.map = mapView
            }
        }
    }
    
    func drawNearbyNightClubs() {
        print("drawing night clubs")
        // if there is at least one night club
        if nearbyNightClubs.count > 0 {
            
            // loop through bars and add them to the screen
            for p in nearbyNightClubs {
                let position = CLLocationCoordinate2D(latitude: p.lat, longitude: p.lng)
                let marker = GMSMarker(position: position)
                marker.title = p.name
                marker.snippet = p.address
                let img = UIImage(named: "record.png")
                marker.icon = img
                marker.map = mapView
            }
        }
    }
    
    func drawNearbyAll() {
        drawNearbyBars()
        drawNearbyNightClubs()
    }
}

// Delegates to handle events for the location manager.
extension MapViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        //print("Location: \(location)")
        
        // update camera with location
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        // not sure what this does
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        // set current location
        currentLocation = location
        
        // search nearby places from current location
        searchNearbyPlaces(location: currentLocation)
        
        dispatchGroup.notify(queue: .main) {
            self.drawNearbyAll()
        }
        
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
