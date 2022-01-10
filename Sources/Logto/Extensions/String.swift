//
//  String.swift
//
//
//  Created by Gao Sun on 2022/1/7.
//

import Foundation

extension String {
    static func fromUrlSafeBase64(string: String) -> String? {
        guard let data = Data.fromUrlSafeBase64(string: string) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    var isUrlSafe: Bool {
        !contains(where: { "+/=".contains($0) })
    }
}
