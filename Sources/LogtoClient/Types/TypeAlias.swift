//
//  TypeAlias.swift
//
//
//  Created by Gao Sun on 2022/3/23.
//

import Foundation

#if !os(macOS)
    import UIKit
    public typealias UnifiedViewController = UIViewController
#else
    import Cocoa
    public typealias UnifiedViewController = NSViewController
#endif
