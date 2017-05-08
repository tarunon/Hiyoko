//
//  UIActivityViewController+Rx.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/05.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class ActivityViewModel: RxViewModel {
    public typealias Result = (UIActivityType?, Bool, [Any]?)
    public typealias Input = Result
    public typealias Output = Never
    
    public let result: Observable<(UIActivityType?, Bool, [Any]?)>
    public let emitter: RxIOEmitter<Input, Never> = RxIOEmitter()
    
    public init() {
        result = emitter.input
    }
}

extension UIActivityViewController {
    public func bind(viewModel: ActivityViewModel.ViewBinder) -> Disposable {
        return Observable<ActivityViewModel.Result>
            .create { [unowned self] (observer) -> Disposable in
                self.completionWithItemsHandler = { (type, success, parameters, error) in
                    if let error = error {
                        if (error as NSError).code != CocoaError.userCancelled.rawValue {
                            observer.onError(error)
                        } else {
                            observer.onCompleted()
                        }
                    } else {
                        observer.onNext((type, success, parameters))
                        observer.onCompleted()
                    }
                    self.completionWithItemsHandler = nil
                }
                return Disposables.create()
            }
            .bind(to: viewModel.input)
    }
}
