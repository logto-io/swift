//
//  String.swift
//
//
//  Created by Gao Sun on 2022/1/7.
//

import Foundation

extension String {
    var isUrlSafe: Bool {
        !contains(where: { "+/=".contains($0) })
    }
}
