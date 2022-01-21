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

    // TO-DO: refactor request utilities
    private static func handleResponse<T: Codable>(
        data: Data?,
        error: Error?,
        completion: @escaping HttpCompletion<T>
    ) {
        let decoder = Utilities.getCamelCaseDecoder()

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

    static func httpGet<T: Codable>(
        useSession session: NetworkSession,
        endpoint: String,
        completion: @escaping HttpCompletion<T>
    ) {
        guard let url = URL(string: endpoint) else {
            completion(nil, LogtoErrors.UrlConstruction.unableToConstructUrl)
            return
        }

        session.loadData(with: url) { data, error in
            Utilities.handleResponse(data: data, error: error, completion: completion)
        }
    }

    static func httpGet<T: Codable>(
        useSession session: NetworkSession,
        endpoint: String,
        headers: [String: String],
        completion: @escaping HttpCompletion<T>
    ) {
        guard let url = URL(string: endpoint) else {
            completion(nil, LogtoErrors.UrlConstruction.unableToConstructUrl)
            return
        }

        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData
        )

        request.httpMethod = "GET"
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        session.loadData(with: request) { data, error in
            Utilities.handleResponse(data: data, error: error, completion: completion)
        }
    }

    static func httpPost<T: Codable>(
        useSession session: NetworkSession,
        endpoint: String,
        body: Data? = nil,
        completion: @escaping HttpCompletion<T>
    ) {
        guard let url = URL(string: endpoint) else {
            completion(nil, LogtoErrors.UrlConstruction.unableToConstructUrl)
            return
        }

        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData
        )

        request.httpMethod = "POST"
        request.httpBody = body

        session.loadData(with: request) { data, error in
            Utilities.handleResponse(data: data, error: error, completion: completion)
        }
    }

    static func httpPost(
        useSession session: NetworkSession,
        endpoint: String,
        body: Data? = nil,
        completion: @escaping HttpEmptyCompletion
    ) {
        guard let url = URL(string: endpoint) else {
            completion(LogtoErrors.UrlConstruction.unableToConstructUrl)
            return
        }

        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData
        )

        request.httpMethod = "POST"
        request.httpBody = body

        session.loadData(with: request) {
            completion($1)
        }
    }
}
