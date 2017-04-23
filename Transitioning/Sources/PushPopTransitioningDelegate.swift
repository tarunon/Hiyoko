//
//  PushPopTransitioningDelegate.swift
//  mstdn
//
//  Created by tarunon on 2017/04/22.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation

class PushPopTransitioningDelegate<From: UIViewController, To: UIViewController>: NSObject, UINavigationControllerDelegate {
    let push: AnimatingTransitioning<From, To>?
    let pop: AnimatingTransitioning<To, From>?
    
    init(push: AnimatingTransitioning<From, To>?, pop: AnimatingTransitioning<To, From>?) {
        self.push = push
        self.pop = pop
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch (operation, fromVC, toVC) {
        case (.push, _ as From, _ as To):
            return push
        case (.pop, _ as To, _ as From):
            return pop
        default:
            return nil
        }
    }
}

class NavigationControllerDelegateForwarder: NSObject, UINavigationControllerDelegate {
    weak var forwardDelegate: UINavigationControllerDelegate?
    
    static func from(forwardDelegate: UINavigationControllerDelegate?) -> NavigationControllerDelegateForwarder {
        if let forwarder = forwardDelegate as? NavigationControllerDelegateForwarder {
            return forwarder
        } else {
            return NavigationControllerDelegateForwarder(forwardDelegate: forwardDelegate)
        }
    }
    
    init(forwardDelegate: UINavigationControllerDelegate?) {
        self.forwardDelegate = forwardDelegate
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        return super.responds(to: aSelector) || (forwardDelegate?.responds(to: aSelector) ?? false)
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return super.forwardingTarget(for: aSelector) ?? forwardDelegate
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return toVC._transitioningDelegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
        case .pop:
            return fromVC._transitioningDelegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
        default:
            return nil
        }
    }
}

private var transitioningDelegateKey: Void?

public extension NSObjectProtocol where Self: UIViewController {
    fileprivate var _transitioningDelegate: UINavigationControllerDelegate? {
        get {
            return objc_getAssociatedObject(self, &transitioningDelegateKey) as? UINavigationControllerDelegate
        }
        set {
            objc_setAssociatedObject(self, &transitioningDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.navigationController?.delegate = NavigationControllerDelegateForwarder(forwardDelegate: self.navigationController?.delegate)
        }
    }
    
    func push<V: UIViewController>(_ viewController: V, pushAnimation: AnimatingTransitioning<Self, V>? = nil, popAnimation: AnimatingTransitioning<V, Self>? = nil) {
        viewController._transitioningDelegate = PushPopTransitioningDelegate(push: pushAnimation, pop: popAnimation)
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func replace<V: UIViewController>(_ viewController: V, pushAnimation: AnimatingTransitioning<Self, V>? = nil) {
        viewController._transitioningDelegate = PushPopTransitioningDelegate(push: pushAnimation, pop: nil)
        self.navigationController!.setViewControllers(self.navigationController!.viewControllers.map { $0 === self ? viewController : $0  }, animated: true)
    }
}
