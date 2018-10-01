//
//  KFVDestinationMap.swift
//  KifuSF
//
//  Created by Alexandru Turcanu on 01/10/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit
import MapKit
import PureLayout

class KFVDestinationMap: UIView {
    let mapView = MKMapView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(mapView)
        
        mapView.clipsToBounds = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        mapView.autoPinEdge(toSuperviewEdge: .leading, withInset: 8)
        mapView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 8)
        mapView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
        mapView.autoSetDimension(.height, toSize: 200)
        
        mapView.layer.cornerRadius = CALayer.kfCornerRadius
        layer.setUpShadow()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}