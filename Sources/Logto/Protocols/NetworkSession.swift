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
        from url: URL,
        completion: @escaping (Data?, Error?) -> Void
    )
}
