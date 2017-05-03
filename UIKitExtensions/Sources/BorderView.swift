//
//  BorderView.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/03.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation

@IBDesignable public class BorderView: UIView {
    @IBInspectable public var top: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var left: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var bottom: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var right: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var borderColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var linePixelWidth: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.setLineWidth(linePixelWidth / UIScreen.main.scale)
        if top {
            context.move(to: CGPoint(x: rect.minX, y: rect.minY))
            context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        }
        if left {
            context.move(to: CGPoint(x: rect.minX, y: rect.minY))
            context.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
        if bottom {
            context.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
            context.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
        if right {
            context.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
            context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        }
        context.strokePath()
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setNeedsDisplay()
    }
}
