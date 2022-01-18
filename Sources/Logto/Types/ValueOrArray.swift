//
//  ValueOrArray.swift
//
//
//  Created by Gao Sun on 2022/1/18.
//

import Foundation

enum ValueOrArray<T> {
    case value(T)
    case array([T])

    var inArray: [T] {
        switch self {
        case let .value(value):
            return [value]
        case let .array(array):
            return array
        }
    }
}
