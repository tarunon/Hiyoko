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
    var result: Observable<Result> { get }
}
