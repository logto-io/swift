//
//  HttpCompletion.swift
//
//
//  Created by Gao Sun on 2022/1/19.
//

import Foundation

public typealias Completion<T, E: Error> = (T?, E?) -> Void

public typealias EmptyCompletion<E: Error> = (E?) -> Void

public typealias HttpCompletion<T> = Completion<T, Error>

public typealias HttpEmptyCompletion = EmptyCompletion<Error>
