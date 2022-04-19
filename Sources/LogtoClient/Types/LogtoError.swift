//
//  File.swift
//
//
//  Created by Gao Sun on 2022/2/4.
//

import Foundation

public struct LogtoError<T>: LocalizedError {
    public let type: T
    public let innerError: Error?
}
