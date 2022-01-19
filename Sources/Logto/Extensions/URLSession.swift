//
//  URLSession.swift
//
//
//  Created by Gao Sun on 2022/1/19.
//

import Foundation

extension URLSession: NetworkSession {
    func loadData(
        from url: URL,
        completion: @escaping (Data?, Error?) -> Void
    ) {
        let task = dataTask(with: url) { data, _, error in
            completion(data, error)
        }

        task.resume()
    }
}
