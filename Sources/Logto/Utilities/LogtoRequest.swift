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
        error: Error?
    ) throws -> T {
        let decoder = LogtoUtilities.getCamelCaseDecoder()

        if let error = error {
            throw error
        }

        guard let data = data else {
            throw LogtoErrors.Request.noResponseData
        }

        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            throw error
        }
    }

    public static func load(
        useSession session: NetworkSession,
        method: HttpMethod,
        url: URL,
        headers: [String: String] = [:],
        body: Data? = nil
    ) async -> (Data?, Error?) {
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData
        )

        request.httpMethod = method.rawValue
        request.httpBody = body
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        return await withCheckedContinuation { continuation in
            session.loadData(with: request) {
                continuation.resume(returning: ($0, $1))
            }
        }
    }

    public static func load(
        useSession session: NetworkSession,
        method: HttpMethod,
        endpoint: String,
        headers: [String: String] = [:],
        body: Data? = nil
    ) async -> (Data?, Error?) {
        guard let url = URL(string: endpoint) else {
            return (nil, LogtoErrors.UrlConstruction.unableToConstructUrl)
        }

        return await load(useSession: session, method: method, url: url, headers: headers, body: body)
    }

    public static func get<T: Codable>(
        useSession session: NetworkSession,
        endpoint: String,
        headers: [String: String] = [:]
    ) async throws -> T {
        let (data, error) = await load(useSession: session, method: .get, endpoint: endpoint, headers: headers)
        return try handleResponse(data: data, error: error)
    }

    public static func get<T: Codable>(
        useSession session: NetworkSession,
        url: URL,
        headers: [String: String] = [:]
    ) async throws -> T {
        let (data, error) = await load(useSession: session, method: .get, url: url, headers: headers)
        return try handleResponse(data: data, error: error)
    }

    public static func post<T: Codable>(
        useSession session: NetworkSession,
        endpoint: String,
        headers: [String: String] = [:],
        body: Data? = nil
    ) async throws -> T {
        let (data, error) = await load(useSession: session, method: .post, endpoint: endpoint, headers: headers,
                                       body: body)
        return try handleResponse(data: data, error: error)
    }

    public static func post(
        useSession session: NetworkSession,
        endpoint: String,
        headers: [String: String] = [:],
        body: Data? = nil
    ) async throws {
        let (_, error) = await load(useSession: session, method: .post, endpoint: endpoint, headers: headers,
                                    body: body)

        if let error = error {
            throw error
        }
    }
}
