//
//  MapViewController.swift
//  UdacityVirtualtourist
//
//  Created by mac on 6/14/19.
//  Copyright © 2019 NorensIKT. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties for MapView
    private let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    private let dummyAnnotationCoordinate = CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661)
    private var selectedAnnotation: MKPointAnnotation?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.centerMapOnLocation(location: initialLocation)
        mapView.delegate = self
    }
    
    // MARK: - IBActions
    
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: mapView)
        debugPrint("handleLongPress: location \(location)")
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        mapView.addPointAnnotation(coordinate: coordinate)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? PhotoAlbumViewController, let annotationView = sender as? MKAnnotationView, let annotation = annotationView.annotation as? MKPointAnnotation {
                viewController.selectedAnnotation = annotation
        }
     }
    
    // MARK: - Helper Functions
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        performSegue(withIdentifier: "photoAlbum", sender: view)
    }
}
