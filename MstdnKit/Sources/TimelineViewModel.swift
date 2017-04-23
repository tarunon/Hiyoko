//
//  TimelineViewModel.swift
//  mstdn
//
//  Created by tarunon on 2017/04/24.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import UIKitExtensions
import RxSwift
import RxCocoa
import Persistents
import APIClient
import Realm
import RealmSwift

public protocol TimeLineViewModelOwner {
    associatedtype BaseRequest: Request
    var loadNext: Observable<Void> { get }
    var reload: Observable<Void> { get }
    var closeButtonTapped: Observable<Void> { get }
    var apiClient: APIClient.Client { get }
    var baseRequest: BaseRequest { get }
    var realm: Realm { get }
}

public class TimeLineViewModel<O: TimeLineViewModelOwner>: RxViewModel where O.BaseRequest.Response == [Status] {
    public typealias Owner = O
    public typealias Result = Void
    public let result: Observable<Void>
    
    public init(owner: O) {
        fatalError()
    }
}
