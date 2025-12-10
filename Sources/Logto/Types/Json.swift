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
    case null

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let v = try? container.decode(String.self) {
            self = .string(v)
            return
        }
        if let v = try? container.decode(Double.self) {
            self = .number(v)
            return
        }
        if let v = try? container.decode(Bool.self) {
            self = .bool(v)
            return
        }
        if let v = try? container.decode([JsonValue].self) {
            self = .array(v)
            return
        }
        if let v = try? container.decode(JsonObject.self) {
            self = .object(v)
            return
        }
        if container.decodeNil() {
            self = .null
            return
        }

        throw DecodingError.typeMismatch(
            JsonValue.self,
            .init(codingPath: decoder.codingPath, debugDescription: "Invalid JSON value")
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(v): try container.encode(v)
        case let .number(v): try container.encode(v)
        case let .bool(v): try container.encode(v)
        case let .array(v): try container.encode(v)
        case let .object(v): try container.encode(v)
        case .null: try container.encodeNil()
        }
    }
}

public typealias JsonObject = [String: JsonValue]
