//
//  ModelTests.swift
//  Hiyoko
//
//  Created by tarunon on 2017/04/29.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import XCTest
@testable import HiyokoKit
import Himotoki

class ModelTests: XCTestCase {
    func successOrFailure<T>(_ f: @autoclosure () throws -> T) {
        do {
            _ = try f()
        } catch {
            XCTFail("\(error)")
        }
    }
    func testUserDecode() {
        successOrFailure(try User.decodeValue(JSONSerialization.jsonObject(with: Data(contentsOf: Bundle(for: ModelTests.self).url(forResource: "User", withExtension: "json")!), options: [])))
    }
    
    func testTweetDecode() {
        successOrFailure(try [Tweet].decode(JSONSerialization.jsonObject(with: Data(contentsOf: Bundle(for: ModelTests.self).url(forResource: "Tweet", withExtension: "json")!), options: [])))
    }
    
    func testSavedSearchDecode() {
        successOrFailure(try [SavedSearch].decode(JSONSerialization.jsonObject(with: Data(contentsOf: Bundle(for: ModelTests.self).url(forResource: "SavedSearch", withExtension: "json")!), options: [])))
    }
    
    func testListDecode() {
        successOrFailure(try List.decodeValue(JSONSerialization.jsonObject(with: Data(contentsOf: Bundle(for: ModelTests.self).url(forResource: "List", withExtension: "json")!), options: [])))
    }
}
