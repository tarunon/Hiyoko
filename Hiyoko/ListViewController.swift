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

final class ListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func deselectAll(animated: Bool = true) {
        tableView.indexPathsForSelectedRows?
            .forEach { tableView.deselectRow(at: $0, animated: animated) }
    }
}

extension ListViewController: StoryboardInstantiatable {
    
}
