//
//  ImageLoader.swift
//  photohunt
//
//  Created by Sunny Hardasani on 2/1/22.
//

import Foundation
import UIKit

class ImageLoader {
    
    // TODO: Convert to LRU Cache for better memory handling
    private var loadedImages = [URL: UIImage]()
    private var runningRequests = [UUID: URLSessionDataTask]()
    let session = URLSession.init(configuration: .default)
    
    func cleanCache() {
        loadedImages.removeAll()
    }
    
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
    
    func loadImage(_ url: URL, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {

        if let image = loadedImages[url] {
            completion(.success(image))
            return nil
        }

        let uuid = UUID()
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
 
            defer { self.runningRequests.removeValue(forKey: uuid) }
            
            if let data = data, let image = UIImage(data: data) {
                self.loadedImages[url] = image
                completion(.success(image))
                return
            }
            
            guard let error = error else {
                completion(.failure(APIError.unknown))
                return
            }
            guard let httpResponse = (response as? HTTPURLResponse) else {
                completion(.failure(APIError.unknown))
                return
            }
            guard ![401, 403].contains(httpResponse.statusCode) else {
                completion(.failure(APIError.badAuthorization))
                return
            }
            guard (error as NSError).code == NSURLErrorCancelled else {
                completion(.failure(error))
                return
            }

            // the request was cancelled, no need to call the callback
        }
        
        task.resume()
        
        runningRequests[uuid] = task
        return uuid
    }
        
}
