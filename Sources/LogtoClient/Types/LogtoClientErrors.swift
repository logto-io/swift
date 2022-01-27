//
//  LogtoClientErrors.swift
//  
//
//  Created by Gao Sun on 2022/1/27.
//

import Foundation

public enum LogtoClientErrors {
    enum Fetch: LocalizedError {
        case unableToFetchOidcConfig
    }
}
