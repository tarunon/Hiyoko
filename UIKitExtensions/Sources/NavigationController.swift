//
//  NavigationController.swift
//  mstdn
//
//  Created by tarunon on 2017/04/22.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation

final public class NavigationController<V: UIViewController>: UINavigationController {
    class InteractivePopGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
        weak var parent: UINavigationController?
        init(parent: UINavigationController?) {
            self.parent = parent
        }
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
    
    public private(set) var rootViewController: V!
    var interactivePopGestureRecognizerDelegate: InteractivePopGestureRecognizerDelegate?
    
    public static func instantiate(rootViewController: V) -> NavigationController {
        let navigationController = NavigationController(rootViewController: rootViewController)
        navigationController.rootViewController = rootViewController
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.interactivePopGestureRecognizerDelegate = InteractivePopGestureRecognizerDelegate(parent: navigationController)
        navigationController.interactivePopGestureRecognizer?.delegate = navigationController.interactivePopGestureRecognizerDelegate
        navigationController.modalPresentationStyle = rootViewController.modalPresentationStyle
        navigationController.modalTransitionStyle = rootViewController.modalTransitionStyle
        return navigationController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
    }
}
