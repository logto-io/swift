import JOSESwift
@testable import Logto
import XCTest

final class LogtoUtilitiesTests: XCTestCase {
    func testWithReservedScopes() throws {
        XCTAssertEqual(LogtoUtilities.withReservedScopes([]).sorted(), ["offline_access", "openid", "profile"].sorted())
        XCTAssertEqual(
            LogtoUtilities.withReservedScopes(["foo"]).sorted(),
            ["foo", "offline_access", "openid", "profile"].sorted()
        )
        XCTAssertEqual(
            LogtoUtilities.withReservedScopes(["foo", "xyz"]).sorted(),
            ["foo", "offline_access", "openid", "profile", "xyz"].sorted()
        )
    }

    func testGenerateState() throws {
        let state = LogtoUtilities.generateState()
        XCTAssertTrue(state.isUrlSafe)
        XCTAssertEqual(Data.fromUrlSafeBase64(string: state)?.count, 64)
    }

    func testGenerateCodeVerifier() throws {
        let verifier = LogtoUtilities.generateCodeVerifier()
        XCTAssertTrue(verifier.isUrlSafe)
        XCTAssertEqual(Data.fromUrlSafeBase64(string: verifier)?.count, 64)
    }

    func testGenerateCodeChallenge() throws {
        XCTAssertEqual(
            LogtoUtilities
                .generateCodeChallenge(
                    codeVerifier: "tO6MabnMFRAatnlMa1DdSstypzzkgalL1-k8Hr_GdfTj-VXGiEACqAkSkDhFuAuD8FOU8lMishaXjt29Xt2Oww"
                ),
            "0K3SLeGlNNzFswYJjcVzcN4C76m_8NZORxFJLBJWGwg"
        )
        XCTAssertEqual(
            LogtoUtilities.generateCodeChallenge(codeVerifier: "ipK7uh7F41nJyYY4RZQzEwBwBTd-BlXSO4W8q0tK5VA"),
            "C51JGVPSnuLTTumLt6X5w2JAL_kBaeqHON3KPIviYaU"
        )
        XCTAssertEqual(
            LogtoUtilities.generateCodeChallenge(codeVerifier: "Á"),
            "p3yvZiKYauPicLIDZ0W1peDz4Z9KFC-9uxtDfoO1KOQ"
        )
        XCTAssertEqual(
            LogtoUtilities.generateCodeChallenge(codeVerifier: "🚀"),
            "67wLKHDrMj8rbP-lxJPO74GufrNq_HPU4DZzAWMdrsU"
        )
    }

    func testDecodeIdToken() throws {
        XCTAssertEqual(
            try LogtoUtilities
                .decodeIdToken(
                    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYXRfaGFzaCI6ImZvbyIsImF1ZCI6ImJhciIsImV4cCI6MTUxNjIzOTAyMSwiaWF0IjoxNTE2MjM5MDIyLCJpc3MiOiJodHRwczovL2xvZ3RvLmRldiJ9.sJMMInlklGgbSOeOa71_uhoUvTLXDFq4jHQ1Bu81GyE"
                ),
            IdTokenClaims(
                sub: "1234567890",
                atHash: "foo",
                aud: "bar",
                exp: 1_516_239_021,
                iat: 1_516_239_022,
                iss: "https://logto.dev",
                name: "John Doe",
                picture: nil,
                username: nil,
                email: nil,
                emailVerified: nil,
                phoneNumber: nil,
                phoneNumberVerified: nil,
                roles: nil,
                organizations: nil,
                organizationRoles: nil
            )
        )
        XCTAssertThrowsError(try LogtoUtilities
            .decodeIdToken(
                "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
            )) {
                XCTAssertNotNil($0 as? DecodingError)
            }
    }

    // MARK: Verify ID Token

