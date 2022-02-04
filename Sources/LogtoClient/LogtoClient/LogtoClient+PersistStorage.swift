//
//  LogtoClient+PersistStorage.swift
//
//
//  Created by Gao Sun on 2022/2/4.
//

import Foundation

extension LogtoClient {
    enum KeyName: String {
        case accessTokenMap = "access_token_map"
        case idToken = "id_token"
        case refreshToken = "refresh_token"
    }

    static let keychainServiceName = "io.logto.client"
    static let jsonEncoder = JSONEncoder()

    func loadFromKeychain() {
        guard let keychain = keychain else {
            return
        }

        if let data = keychain[data: KeyName.accessTokenMap.rawValue],
           let jsonObject = try? JSONSerialization.jsonObject(with: data)
        {
            accessTokenMap = jsonObject as? [String: AccessToken] ?? [:]
        }

        idToken = keychain[KeyName.idToken.rawValue]
        refreshToken = keychain[KeyName.refreshToken.rawValue]
    }

    func saveToKeychain(forKey key: KeyName) {
        guard let keychain = keychain else {
            return
        }

        switch key {
        case .accessTokenMap:
            if let data = try? LogtoClient.jsonEncoder.encode(accessTokenMap) {
                keychain[data: key.rawValue] = data
            }
        case .idToken:
            keychain[key.rawValue] = idToken
        case .refreshToken:
            keychain[key.rawValue] = refreshToken
        }
    }
}
