//
//  Extensions.swift
//  mstdn
//
//  Created by tarunon on 2017/04/22.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation

/// https://gist.github.com/tarunon/6e63b708140392564418eb80ac64e899
public func undefined<T>(file: String = #file, function: String = #function, line: Int = #line, message: String?=nil) -> T {
    fatalError((message ?? "") + "[undefined \(T.self), File: \(file) function: \(function) line: \(line)]")
}

/// https://gist.github.com/erica/5a26d523f3d6ffb74e34d179740596f7
infix operator ???

public func ??? <T>(lhs: T?, error: @autoclosure () -> Error) throws -> T {
    guard let value = lhs else { throw error() }
    return value
}

public indirect enum Box<T> {
    case value(T)
    
    public init(_ value: T) {
        self = .value(value)
    }
    
    public var value: T {
        switch self {
        case .value(let value):
            return value
        }
    }
}
