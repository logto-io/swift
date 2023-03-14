//
//  UserInfoProtocol.swift
//
//
//  Created by Gao Sun on 2022/11/6.
//

import Foundation

public protocol UserInfoProtocol: Codable, Equatable {
    var name: String? { get }
    var picture: String? { get }
    var username: String? { get }
    var email: String? { get }
    var emailVerified: Bool? { get }
    var phoneNumber: String? { get }
    var phoneNumberVerified: Bool? { get }
}
