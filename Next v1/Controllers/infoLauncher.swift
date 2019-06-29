//
//  infoLauncher.swift
//  Next v1
//
//  Created by Andrew Brown on 29/6/19.
//  Copyright © 2019 Andrew Brown. All rights reserved.
//

import UIKit

class InfoLauncher: NSObject {
    
    let blackView = UIView()
    
    let infoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.darkGray
        cv.layer.cornerRadius = 25
        return cv
    }()
    
    func launch() {
        // add slide up menu here
        if let window = UIApplication.shared.keyWindow {
            
            blackView.backgroundColor = UIColor.clear//UIColor(white: 0, alpha: 0.5)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(blackView)
            window.addSubview(infoCollectionView)
            
            let height: CGFloat = 200
            let y = window.frame.height - height - 90
            infoCollectionView.frame = CGRect(x: 0, y: y, width: window.frame.width, height: window.frame.height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.infoCollectionView.frame = CGRect(x: 0, y: y, width: window.frame.width, height: height)
            }, completion: nil)
        }
    }
    
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.5, animations: {
            self.blackView.alpha = 0
            if let window = UIApplication.shared.keyWindow {
                self.infoCollectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.infoCollectionView.frame.width, height: self.infoCollectionView.frame.height)
            }
        })
    }
    
    override init() {
        super.init()
    }
}
