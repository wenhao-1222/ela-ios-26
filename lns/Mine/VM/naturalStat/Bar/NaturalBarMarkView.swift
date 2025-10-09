//
//  NaturalBarMarkView.swift
//  lns
//
//  Created by LNS2 on 2024/9/11.
//

import Foundation
import DGCharts


class NaturalBarMarkView : MarkerView{
    
    var textLayer: CATextLayer = {
            let tempLayer = CATextLayer()
            tempLayer.backgroundColor = UIColor.clear.cgColor
            tempLayer.fontSize = 12
            tempLayer.alignmentMode = .center
            tempLayer.foregroundColor = UIColor.black.cgColor
            return tempLayer
        }()
    
    lazy var markCustomView: NaturalStatCaloriesBarMarkView = {
        let maskView = NaturalStatCaloriesBarMarkView.init(frame: .zero)
        return maskView
    }()
    
    var mOffset: CGPoint?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(80), height: kFitWidth(42)))
            
//            self.backgroundColor = UIColor.red
//            self.layer.cornerRadius = [self.frame.size.width, self.frame.size.height].min()! / 2
//            self.layer.masksToBounds = true
//            self.layer.borderColor = UIColor(white: 150.0/255.0, alpha: 1.0).cgColor
//            self.layer.borderWidth = 1
            
        self.addSubview(markCustomView)
//            self.layer.addSublayer(self.textLayer)
//            self.textLayer.frame = CGRect(x: 0, y: (self.frame.size.height - 16)/2, width: self.frame.size.width, height: 16)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
            super.refreshContent(entry: entry, highlight: highlight)
            
            let point = self.chartView?.getMarkerPosition(highlight: highlight)
            
            DLLog(message: "refreshContent:\(String(describing: point))")
//            let markCenter = self.markCustomView.center
//            self.markCustomView.center = CGPoint.init(x: markCenter.x, y: markCenter.y-(point?.y ?? 0))
        }
        
        override var offset: CGPoint {
            get {
                if(self.mOffset == nil) {
                   // center the marker horizontally and vertically
                    self.mOffset = CGPoint(x: -(self.bounds.size.width / 2), y: -self.bounds.size.height-kFitWidth(5))
                }
                DLLog(message: "\(self.convert(CGPoint(x: 0, y: 0), to: self.superview))")
                
                return self.mOffset!
            }
            set {
                
            }
        }
}
