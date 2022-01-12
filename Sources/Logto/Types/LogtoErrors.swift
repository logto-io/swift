//
//  LogtoErrors.swift
//
//
//  Created by Gao Sun on 2022/1/12.
//

import Foundation

public enum LogtoErrors {
    enum Decode: LocalizedError {
        case noPayloadFound
        case invalidUrlSafeBase64Encoding
    }
}
