//
//  NavigationController.swift
//  mstdn
//
//  Created by tarunon on 2017/04/22.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Base

open class NavigationController<V: UIViewController>: UINavigationController {
    class InteractivePopGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
        weak var parent: UINavigationController?
        init(parent: UINavigationController?) {
            self.parent = parent
        }
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
    
    public private(set) lazy var rootViewController: V = undefined()
    var interactivePopGestureRecognizerDelegate: InteractivePopGestureRecognizerDelegate?
    
    public required init(rootViewController: V) {
        super.init(rootViewController: rootViewController)
        self.rootViewController = rootViewController
        self.setNavigationBarHidden(true, animated: false)
        self.interactivePopGestureRecognizerDelegate = InteractivePopGestureRecognizerDelegate(parent: navigationController)
        self.interactivePopGestureRecognizer?.delegate = self.interactivePopGestureRecognizerDelegate
        self.modalPresentationStyle = rootViewController.modalPresentationStyle
        self.modalTransitionStyle = rootViewController.modalTransitionStyle
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
    }
}
