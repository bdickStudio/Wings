//
//  infoLauncher.swift
//  Next v1
//
//  Created by Andrew Brown on 29/6/19.
//  Copyright © 2019 Andrew Brown. All rights reserved.
//

import UIKit

import GoogleMaps

class InfoLauncher: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let backgroundView = UIView()
    let infoBarView = UIView()
    
    var mapView: GMSMapView?
    
    let infoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.darkGray
        //cv.layer.cornerRadius = 25
        return cv
    }()
    
    let cellId = "cellId"
    
    func launch(mv: GMSMapView, place: Place) {
        
        self.mapView = mv
        
        let placeName: UILabel = {
            let label = UILabel()
            label.text = place.name
            label.textColor = UIColor.white
            label.font = UIFont.boldSystemFont(ofSize: 20)
            return label
        }()
        
        let iconImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: place.type)
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
        
        if let window = UIApplication.shared.keyWindow {
            
            backgroundView.backgroundColor = UIColor.clear
            infoBarView.backgroundColor = UIColor.darkGray
            infoBarView.layer.cornerRadius = 25
            
            backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(backgroundView)
            window.addSubview(infoBarView)
            
            infoBarView.addSubview(placeName)
            infoBarView.addSubview(iconImageView)
            infoBarView.addConstraintsWithFormat("H:|-15-[v0(25)]-8-[v1]|", views: iconImageView, placeName)
            infoBarView.addConstraintsWithFormat("V:|-15-[v0(25)]", views: placeName)
            infoBarView.addConstraintsWithFormat("V:|-15-[v0(25)]", views: iconImageView)
            
            //whiteView.addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
            
            
            let height: CGFloat = 200
            let y = window.frame.height - height - 90
            infoBarView.frame = CGRect(x: 0, y: y, width: window.frame.width, height: window.frame.height)
            
            infoBarView.addSubview(infoCollectionView)
            
            let CVheight: CGFloat = 100
            infoCollectionView.frame = CGRect(x: 0, y: 60, width: infoBarView.frame.width, height: CVheight)
            
            backgroundView.frame = window.frame
            backgroundView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.backgroundView.alpha = 1
                self.infoBarView.frame = CGRect(x: 0, y: y, width: window.frame.width, height: height)
                self.mapView!.frame = CGRect(x: 0, y: 0, width: self.mapView!.frame.width, height: self.mapView!.frame.height - 200)
            }, completion: nil)
        }
    }
    
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundView.alpha = 0
            if let window = UIApplication.shared.keyWindow {
                self.infoBarView.frame = CGRect(x: 0, y: window.frame.height, width: self.infoBarView.frame.width, height: self.infoBarView.frame.height)
            }
            
            self.mapView!.frame = CGRect(x: 0, y: 0, width: self.mapView!.frame.width, height: self.mapView!.frame.height + 200)
        })
    }
    
    override init() {
        super.init()
        
        infoCollectionView.dataSource = self
        infoCollectionView.delegate = self
        
        infoCollectionView.register(InfoCell.self, forCellWithReuseIdentifier: cellId)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = infoCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return(CGSize(width: infoCollectionView.frame.width / 5, height: 100))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
