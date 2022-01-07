//
//  String.swift
//
//
//  Created by Gao Sun on 2022/1/7.
//

import Foundation

extension String {
    static func fromUrlSafeBase64(string: String) -> String? {
        guard let data = Data(base64Encoded: string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            // Base64 encoding
            .padding(toLength: string.count + string.count % 3, withPad: "=", startingAt: 0))
        else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toUrlSafeBase64() -> String {
        Data(utf8)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
