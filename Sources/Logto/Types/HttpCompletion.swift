//
//  HttpCompletion.swift
//
//
//  Created by Gao Sun on 2022/1/19.
//

import Foundation

public typealias HttpCompletion<T> = (T?, Error?) -> Void

public typealias HttpEmptyCompletion = (Error?) -> Void
