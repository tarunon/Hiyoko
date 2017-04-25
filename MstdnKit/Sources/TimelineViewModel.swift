//
//  TimelineViewModel.swift
//  mstdn
//
//  Created by tarunon on 2017/04/24.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxExtensions
import Persistents
import APIClient
import Realm
import RealmSwift

public protocol TimeLineViewControllerType {
    associatedtype BaseRequest: Request
    var loadNext: Observable<Void> { get }
    var reload: Observable<Void> { get }
    var closeButtonTapped: Observable<Void> { get }
    var apiClient: APIClient.Client { get }
    var baseRequest: BaseRequest { get }
    var realm: Realm { get }
}

public class TimeLineViewModel<O: TimeLineViewControllerType>: RxViewModel where O.BaseRequest.Response == [Status] {
    public typealias Result = Void
    public let result: Observable<Void>
    
    public init(view: O) {
        fatalError()
    }
}
