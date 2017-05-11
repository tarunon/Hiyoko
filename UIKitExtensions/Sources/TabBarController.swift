//
//  TabBarController.swift
//  Hiyoko
//
//  Created by ST90872 on 2017/05/11.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import Base

open class TabBarController2<V1: UIViewController, V2: UIViewController>: UITabBarController {
    public private(set) lazy var childViewController1: V1 = undefined()
    public private(set) lazy var childViewController2: V2 = undefined()

    internal var _viewControllers: [UIViewController] {
        return [childViewController1, childViewController2]
    }

    public required init(childViewControllers: (V1, V2)) {
        super.init(nibName: nil, bundle: nil)
        (childViewController1, childViewController2) = childViewControllers
        self.setViewControllers(_viewControllers, animated: false)
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

open class TabBarController3<V1: UIViewController, V2: UIViewController, V3: UIViewController>: UITabBarController {
    public private(set) lazy var childViewController1: V1 = undefined()
    public private(set) lazy var childViewController2: V2 = undefined()
    public private(set) lazy var childViewController3: V3 = undefined()

    internal var _viewControllers: [UIViewController] {
        return [childViewController1, childViewController2, childViewController3]
    }

    public required init(childViewControllers: (V1, V2, V3)) {
        super.init(nibName: nil, bundle: nil)
        (childViewController1, childViewController2, childViewController3) = childViewControllers
        self.setViewControllers(_viewControllers, animated: false)
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

open class TabBarController4<V1: UIViewController, V2: UIViewController, V3: UIViewController, V4: UIViewController>: UITabBarController {
    public private(set) lazy var childViewController1: V1 = undefined()
    public private(set) lazy var childViewController2: V2 = undefined()
    public private(set) lazy var childViewController3: V3 = undefined()
    public private(set) lazy var childViewController4: V4 = undefined()

    internal var _viewControllers: [UIViewController] {
        return [childViewController1, childViewController2, childViewController3, childViewController4]
    }

    public required init(childViewControllers: (V1, V2, V3, V4)) {
        super.init(nibName: nil, bundle: nil)
        (childViewController1, childViewController2, childViewController3, childViewController4) = childViewControllers
        self.setViewControllers(_viewControllers, animated: false)
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

open class TabBarController5<V1: UIViewController, V2: UIViewController, V3: UIViewController, V4: UIViewController, V5: UIViewController>: UITabBarController {
    public private(set) lazy var childViewController1: V1 = undefined()
    public private(set) lazy var childViewController2: V2 = undefined()
    public private(set) lazy var childViewController3: V3 = undefined()
    public private(set) lazy var childViewController4: V4 = undefined()
    public private(set) lazy var childViewController5: V5 = undefined()

    internal var _viewControllers: [UIViewController] {
        return [childViewController1, childViewController2, childViewController3, childViewController4, childViewController5]
    }

    public required init(childViewControllers: (V1, V2, V3, V4, V5)) {
        super.init(nibName: nil, bundle: nil)
        (childViewController1, childViewController2, childViewController3, childViewController4, childViewController5) = childViewControllers
        self.setViewControllers(_viewControllers, animated: false)
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
