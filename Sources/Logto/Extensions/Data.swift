//
//  Data.swift
//
//
//  Created by Gao Sun on 2022/1/10.
//

import Foundation

extension Data {
    static func fromUrlSafeBase64(string: String) -> Data? {
        Data(base64Encoded: string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            // Base64 encoding
            .padding(toLength: string.count + string.count % 4, withPad: "=", startingAt: 0))
    }

    static func randomArray(length: Int) -> Data {
        Data((0..<length).map { _ in UInt8.random(in: UInt8.min...UInt8.max) })
    }

    func toUrlSafeBase64String() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
