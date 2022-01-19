//
//  NetworkSession.swift
//
//
//  Created by Gao Sun on 2022/1/19.
//

import Foundation

// https://www.swiftbysundell.com/articles/mocking-in-swift/#complete-mocking
protocol NetworkSession {
    func loadData(
        with url: URL,
        completion: @escaping HttpCompletion<Data>
    )

    func loadData(
        with request: URLRequest,
        completion: @escaping HttpCompletion<Data>
    )
}
