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
    
    public func state(action: Observable<Never>, result: AnyObserver<Never>) -> Observable<Never> {
        return Observable.empty()
    }
}
