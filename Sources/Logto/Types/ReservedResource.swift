//
//  ReservedResource.swift
//
//
//  Created by Gao Sun on 2023/11/28.
//

import Foundation

/// Resources that reserved by Logto, which cannot be defined by users.
public enum ReservedResource: String {
    /// The resource for organization template per [RFC 0001](https://github.com/logto-io/rfcs).
    case organizations = "urn:logto:resource:organizations"
}
