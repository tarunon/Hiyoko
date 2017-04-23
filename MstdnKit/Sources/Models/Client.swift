//
//  Client.swift
//  mstdn
//
//  Created by tarunon on 2017/04/23.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Himotoki
import Illuso
import Persistents

public struct Client {
    public var id: Int
    public var redirectURI: String
    public var clientId: String
    public var clientSecret: String
    
    public struct Form {
        public var name: String = "Test"
        public var redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
        public var scopes: String = "read write follow"
        public var website: String? = "https://github.com/tarunon/mstdn"
    }
}

extension Client: Decodable {
    public static func decode(_ e: Extractor) throws -> Client {
        return try Client.init(
            id: e <| "id",
            redirectURI: e <| "redirect_uri",
            clientId: e <| "client_id",
            clientSecret: e <| "client_secret"
        )
    }
}

extension Client: Encodable {
    public func encode() throws -> JSON {
        return try encode(
            [
                "id": id,
                "redirect_uri": redirectURI,
                "client_id": clientId,
                "client_secret": clientSecret                
            ]
        )
    }
}

extension Client.Form: Encodable {
    public func encode() throws -> JSON {
        return try encode(
            [
                "client_name": name,
                "redirect_uris": redirectURI,
                "scopes": scopes,
                "website": website
            ]
        )
    }
}

extension Client: PersistentValueProtocol {}
