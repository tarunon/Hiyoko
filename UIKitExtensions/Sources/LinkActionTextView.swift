//
//  LinkActionTextView.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/05.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class LinkActionTextView: UITextView {
    fileprivate var delegateProxy = LinkActionTextViewDelegateProxy()
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event), bounds.contains(point) else {
            return nil
        }
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        guard attributedText.attributes(at: index, longestEffectiveRange: nil, in: NSRange(location: index, length: 0))[NSLinkAttributeName] != nil else {
            return nil
        }
        return view
    }
}

public class LinkActionTextViewDelegateProxy: NSObject, UITextViewDelegate {
    let linkTapSubject = PublishSubject<URL>()
    let linkLongPressSubject = PublishSubject<URL>()
    let linkPreviewSubject = PublishSubject<URL>()
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        switch interaction {
        case .invokeDefaultAction:
            linkTapSubject.onNext(URL)
        case .presentActions:
            linkLongPressSubject.onNext(URL)
        case .preview:
            linkPreviewSubject.onNext(URL)
        }
        return false
    }
}

extension Reactive where Base: LinkActionTextView {
    public var linkTap: ControlEvent<URL> {
        let source = Observable<URL>
            .create { [unowned base=self.base] (observer) in
                let d1 = base.rx.setDelegate(base.delegateProxy)
                let d2 = base.delegateProxy.linkTapSubject.bind(to: observer)
                return Disposables.create(d1, d2)
            }
        return ControlEvent(events: source)
    }
    
    public var linkLongPress: ControlEvent<URL> {
        let source = Observable<URL>
            .create { [unowned base=self.base] (observer) in
                let d1 = base.rx.setDelegate(base.delegateProxy)
                let d2 = base.delegateProxy.linkLongPressSubject.bind(to: observer)
                return Disposables.create(d1, d2)
        }
        return ControlEvent(events: source)
    }
    
    public var linkPreview: ControlEvent<URL> {
        let source = Observable<URL>
            .create { [unowned base=self.base] (observer) in
                let d1 = base.rx.setDelegate(base.delegateProxy)
                let d2 = base.delegateProxy.linkPreviewSubject.bind(to: observer)
                return Disposables.create(d1, d2)
        }
        return ControlEvent(events: source)
    }
}
