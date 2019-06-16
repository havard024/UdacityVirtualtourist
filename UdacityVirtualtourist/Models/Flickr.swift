//
//  Flickr.swift
//  UdacityVirtualtourist
//
//  Created by mac on 6/16/19.
//  Copyright © 2019 NorensIKT. All rights reserved.
//

import Foundation

class FlickrResponse: Codable {
    let photos: FlickrPhotos
}

class FlickrPhotos: Codable {
    let photo: [FlickrPhoto]
}

class FlickrPhoto: Codable {
    let url_m: String
}
