//
//  Extensions.swift
//  mstdn
//
//  Created by tarunon on 2017/04/23.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Himotoki
import Base

public extension Date {
    public struct Transformers {
        public static let timeInterval = Transformer<TimeInterval, Date>.init { Date(timeIntervalSince1970: $0) }
    }
}

public extension URL {
    enum Error: Swift.Error {
        case failToDecode
    }
    public struct Transformers {
        public static let string = Transformer<String, URL>.init { try URL(string: $0) ??? Error.failToDecode }
    }
}
