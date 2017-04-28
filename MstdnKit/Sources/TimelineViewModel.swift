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
import RealmSwift
import RxRealm
import Barrel
import Barrel_Realm

public protocol TimeLineViewControllerType {
    associatedtype BaseRequest: RequestBase
    var loadNext: Observable<Void> { get }
    var reload: Observable<Void> { get }
    var closeButtonTapped: Observable<Void> { get }
    var apiClient: APIClient.Client { get }
    var baseRequest: BaseRequest { get }
    var statuses: AnyObserver<[Status]> { get }
    
    func realm() throws -> Realm
}

public class TimeLineViewModel<V: TimeLineViewControllerType>: RxViewModel where V.BaseRequest.Response == [Status] {
    public typealias Result = Void
    public let result: Observable<Void>
    
    enum Load {
        case reload
        case loadNext
    }
    
    public init(view: V) {
        result = Observable
            .create { (observer) -> Disposable in
                let initialRequst = AnyRequest(Requests.TimelinePagination(base: view.baseRequest))
                let loadSubscription = view.reload
                    .take(1)
                    .flatMapFirst { _ in
                        view.apiClient.request(request: initialRequst)
                    }
                    .flatMap { (response) -> Observable<[Status]> in
                        var nextRequest = response.next
                        return Observable
                            .merge(
                                view.reload.map { (Load.reload, initialRequst) },
                                view.loadNext.flatMap { Observable.from(optional: nextRequest) }.map { (Load.loadNext, $0) }
                            )
                            .flatMapFirst { (loadType, request) -> Observable<[Status]> in
                                switch loadType {
                                case .reload:
                                    return view.apiClient.request(request: request)
                                        .map { $0.response }
                                case .loadNext:
                                    return view.apiClient.request(request: request)
                                        .do(
                                            onNext: { response in
                                                nextRequest = response.next
                                            }
                                        )
                                        .map { $0.response }
                                 }
                            }
                            .startWith(response.response)
                    }
                    .do(
                        onNext: { (statuses) in
                            let realm = try view.realm()
                            try realm.write {
                                realm.add(statuses, update: true)
                            }
                        }
                    )
                    .subscribe()
                
                let publishSubscription = Observable.just((), scheduler: MainScheduler.instance)
                    .flatMap { _ -> Observable<[Status]> in
                        let realm = try view.realm()
                        return Observable<Results<Status>>
                            .array(
                                from: Status.objects(realm).brl
                                    .sorted { $0.created > $1.created }
                                    .confirm(),
                                synchronousStart: true
                            )
                    }
                    .bind(to: view.statuses)
                
                let closeSubscription = view.closeButtonTapped
                    .take(1)
                    .bind(to: observer)
                
                return Disposables.create(loadSubscription, publishSubscription, closeSubscription)
            }
    }
}
