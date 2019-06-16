//
//  FlickrAPI.swift
//  UdacityVirtualtourist
//
//  Created by mac on 6/14/19.
//  Copyright © 2019 NorensIKT. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    struct FlickrURLParams {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
    }
    
    struct FlickrAPIKeys {
        static let SearchMethod = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let ResponseFormat = "format"
        static let DisableJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let Longitute = "lon"
        static let Latitude = "lat"
        static let Page = "page"
        static let PerPage = "per_page"
    }
    
    struct FlickrAPIValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "6018ce76bba90c3eff10d2f95093f634"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let SafeSearch = "1"
        static let PerPage = "10"
    }
}

final class FlickrAPI {
    static let shared = FlickrAPI()
    
    private func flickrURLFromParameters(longitude: Double, latitude: Double) -> URL {
        
        let longitude = String(format: "%.6f", longitude)
        let latitude = String(format: "%.6f", latitude)
    
        // Build base URL
        var components = URLComponents()
        components.scheme = Constants.FlickrURLParams.APIScheme
        components.host = Constants.FlickrURLParams.APIHost
        components.path = Constants.FlickrURLParams.APIPath
    
        // Build query string
        components.queryItems = [URLQueryItem]()
    
        // Query components
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.APIKey, value: Constants.FlickrAPIValues.APIKey));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.SearchMethod, value: Constants.FlickrAPIValues.SearchMethod));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.ResponseFormat, value: Constants.FlickrAPIValues.ResponseFormat));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.Extras, value: Constants.FlickrAPIValues.MediumURL));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.SafeSearch, value: Constants.FlickrAPIValues.SafeSearch));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.DisableJSONCallback, value: Constants.FlickrAPIValues.DisableJSONCallback));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.Longitute, value: String(format: "%.8f", longitude)))
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.Latitude, value: String(format: "%.8f", latitude)))
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.PerPage, value: Constants.FlickrAPIValues.PerPage))
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.Page, value: String(Int.random(in: 1..<100)))) // Somewhat randomize returned images
    
        return components.url!
    }
    
    enum FlickrError: LocalizedError {
        case invalidStatusCode(Int)
        case serverError(String?)
        case noData
        case parseError
        
        var localizedDescription: String {
            switch self {
                
            case .invalidStatusCode(let code):
                return "Server failed with status code: \(code)"
            case .serverError(let error):
                return "Server failed with error: \(error ?? "No error")"
            case .noData:
                return "No data returned from server"
            case .parseError:
                return "Failed to parse server response to local model"
            }
        }
    }
    
    func performFlickrSearch(longitude: Double, latitude: Double,  completion: @escaping (_ error: Error?, _ photos: [FlickrPhoto]) -> Void) {
        
        let searchURL = flickrURLFromParameters(longitude: longitude, latitude: latitude)
        // Perform the request
        let session = URLSession.shared
        let request = URLRequest(url: searchURL)
        let task = session.dataTask(with: request){
            (data, response, error) in
            if (error == nil)
            {
                // Check response code
                let status = (response as! HTTPURLResponse).statusCode
                if (status < 200 || status > 300)
                {
                    DispatchQueue.main.async {
                        completion(FlickrError.invalidStatusCode(status), [])
                    }
                    return
                }
                
                /* Check data returned? */
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(FlickrError.noData, [])
                    }
                    return
                }
                
                // Parse the data
                let decoder = JSONDecoder()
                let parsedResult: FlickrResponse
                do {
                    parsedResult = try decoder.decode(FlickrResponse.self, from: data)
                } catch {
                    DispatchQueue.main.async {
                        completion(FlickrError.parseError, [])
                    }
                    return
                }
                
                print("Result: \(parsedResult)")
                
                DispatchQueue.main.async {
                    completion(nil, parsedResult.photos.photo)
                }
                return
            }
            else {
                DispatchQueue.main.async {
                    completion(FlickrError.serverError(error?.localizedDescription), [])
                }
                return
            }
        }
        task.resume()
    }
    
    func fetchImage(_ url: String, completion: @escaping (Error?, UIImage?) -> Void) {
        
        let imageURL = URL(string: url)
        
        let task = URLSession.shared.dataTask(with: imageURL!) { (data, response, error) in
            if error == nil {
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(FlickrError.noData, nil)
                    }
                    return
                }
                
                let downloadImage = UIImage(data: data)!
                
                DispatchQueue.main.async {
                    completion(nil, downloadImage)
                }
            } else {
                DispatchQueue.main.async {
                    completion(error, nil)
                }
            }
        }
        
        task.resume()
    }
}
