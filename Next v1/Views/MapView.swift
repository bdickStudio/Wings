//
//  MapView.swift
//  Next v1
//
//  Created by Andrew Brown on 29/6/19.
//  Copyright © 2019 Andrew Brown. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

var APIKEY = "AIzaSyCsafByyASM6N5ZqmgJyHBttYpCZn0R4Mk"

struct Place {
    let name: String
    let id: String
    let lat: Double
    let lng: Double
    let address: String
    var type: String
    
    init(n: String, i: String, lt: Double, lg: Double, a: String, t: String) {
        name = n
        id = i
        lat = lt
        lng = lg
        address = a
        type = t
    }
}

class MapView: UIView, GMSMapViewDelegate {
    
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
    var nearbyBars: [Place] = []
    var nearbyNightClubs: [Place] = []
    
    // A default location to use when location permission is not granted.
    let defaultLocation = CLLocation(latitude: -33.667677, longitude: 151.305951)
    
    // let searchNearbyPlacesArray : [(MapViewController) -> () -> ()] = [nearbyBars, nearbyNightClubs, nearbyAll]
    
    // dispatch group for waiting for GET response
    let dispatchGroup = DispatchGroup()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        GMSServices.provideAPIKey("AIzaSyCsafByyASM6N5ZqmgJyHBttYpCZn0R4Mk")
        GMSPlacesClient.provideAPIKey("AIzaSyCsafByyASM6N5ZqmgJyHBttYpCZn0R4Mk")
        
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        // initialize places client
        placesClient = GMSPlacesClient.shared()
        
        setupMapView()
        setupStyle()
        
    }
    
    func setupMapView() {
        
        // Create first camera view
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        // create map
        //mapView = GMSMapView.map(withFrame: CGRect(x: 10, y: 110, width: self.bounds.width - 20, height: self.bounds.height - 205), camera: camera)
        mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        
        mapView.delegate = self
        
        // round the edges
        mapView.layer.cornerRadius = 25
        
        // not sure what this does
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        
        // Add the map to the view, hide it until we've got a location update.
        addSubview(mapView)
        mapView.isHidden = true
        
    }
    
    func setupStyle() {
        
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
                                let id = locationDictionary["place_id"] as! String
                                let address = locationDictionary["vicinity"] as! String
                                let location = geometry["location"]! as! [String : Any]
                                let lat = location["lat"] as! Double
                                let long = location["lng"] as! Double
                                let types = locationDictionary["types"] as! [String]
                                
                                let openNowDict = locationDictionary["opening_hours"] as! [String : Any]
                                let openNow = openNowDict["open_now"] as! Bool
                                
                                // create new place with variables
                                var newVenue = Place(n:name, i:id, lt:lat, lg:long, a:address, t:"")
                                
                                // if place is open add to appropriate array
                                if openNow {
                                
                                    if types.contains("night_club") {
                                        newVenue.type = "record.png"
                                        self.nearbyNightClubs.append(newVenue)
                                    }
                                
                                    if types.contains("bar") && !(types.contains("night_club")) {
                                        newVenue.type = "cocktail.png"
                                        self.nearbyBars.append(newVenue)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // print count of nearby places
                //print("NEARBY Night clubs: \(self.nearbyNightClubs.count)")
                //print("NEARBY Bars: \(self.nearbyBars.count)")
                self.dispatchGroup.leave()
                
            } else {
                // error handle
            }
            }.resume()
        
    }
    
    func drawNearbyBars() {
        
        //print("drawing bars")
        // if there is at least one bar
        if nearbyBars.count != 0 {
            
            // loop through bars and add them to the screen
            for p in nearbyBars {
                let position = CLLocationCoordinate2D(latitude: p.lat, longitude: p.lng)
                let marker = GMSMarker(position: position)
                marker.title = p.name
                marker.snippet = p.address
                let img = UIImage(named: p.type)
                marker.icon = img
                marker.map = mapView
            }
        }
    }
    
    func drawNearbyNightClubs() {
        //print("drawing night clubs")
        // if there is at least one night club
        if nearbyNightClubs.count > 0 {
            
            // loop through bars and add them to the screen
            for p in nearbyNightClubs {
                let position = CLLocationCoordinate2D(latitude: p.lat, longitude: p.lng)
                let marker = GMSMarker(position: position)
                //marker.title = p.name
                //marker.snippet = p.address
                let img = UIImage(named: p.type)
                marker.icon = img
                marker.map = self.mapView
            }
        }
    }
    
    func drawNearbyAll() {
        drawNearbyBars()
        drawNearbyNightClubs()
    }
    
    let infoLauncher = InfoLauncher()
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    
        let allNearByPlaces = nearbyBars + nearbyNightClubs
        var place: Place?
        
        for p in allNearByPlaces {
            if p.lat == marker.position.latitude && p.lng == marker.position.longitude {
                place = p
            }
        }
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.openingHours.rawValue))!
        
        placesClient?.fetchPlace(fromPlaceID: place!.id, placeFields: fields, sessionToken: nil, callback: {
            (place: GMSPlace?, error: Error?) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            if let place = place {
                //print(place.openingHours)
                print("The selected place is: \(place.name!)")
            }
        })
        
        infoLauncher.launch(mv: self.mapView, place: place!)
        
        return false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Delegates to handle events for the location manager.
extension MapView: CLLocationManagerDelegate {
    
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

