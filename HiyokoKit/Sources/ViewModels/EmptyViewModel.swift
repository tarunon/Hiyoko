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
    public typealias Result = Void
    public typealias Input = Void
    public typealias Output = Void
    
    public let result: Observable<Void>
    public let emitter: RxIOEmitter<Void, Void> = RxIOEmitter()
    
    public init() {
        result = emitter.input
    }
}
