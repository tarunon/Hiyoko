//
//  TweetCellInteractiveView.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/07.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Instantiate
import InstantiateStandard

protocol TweetCellInteractiveViewType: class {
    var tweetCellContainerView: UIView! { get }
    var tweetActionView: IBTweetActionView! { get }
    var interactiveScrollView: UIScrollView! { get }
    var tweetActionCenter: NSLayoutConstraint! { get }
}

protocol HasTweetCellInteractiveViewType: TweetCellInteractiveViewType {
    associatedtype TweetCellInteractiveView: TweetCellInteractiveViewType
    var interactiveView: TweetCellInteractiveView! { get }
}

extension HasTweetCellInteractiveViewType {
    var tweetCellContainerView: UIView! {
        return interactiveView.tweetCellContainerView
    }
    
    var tweetActionView: IBTweetActionView! {
        return interactiveView.tweetActionView
    }
    
    var interactiveScrollView: UIScrollView! {
        return interactiveView.interactiveScrollView
    }
    
    var tweetActionCenter: NSLayoutConstraint! {
        return interactiveView.tweetActionCenter
    }
}

final class TweetCellInteractiveView: UIView {
    @IBOutlet weak var tweetCellContainerView: UIView!
    @IBOutlet weak var tweetActionView: IBTweetActionView!
    @IBOutlet weak var interactiveScrollView: UIScrollView! {
        didSet {
            self.addGestureRecognizer(interactiveScrollView.panGestureRecognizer)
        }
    }
    @IBOutlet var tweetActionCenter: NSLayoutConstraint!
}

extension TweetCellInteractiveView: NibInstantiatable {
    
}

extension TweetCellInteractiveView: TweetCellInteractiveViewType {
    
}

final class IBTweetCellInteractiveView: UIView, NibInstantiatableWrapper {
    typealias Wrapped = TweetCellInteractiveView
    
    #if TARGET_INTERFACE_BUILDER
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        loadView()
    }
    #else
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadView()
    }
    #endif
}

extension  IBTweetCellInteractiveView: HasTweetCellInteractiveViewType {
    var interactiveView: TweetCellInteractiveView! {
        return view
    }
}

/// Workaround for disabling cell tap events when add scrollView
/// Allow tap event if it has gestureRecognizer
class InteractiveScrollView: UIScrollView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return (view?.gestureRecognizers?.isEmpty == false || view is UIControl) ? view : nil
    }
}
