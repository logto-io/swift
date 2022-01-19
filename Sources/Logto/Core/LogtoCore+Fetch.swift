//
//  LogtoCore+Fetch.swift
//  
//
//  Created by Gao Sun on 2022/1/18.
//

import Foundation

extension LogtoCore {
    struct OidcConfigResponse: Codable, Equatable {
        let authorizationEndpoint: String
        let tokenEndpoint: String
        let endSessionEndpoint: String
        let revocationEndpoint: String
        let jwksUri: String
        let issuer: String
    }
    
    static func fetchOidcConfig(endpoint: String, completion: @escaping (OidcConfigResponse?, Error?) -> Void) {
        Utilities.httpGet(endpoint: endpoint, completion: completion)
    }
}
