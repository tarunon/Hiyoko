//
//  Entities.swift
//  Hiyoko
//
//  Created by tarunon on 2017/04/29.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RealmSwift
import Himotoki
import Illuso

public struct Entities {
    public struct Hashtag {
        public var indices: Range<Int>
        public var text: String
    }
    
    public struct Symbol {
        public var indices: Range<Int>
        public var text: String
    }
    
    public struct URL {
        public var displayURL: String
        public var expandedURL: Foundation.URL
        public var indices: Range<Int>
        public var url: Foundation.URL
    }
    
    public struct Mention {
        public var id: Int64
        public var indices: Range<Int>
        public var name: String
        public var screenName: String
    }
    
    public struct Media {
        public struct Size {
            public var resize: String
            public var width: Int
            public var height: Int
        }
        public struct Sizes {
            public var thumb: Size
            public var large: Size
            public var medium: Size
            public var small: Size
        }
        public struct VideoInfo {
            public struct Variant {
                public var bitrate: Int?
                public var contentType: String
                public var url: Foundation.URL
            }
            public var aspectRatio: (width: Int, height: Int)
            public var durationMillis: Int
            public var variants: [Variant]
        }
        public var id: Int64
        public var displayURL: String
        public var expandedURL: Foundation.URL
        public var indices: Range<Int>
        public var mediaURL: Foundation.URL
        public var sizes: Sizes
        public var type: String
        public var videoInfo: VideoInfo?
        public var url: Foundation.URL
    }
    
    public var hashtags: [Hashtag]
    public var symbols: [Symbol]
    public var urls: [URL]
    public var mentions: [Mention]
    public var media: [Media]
    public var extends: [Media]
    
    static let empty = Entities(hashtags: [], symbols: [], urls: [], mentions: [], media: [], extends: [])
}

extension Entities.Hashtag: Decodable {
    public static func decode(_ e: Extractor) throws -> Entities.Hashtag {
        return try .init(
            indices: Range.Transformers.array.apply(e <|| "indices"),
            text: e <| "text"
        )
    }
}

extension Entities.Hashtag: Encodable {
    public func encode() throws -> JSON {
        return try encode(
            [
                "indices": indices,
                "text": text
            ]
        )
    }
}

extension Entities.Symbol: Decodable {
    public static func decode(_ e: Extractor) throws -> Entities.Symbol {
        return try .init(
            indices: Range.Transformers.array.apply(e <|| "indices"),
            text: e <| "text"
        )
    }
}

extension Entities.Symbol: Encodable {
    public func encode() throws -> JSON {
        return try encode(
            [
                "indices": indices,
                "text": text
            ]
        )
    }
}

extension Entities.URL: Decodable {
    public static func decode(_ e: Extractor) throws -> Entities.URL {
        return try .init(
            displayURL: e <| "display_url",
            expandedURL: e <| "expanded_url",
            indices: Range.Transformers.array.apply(e <|| "indices"),
            url: e <| "url"
        )
    }
}

extension Entities.URL: Encodable {
    public func encode() throws -> JSON {
        return try encode(
            [
                "display_url": displayURL,
                "expanded_url": expandedURL,
                "indices": indices,
                "url": url
            ]
        )
    }
}

extension Entities.Mention: Decodable {
    public static func decode(_ e: Extractor) throws -> Entities.Mention {
        return try .init(
            id: e <| "id",
            indices: Range.Transformers.array.apply(e <|| "indices"),
            name: e <| "name",
            screenName: e <| "screen_name"
        )
    }
}

extension Entities.Mention: Encodable {
    public func encode() throws -> JSON {
        return try encode(
            [
                "id": id,
                "indices": indices,
                "name": name,
                "screen_name": screenName
            ]
        )
    }
}

extension Entities.Media.Size: Decodable {
    public static func decode(_ e: Extractor) throws -> Entities.Media.Size {
        return try .init(
            resize: e <| "resize",
            width: e <| "w",
            height: e <| "h"
        )
    }
}

extension Entities.Media.Size: Encodable {
    public func encode() throws -> JSON {
        return try encode(
            [
                "resize": resize,
                "w": width,
                "h": height
            ]
        )
    }
}

extension Entities.Media.Sizes: Decodable {
    public static func decode(_ e: Extractor) throws -> Entities.Media.Sizes {
        return try .init(
            thumb: e <| "thumb",
            large: e <| "large",
            medium: e <| "medium",
            small: e <| "small"
        )
    }
}

extension Entities.Media.Sizes: Encodable {
    public func encode() throws -> JSON {
        return try encode(
            [
                "thumb": thumb,
                "large": large,
                "medium": medium,
                "small": small
            ]
        )
    }
}

extension Entities.Media.VideoInfo.Variant: Decodable {
    public static func decode(_ e: Extractor) throws -> Entities.Media.VideoInfo.Variant {
        return try .init(
            bitrate: e <|? "bitrate",
            contentType: e <| "content_type",
            url: e <| "url"
        )
    }
}

extension Entities.Media.VideoInfo.Variant: Encodable {
    public func encode() throws -> JSON {
        return try encode(
            dictionary: [
                "bitrate": bitrate,
                "content_type": contentType,
                "url": url
            ]
        )
    }
}

extension Entities.Media.VideoInfo: Decodable {
    public static func decode(_ e: Extractor) throws -> Entities.Media.VideoInfo {
        return try .init(
            aspectRatio: Transformer<[Int], (width: Int, height: Int)> { ($0[0], $0[1]) }.apply(e <|| "aspect_ratio"),
            durationMillis: e <| "duration_millis",
            variants: e <|| "variants"
        )
    }
}

extension Entities.Media.VideoInfo: Encodable {
    public func encode() throws -> JSON {
        return try encode(
            [
                "aspect_ratio": [aspectRatio.width, aspectRatio.height],
                "duration_millis": durationMillis,
                "variants": variants
            ]
        )
    }
}

extension Entities.Media: Decodable {
    public static func decode(_ e: Extractor) throws -> Entities.Media {
        return try .init(
            id: e <| "id",
            displayURL: e <| "display_url",
            expandedURL: e <| "expanded_url",
            indices: Range.Transformers.array.apply(e <|| "indices"),
            mediaURL: e <| "media_url_https",
            sizes: e <| "sizes",
            type: e <| "type",
            videoInfo: e <|? "video_info",
            url: e <| "url"
        )
    }
}

extension Entities.Media: Encodable {
    public func encode() throws -> JSON {
        return try encode(
            dictionary: [
                "id": id,
                "display_url": displayURL,
                "expanded_url": expandedURL,
                "indices": indices,
                "media_url_https": mediaURL,
                "sizes": sizes,
                "type": type,
                "video_info": videoInfo,
                "url": url
            ]
        )
    }
}

extension Entities: Decodable {
    public static func decode(_ e: Extractor) throws -> Entities {
        return try .init(
            hashtags: e <||? "hashtags" ?? [],
            symbols: e <||? "symbols" ?? [],
            urls: e <||? "urls" ?? [],
            mentions: e <||? "user_mentions" ?? [],
            media: e <||? "media" ?? [],
            extends: e <||? "extended_entities" ?? []
        )
    }
}

extension Entities: Encodable {
    public func encode() throws -> JSON {
        return try encode(
            [
                "hashtags": hashtags,
                "symbols": symbols,
                "urls": urls,
                "mentions": mentions,
                "media": media,
                "extends": extends
            ]
        )
    }
}
