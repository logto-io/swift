//
//  LogtoRequest.swift
//
//
//  Created by Gao Sun on 2022/1/24.
//

import Foundation

public enum LogtoRequest {
    public enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
    }

    private static func handleResponse<T: Codable>(
        data: Data?,
        error: Error?,
        completion: @escaping HttpCompletion<T>
    ) {
        let decoder = LogtoUtilities.getCamelCaseDecoder()

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

    public static func load(
        useSession session: NetworkSession,
        method: HttpMethod,
        url: URL,
        headers: [String: String] = [:],
        body: Data? = nil,
        completion: @escaping HttpCompletion<Data>
    ) {
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData
        )

        request.httpMethod = method.rawValue
        request.httpBody = body
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        session.loadData(with: request, completion: completion)
    }

    public static func load(
        useSession session: NetworkSession,
        method: HttpMethod,
        endpoint: String,
        headers: [String: String] = [:],
        body: Data? = nil,
        completion: @escaping HttpCompletion<Data>
    ) {
        guard let url = URL(string: endpoint) else {
            completion(nil, LogtoErrors.UrlConstruction.unableToConstructUrl)
            return
        }

        load(useSession: session, method: method, url: url, headers: headers, body: body, completion: completion)
    }

    public static func get<T: Codable>(
        useSession session: NetworkSession,
        endpoint: String,
        headers: [String: String] = [:],
        completion: @escaping HttpCompletion<T>
    ) {
        load(useSession: session, method: .get, endpoint: endpoint, headers: headers) { data, error in
            handleResponse(data: data, error: error, completion: completion)
        }
    }

    public static func get<T: Codable>(
        useSession session: NetworkSession,
        url: URL,
        headers: [String: String] = [:],
        completion: @escaping HttpCompletion<T>
    ) {
        load(useSession: session, method: .get, url: url, headers: headers) { data, error in
            handleResponse(data: data, error: error, completion: completion)
        }
    }

    public static func post<T: Codable>(
        useSession session: NetworkSession,
        endpoint: String,
        headers: [String: String] = [:],
        body: Data? = nil,
        completion: @escaping HttpCompletion<T>
    ) {
        load(useSession: session, method: .post, endpoint: endpoint, headers: headers, body: body) { data, error in
            handleResponse(data: data, error: error, completion: completion)
        }
    }

    public static func post(
        useSession session: NetworkSession,
        endpoint: String,
        headers: [String: String] = [:],
        body: Data? = nil,
        completion: @escaping HttpEmptyCompletion
    ) {
        load(useSession: session, method: .post, endpoint: endpoint, headers: headers, body: body) {
            completion($1)
        }
    }
}
