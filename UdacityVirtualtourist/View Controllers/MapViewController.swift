//
//  MapViewController.swift
//  UdacityVirtualtourist
//
//  Created by mac on 6/14/19.
//  Copyright © 2019 NorensIKT. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties for MapView
    private let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    private let dummyAnnotationCoordinate = CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661)
    private var selectedAnnotation: MKPointAnnotation?
    private var pins: [Pin] = []
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.centerMapOnLocation(location: initialLocation)
        mapView.delegate = self
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do {
            let result = try DataController.shared.viewContext.fetch(fetchRequest)
            debugPrint("Fetched pins from core data: \(result)")
            self.pins = result
            result.forEach { pin in
                let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                mapView.addPinToMap(pin: pin)
            }
        } catch {
            // This is bad
            debugPrint("Error: \(error)")
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: mapView)
        debugPrint("handleLongPress: location \(location)")
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        addPin(coordinate)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? PhotoAlbumViewController, let annotationView = sender as? MKAnnotationView, let annotation = annotationView.annotation as? MKPointAnnotation {
                if let objectIDURL = URL(string: annotation.title!) {
                    let coordinator: NSPersistentStoreCoordinator? = DataController.shared.viewContext.persistentStoreCoordinator
                    let managedObjectID = coordinator?.managedObjectID(forURIRepresentation: objectIDURL)
                    let pin = pins.first(where: { $0.objectID == managedObjectID })
                    viewController.selectedPin = pin
                }
        }
     }
    
    // MARK: - Helper Functions
    
    private func addPin(_ coordinate: CLLocationCoordinate2D) {
        let pin = Pin(context: DataController.shared.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        
        do {
            try DataController.shared.viewContext.save()
            mapView.addPinToMap(pin: pin)
        } catch {
            // TODO: Notify user about error
        }
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        performSegue(withIdentifier: "photoAlbum", sender: view)
    }
}
