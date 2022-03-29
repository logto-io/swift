//
//  URLSession.swift
//
//
//  Created by Gao Sun on 2022/1/19.
//

import Foundation

extension URLSession: NetworkSession {
    private func handleResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) -> (Data?, Error?) {
        guard let httpResponse = response as? HTTPURLResponse else {
            return (nil, LogtoErrors.Response.notHttpResponse(response: response))
        }

        guard httpResponse.statusCode < 400 else {
            return (
                nil,
                LogtoErrors.Response.withCode(code: httpResponse.statusCode, httpResponse: httpResponse, data: data)
            )
        }

        return (data, error)
    }

    public func loadData(with request: URLRequest) async -> (Data?, Error?) {
        await withCheckedContinuation { continuation in
            let task = dataTask(with: request) { data, response, error in
                continuation.resume(returning: self.handleResponse(data: data, response: response, error: error))
            }

            task.resume()
        }
    }
}
