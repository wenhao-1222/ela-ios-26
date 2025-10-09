//
//  MallOrderExpressCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/18.
//

import UIKit

class ExpressModel: NSObject {
    
    var title = ""
    
    var msgArray:[ExpressMsgModel] = [ExpressMsgModel]()
    
    func dealMsg(titleStr:String,msgArr:NSArray) -> ExpressModel {
        let model = ExpressModel()
        model.title = titleStr
        
        for i in 0..<msgArr.count{
            let dict = msgArr[i]as? NSDictionary ?? [:]
            let msgModel = ExpressMsgModel()
            msgModel.time = dict.stringValueForKey(key: "ftime")
            msgModel.msg = dict.stringValueForKey(key: "context")
            
            model.msgArray.append(msgModel)
        }
        
        return model
    }
}

class ExpressMsgModel: NSObject {
    
    var title = ""
    
    var time = ""
    
    var msg = ""
}

class MallOrderExpressCell: UITableViewCell {
    
    private struct PhoneInfo {
       let range: NSRange
       let number: String
   }

   private lazy var detailTapGesture: UITapGestureRecognizer = {
       let tap = UITapGestureRecognizer(target: self, action: #selector(handleDetailTap(_:)))
       return tap
   }()

   private var phoneInfos: [PhoneInfo] = []

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .COLOR_BG_WHITE
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var circleView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(5)
        vi.clipsToBounds = true
        vi.layer.borderWidth = kFitWidth(1)
        vi.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_20.cgColor
        
        return vi
    }()
    lazy var expStatusLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var expressDetailLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.customLineHeight = 1.5
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        lab.isUserInteractionEnabled = true
        lab.addGestureRecognizer(detailTapGesture)
        
        return lab
    }()
    lazy var topLineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_20
        
        return vi
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_20
        
        return vi
    }()
}

extension MallOrderExpressCell{
    func udpateUI(model:ExpressMsgModel,textColor:UIColor = .COLOR_TEXT_TITLE_0f1214_50,circleType:Int=1) {
        var detailString = ""
        if model.title.count > 0 {
            expStatusLabel.textColor = .COLOR_TEXT_TITLE_0f1214
            expStatusLabel.font = .systemFont(ofSize: 16, weight: .medium)
            expStatusLabel.text = model.title
//            expressDetailLabel.text = "\(model.time)\n\(model.msg)"
            detailString = "\(model.time)\n\(model.msg)"
        }else{
            expStatusLabel.textColor = textColor
            expStatusLabel.font = .systemFont(ofSize: 13, weight: .regular)
            expStatusLabel.text = model.time
            expressDetailLabel.text = "\(model.msg)"
            detailString = "\(model.msg)"
        }
        
        updateDetailLabelText(detailString, baseColor: textColor)
        
        if circleType == 1{
            circleView.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_20.cgColor
            circleView.backgroundColor = .white
        }else{
            circleView.layer.borderColor = UIColor.THEME.cgColor
            circleView.backgroundColor = .THEME
        }
    }
    func updateLine(index:Int,dataCount:Int) {
        if dataCount == 1{
            topLineView.isHidden = true
            lineView.isHidden = true
            return
        }
        topLineView.isHidden = false
        lineView.isHidden = false
        if index == 1{
            topLineView.isHidden = true
        }else if index == dataCount{
            lineView.isHidden = true
        }
    }
}

extension MallOrderExpressCell{
    func initUI() {
        contentView.addSubview(topLineView)
        contentView.addSubview(lineView)
        contentView.addSubview(circleView)
        contentView.addSubview(expStatusLabel)
        contentView.addSubview(expressDetailLabel)
        
        setConstrait()
    }
    func setConstrait() {
        circleView.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(expStatusLabel)
            make.width.height.equalTo(kFitWidth(10))
            make.left.equalTo(kFitWidth(16))
        }
        expStatusLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(36))
            make.top.equalToSuperview()
        }
        expressDetailLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(36))
            make.top.equalTo(expStatusLabel.snp.bottom).offset(kFitWidth(2))
            make.bottom.equalTo(kFitWidth(-13))
            make.right.equalTo(kFitWidth(-16))
        }
        topLineView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(circleView)
            make.top.equalToSuperview()
            make.width.equalTo(kFitWidth(1))
            make.bottom.equalTo(circleView)
        }
        lineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.equalTo(kFitWidth(1))
            make.top.equalTo(circleView)
            make.centerX.lessThanOrEqualTo(circleView)
        }
    }
}
// MARK: - Phone detection
private extension MallOrderExpressCell {
    func updateDetailLabelText(_ text: String, baseColor: UIColor) {
        phoneInfos.removeAll()

        let attributed = NSMutableAttributedString(string: text)
        let fullRange = NSRange(location: 0, length: (text as NSString).length)
        attributed.addAttributes([
            .foregroundColor: baseColor,
            .font: expressDetailLabel.font ?? UIFont.systemFont(ofSize: 13)
        ], range: fullRange)

        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue) {
            detector.enumerateMatches(in: text, options: [], range: fullRange) { [weak self] result, _, _ in
                guard
                    let self,
                    let result,
                    let number = result.phoneNumber
                else { return }

                attributed.addAttribute(.foregroundColor, value: UIColor.THEME, range: result.range)
                phoneInfos.append(PhoneInfo(range: result.range, number: number))
            }
        }

        expressDetailLabel.attributedText = attributed
    }

    @objc
    func handleDetailTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }
        guard let label = gesture.view as? UILabel else { return }
        let location = gesture.location(in: label)

        guard let index = characterIndex(in: label, at: location) else { return }

        guard let info = phoneInfos.first(where: { NSLocationInRange(index, $0.range) }) else { return }

        callPhoneNumber(info.number)
    }

    func characterIndex(in label: UILabel, at point: CGPoint) -> Int? {
        guard let attributedText = label.attributedText, attributedText.length > 0 else { return nil }

        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainerSize = CGSize(width: label.bounds.width, height: label.bounds.height)
        let textContainer = NSTextContainer(size: textContainerSize)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        layoutManager.addTextContainer(textContainer)

        layoutManager.ensureLayout(for: textContainer)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)

        let xOffset: CGFloat
        switch label.textAlignment {
        case .center:
            xOffset = (label.bounds.width - textBoundingBox.width) * 0.5 - textBoundingBox.origin.x
        case .right:
            xOffset = (label.bounds.width - textBoundingBox.width) - textBoundingBox.origin.x
        default:
            xOffset = -textBoundingBox.origin.x
        }

        let yOffset = (label.bounds.height - textBoundingBox.height) * 0.5 - textBoundingBox.origin.y
        let location = CGPoint(x: point.x - xOffset, y: point.y - yOffset)

        guard textBoundingBox.contains(location) else { return nil }

        let index = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }

    func callPhoneNumber(_ rawNumber: String) {
        let digits = rawNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard let url = URL(string: "tel://\(digits)"), !digits.isEmpty else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
