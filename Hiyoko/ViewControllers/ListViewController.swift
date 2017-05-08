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
