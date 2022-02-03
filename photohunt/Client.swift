//
//  Imgur.swift
//  photohunt
//
//  Created by Sunny Hardasani on 1/31/22.
//

import Foundation


class Client {
    
    func searchImages(_ word: String, completion: @escaping (Result<ImgurResult, Error>) -> ()) {
        
        guard let request = createRequest(searchTerm: word) else {
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            guard let httpResponse = (response as? HTTPURLResponse) else {
                completion(.failure(APIError.unknown))
                return
            }
            
            guard ![401, 403].contains(httpResponse.statusCode) else {
                completion(.failure(APIError.badAuthorization))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.emptyResponse))
                return
            }
            
            completion(Parser.parse(data))
        }
        
        dataTask.resume()

    }
    
    func createRequest(searchTerm: String) -> URLRequest? {
        let queryItems = [URLQueryItem(name: "q", value: searchTerm)]
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.imgur.com"
        components.path = "/3/gallery/search/"
        components.queryItems = queryItems

        guard let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        
        // TODO: this should be secure
        request.setValue("Client-ID b067d5cb828ec5a", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
}
