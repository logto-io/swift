//
//  LogtoUtilities.swift
//
//
//  Created by Gao Sun on 2022/1/7.
//

import Foundation

public enum LogtoUtilities {
    static func generateState() -> String {
        Data.randomArray(length: 64).toUrlSafeBase64String()
    }

    static func generateCodeVerifier() -> String {
        Data.randomArray(length: 64).toUrlSafeBase64String()
    }
}
