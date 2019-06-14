//
//  PhotoAlbumViewController.swift
//  UdacityVirtualtourist
//
//  Created by mac on 6/14/19.
//  Copyright © 2019 NorensIKT. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {

    var selectedAnnotation: MKPointAnnotation?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let selectedAnnotation = selectedAnnotation else {
            preconditionFailure("You need to set the selectedAnnotation in this view controller else this view is rendered useless.")
        }
        
        let coordinate = selectedAnnotation.coordinate
        mapView.centerMapOnLocation(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), regionRadius: 100)
        mapView.addAnnotation(selectedAnnotation)
        mapView.disableUserInteraction()
    }
}
