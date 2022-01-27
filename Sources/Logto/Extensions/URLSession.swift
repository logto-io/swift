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
        error: Error?,
        completion: @escaping HttpCompletion<Data>
    ) {
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(nil, LogtoErrors.Response.notHttpResponse(response: response))
            return
        }

        guard httpResponse.statusCode < 400 else {
            completion(
                nil,
                LogtoErrors.Response.withCode(code: httpResponse.statusCode, httpResponse: httpResponse)
            )
            return
        }

        completion(data, error)
    }

    public func loadData(
        with request: URLRequest,
        completion: @escaping HttpCompletion<Data>
    ) {
        let task = dataTask(with: request) { data, response, error in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
        }

        task.resume()
    }
}
