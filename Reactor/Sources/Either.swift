//
//  Zip.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/09.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation
import RxSwift

public enum Either2<A, B> {
    case a(A)
    case b(B)
    
    public var a: Observable<A> {
        switch self {
        case .a(let a): return .just(a)
        default: return .empty()
        }
    }
    
    public var b: Observable<B> {
        switch self {
        case .b(let b): return .just(b)
        default: return .empty()
        }
    }
}

public enum Either3<A, B, C> {
    case a(A)
    case b(B)
    case c(C)
    
    public var a: Observable<A> {
        switch self {
        case .a(let a): return .just(a)
        default: return .empty()
        }
    }
    
    public var b: Observable<B> {
        switch self {
        case .b(let b): return .just(b)
        default: return .empty()
        }
    }
    
    public var c: Observable<C> {
        switch self {
        case .c(let c): return .just(c)
        default: return .empty()
        }
    }
}

public enum Either4<A, B, C, D> {
    case a(A)
    case b(B)
    case c(C)
    case d(D)
    
    public var a: Observable<A> {
        switch self {
        case .a(let a): return .just(a)
        default: return .empty()
        }
    }
    
    public var b: Observable<B> {
        switch self {
        case .b(let b): return .just(b)
        default: return .empty()
        }
    }
    
    public var c: Observable<C> {
        switch self {
        case .c(let c): return .just(c)
        default: return .empty()
        }
    }
    
    public var d: Observable<D> {
        switch self {
        case .d(let d): return .just(d)
        default: return .empty()
        }
    }
}

public enum Either5<A, B, C, D, E> {
    case a(A)
    case b(B)
    case c(C)
    case d(D)
    case e(E)
    
    public var a: Observable<A> {
        switch self {
        case .a(let a): return .just(a)
        default: return .empty()
        }
    }
    
    public var b: Observable<B> {
        switch self {
        case .b(let b): return .just(b)
        default: return .empty()
        }
    }
    
    public var c: Observable<C> {
        switch self {
        case .c(let c): return .just(c)
        default: return .empty()
        }
    }
    
    public var d: Observable<D> {
        switch self {
        case .d(let d): return .just(d)
        default: return .empty()
        }
    }
    
    public var e: Observable<E> {
        switch self {
        case .e(let e): return .just(e)
        default: return .empty()
        }
    }
}
