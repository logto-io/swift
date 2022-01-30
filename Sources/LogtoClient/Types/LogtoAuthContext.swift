//
//  LogtoAuthContext.swift
//
//
//  Created by Gao Sun on 2022/1/29.
//

import AuthenticationServices
import Foundation

class LogtoAuthContext: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}
