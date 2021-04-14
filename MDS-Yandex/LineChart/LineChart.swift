//
//  LineChart.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 25.03.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import UIKit

struct PointEntry {
    let value: Double
    let label: String
}

extension PointEntry: Comparable {
    static func <(lhs: PointEntry, rhs: PointEntry) -> Bool {
        return lhs.value < rhs.value
    }
    static func ==(lhs: PointEntry, rhs: PointEntry) -> Bool {
        return lhs.value == rhs.value
    }
}

class LineChart: UIView {
    
    var graphColor: UIColor = Color.red
    
    // gap between each point
    var lineGap: CGFloat = 60.0
    
    // preseved space at top of the chart
    let topSpace: CGFloat = 40.0
    
    // preserved space at bottom of the chart to show labels along the Y axis
    let bottomSpace: CGFloat = 40.0
    
    // The top most horizontal line in the chart will be 10% higher than the highest value in the chart
    let topHorizontalLine: CGFloat = 110.0 / 100.0
    
    var isCurved: Bool = false

    // Active or desactive animation on dots
    var animateDots: Bool = true

    // Active or desactive dots
    var showDots: Bool = true
    
    var showLables: Bool = false

    // Dot inner Radius
    var innerRadius: CGFloat = 4

    // Dot outer Radius
    var outerRadius: CGFloat = 8
    
    var dataEntries: [PointEntry]? {
        didSet {
            if let lastElement = dataEntries?.last?.value,
                let firstElement = dataEntries?.first?.value {
                if (firstElement - lastElement < 0) {
                    graphColor = Color.green
                } else if (firstElement - lastElement > 0) {
                    graphColor = Color.lineRed
                } else {
                    graphColor = Color.black
                }
            }
            setupView()
            self.setNeedsLayout()
        }
    }
    
    // Contains the main line which represents the data
    private let dataLayer: CALayer = CALayer()

    // To show the gradient below the main line
    private let gradientLayer: CAGradientLayer = CAGradientLayer()
    
    // Contains dataLayer and gradientLayer
    private let mainLayer: CALayer = CALayer()
    
    // Contains mainLayer and label for each data entry
    private let scrollView: UIScrollView = UIScrollView()
    
    // Contains horizontal lines
    private let gridLayer: CALayer = CALayer()
    
    // An array of CGPoint on dataLayer coordinate system that the main line will go through. These points will be calculated from dataEntries array
    private var dataPoints: [CGPoint]?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        mainLayer.addSublayer(dataLayer)
        scrollView.layer.addSublayer(mainLayer)
        
