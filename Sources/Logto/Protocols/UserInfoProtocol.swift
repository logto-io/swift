//
//  UserInfoProtocol.swift
//
//
//  Created by Gao Sun on 2022/11/6.
//

import Foundation

public protocol UserInfoProtocol: Codable, Equatable {
    /// The user's full name.
    var name: String? { get }
    /// The user's profile picture URL.
    var picture: String? { get }
    /// The user's username.
    var username: String? { get }
    /// The user's email address.
    var email: String? { get }
    /// Whether the user's email address is verified.
    var emailVerified: Bool? { get }
    /// The user's phone number.
    var phoneNumber: String? { get }
    /// Whether the user's phone number is verified.
    var phoneNumberVerified: Bool? { get }
    /// The role names of the current user.
    var roles: [String]? { get }
    /// The organization IDs that the user has membership.
    var organizations: [String]? { get }
    /// The organization roles that the user has.
    /// Each role is in the format of `<organization_id>:<role_name>`.
    ///
    /// # Example #
    /// The following array indicates that user is an admin of org1 and a member of org2:
    /// ```swift
    /// ["org1:admin", "org2:member"]
    /// ```
    var organizationRoles: [String]? { get }
}
