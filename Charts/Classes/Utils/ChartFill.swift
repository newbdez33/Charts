//
//  ChartFill.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 27/01/2016.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

public class ChartFill: NSObject
{
    @objc(ChartFillType)
    public enum `Type`: Int
    {
        case Empty
        case Color
        case LinearGradient
        case RadialGradient
        case Image
        case TiledImage
        case Layer
    }
    
    private var _type: Type = Type.Empty
    private var _color: CGColor?
    private var _gradient: CGGradient?
    private var _gradientAngle: CGFloat = 0.0
    private var _gradientStartOffsetPercent: CGPoint = CGPoint()
    private var _gradientStartRadiusPercent: CGFloat = 0.0
    private var _gradientEndOffsetPercent: CGPoint = CGPoint()
    private var _gradientEndRadiusPercent: CGFloat = 0.0
    private var _image: CGImage?
    private var _layer: CGLayer?
    
    // MARK: Properties
    
    public var type: Type
    {
        return _type
    }
    
    public var color: CGColor?
    {
        return _color
    }
    
    public var gradient: CGGradient?
    {
        return _gradient
    }
    
    public var gradientAngle: CGFloat
    {
        return _gradientAngle
    }
    
    public var gradientStartOffsetPercent: CGPoint
    {
        return _gradientStartOffsetPercent
    }
    
    public var gradientStartRadiusPercent: CGFloat
    {
        return _gradientStartRadiusPercent
    }
    
    public var gradientEndOffsetPercent: CGPoint
    {
        return _gradientEndOffsetPercent
    }
    
    public var gradientEndRadiusPercent: CGFloat
    {
        return _gradientEndRadiusPercent
    }
    
    public var image: CGImage?
    {
        return _image
    }
    
    public var layer: CGLayer?
    {
        return _layer
    }
    
    // MARK: Constructors
    
    public override init()
    {
    }
    
    public init(CGColor: CGColor)
    {
        _type = .Color
        _color = CGColor
    }
    
    public convenience init(color: NSUIColor)
    {
        self.init(CGColor: color.cgColor)
    }
    
    public init(linearGradient: CGGradient, angle: CGFloat)
    {
        _type = .LinearGradient
        _gradient = linearGradient
        _gradientAngle = angle
    }
    
    public init(
        radialGradient: CGGradient,
        startOffsetPercent: CGPoint,
        startRadiusPercent: CGFloat,
        endOffsetPercent: CGPoint,
        endRadiusPercent: CGFloat
        )
    {
        _type = .RadialGradient
        _gradient = radialGradient
        _gradientStartOffsetPercent = startOffsetPercent
        _gradientStartRadiusPercent = startRadiusPercent
        _gradientEndOffsetPercent = endOffsetPercent
        _gradientEndRadiusPercent = endRadiusPercent
    }
    
    public convenience init(radialGradient: CGGradient)
    {
        self.init(
            radialGradient: radialGradient,
            startOffsetPercent: CGPoint(x:0.0, y:0.0),
            startRadiusPercent: 0.0,
            endOffsetPercent: CGPoint(x:0.0, y:0.0),
            endRadiusPercent: 1.0
        )
    }
    
    public init(CGImage: CGImage, tiled: Bool)
    {
        _type = tiled ? .TiledImage : .Image
        _image = CGImage
    }
    
    public convenience init(image: NSUIImage, tiled: Bool)
    {
        if image.cgImage == nil
        {
            self.init()
        }
        else
        {
            self.init(CGImage: image.cgImage!, tiled: tiled)
        }
    }
    
    public convenience init(CGImage: CGImage)
    {
        self.init(CGImage: CGImage, tiled: false)
    }
    
    public convenience init(image: NSUIImage)
    {
        self.init(image: image, tiled: false)
    }
    
    public init(CGLayer: CGLayer)
    {
        _type = .Layer
        _layer = CGLayer
    }
    
    // MARK: Constructors
    
    public class func fillWithCGColor(CGColor: CGColor) -> ChartFill
    {
        return ChartFill(CGColor: CGColor)
    }
    
