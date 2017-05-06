
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
    let tapGestureRecognizer = UITapGestureRecognizer()
    let longPressGestureRecognizer = UILongPressGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addGestureRecognizer(longPressGestureRecognizer)
        self.addGestureRecognizer(tapGestureRecognizer)
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

class TweetContentImageFlowLayout: NSObject, UICollectionViewDelegateFlowLayout {
    var numberOfItems: Int
    init(numberOfItems: Int) {
        self.numberOfItems = numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewSize = CGSize(width: collectionView.frame.width - 2.0, height: collectionView.frame.height - 2.0)
        switch (numberOfItems, indexPath.item) {
        case (1, _):
            return collectionViewSize
        case (2, _):
            return CGSize(width: collectionViewSize.width / 2.0, height: collectionViewSize.height)
        case (let x, let y) where ((x % 2) == 1 && (x - 1) == y):
            return CGSize(width: collectionViewSize.width / 2.0, height: collectionViewSize.height)
        default:
            return CGSize(width: collectionViewSize.width / 2.0, height: collectionViewSize.height / 2.0)
        }
    }
}
