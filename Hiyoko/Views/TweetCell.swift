//
//  TweetCell.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/04.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Instantiate
import InstantiateStandard

protocol TweetCellType: class {
    associatedtype ContentView: NibInstantiatableWrapper
    var profileImageButton: UIButton! { get }
    var userNameLabel: UILabel! { get }
    var screenNameLabel: UILabel! { get }
    var dateLabel: UILabel! { get }
    var tweetContentView: ContentView! { get }
}

final class TweetCell: UITableViewCell {
    @IBOutlet weak var profileImageButton: UIButton! {
        didSet {
            profileImageButton.layer.cornerRadius = 5.0
            profileImageButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tweetContentView: IBTweetContentView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension TweetCell: NibInstantiatable {
    
}

extension TweetCell: Reusable {
    
}

extension TweetCell: TweetCellType {
    typealias ContentView = IBTweetContentView
}

final class TweetImageCell: UITableViewCell {
    @IBOutlet weak var profileImageButton: UIButton! {
        didSet {
            profileImageButton.layer.cornerRadius = 5.0
            profileImageButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tweetContentView: IBTweetContentImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension TweetImageCell: NibInstantiatable {
    
}

extension TweetImageCell: Reusable {
    
}

extension TweetImageCell: TweetCellType {
    typealias ContentView = IBTweetContentImageView
}

final class TweetQuotedCell: UITableViewCell {
    @IBOutlet weak var profileImageButton: UIButton! {
        didSet {
            profileImageButton.layer.cornerRadius = 5.0
            profileImageButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tweetContentView: IBTweetContentQuotedView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension TweetQuotedCell: NibInstantiatable {
    
}

extension TweetQuotedCell: Reusable {
    
}

extension TweetQuotedCell: TweetCellType {
    typealias ContentView = IBTweetContentQuotedView
}