    func testVerifyIdTokenFailure() throws {
        let idToken =
            "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IkNza2w2SDRGR3NpLXE0QkVPT1BQOWJlbHNoRGFHZjd3RXViVU5KQllwQmsifQ.eyJzdWIiOiJ3anNadVc4VWpQd2ciLCJhdF9oYXNoIjoibkZOZGdOSWcwWmw0ZWxaTEhMVVpHZyIsImF1ZCI6ImZvbyIsImV4cCI6MTY0MTgxNTYxNywiaWF0IjoxNjQxODEyMDE3LCJpc3MiOiJodHRwczovL2xvZ3RvLmRldi9vaWRjIn0.SCAFRIRWq_iSVbbb3yO3_vvin8XUVWeFIgnsHumSdSBG8qeF9LuO-Hm4xjrTN-XREsifAfGHMrmRC23_QAkwtK8u36m-rlvBnJjq9SdqlQJAyFhCez2Uojzn97CFlwv_n8ucSyy6ToeBrbR1DqvUWdo8lrCer7WHQ3OJRe2U3pAAU9_zqMU6sntP2GshNYnA3IKylhRNFQlP91HT80ROPhgll6GCieTLlCiIeb6Q3KigBDTQ1vJYhK-NaHNP646MQeheUofhFsEZGZFS0OxNPm1FDCsxU2Nwvts7KjxjYM5wb2D5ELB1tFmes7XNWk12bNyN0dEGTugH98CtC_kIA67rZU5q9eUZRuWHPRjraWkdTemNWtW5MvBaVpAMYNJn0Fk5EKSsco_MNvZCszoKvViGo06f1YUex_jkGsOTcttdIbR-780ulWCR0txmg2gu21RRN7oMF4aTs-W7cEKOYuyRX85XTWo_Lu3BugI8kKbSwUsmO8oYPjdpipjcTf-8KJLNOkBefiWDNzM0VoysAlKYUx9aMOSD4gc7h0di7KVZFlEQ7JByn1_gyi8yHrRrHCkzLCe73gBGruijhADoISC6Uq3WmdkQvdYRpRMv0Fz9Wj6vjRhvr1nAu4ZHhsfohCIHVVMKHxXmgfjNKjBTcaRWxit39MK_-sk2Fr52F2w"
        let jwk = try RSAPublicKey(data: Data("""
            {"kty":"RSA","use":"sig","kid":"Cskl6H4FGsi-q4BEOOPP9belshDaGf7wEubUNJBYpBk","e":"AQAB","n":"pB5nO7qovnRQrSQoVmdh0g6TGtMMjc1eS0rexzcuVIgtD-7-84DHt9FaiS8UVr2Tjdp_U4Jr-mJJNbYhxae2FjNkpWf_ETND8hEYTSCZTJCkX0asnzb-xZgt2_xNiOAUzmXEaSHO215Y-WYL2LydLjoMrK70FfoFC4jnsgnnKlf1fQW2llCpG-b19w-aHU5m8fPOWKz5n27jEYNbEqHK-wsGavt7eyhVfEVPNbVl5j_n8o-VfnQT-LyO4Fg6U0XwHz1yXrT7NUMO_qdfwv1QbM0EPyWkxLoSColRZVibPmMpkc9RcOJ2crP5u602W8UOYvbtcBCaXVbzp5iriBAVxRq3tsrnTpHr-1FV5jtwU1aLMucIkOM3iJGSLoLizgwEIAnmLh1u_-lxFeSEWDX3RIE3kZOWdZoRBKcxCYPV4X7Mkca8UNW42FTeUG8f9bq43_FgZvWnnFBYpzTuHTnLlkw1a3GmjRy02_tqhV7xp5rM65Jc8HZEW81L3JKLp87ySqjKWfBkmI0ebzEPZVwV69ggI6eBVzGK1nViHsBWgDAomBGPVUqfZmACIcdy7hOp-40mDa6RscqBFtpd3RPb6lGyf2yDCH-4AY6ZRQUX10TdtW2NQon8-SBNgye4x5ZiUS7EXFxvIaTEZ_MZryS3yo5_xWtYAZLCJrDqEZLY2mE"}
        """.utf8))
        let jwk2 = try RSAPublicKey(data: Data("""
            {"kty":"RSA","use":"sig","kid":"Cskl6H4FGsi-q4BEOOPP9belshDaGf7wEubUNJBYpBk","e":"AQAB","n":"1B5nO7qovnRQrSQoVmdh0g6TGtMMjc1eS0rexzcuVIgtD-7-84DHt9FaiS8UVr2Tjdp_U4Jr-mJJNbYhxae2FjNkpWf_ETND8hEYTSCZTJCkX0asnzb-xZgt2_xNiOAUzmXEaSHO215Y-WYL2LydLjoMrK70FfoFC4jnsgnnKlf1fQW2llCpG-b19w-aHU5m8fPOWKz5n27jEYNbEqHK-wsGavt7eyhVfEVPNbVl5j_n8o-VfnQT-LyO4Fg6U0XwHz1yXrT7NUMO_qdfwv1QbM0EPyWkxLoSColRZVibPmMpkc9RcOJ2crP5u602W8UOYvbtcBCaXVbzp5iriBAVxRq3tsrnTpHr-1FV5jtwU1aLMucIkOM3iJGSLoLizgwEIAnmLh1u_-lxFeSEWDX3RIE3kZOWdZoRBKcxCYPV4X7Mkca8UNW42FTeUG8f9bq43_FgZvWnnFBYpzTuHTnLlkw1a3GmjRy02_tqhV7xp5rM65Jc8HZEW81L3JKLp87ySqjKWfBkmI0ebzEPZVwV69ggI6eBVzGK1nViHsBWgDAomBGPVUqfZmACIcdy7hOp-40mDa6RscqBFtpd3RPb6lGyf2yDCH-4AY6ZRQUX10TdtW2NQon8-SBNgye4x5ZiUS7EXFxvIaTEZ_MZryS3yo5_xWtYAZLCJrDqEZLY2mE"}
        """.utf8))
        let jwks = JWKSet(keys: [jwk2, jwk])
        let jwks2 = JWKSet(keys: [jwk2])
        let issuer = "https://logto.dev/oidc"
        let clientId = "foo"

        XCTAssertThrowsError(try LogtoUtilities
            .verifyIdToken(idToken, issuer: "foo", clientId: "bar", jwks: JWKSet(keys: []))) {
                XCTAssertEqual($0 as? LogtoErrors.Verification, LogtoErrors.Verification.missingJwk)
            }
        XCTAssertThrowsError(try LogtoUtilities.verifyIdToken(idToken, issuer: "foo", clientId: "bar", jwks: jwks2)) {
            XCTAssertEqual($0 as? LogtoErrors.Verification, LogtoErrors.Verification.noSigningKeyMatched)
        }
        XCTAssertThrowsError(try LogtoUtilities.verifyIdToken(idToken, issuer: "foo", clientId: "bar", jwks: jwks)) {
            XCTAssertEqual($0 as? LogtoErrors.Verification, LogtoErrors.Verification.jwtValueMismatched(field: .issuer))
        }
        XCTAssertThrowsError(try LogtoUtilities.verifyIdToken(idToken, issuer: issuer, clientId: "bar", jwks: jwks)) {
            XCTAssertEqual(
                $0 as? LogtoErrors.Verification,
                LogtoErrors.Verification.jwtValueMismatched(field: .audience)
            )
        }
        XCTAssertThrowsError(try LogtoUtilities.verifyIdToken(
            idToken,
            issuer: issuer,
            clientId: clientId,
            jwks: jwks,
            forTimeInterval: 1_641_815_618
        )) {
            XCTAssertEqual($0 as? LogtoErrors.Verification, LogtoErrors.Verification.jwtExpired)
        }
        XCTAssertThrowsError(try LogtoUtilities
            .verifyIdToken(idToken, issuer: issuer, clientId: clientId, jwks: jwks, forTimeInterval: 0)) {
                XCTAssertEqual($0 as? LogtoErrors.Verification, LogtoErrors.Verification.jwtIssuedTimeIncorrect)
            }
    }

