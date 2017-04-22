//
//  NavigationController.swift
//  mstdn
//
//  Created by tarunon on 2017/04/22.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation

public class NavigationController<V: UIViewController>: UINavigationController {
    class InteractivePopGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
        weak var parent: UINavigationController?
        init(parent: UINavigationController?) {
            self.parent = parent
        }
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
    
    public let rootViewController: V
    var interactivePopGestureRecognizerDelegate: InteractivePopGestureRecognizerDelegate?
    
    public init(rootViewController: V) {
        self.rootViewController = rootViewController
        super.init(rootViewController: rootViewController)
        self.setNavigationBarHidden(true, animated: false)
        interactivePopGestureRecognizerDelegate = InteractivePopGestureRecognizerDelegate(parent: self)
        self.interactivePopGestureRecognizer?.delegate = interactivePopGestureRecognizerDelegate
        self.modalPresentationStyle = rootViewController.modalPresentationStyle
        self.modalTransitionStyle = rootViewController.modalTransitionStyle
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
    }
}
