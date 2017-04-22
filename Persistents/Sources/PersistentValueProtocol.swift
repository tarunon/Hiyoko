//
//  PersistentValueProtocol.swift
//  mstdn
//
//  Created by tarunon on 2017/04/22.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Himotoki
import Illuso
import Base

public protocol PersistentValueProtocol {
    func encode() throws -> Data
    static func decode(data: Data) throws -> Self
}

public extension PersistentValueProtocol {
    public func encode() throws -> Data {
        return try NSKeyedArchiver.archivedData(withRootObject: Illuso.encode(self))
    }
}

public extension PersistentValueProtocol where Self: Decodable {
    public static func decode(data: Data) throws -> Self {
        return try decodeValue(NSKeyedUnarchiver.unarchiveObject(with: data) ?? DecodeError.custom("fail to unarchive"))
    }
}
