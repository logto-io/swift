import Foundation

/// A signed ID Token and the JWK to verify it, shared by the verification tests.
///
/// The token was issued at `issuedAt` and expires at `expiresAt` (in 2022), so verifying it requires either a
/// `forTimeInterval` within that window or a clock tolerance that covers its age.
public enum IdTokenFixtures {
    public static let issuer = "https://logto.dev/oidc"
    public static let clientId = "foo"
    public static let issuedAt: TimeInterval = 1_641_812_017
    public static let expiresAt: TimeInterval = 1_641_815_617

    public static let rsaIdToken =
        "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IkNza2w2SDRGR3NpLXE0QkVPT1BQOWJlbHNoRGFHZjd3RXViVU5KQllwQmsifQ.eyJzdWIiOiJ3anNadVc4VWpQd2ciLCJhdF9oYXNoIjoibkZOZGdOSWcwWmw0ZWxaTEhMVVpHZyIsImF1ZCI6ImZvbyIsImV4cCI6MTY0MTgxNTYxNywiaWF0IjoxNjQxODEyMDE3LCJpc3MiOiJodHRwczovL2xvZ3RvLmRldi9vaWRjIn0.SCAFRIRWq_iSVbbb3yO3_vvin8XUVWeFIgnsHumSdSBG8qeF9LuO-Hm4xjrTN-XREsifAfGHMrmRC23_QAkwtK8u36m-rlvBnJjq9SdqlQJAyFhCez2Uojzn97CFlwv_n8ucSyy6ToeBrbR1DqvUWdo8lrCer7WHQ3OJRe2U3pAAU9_zqMU6sntP2GshNYnA3IKylhRNFQlP91HT80ROPhgll6GCieTLlCiIeb6Q3KigBDTQ1vJYhK-NaHNP646MQeheUofhFsEZGZFS0OxNPm1FDCsxU2Nwvts7KjxjYM5wb2D5ELB1tFmes7XNWk12bNyN0dEGTugH98CtC_kIA67rZU5q9eUZRuWHPRjraWkdTemNWtW5MvBaVpAMYNJn0Fk5EKSsco_MNvZCszoKvViGo06f1YUex_jkGsOTcttdIbR-780ulWCR0txmg2gu21RRN7oMF4aTs-W7cEKOYuyRX85XTWo_Lu3BugI8kKbSwUsmO8oYPjdpipjcTf-8KJLNOkBefiWDNzM0VoysAlKYUx9aMOSD4gc7h0di7KVZFlEQ7JByn1_gyi8yHrRrHCkzLCe73gBGruijhADoISC6Uq3WmdkQvdYRpRMv0Fz9Wj6vjRhvr1nAu4ZHhsfohCIHVVMKHxXmgfjNKjBTcaRWxit39MK_-sk2Fr52F2w"

    public static let rsaJwkJson =
        #"{"kty":"RSA","use":"sig","kid":"Cskl6H4FGsi-q4BEOOPP9belshDaGf7wEubUNJBYpBk","e":"AQAB","n":"pB5nO7qovnRQrSQoVmdh0g6TGtMMjc1eS0rexzcuVIgtD-7-84DHt9FaiS8UVr2Tjdp_U4Jr-mJJNbYhxae2FjNkpWf_ETND8hEYTSCZTJCkX0asnzb-xZgt2_xNiOAUzmXEaSHO215Y-WYL2LydLjoMrK70FfoFC4jnsgnnKlf1fQW2llCpG-b19w-aHU5m8fPOWKz5n27jEYNbEqHK-wsGavt7eyhVfEVPNbVl5j_n8o-VfnQT-LyO4Fg6U0XwHz1yXrT7NUMO_qdfwv1QbM0EPyWkxLoSColRZVibPmMpkc9RcOJ2crP5u602W8UOYvbtcBCaXVbzp5iriBAVxRq3tsrnTpHr-1FV5jtwU1aLMucIkOM3iJGSLoLizgwEIAnmLh1u_-lxFeSEWDX3RIE3kZOWdZoRBKcxCYPV4X7Mkca8UNW42FTeUG8f9bq43_FgZvWnnFBYpzTuHTnLlkw1a3GmjRy02_tqhV7xp5rM65Jc8HZEW81L3JKLp87ySqjKWfBkmI0ebzEPZVwV69ggI6eBVzGK1nViHsBWgDAomBGPVUqfZmACIcdy7hOp-40mDa6RscqBFtpd3RPb6lGyf2yDCH-4AY6ZRQUX10TdtW2NQon8-SBNgye4x5ZiUS7EXFxvIaTEZ_MZryS3yo5_xWtYAZLCJrDqEZLY2mE"}"#

    public static let rsaJwkSetJson = "{\"keys\":[\(rsaJwkJson)]}"
}
