//
//  LogtoUtilities.swift
//
//
//  Created by Gao Sun on 2022/1/7.
//

import Foundation

public enum LogtoUtilities {
    private static func randomString(length: Int = 64) -> String {
        let randomAlphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< length).compactMap { _ in randomAlphabet.randomElement() })
    }

    static func generateState() -> String {
        randomString().toUrlSafeBase64()
    }

    static func generateCodeVerifier() -> String {
        randomString().toUrlSafeBase64()
    }
}