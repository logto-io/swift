//
//  Dictionary.swift
//
//
//  Created by Gao Sun on 2022/1/30.
//

import Foundation

extension Dictionary where Key == String, Value == String? {
    var urlParamEncoded: String {
        var components = URLComponents()
        components.queryItems = compactMapValues { $0 }.compactMap {
            URLQueryItem(name: $0, value: $1)
        }
        return components.percentEncodedQuery ?? ""
    }
}
