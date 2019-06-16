//
//  PhotoAlbumViewController.swift
//  UdacityVirtualtourist
//
//  Created by mac on 6/14/19.
//  Copyright © 2019 NorensIKT. All rights reserved.
//

import UIKit
import MapKit
import CoreData

// Note: Followed the following tutorial to set up the collection view: https://www.raywenderlich.com/9334-uicollectionview-tutorial-getting-started
class PhotoAlbumViewController: UIViewController {

    var selectedPin: Pin!
    var photos: [Photo] = []
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
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", selectedPin)
        fetchRequest.predicate = predicate
        
        do {
            let result = try DataController.shared.viewContext.fetch(fetchRequest)
            self.photos = result
            collectionView.reloadData()
            debugPrint("Result: \(result)")
        } catch {
            debugPrint("Error: \(error)")
        }
        if let photos = selectedPin.photos, photos.count > 0 {
            debugPrint("Use existing images...")
            
        } else {
            fetchImagesFromFlickr()
        }
        #warning("Only fetch images if there are none stored locally for given pin")
        //
    }
    
    // MARK: - IBActions
    
    @IBAction func newCollectionTapped(_ sender: Any) {
        photos.forEach{ DataController.shared.viewContext.delete($0) }
        try? DataController.shared.viewContext.save()
        photos.removeAll()
        collectionView.reloadData()
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
                var corePhotos: [Photo] = []
                photos.forEach { p in
                    let photo = Photo(context: DataController.shared.viewContext)
                    photo.url =  URL(string: p.url_m)!
                    try? DataController.shared.viewContext.save()
                    corePhotos.append(photo)
                }
                self.photos = corePhotos
                self.collectionView.reloadData()
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
        
        if let data = item.image {
            cell.backgroundColor = nil
            cell.imageView.image = UIImage(data: data)!
        } else {
            FlickrAPI.shared.fetchImage(item.url!) { error, data in
                if let data = data {
                    let image = UIImage(data: data)!
                    cell.backgroundColor = nil
                    cell.imageView.image = image
                    let photo = Photo(context: DataController.shared.viewContext)
                    photo.image = data
                    photo.pin = self.selectedPin
                    try? DataController.shared.viewContext.save()
                } else {
                    cell.backgroundColor = .red
                }
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
        let p = photos.remove(at: indexPath.item)
        DataController.shared.viewContext.delete(p)
        collectionView.deleteItems(at: [indexPath])
        try? DataController.shared.viewContext.save()
    }
}
