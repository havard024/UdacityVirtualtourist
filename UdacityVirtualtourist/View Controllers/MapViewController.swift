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
        mapView.addPointAnnotation(coordinate: dummyAnnotationCoordinate)
        mapView.delegate = self
    }
    
    // MARK: - IBActions
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: mapView)
        debugPrint("handleTap: location \(location)")
        handleGesture(location: location)
    }
    
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: mapView)
        debugPrint("handleLongPress: location \(location)")
        handleGesture(location: location)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? PhotoAlbumViewController, let annotationView = sender as? MKAnnotationView, let annotation = annotationView.annotation as? MKPointAnnotation {
                viewController.selectedAnnotation = annotation
        }
     }
    
    // MARK: - Helper Functions
    
    func handleGesture(location: CGPoint) {
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        #warning("Is this a safe way to detect if map annotation was clicked?")
        if let subview = mapView.hitTest(location, with: nil) {
            debugPrint("Clicked on subview: \(subview)")
            if subview.isKind(of: NSClassFromString("_MKBezierPathView")!) {
                debugPrint("Clicked on existing annotation don't add a new!")
            } else {
                mapView.addPointAnnotation(coordinate: coordinate)
            }
        } else {
            // Can this happen? Assume not
        }
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    #warning("Sometimes didSelect can be triggered after a gesture handler. This is not intentional and should be fixed somehow so that it is consistent that it either navigates or not every times.")
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        performSegue(withIdentifier: "photoAlbum", sender: view)
    }
}
