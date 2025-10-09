//
//  NaturalBarCPFMarkView.swift
//  lns
//
//  Created by LNS2 on 2024/9/12.
//

import Foundation
import DGCharts


class NaturalBarCPFMarkView : MarkerView{
    
    var textLayer: CATextLayer = {
            let tempLayer = CATextLayer()
            tempLayer.backgroundColor = UIColor.clear.cgColor
            tempLayer.fontSize = 12
            tempLayer.alignmentMode = .center
            tempLayer.foregroundColor = UIColor.black.cgColor
            return tempLayer
        }()
    
    lazy var markCustomView: NaturalStatCPFBarMarkView = {
        let maskView = NaturalStatCPFBarMarkView.init(frame: .zero)
        return maskView
    }()
    
    var mOffset: CGPoint?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(80), height: kFitWidth(80)))
        self.addSubview(markCustomView)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
            super.refreshContent(entry: entry, highlight: highlight)
            
            let point = self.chartView?.getMarkerPosition(highlight: highlight)
            
            DLLog(message: "refreshContent:\(String(describing: point))")
        }
        
        override var offset: CGPoint {
            get {
                if(self.mOffset == nil) {
                   // center the marker horizontally and vertically
                    self.mOffset = CGPoint(x: -(self.bounds.size.width / 2), y: -self.bounds.size.height+kFitWidth(5))
                }
                DLLog(message: "\(self.convert(CGPoint(x: 0, y: 0), to: self.superview))")
                
                return self.mOffset!
            }
            set {
                
            }
        }
}

