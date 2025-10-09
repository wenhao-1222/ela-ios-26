//
//  WHToast.swift
//  kxf
//
//  Created by 文 on 2023/5/23.
//
import UIKit

public struct WHToast {
    // 位置：上中下；传入正数向上偏移，传入负数向下偏移。
    public enum Position {
        case top(CGFloat = 0)
        case middle(CGFloat = 0)
        case bottom(CGFloat = 0)
    }
    
    // 配置项：位置、文字颜色、背景颜色、字体大小、圆角、显示时长等。
    public enum Setting {
        case position(Position)
        case textColor(UIColor)
        case backColor(UIColor)
        case fontSize(CGFloat)
        case radiusSize(CGFloat)
        case duration(TimeInterval)
    }
    
    // 默认值：未配置时为该值。
    var position: Position = .middle()
    var textColor: UIColor = .white
    var backColor: UIColor = .COLOR_TEXT_GREY//UIColor(displayP3Red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    var fontSize: CGFloat = 16
    var radiusSize: CGFloat = 5
    var duration: TimeInterval = 2
    
    // 单例配置值：用于全局设置。
    static var setting = WHToast()
    
    // 设置全局配置值。
    static func config(_ settings: Setting ...){
        WHToast.change(obj:&WHToast.setting, settings: settings)
    }
    
    // 改变obj的设置。
    static func change(obj: inout WHToast, settings: [Setting]) {
        for setting in settings {
            switch setting {
            case let .position(position):
                obj.position = position
            case let .textColor(color):
                obj.textColor = color
            case let .backColor(color):
                obj.backColor = color
            case let .fontSize(size):
                obj.fontSize = size
            case let .radiusSize(size):
                obj.radiusSize = size
            case let .duration(interval):
                obj.duration = interval
            }
        }
    }
    
    func toast(message: String){
        if message.isEmpty {
            return
        }
        
        guard let view = self.topView() else {
            return
        }
        
        let padding: CGFloat = 18
        
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width - self.fontSize * 4, height: CGFloat.greatestFiniteMagnitude))
        label.text = message
        label.font = .systemFont(ofSize: self.fontSize)
        label.lineBreakMode = .byCharWrapping
        label.numberOfLines = 0
        label.textColor = self.textColor
        label.sizeToFit()
        
        let back = UIView()
        back.frame = CGRect(origin: label.frame.origin, size: CGSize(width: label.frame.width + padding * 2, height: label.frame.height + padding))
        back.layer.cornerRadius = self.radiusSize
        back.backgroundColor = self.backColor
        back.addSubview(label)
        back.alpha = 0.0
        label.center = back.center
        
        DispatchQueue.main.async {
            view.addSubview(back)
            view.bringSubviewToFront(back)
            switch self.position {
            case let .top(offset):
                back.center = CGPoint(x: view.center.x, y: back.frame.height + padding - offset)
            case let .middle(offset):
                back.center = CGPoint(x: view.center.x, y: view.center.y - offset)
            case let .bottom(offset):
                back.center = CGPoint(x: view.center.x, y: view.frame.height - back.frame.height - padding - offset)
            }
            
            UIView.animate(withDuration: 0.5){
                back.alpha = 1.0
            }
            
            Timer.scheduledTimer(withTimeInterval: self.duration, repeats: false) { timer in
                UIView.animate(withDuration: 0.5) {
                    back.alpha = 0.0
                } completion: { _ in
                    back.removeFromSuperview()
                }
                timer.invalidate()
            }
        }
    }
    
    private func topView() -> UIView? {
        if var topVC = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topVC.presentedViewController {
                topVC = presentedViewController
            }
            return topVC.view
        }
        return nil
    }
}

public func toast(_ message: String?, _ settings: WHToast.Setting ...) {
    guard let text = message else {
        return
    }
    var t = WHToast(position: WHToast.setting.position, textColor: WHToast.setting.textColor, backColor: WHToast.setting.backColor, fontSize: WHToast.setting.fontSize, duration: WHToast.setting.duration)
    WHToast.change(obj: &t, settings: settings)
    t.toast(message: text)
}
