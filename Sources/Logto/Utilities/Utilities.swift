//
//  Utilities.swift
//
//  Internal utilities.
//
//  Created by Gao Sun on 2022/1/18.
//

import Foundation

enum Utilities {
    static func getCamelCaseDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    static func httpGet<T: Codable>(endpoint: String, completion: @escaping (T?, Error?) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(nil, LogtoErrors.UrlConstruction.unableToConstructUrl)
            return
        }
        
        let decoder = Utilities.getCamelCaseDecoder()
            
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, LogtoErrors.Request.noResponseData)
                return
            }
            
            do {
                let decoded = try decoder.decode(T.self, from: data)
                completion(decoded, nil)
            }
            catch let error {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
}
