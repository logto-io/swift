//
//  UserScope.swift
//
//
//  Created by Gao Sun on 2023/11/28.
//

import Foundation

public enum UserScope: String {
    /// The reserved scope for OpenID Connect. It maps to the `sub` claim.
    case openid
    /// The OAuth 2.0 scope for offline access (`refresh_token`).
    case offlineAccess = "offline_access"
    /// The scope for the basic profile. It maps to the `name`, `username`, `picture` claims.
    case profile
    /// The scope for the email address. It maps to the `email`, `email_verified` claims.
    case email
    /// The scope for the phone number. It maps to the `phone_number`, `phone_number_verified` claims.
    case phone
    /// The scope for the custom data. It maps to the `custom_data` claim.
    ///
    /// Note that the custom data is not included in the ID token by default. You need to
    /// use `fetchUserInfo()` to get the custom data.
    case customData = "custom_data"
    /// The scope for the identities. It maps to the `identities` claim.
    ///
    /// Note that the identities are not included in the ID token by default. You need to
    /// use `fetchUserInfo()` to get the identities.
    case identities
    /// The scope for user's roles for API resources. It maps to the `roles` claim.
    case roles
    /// Scope for user's organization IDs and perform organization token grant per [RFC 0001](https://github.com/logto-io/rfcs).
    ///
    /// To learn more about Logto Organizations, see [Logto docs](https://docs.logto.io/docs/recipes/organizations/).
    case organizations = "urn:logto:scope:organizations"
    /// Scope for user's organization roles per [RFC 0001](https://github.com/logto-io/rfcs).
    ///
    /// To learn more about Logto Organizations, see [Logto docs](https://docs.logto.io/docs/recipes/organizations/).
    case organizationRoles = "urn:logto:scope:organization_roles"
}
