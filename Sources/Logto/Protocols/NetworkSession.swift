//
//  NetworkSession.swift
//
//
//  Created by Gao Sun on 2022/1/19.
//

import Foundation

// https://www.swiftbysundell.com/articles/mocking-in-swift/#complete-mocking
public protocol NetworkSession {
    func loadData(with request: URLRequest) async -> (Data?, Error?)
}
