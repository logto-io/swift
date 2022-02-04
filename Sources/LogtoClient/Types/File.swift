//
//  LogtoResult.swift
//
//
//  Created by Gao Sun on 2022/2/4.
//

import Foundation

public enum LogtoResult<T: LogtoError> {
    case success
    case failure(error: T)
}

public typealias LogtoCompletion<T: LogtoError> = (LogtoResult<T>) -> Void
