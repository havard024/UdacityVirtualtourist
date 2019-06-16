//
//  PhotoAlbumViewController.swift
//  UdacityVirtualtourist
//
//  Created by mac on 6/14/19.
//  Copyright © 2019 NorensIKT. All rights reserved.
//

import UIKit
import MapKit

// Note: Followed the following tutorial to set up the collection view: https://www.raywenderlich.com/9334-uicollectionview-tutorial-getting-started
class PhotoAlbumViewController: UIViewController {

    var selectedPin: Pin!
    var photos: [FlickrPhoto] = []
    private let reuseIdentifier = "PhotoCell"
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)

    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let selectedPin = selectedPin else {
            preconditionFailure("You need to set the selectedPin in this view controller else this view is rendered useless.")
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: selectedPin.latitude, longitude: selectedPin.longitude)
        mapView.centerMapOnLocation(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), regionRadius: 100)
        mapView.addPinToMap(pin: selectedPin)
        mapView.disableUserInteraction()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
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
        let coordinate = CLLocationCoordinate2D(latitude: selectedPin.latitude, longitude: selectedPin.longitude)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        let item = photos[indexPath.item]
        // Configure the cell
        
        cell.backgroundColor = .gray
        FlickrAPI.shared.fetchImage(item.url_m) { error, image in
            if let image = image {
                cell.backgroundColor = nil
                cell.imageView.image = image
            } else {
                cell.backgroundColor = .red
            }
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

// MARK: - UICollectionViewDelegate

extension PhotoAlbumViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        photos.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
    }
}
