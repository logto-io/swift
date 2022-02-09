//
//  LogtoClient+PersistStorage.swift
//
//
//  Created by Gao Sun on 2022/2/4.
//

import Foundation

extension LogtoClient {
    enum KeyName: String {
        case idToken = "id_token"
        case refreshToken = "refresh_token"
    }

    static let keychainServiceName = "io.logto.client"
    static let jsonEncoder = JSONEncoder()
    static let jsonDecoder = JSONDecoder()

    func loadFromKeychain() {
        guard let keychain = keychain else {
            return
        }

        idToken = keychain[KeyName.idToken.rawValue]
        refreshToken = keychain[KeyName.refreshToken.rawValue]
    }

    func saveToKeychain(forKey key: KeyName) {
        guard let keychain = keychain else {
            return
        }

        switch key {
        case .idToken:
            keychain[key.rawValue] = idToken
        case .refreshToken:
            keychain[key.rawValue] = refreshToken
        }
    }
}