        gradientLayer.colors = [graphColor.withAlphaComponent(0.3).cgColor, UIColor.clear.cgColor]
        scrollView.layer.addSublayer(gradientLayer)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        self.layer.addSublayer(gridLayer)
        self.addSubview(scrollView)
        self.backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        scrollView.isScrollEnabled = false
        if let dataEntries = dataEntries {
            lineGap = (self.frame.size.width / CGFloat(dataEntries.count - 1))
            scrollView.contentSize = CGSize(width: CGFloat(dataEntries.count - 1) * lineGap, height: self.frame.size.height)
            mainLayer.frame = CGRect(x: 0, y: 0, width: CGFloat(dataEntries.count) * lineGap, height: self.frame.size.height)
            dataLayer.frame = CGRect(x: 0, y: topSpace, width: mainLayer.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
            gradientLayer.frame = dataLayer.frame
            dataPoints = convertDataEntriesToPoints(entries: dataEntries)
            gridLayer.frame = CGRect(x: 0, y: topSpace, width: self.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
            if showDots {
                drawDots()
            }
            clean()
            drawHorizontalLines()
            if isCurved {
                drawCurvedChart()
            } else {
                drawChart()
            }
            maskGradientLayer()
            if showLables {
                drawLables()
            }
        }
    }
    
    /*
     Convert an array of PointEntry to an array of CGPoint on dataLayer coordinate system
     */
    private func convertDataEntriesToPoints(entries: [PointEntry]) -> [CGPoint] {
        if let max = entries.max()?.value,
            let min = entries.min()?.value {
            
            var result: [CGPoint] = []
            let minMaxRange: CGFloat = CGFloat(max - min) * topHorizontalLine
            
            for i in 0..<entries.count {
                let height = dataLayer.frame.height * (1 - ((CGFloat(entries[i].value) - CGFloat(min)) / minMaxRange))
                let point = CGPoint(x: CGFloat(i)*lineGap, y: height)
                result.append(point)
            }
            return result
        }
        return []
    }
    
    /*
     Draw a zigzag line connecting all points in dataPoints
     */
    private func drawChart() {
        if let dataPoints = dataPoints,
            dataPoints.count > 0,
            let path = createPath() {
            
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = graphColor.cgColor
    
            lineLayer.fillColor = UIColor.clear.cgColor
            dataLayer.addSublayer(lineLayer)
        }
    }

    /*
     Create a zigzag bezier path that connects all points in dataPoints
     */
    private func createPath() -> UIBezierPath? {
        guard let dataPoints = dataPoints, dataPoints.count > 0 else {
            return nil
        }
        let path = UIBezierPath()
        path.move(to: dataPoints[0])
        
        for i in 1..<dataPoints.count {
            path.addLine(to: dataPoints[i])
        }
        return path
    }
    
    /*
     Draw a curved line connecting all points in dataPoints
     */
    private func drawCurvedChart() {
        guard let dataPoints = dataPoints, dataPoints.count > 0 else {
            return
        }
        if let path = CurveAlgorithm.shared.createCurvedPath(dataPoints) {
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = graphColor.cgColor
            lineLayer.lineWidth = 2.0
            lineLayer.fillColor = UIColor.clear.cgColor
            dataLayer.addSublayer(lineLayer)
        }
    }
    
    /*
     Create a gradient layer below the line that connecting all dataPoints
     */
    private func maskGradientLayer() {
        if let dataPoints = dataPoints,
            dataPoints.count > 0 {
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: dataPoints[0].x, y: dataLayer.frame.height))
            path.addLine(to: dataPoints[0])
            if isCurved,
                let curvedPath = CurveAlgorithm.shared.createCurvedPath(dataPoints) {
                path.append(curvedPath)
            } else if let straightPath = createPath() {
                path.append(straightPath)
            }
            path.addLine(to: CGPoint(x: dataPoints[dataPoints.count-1].x, y: dataLayer.frame.height))
            path.addLine(to: CGPoint(x: dataPoints[0].x, y: dataLayer.frame.height))
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            maskLayer.fillColor = UIColor.white.cgColor
            maskLayer.strokeColor = UIColor.clear.cgColor
            maskLayer.lineWidth = 0.0
            
            gradientLayer.mask = maskLayer
        }
    }
    
    /*
     Create titles at the bottom for all entries showed in the chart
     */
    private func drawLables() {
        if let dataEntries = dataEntries,
            dataEntries.count > 0 {
            for i in 0..<dataEntries.count {
                let textLayer = CATextLayer()
                textLayer.frame = CGRect(x: lineGap*CGFloat(i) - lineGap/2, y: mainLayer.frame.size.height - bottomSpace/2 - 8, width: lineGap, height: 16)
                textLayer.foregroundColor = Color.black.cgColor
                textLayer.backgroundColor = UIColor.clear.cgColor
                textLayer.alignmentMode = CATextLayerAlignmentMode.center
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                textLayer.fontSize = 11
                textLayer.string = dataEntries[i].label
                mainLayer.addSublayer(textLayer)
            }
        }
    }
    
    /*
     Create horizontal lines (grid lines) and show the value of each line
     */
    private func drawHorizontalLines() {
        guard let dataEntries = dataEntries else {
            return
        }

        var gridValues: [CGFloat]? = nil
        if dataEntries.count < 4 && dataEntries.count > 0 {
            gridValues = [0, 1]
        } else if dataEntries.count >= 4 {
            gridValues = [0, 0.25, 0.5, 0.75, 1]
        }
        if let gridValues = gridValues {
            for value in gridValues {
                let height = value * gridLayer.frame.size.height

                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0, y: height))
                path.addLine(to: CGPoint(x: gridLayer.frame.size.width, y: height))

                let lineLayer = CAShapeLayer()
                lineLayer.path = path.cgPath
                lineLayer.fillColor = UIColor.clear.cgColor
                lineLayer.strokeColor = Color.black.withAlphaComponent(1.0).cgColor
                lineLayer.lineWidth = 0.5
                if (value > 0.0 && value < 1.0) {
                    lineLayer.lineDashPattern = [4, 4]
                }

                gridLayer.addSublayer(lineLayer)

                var minMaxGap:CGFloat = 0
                var lineValue: Double = 0
                if let max = dataEntries.max()?.value,
                    let min = dataEntries.min()?.value {
                    minMaxGap = CGFloat(max - min) * topHorizontalLine
                    lineValue = Double((1 - value) * minMaxGap) + Double(min)
                }

                let textLayer = CATextLayer()
                textLayer.frame = CGRect(x: 4, y: height, width: 50, height: 16)
                textLayer.foregroundColor = Color.black.withAlphaComponent(0.8).cgColor
                textLayer.backgroundColor = UIColor.clear.cgColor
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                textLayer.fontSize = 12
                textLayer.string = String(format: "%.1f", lineValue)

                gridLayer.addSublayer(textLayer)
            }
        }
    }
    
    private func clean() {
        mainLayer.sublayers?.forEach({
            if $0 is CATextLayer {
                $0.removeFromSuperlayer()
            }
        })
        dataLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        gridLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
    }
    /*
     Create Dots on line points
     */
    private func drawDots() {
//        var dotLayers: [DotCALayer] = []
//        if let dataPoints = dataPoints {
//            for dataPoint in dataPoints {
//                let xValue = dataPoint.x - outerRadius/2
//                let yValue = (dataPoint.y + lineGap) - (outerRadius * 2)
//                let dotLayer = DotCALayer()
//                dotLayer.dotInnerColor = UIColor.white
//                dotLayer.innerRadius = innerRadius
//                dotLayer.backgroundColor = UIColor.white.cgColor
//                dotLayer.cornerRadius = outerRadius / 2
//                dotLayer.frame = CGRect(x: xValue, y: yValue, width: outerRadius, height: outerRadius)
//                dotLayers.append(dotLayer)
//
//                mainLayer.addSublayer(dotLayer)
//
//                if animateDots {
//                    let anim = CABasicAnimation(keyPath: "opacity")
//                    anim.duration = 1.0
//                    anim.fromValue = 0
//                    anim.toValue = 1
//                    dotLayer.add(anim, forKey: "opacity")
//                }
//            }
//        }
    }
}
