
//
//  TweetContentImageCell.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/05.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Instantiate
import InstantiateStandard

final class TweetContentImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var hilightView: UIView!
    let longPressGestureRecognizer = UILongPressGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    override var isHighlighted: Bool {
        didSet {
            hilightView.isHidden = !isHighlighted
        }
    }
}

extension TweetContentImageCell: NibInstantiatable {
    
}

extension TweetContentImageCell: Reusable {
    
}

