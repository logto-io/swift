import Foundation
import Logto

/// The options for verifying the ID Token received from the Logto server.
public struct IdTokenVerificationOptions: Equatable {
    /// The default clock tolerance in seconds, which is 5 minutes and matches the default of the Logto JS SDK.
    public static let defaultClockTolerance = LogtoUtilities.defaultIdTokenClockTolerance

    /// The clock tolerance in seconds when verifying the `iat` and `exp` claims of the ID Token.
    ///
    /// Sign-in fails with `LogtoErrors.Verification.jwtIssuedTimeIncorrect` or `LogtoErrors.Verification.jwtExpired`
    /// on devices whose clock drifts from the Logto server by more than this value. It must be a positive number of
    /// seconds, which is validated when constructing a `LogtoConfig`.
    public let clockTolerance: TimeInterval

    public init(clockTolerance: TimeInterval = IdTokenVerificationOptions.defaultClockTolerance) {
        self.clockTolerance = clockTolerance
    }
}
