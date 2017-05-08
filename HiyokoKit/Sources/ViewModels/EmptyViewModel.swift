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

public class EmptyViewModel: RxViewModel {
    public typealias Result = Never
    public typealias Action = Never
    public typealias State = Never
    
    public init() {
        
    }
    
    public func process(action: Observable<Never>) throws -> Process<Never, Never> {
        return .init(state: Observable.empty(), result: Observable.never())
    }
}
