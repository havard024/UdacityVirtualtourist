//
//  MapView+Convenience.swift
//  UdacityVirtualtourist
//
//  Created by mac on 6/14/19.
//  Copyright © 2019 NorensIKT. All rights reserved.
//

import MapKit

extension MKMapView {
    func centerMapOnLocation(location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        self.setRegion(coordinateRegion, animated: true)
    }

    func addPinToMap(pin: Pin) {
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = pin.objectID.uriRepresentation().absoluteString
        self.addAnnotation(annotation)
        debugPrint("addPointAnnotation: coordinate \(coordinate) with id: \(annotation.title)")
    }
    
    func disableUserInteraction() {
        self.isZoomEnabled = false;
        self.isScrollEnabled = false;
        self.isUserInteractionEnabled = false;
    }
}
