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

    var selectedAnnotation: MKPointAnnotation!
    var photos: [FlickrPhoto] = []
    private let reuseIdentifier = "PhotoCell"
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
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
        
        collectionView.dataSource = self
        #warning("Only fetch images if there are none stored locally for given pin")
        fetchImagesFromFlickr()
    }
    
    // MARK: - IBActions
    
    @IBAction func newCollectionTapped(_ sender: Any) {
        fetchImagesFromFlickr()
    }
    
    // MARK: - Helper Functions
    
    private func fetchImagesFromFlickr() {
        // Send the request
        let coordinate = selectedAnnotation.coordinate
        FlickrAPI.shared.performFlickrSearch(longitude: coordinate.longitude, latitude: coordinate.latitude) { error, photos in
            if let error = error {
                debugPrint(error)
            } else {
                debugPrint(photos)
                self.photos = photos
                self.collectionView.reloadData()
                photos.map { photo in
                    FlickrAPI.shared.fetchImage(photo.url_m) { error, image in
                        if let error = error {
                            debugPrint(error)
                        } else {
                            debugPrint("Successfully downloaded image")
                        }
                    }
                }
            }
            
        }
    }
}

// MARK: - UICollectionViewDataSource

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        // Configure the cell
        cell.backgroundColor = .black
        
        return cell
    }
}
