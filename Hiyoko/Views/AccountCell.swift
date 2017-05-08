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

extension AccountCell {
    func bind(viewModel: AccountCellViewModel.Emitter) -> Disposable {
        let uiBinding = viewModel.state
            .bind { (output) -> Disposable in
                let d1 = output
                    .flatMapFirst { $0.userName }
                    .bind(to: nameLabel.rx.text)
                let d2 = output
                    .flatMapFirst { $0.screenName }
                    .bind(to: screenNameLabel.rx.text)
                let d3 = output
                    .flatMapFirst { $0.profileImage }
                    .bind(to: profileImageView.rx.image)
                return Disposables.create(d1, d2, d3)
            }
        let delete = deleteButton.rx.tap
            .bind(to: viewModel.action)
        return Disposables.create(uiBinding, delete)
    }
}
