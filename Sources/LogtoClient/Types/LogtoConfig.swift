//
//  LogtoConfig.swift
//
//
//  Created by Gao Sun on 2022/1/21.
//

import Foundation
import Logto

public struct LogtoConfig {
    private let _scopes: [String]
    private let _resources: [String]

    public let endpoint: URL
    public let appId: String
    public let prompt: LogtoCore.Prompt
    public let usingPersistStorage: Bool
    public let prefersEphemeralWebBrowserSession: Bool
    /// The options for verifying the ID Token, such as the clock tolerance for devices whose clock drifts from the
    /// Logto server. See `IdTokenVerificationOptions`.
    public let idTokenVerification: IdTokenVerificationOptions

    public var scopes: [String] {
        LogtoUtilities.withReservedScopes(_scopes)
    }

    public var resources: [String] {
        scopes.contains(UserScope.organizations.rawValue)
            ? _resources + [ReservedResource.organizations.rawValue]
            : _resources
    }

    /// Have to do this in Swift
    /// - Throws: `LogtoErrors.UrlConstruction.unableToConstructUrl` if the endpoint is not a valid URL, or
    ///   `LogtoClientErrors.Config.invalidClockTolerance` if the clock tolerance is not a positive number of seconds.
    public init(
        endpoint: String,
        appId: String,
        scopes: [String] = [],
        resources: [String] = [],
        prompt: LogtoCore.Prompt = .consent,
        usingPersistStorage: Bool = true,
        prefersEphemeralWebBrowserSession: Bool = false,
        idTokenVerification: IdTokenVerificationOptions = IdTokenVerificationOptions()
    ) throws {
        guard let endpoint = URL(string: endpoint) else {
            throw LogtoErrors.UrlConstruction.unableToConstructUrl
        }

        guard idTokenVerification.clockTolerance > 0, idTokenVerification.clockTolerance.isFinite else {
            throw LogtoClientErrors.Config.invalidClockTolerance
        }

        self.endpoint = endpoint
        self.appId = appId
        _scopes = scopes
        _resources = resources
        self.prompt = prompt
        self.usingPersistStorage = usingPersistStorage
        self.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
        self.idTokenVerification = idTokenVerification
    }
}
