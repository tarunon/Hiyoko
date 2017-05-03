//
//  RxViewModel.swift
//  mstdn
//
//  Created by tarunon on 2017/04/23.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public protocol RxViewModel {
    associatedtype Result
    associatedtype Input
    associatedtype Output
    
    var emitter: RxIOEmitter<Input, Output> { get }
    var result: Observable<Result> { get }
}

public class RxIOEmitter<Input, Output> {
    fileprivate let inputSubject = ReplaySubject<Input>.create(bufferSize: 1)
    fileprivate let outputSubject = ReplaySubject<Output>.create(bufferSize: 1)
    
    public init(inputType: Input.Type=Input.self, outputType: Output.Type=Output.self) {
        
    }
        
    public var input: Observable<Input> {
        return inputSubject.asObservable()
    }
    
    public var output: AnyObserver<Output> {
        return outputSubject.asObserver()
    }
}

public class ViewBinder<Input, Output> {
    public let input: AnyObserver<Input>
    public let output: Observable<Output>
    init<I: ObserverType, O: ObservableType>(_ input: I, _ output: O) where I.E == Input, O.E == Output {
        self.input = input.asObserver()
        self.output = output.asObservable()
    }
}

extension RxViewModel {
    public typealias ViewBinder = RxExtensions.ViewBinder<Input, Output>
    
    internal func asViewBinder() -> ViewBinder {
        return ViewBinder(emitter.inputSubject, emitter.outputSubject)
    }
}
