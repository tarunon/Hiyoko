//
//  EmptyViewModel.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/05.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import RxExtensions

public class EmptyReactor: Reactor {
    public typealias Result = Never
    public typealias Action = Never
    public typealias State = Never
    
    public init() {
        
    }
    
    public func process(action: Observable<Never>) throws -> Process<Never, Never> {
        return .init(state: Observable.never(), result: Observable.never())
    }
}

public protocol EmptyView: View {
    associatedtype State = Never
    associatedtype Action = Never
}

extension EmptyView where State == Never, Action == Never {
    public func present(state: Observable<Never>) -> Present<Never> {
        return .init(action: Observable.never())
    }
}
