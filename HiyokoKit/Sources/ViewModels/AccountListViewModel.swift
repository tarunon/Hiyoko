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
        
        var select: Account? {
            switch self {
            case .select(let account): return account
            default: return nil
            }
        }
        
        var delete: Account? {
            switch self {
            case .delete(let account): return account
            default: return nil
            }
        }
        
        var new: (Account, OAuthSwiftCredential)? {
            switch self {
            case .new(let account, let credential): return (account, credential)
            default: return nil
            }
        }
    }
    
    public typealias Result = (Account, OAuthSwiftCredential)
    public typealias Input = Action
    public typealias Output = [AnimatableSection<AccountCellModel>]
    
    public let result: Observable<(Account, OAuthSwiftCredential)>
    public let emitter: RxIOEmitter<AccountListViewModel.Action, [AnimatableSection<AccountCellModel>]> = RxIOEmitter()
    
    public init(realm: @escaping () throws -> Realm, credentialFor: @escaping (Account) -> PersistentStore<OAuthSwiftCredential>) {
        result = Observable
            .create { [emitter = self.emitter] (observer: AnyObserver<Result>) in
                let _realm: Realm
                do {
                    _realm = try realm()
                } catch {
                    observer.onError(error)
                    return Disposables.create()
                }
                let models = Observable
                    .array(
                        from: Account.objects(_realm).brl
                            .sorted { $0.createdAt < $1.createdAt }
                            .confirm()
                    )
                    .map { try $0.map { try AccountCellModel.account($0, $0.id, credentialFor($0).restore()) } + [AccountCellModel.new] }
                    .map { [AnimatableSection(items: $0)] }
                    .bind(to: emitter.output)
                
                let action = emitter.input
                    .shareReplay(1)
                    .bind  { (action) -> Disposable in
                        let select = action
                            .flatMapFirst { Observable.from(optional: $0.select) }
                            .map { ($0, try credentialFor($0).restore()) }
                            .bind(to: observer)
                        let delete = action
                            .flatMapFirst { Observable.from(optional: $0.delete) }
                            .do(
                                onNext: { (account) in
                                    try _realm.write {
                                        _realm.delete(account)
                                    }
                                }
                            )
                            .subscribe()
                        let new = action
                            .flatMapFirst { Observable.from(optional: $0.new) }
                            .shareReplay(1)
                            .bind { (newAccount) -> Disposable in
                                let store = newAccount
                                    .do(
                                        onNext: { (account, credential) in
                                            try credentialFor(account).store(credential)
                                            let _realm = try realm()
                                            try _realm.write {
                                                _realm.add(account, update: true)
                                            }
                                        }
                                    )
                                    .subscribe()
                                let select = newAccount
                                    .bind(to: observer)
                                return Disposables.create([store, select])
                            }
                        return Disposables.create([select, delete, new])
                    }
                return Disposables.create([models, action])
            }
    }
}

final public class AccountCellViewModel: RxViewModel {
    public typealias Result = AccountListViewModel.Action
    public typealias Input = Void
    public enum Output {
        case userName(String)
        case screenName(String)
        case profileImage(UIImage?)
        
        public var userName: String? {
            switch self {
            case .userName(let userName): return userName
            default: return nil
            }
        }

        public var screenName: String? {
            switch self {
            case .screenName(let screenName): return screenName
            default: return nil
            }
        }
        
        public var profileImage: UIImage?? {
            switch self {
            case .profileImage(let profileImage): return profileImage
            default: return nil
            }
        }
    }
    
    public let result: Observable<AccountListViewModel.Action>
    public var emitter: RxIOEmitter<Void, AccountCellViewModel.Output> = RxIOEmitter()
    
    public init(account: Account, apiClient: TwitterClient) {
        result = Observable
            .create { [emitter = self.emitter] (observer: AnyObserver<Result>) in
                let uiBinding = Observable.from(object: account)
                    .catchError { _ in Observable.empty() }
                    .shareReplay(1)
                    .bind { (account) -> Disposable in
                        let profileImage = account
                            .flatMap { Observable.from(optional: $0.profileImageURL) }
                            .flatMap { apiClient.request(request: GetProfileImageRequest(url: $0, quality: .bigger))  }
                            .map { Output.profileImage($0) }
                            .observeOn(MainScheduler.instance)
                            .startWith(Output.profileImage(nil))
                            .bind(to: emitter.output)
                        let userName = account
                            .map { Output.userName($0.userName) }
                            .bind(to: emitter.output)
                        let screenName = account
                            .map { Output.screenName("@" + $0.screenName) }
                            .bind(to: emitter.output)
                        return Disposables.create([profileImage, userName, screenName])
                    }
                let deleted = emitter.input
                    .map { Result.delete(account) }
                    .bind(to: observer)
                return Disposables.create([uiBinding, deleted])
            }
    }
}
