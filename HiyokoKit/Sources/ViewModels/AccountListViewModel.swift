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

public class AccountListReactor: Reactor {
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
    
    public func process(action: Observable<Action>) throws -> Process<State, Result> {
        let realm = try self.realm()
        
        let result = action
            .flatMap { (action) -> Observable<Result> in
                switch action {
                case .select(let account):
                    return .just((account, try self.credentialFor(account).restore()))
                case .delete(let account):
                    try realm.write {
                        realm.delete(account)
                    }
                    return .empty()
                case .new(let account, let credential):
                    try self.credentialFor(account).store(credential)
                    try realm.write {
                        realm.add(account, update: true)
                    }
                    return .just((account, credential))
                }
            }
        
        let accounts = Observable
            .array(
                from: Account.objects(realm).brl
                    .sorted { $0.createdAt < $1.createdAt }
                    .confirm()
            )
            .map { try $0.map { try AccountCellModel.account($0, $0.id, self.credentialFor($0).restore()) } + [AccountCellModel.new] }
            .map { [AnimatableSection(items: $0)] }
        
        return .init(state: accounts, result: result)
    }
}

final public class AccountCellReactor: Reactor {
    public typealias Result = AccountListReactor.Action
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
    
    public func process(action: Observable<Void>) throws -> Process<State, Result> {
        return .init(
            state: Observable<State>
                .merge(
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
                ),
            result: action
                .map { Result.delete(self.account) }
        )
    }
}
