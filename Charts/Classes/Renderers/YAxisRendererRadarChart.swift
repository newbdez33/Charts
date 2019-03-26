//
//  YAxisRendererRadarChart.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif

open class YAxisRendererRadarChart: YAxisRenderer
{
    fileprivate weak var chart: RadarChartView?
    
    public init(viewPortHandler: ViewPortHandler?, yAxis: YAxis?, chart: RadarChartView?)
    {
        super.init(viewPortHandler: viewPortHandler, yAxis: yAxis, transformer: nil)
        
        self.chart = chart
    }
    
    open override func computeAxisValues(min yMin: Double, max yMax: Double)
    {
        guard let
            axis = axis as? YAxis
            else { return }
        
        let labelCount = axis.labelCount
        let range = abs(yMax - yMin)
        
        if labelCount == 0 || range <= 0
        {
            axis.entries = [Double]()
            return
        }
        
        // Find out how much spacing (in yValue space) between axis values
        var rawInterval = range / Double(labelCount)
        if rawInterval.isInfinite
        {
            rawInterval = range > 0.0 && !range.isInfinite ? range : 1.0
        }
        var interval = ChartUtils.roundToNextSignificant(number: Double(rawInterval))
        
        // If granularity is enabled, then do not allow the interval to go below specified granularity.
        // This is used to avoid repeated values when rounding values for display.
        if axis.isGranularityEnabled
        {
            interval = interval < axis.granularity ? axis.granularity : interval
        }
        
        // Normalize interval
        let intervalMagnitude = ChartUtils.roundToNextSignificant(number: pow(10.0, floor(log10(interval))))
        let intervalSigDigit = Int(interval / intervalMagnitude)
        
        if intervalSigDigit > 5
        {
            // Use one order of magnitude higher, to avoid intervals like 0.9 or
            // 90
            interval = floor(10 * intervalMagnitude)
        }
        
        let centeringEnabled = axis.isCenterAxisLabelsEnabled
        var n = centeringEnabled ? 1 : 0

        // force label count
        if axis.isForceLabelsEnabled
        {
            let step = Double(range) / Double(labelCount - 1)
            
            // Ensure stops contains at least n elements.
            axis.entries.removeAll(keepingCapacity: true)
            axis.entries.reserveCapacity(labelCount)
            
            var v = yMin
            
            for _ in 0 ..< labelCount
            {
                axis.entries.append(v)
                v += step
            }
            
            n = labelCount
        }
        else
        {
            // no forced count
            
            var first = interval == 0.0 ? 0.0 : ceil(yMin / interval) * interval
            
            if centeringEnabled
            {
                first -= interval
            }

            let last = interval == 0.0 ? 0.0 : ChartUtils.nextUp(floor(yMax / interval) * interval)
            
            if interval != 0.0
            {
                for _ in stride(from: first, through: last, by: interval)
                {
                    n += 1
                }
            }
            
            n += 1
            
            // Ensure stops contains at least n elements.
            axis.entries.removeAll(keepingCapacity: true)
            axis.entries.reserveCapacity(labelCount)
            
            var f = first
            var i = 0
            while i < n
            {
                if f == 0.0
                {
                    // Fix for IEEE negative zero case (Where value == -0.0, and 0.0 == -0.0)
                    f = 0.0
                }

                axis.entries.append(Double(f))
                
                f += interval
                i += 1
            }
        }
        
        // set decimals
        if interval < 1
        {
            axis.decimals = Int(ceil(-log10(interval)))
        }
        else
        {
            axis.decimals = 0
        }
        
        if centeringEnabled
        {
            axis.centeredEntries.reserveCapacity(n)
            axis.centeredEntries.removeAll()
            
            let offset = (axis.entries[1] - axis.entries[0]) / 2.0
            
            for i in 0 ..< n
            {
                axis.centeredEntries.append(axis.entries[i] + offset)
            }
        }
        
        axis._axisMinimum = axis.entries[0]
        axis._axisMaximum = axis.entries[n-1]
        axis.axisRange = abs(axis._axisMaximum - axis._axisMinimum)
    }
    
    open override func renderAxisLabels(context: CGContext)
    {
        guard let
            yAxis = axis as? YAxis,
            let chart = chart
            else { return }
        
        if !yAxis.isEnabled || !yAxis.isDrawLabelsEnabled
        {
            return
        }
        
        let labelFont = yAxis.labelFont
        let labelTextColor = yAxis.labelTextColor
        
        let center = chart.centerOffsets
        let factor = chart.factor
        
        let labelCount = yAxis.entryCount
        
        let labelLineHeight = yAxis.labelFont.lineHeight
        
        for j in 0 ..< labelCount
        {
            if j == labelCount - 1 && yAxis.isDrawTopYLabelEntryEnabled == false
            {
                break
            }
            
            let r = CGFloat(yAxis.entries[j] - yAxis._axisMinimum) * factor
            
            let p = ChartUtils.getPosition(center: center, dist: r, angle: chart.rotationAngle)
            
            let label = yAxis.getFormattedLabel(j)
            
            ChartUtils.drawText(
                context: context,
                text: label,
                point: CGPoint(x: p.x + 10.0, y: p.y - labelLineHeight),
                align: .left,
                attributes: [
                    convertFromNSAttributedStringKey(NSAttributedString.Key.font): labelFont,
                    convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): labelTextColor
                ])
        }
    }
    
    open override func renderLimitLines(context: CGContext)
    {
        guard
            let yAxis = axis as? YAxis,
            let chart = chart,
            let data = chart.data
            else { return }
        
        var limitLines = yAxis.limitLines
        
        if limitLines.count == 0
        {
            return
        }
        
        context.saveGState()
        
        let sliceangle = chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        let factor = chart.factor
        
        let center = chart.centerOffsets
        
        for i in 0 ..< limitLines.count
        {
            let l = limitLines[i]
            
            if !l.isEnabled
            {
                continue
            }
            
            context.setStrokeColor(l.lineColor.cgColor)
            context.setLineWidth(l.lineWidth)
            if l.lineDashLengths != nil
            {
                context.setLineDash(phase: l.lineDashPhase, lengths: l.lineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            let r = CGFloat(l.limit - chart.chartYMin) * factor
            
            context.beginPath()
            
            for j in 0 ..< (data.maxEntryCountSet?.entryCount ?? 0)
            {
                let p = ChartUtils.getPosition(center: center, dist: r, angle: sliceangle * CGFloat(j) + chart.rotationAngle)
                
                if j == 0
                {
                    context.move(to: CGPoint(x: p.x, y: p.y))
                }
                else
                {
                    context.addLine(to: CGPoint(x: p.x, y: p.y))
                }
            }
            
            context.closePath()
            
            context.strokePath()
        }
        
        context.restoreGState()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
