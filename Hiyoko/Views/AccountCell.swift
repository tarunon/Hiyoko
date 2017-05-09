//
//  AccountCell.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/01.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import HiyokoKit
import Instantiate
import InstantiateStandard
import RxSwift
import RxCocoa
import RxDataSources
import RxExtensions
import SafariServices
import Base

final class AccountCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = 5.0
            profileImageView.layer.masksToBounds = true
            profileImageView.layer.shouldRasterize = true
            profileImageView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
}

extension AccountCell: NibInstantiatable {

}

extension AccountCell: Reusable {
    
}

extension AccountCell: View {
    typealias State = AccountCellReactor.State
    typealias Action = AccountCellReactor.Action

    func present(state: Observable<State>) -> Present<Action> {
        let d1 = state
            .flatMapFirst { $0.userName }
            .bind(to: self.nameLabel.rx.text)
        let d2 = state
            .flatMapFirst { $0.screenName }
            .bind(to: self.screenNameLabel.rx.text)
        let d3 = state
            .flatMapFirst { $0.profileImage }
            .bind(to: self.profileImageView.rx.image)
        return .init(
            action: self.deleteButton.rx.tap,
            bind: Disposables.create(d1, d2, d3)
        )
    }
}
