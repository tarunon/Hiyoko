//
//  ListViewController.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/03.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Instantiate
import InstantiateStandard
import UIKitExtensions
import RxExtensions
import HiyokoKit
import APIClient
import Base
import RealmSwift
import Persistents
import OAuthSwift

final class ListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 64.0
        }
    }
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deselectAll(animated: animated)
    }
    
    func deselectAll(animated: Bool = true) {
        tableView.indexPathsForSelectedRows?
            .forEach { tableView.deselectRow(at: $0, animated: animated) }
    }
}

extension ListViewController: StoryboardInstantiatable {
    struct Dependency {
        let title: String
        let leftButtonConfig: (UIButton) -> ()
        let rightButtonConfig: (UIButton) -> ()
        
        init(title: String, leftButtonConfig: @escaping (UIButton) -> () = { $0.isHidden = true }, rightButtonConfig: @escaping (UIButton) -> () = { $0.isHidden = true }) {
            self.title = title
            self.leftButtonConfig = leftButtonConfig
            self.rightButtonConfig = rightButtonConfig
        }
    }
    
    func inject(_ dependency: Dependency) {
        self.titleLabel.text = dependency.title
        dependency.leftButtonConfig(self.leftButton)
        dependency.rightButtonConfig(self.rightButton)
    }
}

extension ListViewController: Either2View {
    typealias View1 = TimelineView
    typealias View2 = AccountListView
    
    var view1: ListViewController.TimelineView {
        return TimelineView(view: self)
    }
    
    var view2: ListViewController.AccountListView {
        return AccountListView(view: self)
    }
    
    class TimelineReactor<InitialRequest: PaginationRequest>: Either2Reactor where InitialRequest.Base.Response: RangeReplaceableCollection & RandomAccessCollection, InitialRequest.Base.Response.Iterator.Element: Tweet, InitialRequest.Response == PaginatedResponse<InitialRequest.Base.Response, InitialRequest.Base.Error>, InitialRequest.Error == InitialRequest.Base.Error {
        typealias Reactor1 = HiyokoKit.TimelineReactor<InitialRequest>
        typealias Reactor2 = HiyokoKit.AccountListReactor
        
        typealias Result = Reactor1.Result
        
        lazy var reactor1: Reactor1 = undefined()
        lazy var reactor2: Reactor2 = undefined()
        
        init(realm: @escaping () throws -> Realm, client: TwitterClient, initialRequest: InitialRequest) {
            reactor1 = Reactor1(realm: realm, client: client, initialRequest: initialRequest)
        }
    }
    
    class AccountListReactor: Either2Reactor {
        typealias Reactor1 = HiyokoKit.TimelineReactor<SinceMaxPaginationRequest<HomeTimeLineRequest>>
        typealias Reactor2 = HiyokoKit.AccountListReactor
        
        typealias Result = Reactor2.Result
        
        lazy var reactor1: Reactor1 = undefined()
        lazy var reactor2: Reactor2 = undefined()
        
        init(realm: @escaping () throws -> Realm, credentialFor: @escaping (Account) -> PersistentStore<OAuthSwiftCredential>) {
            reactor2 = Reactor2(realm: realm, credentialFor: credentialFor)
        }
    }
}

