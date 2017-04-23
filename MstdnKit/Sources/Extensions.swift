//
//  Extensions.swift
//  mstdn
//
//  Created by tarunon on 2017/04/23.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Himotoki

public extension Date {
    public struct Transformers {
        public static let timeInterval = Transformer<TimeInterval, Date>.init { Date(timeIntervalSince1970: $0) }
    }
}
