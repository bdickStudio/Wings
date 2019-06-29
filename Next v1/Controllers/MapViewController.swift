//
//  ViewController.swift
//  Next v1
//
//  Created by Andrew Brown on 10/6/19.
//  Copyright © 2019 Andrew Brown. All rights reserved.
//


// https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.667677,151.305951&radius=1000&type=bar&key=AIzaSyCsafByyASM6N5ZqmgJyHBttYpCZn0R4Mk

import UIKit

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

class MapViewController: UIViewController, MenuBarListener {
    
    let menuBar: MenuBar = {
        let mb = MenuBar()
        return mb
    }()
    
    let mapView: MapView = {
        let mv = MapView()
        return mv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuBar.delegate = self
        
        // set up the views
        setupMenuBar()
        setupMapView()
    }
    
    private func setupMenuBar() {
        view.addSubview(menuBar)
        view.addConstraintsWithFormat("H:|[v0]|", views: menuBar)
        view.addConstraintsWithFormat("V:|-50-[v0(50)]", views: menuBar)
    }
    
    func setupMapView() {
        view.addSubview(mapView)
        view.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: mapView)
        view.addConstraintsWithFormat("V:|-110-[v0]-95-|", views: mapView)
    }
    
    func didSelectMenuOption(option: Int) {
        
        mapView.mapView.clear()
        if option == 0 {
            mapView.drawNearbyBars()
        }
        
        else if option == 1 {
            mapView.drawNearbyNightClubs()
        }
        
        else {
            mapView.drawNearbyAll()
        }
    }
}
