//
//  HttpCompletion.swift
//
//
//  Created by Gao Sun on 2022/1/19.
//

import Foundation

typealias HttpCompletion<T> = (T?, Error?) -> Void
