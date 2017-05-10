//
//  UITextField+Rx.swift
//  mstdn
//
//  Created by tarunon on 2017/04/23.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RxTextFieldDelegateProxy: DelegateProxy, DelegateProxyType, UITextFieldDelegate {
    let textField: UITextField
    required init(parentObject: AnyObject) {
        self.textField = parentObject as! UITextField
        super.init(parentObject: parentObject)
    }
    
    class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let textField: UITextField = object as! UITextField
        return textField.delegate
    }
    
    class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let textField: UITextField = object as! UITextField
        textField.delegate = delegate.map { $0 as! UITextFieldDelegate }
    }
}

public extension Reactive where Base: UITextField {
    public var delegate: DelegateProxy {
        return RxTextFieldDelegateProxy.proxyForObject(base)
    }
    
    public func setDelegate(delegate: UITextFieldDelegate) -> Disposable {
        return RxTextFieldDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: base)
    }
    
    public var didBeginEditing: ControlEvent<Void> {
        let source = base.rx.delegate
            .methodInvoked(#selector(UITextFieldDelegate.textFieldDidBeginEditing(_:)))
            .map { _ in }
        return ControlEvent(events: source)
    }
    
    public var didEndEditing: ControlEvent<Void> {
        let source = base.rx.delegate
            .methodInvoked(#selector(UITextFieldDelegate.textFieldDidEndEditing(_:)))
            .map { _ in }
        return ControlEvent(events: source)
    }
}
