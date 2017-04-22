//
//  PresentDismissTransitioningDelegate.swift
//  mstdn
//
//  Created by tarunon on 2017/04/22.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation

class PresentDismissTransitioningDelegate<Presenting: UIViewController, Presented: UIViewController>: NSObject, UIViewControllerTransitioningDelegate {
    let present: AnimatingTransitioning<Presenting, Presented>?
    let dismiss: AnimatingTransitioning<Presented, Presenting>?
    
    init(present: AnimatingTransitioning<Presenting, Presented>?, dismiss: AnimatingTransitioning<Presented, Presenting>?) {
        self.present = present
        self.dismiss = dismiss
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard presenting is Presenting && presented is Presented else {
            return nil
        }
        return present
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard dismissed is Presented && dismissed.presentingViewController is Presenting else {
            return nil
        }
        return dismiss
    }
}

private var transitioningDelegateKey: Void?

public extension NSObjectProtocol where Self: UIViewController {
    private var _transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get {
            return objc_getAssociatedObject(self, &transitioningDelegateKey) as? UIViewControllerTransitioningDelegate
        }
        set {
            objc_setAssociatedObject(self, &transitioningDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.transitioningDelegate = newValue
        }
    }
    
    public func present<V: UIViewController>(_ viewController: V, presentAnimation: AnimatingTransitioning<Self, V>? = nil, dismissAnimation: AnimatingTransitioning<V, Self>? = nil) {
        viewController._transitioningDelegate = PresentDismissTransitioningDelegate(present: presentAnimation, dismiss: dismissAnimation)
        self.present(viewController, animated: true)
    }
}
