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

    static func httpGet<T: Codable>(useSession session: NetworkSession, endpoint: String,
                                    completion: @escaping HttpCompletion<T>)
    {
        guard let url = URL(string: endpoint) else {
            completion(nil, LogtoErrors.UrlConstruction.unableToConstructUrl)
            return
        }

        let decoder = Utilities.getCamelCaseDecoder()

        session.loadData(from: url) { data, error in
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
            } catch {
                completion(nil, error)
            }
        }
    }
}
