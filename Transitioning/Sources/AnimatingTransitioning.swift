//
//  AnimatingTransitioning.swift
//  mstdn
//
//  Created by tarunon on 2017/04/22.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation

public class AnimatingContext<From: UIViewController, To: UIViewController> {
    let native: UIViewControllerContextTransitioning
    
    init(native: UIViewControllerContextTransitioning) {
        self.native = native
    }
    
    public var containerView: UIView {
        return native.containerView
    }
    
    public func completeTransition() {
        native.completeTransition(true)
    }
    
    public var fromViewController: From {
        return native.viewController(forKey: .from) as! From
    }
    
    public var toViewController: To {
        return native.viewController(forKey: .to) as! To
    }
}

public class AnimatingTransitioning<From: UIViewController, To: UIViewController>: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval
    let animation: (AnimatingContext<From, To>) -> ()
    
    init(duration: TimeInterval, animation: @escaping (AnimatingContext<From, To>) -> ()) {
        self.duration = duration
        self.animation = animation
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.animation(AnimatingContext(native: transitionContext))
    }
}