    func testVerifyIdTokenRSA() throws {
        let idToken =
            "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IkNza2w2SDRGR3NpLXE0QkVPT1BQOWJlbHNoRGFHZjd3RXViVU5KQllwQmsifQ.eyJzdWIiOiJ3anNadVc4VWpQd2ciLCJhdF9oYXNoIjoibkZOZGdOSWcwWmw0ZWxaTEhMVVpHZyIsImF1ZCI6ImZvbyIsImV4cCI6MTY0MTgxNTYxNywiaWF0IjoxNjQxODEyMDE3LCJpc3MiOiJodHRwczovL2xvZ3RvLmRldi9vaWRjIn0.SCAFRIRWq_iSVbbb3yO3_vvin8XUVWeFIgnsHumSdSBG8qeF9LuO-Hm4xjrTN-XREsifAfGHMrmRC23_QAkwtK8u36m-rlvBnJjq9SdqlQJAyFhCez2Uojzn97CFlwv_n8ucSyy6ToeBrbR1DqvUWdo8lrCer7WHQ3OJRe2U3pAAU9_zqMU6sntP2GshNYnA3IKylhRNFQlP91HT80ROPhgll6GCieTLlCiIeb6Q3KigBDTQ1vJYhK-NaHNP646MQeheUofhFsEZGZFS0OxNPm1FDCsxU2Nwvts7KjxjYM5wb2D5ELB1tFmes7XNWk12bNyN0dEGTugH98CtC_kIA67rZU5q9eUZRuWHPRjraWkdTemNWtW5MvBaVpAMYNJn0Fk5EKSsco_MNvZCszoKvViGo06f1YUex_jkGsOTcttdIbR-780ulWCR0txmg2gu21RRN7oMF4aTs-W7cEKOYuyRX85XTWo_Lu3BugI8kKbSwUsmO8oYPjdpipjcTf-8KJLNOkBefiWDNzM0VoysAlKYUx9aMOSD4gc7h0di7KVZFlEQ7JByn1_gyi8yHrRrHCkzLCe73gBGruijhADoISC6Uq3WmdkQvdYRpRMv0Fz9Wj6vjRhvr1nAu4ZHhsfohCIHVVMKHxXmgfjNKjBTcaRWxit39MK_-sk2Fr52F2w"
        let jwk = try RSAPublicKey(data: Data("""
            {"kty":"RSA","use":"sig","kid":"Cskl6H4FGsi-q4BEOOPP9belshDaGf7wEubUNJBYpBk","e":"AQAB","n":"pB5nO7qovnRQrSQoVmdh0g6TGtMMjc1eS0rexzcuVIgtD-7-84DHt9FaiS8UVr2Tjdp_U4Jr-mJJNbYhxae2FjNkpWf_ETND8hEYTSCZTJCkX0asnzb-xZgt2_xNiOAUzmXEaSHO215Y-WYL2LydLjoMrK70FfoFC4jnsgnnKlf1fQW2llCpG-b19w-aHU5m8fPOWKz5n27jEYNbEqHK-wsGavt7eyhVfEVPNbVl5j_n8o-VfnQT-LyO4Fg6U0XwHz1yXrT7NUMO_qdfwv1QbM0EPyWkxLoSColRZVibPmMpkc9RcOJ2crP5u602W8UOYvbtcBCaXVbzp5iriBAVxRq3tsrnTpHr-1FV5jtwU1aLMucIkOM3iJGSLoLizgwEIAnmLh1u_-lxFeSEWDX3RIE3kZOWdZoRBKcxCYPV4X7Mkca8UNW42FTeUG8f9bq43_FgZvWnnFBYpzTuHTnLlkw1a3GmjRy02_tqhV7xp5rM65Jc8HZEW81L3JKLp87ySqjKWfBkmI0ebzEPZVwV69ggI6eBVzGK1nViHsBWgDAomBGPVUqfZmACIcdy7hOp-40mDa6RscqBFtpd3RPb6lGyf2yDCH-4AY6ZRQUX10TdtW2NQon8-SBNgye4x5ZiUS7EXFxvIaTEZ_MZryS3yo5_xWtYAZLCJrDqEZLY2mE"}
        """.utf8))
        let jwks = JWKSet(keys: [jwk])
        let issuer = "https://logto.dev/oidc"
        let clientId = "foo"
        XCTAssertNoThrow(try LogtoUtilities.verifyIdToken(
            idToken,
            issuer: issuer,
            clientId: clientId,
            jwks: jwks,
            forTimeInterval: 1_641_812_017
        ))
    }

