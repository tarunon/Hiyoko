//
//  Section.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/01.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxDataSources

public struct Section<I> {
    public var items: [I]
    
    public init(items: [I]) {
        self.items = items
    }
}

extension Section: SectionModelType {
    public typealias Item = I
    public init(original: Section, items: [I]) {
        self = original
        self.items = items
    }
}

public struct AnimatableSection<I: Equatable & IdentifiableType> {
    public var identity = 0
    public var items: [I]
    
    public init(items: [I]) {
        self.items = items
    }
}

extension AnimatableSection: AnimatableSectionModelType {
    public typealias Identity = Int
    public typealias Item = I
    public init(original: AnimatableSection, items: [I]) {
        self = original
        self.items = items
    }
}
