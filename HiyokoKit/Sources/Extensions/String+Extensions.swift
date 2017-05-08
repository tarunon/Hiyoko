//
//  String+Extensions.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/04.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation

extension String {
    func substring(with range: Range<Int>) -> String {
        return self.substring(with: index(startIndex, offsetBy: range.lowerBound)..<index(startIndex, offsetBy: range.upperBound))
    }
    
    func substring(from offset: Int) -> String {
        guard let index = index(startIndex, offsetBy: offset, limitedBy: endIndex) else {
            return ""
        }
        return self.substring(from: index)
    }
    
    func twitterUnescaped() -> String {
        return self
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&amp;", with: "&")
    }
}