    func testVerifyIdTokenEC() throws {
        let idToken =
            "eyJhbGciOiJFUzUxMiJ9.eyJ1cm46ZXhhbXBsZTpjbGFpbSI6dHJ1ZSwiaWF0IjoxNjQyNDA5NjQ4LCJpc3MiOiJodHRwczovL2xvZ3RvLmRldi9vaWRjIiwic3ViIjoiZm9vIiwiYXVkIjoiMTIzIiwiZXhwIjoxNjQyNDE2ODQ4fQ.ABQro2j_TvBHv9rUaOGBbLrWiW0XgpWTGhEus95uvnFkB2AqPFRNG_mF4P5Q3VPMVke-b6KkVdZ9En0T1BNJ7vmHAQhSVamZSpj6A_fKLhR7cghYsl4yX0vMPpiC7fdluskMLj_68wOaQ3Gay48MqQqPevw_6VKKZ7FMdS8UrwDgCqmX"
        let jwk = try ECPublicKey(data: Data("""
            {"kty":"EC","x":"AOFMpV0kE_gJqYs0Apah4NWYz8UMV7xkbqeIC4cP4d_HSvo4p3n8EhxJf-7wBxF4yOX5ctwH1DmK5U40-lqQF3gP","y":"AS9fnFxFydqBbKjnSO_YOX0LWgdxA4N0Td-xEgsPPhgc_PkkvoE2307IlbRh6cvFcWm7hO_dnlRnyC420tEDEtTy","crv":"P-521"}
        """.utf8))
        let jwks = JWKSet(keys: [jwk])
        let issuer = "https://logto.dev/oidc"
        let clientId = "123"
        XCTAssertNoThrow(try LogtoUtilities.verifyIdToken(
            idToken,
            issuer: issuer,
            clientId: clientId,
            jwks: jwks,
            forTimeInterval: 1_642_409_648
        ))
    }
}
