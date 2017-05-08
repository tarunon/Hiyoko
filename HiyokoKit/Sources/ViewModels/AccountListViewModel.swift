//
//  AccountListViewModel.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/01.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import RxExtensions
import Persistents
import OAuthSwift
import RealmSwift
import Barrel
import Barrel_Realm
import RxRealm

public enum AccountCellModel {
    case account(Account, Int64, OAuthSwiftCredential)
    case new
}

extension AccountCellModel: Equatable {
    public static func == (lhs: AccountCellModel, rhs: AccountCellModel) -> Bool {
        switch (lhs, rhs) {
        case (.account(_, let lid, _), .account(_, let rid, _)):
            return lid == rid
        case (.new, .new):
            return true
        default:
            return false
        }
    }
}

extension AccountCellModel: IdentifiableType {
    public typealias Identity = Int64
    public var identity: Int64 {
        switch self {
        case .account(_ , let id, _):
            return id
        case .new:
            return 0
        }
    }
}

public class AccountListViewModel: RxViewModel {
    public enum Action {
        case select(Account)
        case delete(Account)
        case new(Account, OAuthSwiftCredential)
        
        var select: Observable<Account> {
            switch self {
            case .select(let account): return .just(account)
            default: return .empty()
            }
        }
        
        var delete: Observable<Account> {
            switch self {
            case .delete(let account): return .just(account)
            default: return .empty()
            }
        }
        
        var new: Observable<(Account, OAuthSwiftCredential)> {
            switch self {
            case .new(let account, let credential): return .just((account, credential))
            default: return .empty()
            }
        }
    }
    
    public typealias Result = (Account, OAuthSwiftCredential)
    public typealias State = [AnimatableSection<AccountCellModel>]
    
    
    let realm: () throws -> Realm
    let credentialFor: (Account) -> PersistentStore<OAuthSwiftCredential>
    
    public init(realm: @escaping () throws -> Realm, credentialFor: @escaping (Account) -> PersistentStore<OAuthSwiftCredential>) {
        self.realm = realm
        self.credentialFor = credentialFor
    }
    
    public func state(action: Observable<AccountListViewModel.Action>, result: AnyObserver<(Account, OAuthSwiftCredential)>) -> Observable<[AnimatableSection<AccountCellModel>]> {
        let actions = Observable<State>
            .create { (observer) in
                observer.onCompleted()
                return action
                    .shareReplay(1)
                    .bind { (action) -> Disposable in
                        let d1 = action
                            .flatMapFirst { $0.select }
                            .map { ($0, try self.credentialFor($0).restore()) }
                            .bind(to: result)
                        let d2 = action
                            .flatMapFirst { $0.delete }
                            .do(
                                onNext: { (account) in
                                    try account.realm?.write {
                                        account.realm?.delete(account)
                                    }
                                }
                            )
                            .flatMap { _ in Observable.empty() }
                            .bind(to: result)
                        let d3 = action
                            .flatMapFirst { $0.new }
                            .shareReplay(1)
                            .bind { (newAccount) -> Disposable in
                                let d1 = newAccount
                                    .do(
                                        onNext: { (account, credential) in
                                            try self.credentialFor(account).store(credential)
                                            let realm = try self.realm()
                                            try realm.write {
                                                realm.add(account, update: true)
                                            }
                                        }
                                    )
                                    .bind(to: result)
                                return Disposables.create(d1, d2)
                        }
                        return Disposables.create(d1, d2, d3)
                }
        }
        
        let accounts = Observable<Realm>
            .create { (observer) -> Disposable in
                do {
                    observer.onNext(try self.realm())
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
            .subscribeOn(MainScheduler.instance)
            .shareReplay(1)
            .flatMap { (realm) in
                Observable
                    .array(
                        from: Account.objects(realm).brl
                            .sorted { $0.createdAt < $1.createdAt }
                            .confirm()
                    )
            }
            .map { try $0.map { try AccountCellModel.account($0, $0.id, self.credentialFor($0).restore()) } + [AccountCellModel.new] }
            .map { [AnimatableSection(items: $0)] }
        
        return Observable
            .merge(actions, accounts)
    }
}

final public class AccountCellViewModel: RxViewModel {
    public typealias Result = AccountListViewModel.Action
    public typealias Action = Void
    public enum State {
        case userName(String)
        case screenName(String)
        case profileImage(UIImage?)
        
        public var userName: Observable<String> {
            switch self {
            case .userName(let userName): return .just(userName)
            default: return .empty()
            }
        }

        public var screenName: Observable<String> {
            switch self {
            case .screenName(let screenName): return .just(screenName)
            default: return .empty()
            }
        }
        
        public var profileImage: Observable<UIImage?> {
            switch self {
            case .profileImage(let profileImage): return .just(profileImage)
            default: return .empty()
            }
        }
    }
    
    let account: Account
    let client: TwitterClient
    
    public init(account: Account, client: TwitterClient) {
        self.account = account
        self.client = client
    }
    
    public func state(action: Observable<Void>, result: AnyObserver<AccountListViewModel.Action>) -> Observable<AccountCellViewModel.State> {
        let actions = Observable<State>
            .create { (observer) in
                observer.onCompleted()
                return action
                    .map { Result.delete(self.account) }
                    .bind(to: result)
            }
        
        return Observable<State>
            .merge(
                actions,
                Observable<State>
                    .of(
                        .userName(self.account.userName),
                        .screenName("@" + self.account.screenName)
                ),
                Observable.from(optional: account.profileImageURL)
                    .flatMap { self.client.request(request: GetProfileImageRequest(url: $0, quality: .bigger))  }
                    .map { UIImage?.some($0) }
                    .startWith(nil)
                    .map { State.profileImage($0) }
                    .observeOn(MainScheduler.instance)
        )
    }
}
