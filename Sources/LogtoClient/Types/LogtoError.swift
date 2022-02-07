//
//  File.swift
//
//
//  Created by Gao Sun on 2022/2/4.
//

import Foundation

public protocol LogtoError: LocalizedError {
    associatedtype T
    var type: T { get }
    var innerError: Error? { get }
}