    public class func fillWithColor(color: NSUIColor) -> ChartFill
    {
        return ChartFill(color: color)
    }
    
    public class func fillWithLinearGradient(linearGradient: CGGradient, angle: CGFloat) -> ChartFill
    {
        return ChartFill(linearGradient: linearGradient, angle: angle)
    }
    
    public class func fillWithRadialGradient(
        radialGradient: CGGradient,
        startOffsetPercent: CGPoint,
        startRadiusPercent: CGFloat,
        endOffsetPercent: CGPoint,
        endRadiusPercent: CGFloat
        ) -> ChartFill
    {
        return ChartFill(
            radialGradient: radialGradient,
            startOffsetPercent: startOffsetPercent,
            startRadiusPercent: startRadiusPercent,
            endOffsetPercent: endOffsetPercent,
            endRadiusPercent: endRadiusPercent
        )
    }
    
    public class func fillWithRadialGradient(radialGradient: CGGradient) -> ChartFill
    {
        return ChartFill(radialGradient: radialGradient)
    }
    
    public class func fillWithCGImage(CGImage: CGImage, tiled: Bool) -> ChartFill
    {
        return ChartFill(CGImage: CGImage, tiled: tiled)
    }
    
    public class func fillWithImage(image: NSUIImage, tiled: Bool) -> ChartFill
    {
        return ChartFill(image: image, tiled: tiled)
    }
    
    public class func fillWithCGImage(CGImage: CGImage) -> ChartFill
    {
        return ChartFill(CGImage: CGImage)
    }
    
    public class func fillWithImage(image: NSUIImage) -> ChartFill
    {
        return ChartFill(image: image)
    }
    
    public class func fillWithCGLayer(CGLayer: CGLayer) -> ChartFill
    {
        return ChartFill(CGLayer: CGLayer)
    }
    
    // MARK: Drawing code
    
    /// Draws the provided path in filled mode with the provided area
    public func fillPath(
        context context: CGContext,
        rect: CGRect)
    {
        let fillType = _type
        if fillType == .Empty
        {
            return
        }
        
        context.saveGState()
        
        switch fillType
        {
        case .Color:
            
            context.setFillColor(_color!)
            context.fillPath()
            
        case .Image:
            
            context.clip()
            context.draw(_image!, in: rect)
            
        case .TiledImage:
            
            context.clip()
            context.draw(_image!, in: rect, byTiling: true)
            
        case .Layer:
            
            context.clip()
            context.draw(_layer!, in: rect)
            
        case .LinearGradient:
            
            let radians = ChartUtils.Math.FDEG2RAD * (360.0 - _gradientAngle)
            let centerPoint = CGPoint(x:rect.midX, y:rect.midY)
            let xAngleDelta = cos(radians) * rect.width / 2.0
            let yAngleDelta = sin(radians) * rect.height / 2.0
            let startPoint = CGPoint(
                x:centerPoint.x - xAngleDelta,
                y:centerPoint.y - yAngleDelta
            )
            let endPoint = CGPoint(
                x:centerPoint.x + xAngleDelta,
                y:centerPoint.y + yAngleDelta
            )
            
            context.clip()
            context.drawLinearGradient(
                _gradient!,
                start: startPoint,
                end: endPoint,
                options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
            )
            
        case .RadialGradient:
            
            let centerPoint = CGPoint(x:rect.midX, y:rect.midY)
            let radius = max(rect.width, rect.height) / 2.0
            
            context.clip()
            context.drawRadialGradient(
                _gradient!,
                startCenter: CGPoint(
                    x:centerPoint.x + rect.width * _gradientStartOffsetPercent.x,
                    y:centerPoint.y + rect.height * _gradientStartOffsetPercent.y
                ),
                startRadius: radius * _gradientStartRadiusPercent,
                endCenter: CGPoint(
                    x:centerPoint.x + rect.width * _gradientEndOffsetPercent.x,
                    y:centerPoint.y + rect.height * _gradientEndOffsetPercent.y
                ),
                endRadius: radius * _gradientEndRadiusPercent,
                options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
            )
            
        case .Empty:
            break;
        }
        
        context.restoreGState()
    }
    
}
