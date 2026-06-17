//
//  LogtoAuthContext.swift
//
//
//  Created by Gao Sun on 2022/1/29.
//

#if os(iOS)
    import AuthenticationServices
    import Foundation
    import UIKit

    class LogtoAuthContext: NSObject, ASWebAuthenticationPresentationContextProviding {
        func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
            UIApplication.shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .filter { $0.activationState == .foregroundActive }
                .flatMap(\.windows)
                .first { $0.isKeyWindow } ?? ASPresentationAnchor()
        }
    }
#endif
