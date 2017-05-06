//
//  TweetContentView.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/04.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Instantiate
import InstantiateStandard
import UIKitExtensions

class TweetContentViewBase: UIView {
    @IBOutlet weak var textView: LinkActionTextView! {
        didSet {
            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0.0
        }
    }
}

final class TweetContentView: TweetContentViewBase {
    
}

extension TweetContentView: NibInstantiatable {
    
}

protocol TweetContentImageViewType: class {
    var imageCollectionView: UICollectionView! { get }
}

final class TweetContentImageView: TweetContentViewBase {
    @IBOutlet weak var imageCollectionView: UICollectionView! {
        didSet {
            imageCollectionView.registerNib(type: TweetContentImageCell.self)
            imageCollectionView.layer.cornerRadius = 5.0
            imageCollectionView.layer.masksToBounds = true
        }
    }
}

extension TweetContentImageView: NibInstantiatable {
    class var nib: UINib { return TweetContentView.nib }
    class var instantiateIndex: Int { return 1 }
}

extension TweetContentImageView: Reusable {
    
}

extension TweetContentImageView: TweetContentImageViewType {
    
}

@IBDesignable final class IBTweetContentView: UIView, NibInstantiatableWrapper {
    typealias Wrapped = TweetContentView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        loadView()
    }
}

@IBDesignable final class IBTweetContentImageView: UIView, NibInstantiatableWrapper {
    typealias Wrapped = TweetContentImageView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        loadView()
    }
}

class TweetContentImageFlowLayout: NSObject, UICollectionViewDelegateFlowLayout {
    var numberOfItems: Int
    var collectionViewSize: CGSize
    init(numberOfItems: Int, collectionViewSize: CGSize) {
        self.numberOfItems = numberOfItems
        self.collectionViewSize = collectionViewSize
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
        switch (numberOfItems, indexPath.item) {
        case (1, _):
            return collectionViewSize
        case (2, _):
            return CGSize(width: (collectionViewSize.width - 1.0) / 2.0, height: collectionViewSize.height)
        case (let x, let y) where ((x % 2) == 1 && (x - 1) == y):
            return CGSize(width: (collectionViewSize.width - 1.0) / 2.0, height: collectionViewSize.height)
        default:
            return CGSize(width: (collectionViewSize.width - 1.0) / 2.0, height: (collectionViewSize.height - 1.0) / 2.0)
        }
    }
}
