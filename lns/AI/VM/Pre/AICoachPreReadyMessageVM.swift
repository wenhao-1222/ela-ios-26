//
//  AICoachPreReadyMessageVM.swift
//  lns
//
//  Created by Codex on 2026/5/25.
//

import UIKit
import SnapKit

final class AICoachPreReadyMessageVM: UIView {

    let selfHeight = kFitWidth(34)

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        backgroundColor = .clear
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "你的首期教练反馈已经准备好了，快去查看！"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.82
        return label
    }()
}

extension AICoachPreReadyMessageVM {
    func updateContent(msgDict:NSDictionary) {
        let attr = NSMutableAttributedString()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        paragraphStyle.alignment = .center
        attr.append(NSAttributedString(string: "请继续保持记录饮食和体重\n我预计会在 ", attributes: [.font:UIFont.systemFont(ofSize: 14, weight: .semibold),
              .foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214,
            .paragraphStyle: paragraphStyle]))
        
        let latestReport = msgDict["latestReport"]as? NSDictionary ?? [:]
        
        if msgDict.doubleValueForKey(key: "reportCount") == 0 {
            //首报未出
            //  remainingDays  不适用首报未出的情况
            let remainingDays = max(1,7 - msgDict.stringValueForKey(key: "completeDays").intValue)
            
            
            attr.append(NSAttributedString(string: "\(remainingDays)", attributes: [.font:UIFont.systemFont(ofSize: 14, weight: .medium),
                  .foregroundColor:UIColor.THEME,
                  .paragraphStyle: paragraphStyle]))
            attr.append(NSAttributedString(string: " 天后为你带来第一次全面反馈", attributes: [.font:UIFont.systemFont(ofSize: 14, weight: .semibold),
                  .foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214,
                  .paragraphStyle: paragraphStyle]))
          attr.append(NSAttributedString(string: "\n为了让分析更精准，我还需要更多时间来了解你", attributes: [.font:UIFont.systemFont(ofSize: 12, weight: .regular),
                    .foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214_50,
                     .paragraphStyle: paragraphStyle]))
            
            messageLabel.attributedText = attr
        }else if msgDict.doubleValueForKey(key: "reportCount") == 1{
            //只出了一份报告  首报
            if latestReport.stringValueForKey(key: "reportStatus") == "2"{
                //首报未读
                messageLabel.text = "你的首期教练反馈已经准备好了，快去查看！"
            }else{
                //首报已读，则已开始下一周期的报告
                let remainingDays = msgDict.stringValueForKey(key: "remainingDays")//max(1,7 - msgDict.stringValueForKey(key: "completeDays").intValue)
                attr.append(NSAttributedString(string: "\(remainingDays)", attributes: [.font:UIFont.systemFont(ofSize: 14, weight: .medium),
                      .foregroundColor:UIColor.THEME,
                      .paragraphStyle: paragraphStyle]))
                attr.append(NSAttributedString(string: " 天后给你发送下一阶段的跟进反馈", attributes: [.font:UIFont.systemFont(ofSize: 14, weight: .semibold),
                      .foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214,
                      .paragraphStyle: paragraphStyle]))
                messageLabel.attributedText = attr
            }
        }else{
            //续报
            if latestReport.stringValueForKey(key: "reportStatus") == "2"{
                //首报未读
                messageLabel.text = "你最新的教练反馈已经准备好了，快去查看！"
            }else{
                //首报已读，则已开始下一周期的报告
                let remainingDays = msgDict.stringValueForKey(key: "remainingDays")//max(1,7 - msgDict.stringValueForKey(key: "completeDays").intValue)
                attr.append(NSAttributedString(string: "\(remainingDays)", attributes: [.font:UIFont.systemFont(ofSize: 14, weight: .medium),
                      .foregroundColor:UIColor.THEME,
                      .paragraphStyle: paragraphStyle]))
                attr.append(NSAttributedString(string: " 天后给你发送下一阶段的跟进反馈", attributes: [.font:UIFont.systemFont(ofSize: 14, weight: .semibold),
                      .foregroundColor:UIColor.COLOR_TEXT_TITLE_0f1214,
                      .paragraphStyle: paragraphStyle]))
                messageLabel.attributedText = attr
            }
        }
    }
}

extension AICoachPreReadyMessageVM {
    func prepareEntranceAnimation() {
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: -kFitWidth(12))
    }

    func applyFinalPresentationState() {
        alpha = 1
        transform = .identity
    }

    func playEntranceAnimation(duration: TimeInterval,
                               completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveLinear) {
            self.applyFinalPresentationState()
        } completion: { _ in
            completion?()
        }
    }
}

private extension AICoachPreReadyMessageVM {
    func initUI() {
        addSubview(messageLabel)

        messageLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalToSuperview()
        }
    }
}
