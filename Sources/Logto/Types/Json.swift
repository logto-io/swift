//
//  File.swift
//
//
//  Created by Gao Sun on 2022/11/6.
//

import Foundation

public enum JsonValue: Codable, Equatable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case array([JsonValue])
    case object(JsonObject)
}

public typealias JsonObject = [String: JsonValue]
