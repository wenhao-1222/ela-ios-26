//
//  QuestionnaireBodyFatItemVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/28.
//

import Foundation
import UIKit

class QuestionnaireBodyFatItemVM: UIView {
    
    var selfHeight = kFitWidth(179)
    var isRight = false
    var isSelect = false
    
    var numberLabelWidth = kFitWidth(20)
    var numberLabelWidthSelect = kFitWidth(20)
    var itemWidth = SCREEN_WIDHT * 0.5
    var imageSide = kFitWidth(164)
    var imageLeftInset = kFitWidth(16)
    var imageRightInset = kFitWidth(16)
    var selectedImageSide = kFitWidth(148)
    var selectedImageTopInset = kFitWidth(8)
    var selectedImageLeftInset = kFitWidth(24)
    var selectedImageRightInset = kFitWidth(24)
    var selectIconSize = kFitWidth(16)
    var selectIconLeft = kFitWidth(28)
    var selectIconTop = kFitWidth(49)
    var selectedTitleIconSpacing = kFitWidth(4)
    var centersSelectedContent = false
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    private let feedbackWeight: CGFloat = 0.9
    private var lastFeedbackTime: TimeInterval = 0
    private let minimumFeedbackInterval: TimeInterval = 0.1
    private var currentValueText = ""
    private var selectionAnimationToken: Int = 0

    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT * 0.5, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
//        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var imgView : UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.layer.cornerRadius = kFitWidth(12)
        img.clipsToBounds = true
        
        return img
    }()
    
    //body_fat_img_cover
    
    lazy var coverViewForLabel : UIImageView = {
        let layerView = UIImageView()
        layerView.setImgLocal(imgName: "body_fat_img_cover")
        layerView.frame = CGRect(x: 0, y: kFitWidth(104), width: kFitWidth(164), height: kFitWidth(60))
        return layerView
    }()
    lazy var titleLab : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_WHITE
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "体脂率"
        
        return lab
    }()
    lazy var numberLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_WHITE
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        lab.textAlignment = .left
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var coverView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        vi.alpha = 0
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        vi.isHidden = true
        return vi
    }()
    lazy var selectImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "body_fat_select_icon")
        
        return img
    }()
    lazy var rectView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.layer.cornerRadius = kFitWidth(12)
        vi.layer.borderColor = UIColor.THEME.cgColor
        vi.layer.borderWidth = kFitWidth(1)
        vi.clipsToBounds = true
        
        return vi
    }()
}

extension QuestionnaireBodyFatItemVM{
    func applyLayout(itemWidth: CGFloat,
                     itemHeight: CGFloat,
                     imageSide: CGFloat,
                     imageLeftInset: CGFloat,
                     imageRightInset: CGFloat,
                     selectedImageInset: CGFloat,
                     selectedImageSide: CGFloat,
                     selectIconSize: CGFloat,
                     selectIconLeft: CGFloat,
                     selectIconTop: CGFloat,
                     selectedTitleIconSpacing: CGFloat = kFitWidth(4),
                     centersSelectedContent: Bool = false) {
        self.itemWidth = itemWidth
        self.selfHeight = itemHeight
        self.imageSide = imageSide
        self.imageLeftInset = imageLeftInset
        self.imageRightInset = imageRightInset
        self.selectedImageSide = selectedImageSide
        self.selectedImageLeftInset = selectedImageInset
        self.selectedImageRightInset = selectedImageInset
        self.selectedImageTopInset = (imageSide - selectedImageSide) * 0.5
        self.selectIconSize = selectIconSize
        self.selectIconLeft = selectIconLeft
        self.selectIconTop = selectIconTop
        self.selectedTitleIconSpacing = selectedTitleIconSpacing
        self.centersSelectedContent = centersSelectedContent
        frame.size = CGSize(width: itemWidth, height: itemHeight)
        setConstrait()
        resetToUnselectedStyle()
    }

    @objc func tapAction() {
        if self.isSelect{
            return
        }
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
}

extension QuestionnaireBodyFatItemVM{
    func refreshForRight() {
        imgView.frame = CGRect.init(x: itemWidth - imageRightInset - imageSide, y: kFitWidth(0), width: imageSide, height: imageSide)
        rectView.frame =  imgView.frame
    }

    func resetToUnselectedStyle() {
        [imgView, coverView, coverViewForLabel, titleLab, numberLabel, selectImgView].forEach {
            $0.layer.removeAllAnimations()
            $0.transform = .identity
        }

        isSelect = false
        titleLab.text = "体脂率"
        titleLab.textAlignment = .left
        let labelX = kFitWidth(16)
        titleLab.frame = CGRect(x: labelX, y: max(imageSide - kFitWidth(44), 0), width: max(imageSide - kFitWidth(32), kFitWidth(60)), height: kFitWidth(12))
        numberLabel.frame = CGRect(x: labelX, y: max(imageSide - kFitWidth(29), 0), width: min(numberLabelWidth, max(imageSide - kFitWidth(32), kFitWidth(44))), height: kFitWidth(20))
        numberLabel.textAlignment = .left
        applyValueText(fontSize: 20)
        imgView.layer.cornerCurve = .continuous
        imgView.layer.cornerRadius = kFitWidth(12)

        if isRight {
            refreshForRight()
        } else {
            imgView.frame = CGRect(x: imageLeftInset, y: 0, width: imageSide, height: imageSide)
            rectView.frame = imgView.frame
        }

        coverViewForLabel.frame = CGRect(x: 0, y: max(imageSide - kFitWidth(60), 0), width: imageSide, height: min(kFitWidth(60), imageSide))
        coverView.frame = imgView.bounds
        coverView.alpha = 0
        coverView.isHidden = true
        coverViewForLabel.alpha = 1
        coverViewForLabel.isHidden = false
        selectImgView.alpha = 0
    }

    func updateUI(dict:NSDictionary,isRight:Bool) {
        let valueText = "\(dict["data"]as? String ?? "")"
        currentValueText = valueText

        imgView.setImgLocal(imgName: "\(dict["imgUrl"]as? String ?? "")")
        self.isRight = isRight
        
        numberLabelWidth = measuredValueTextWidth(fontSize: 20) + kFitWidth(38)
        numberLabelWidthSelect = measuredValueTextWidth(fontSize: 28) + kFitWidth(54)
        
        if isRight{
            refreshForRight()
        }
        resetToUnselectedStyle()
    }
    func updateUIIsSelected(isSelect: Bool) {
        guard self.isSelect != isSelect else { return }
        selectionAnimationToken += 1
        let animationToken = selectionAnimationToken
        self.isSelect = isSelect

        if isSelect {
            let animationDuration: TimeInterval = 0.24
            let leftGap = isRight ? (itemWidth - selectedImageRightInset - selectedImageSide) : selectedImageLeftInset
            let finalFrame = CGRect(x: leftGap, y: selectedImageTopInset, width: selectedImageSide, height: selectedImageSide)

            [imgView, coverView, coverViewForLabel, titleLab, numberLabel, selectImgView].forEach {
                $0.layer.removeAllAnimations()
                $0.transform = .identity
            }

            titleLab.text = "已选择体脂率"
            imgView.layer.cornerCurve = .continuous
            imgView.layer.cornerRadius = kFitWidth(8)

            coverView.isHidden = false
            coverViewForLabel.isHidden = false
            coverViewForLabel.alpha = 1
            coverView.alpha = 0

            // 选中态文案/数值目标
            let targetTitleFrame: CGRect
            let targetNumberFrame: CGRect
            if centersSelectedContent {
                let titleTextWidth = ceil(("已选择体脂率" as NSString).size(withAttributes: [.font: titleLab.font as Any]).width)
                let titleGroupWidth = selectIconSize + selectedTitleIconSpacing + titleTextWidth
                let titleGroupMinX = max((selectedImageSide - titleGroupWidth) * 0.5, 0)
                let titleY = selectedImageSide * 0.30
                targetTitleFrame = CGRect(
                    x: titleGroupMinX + selectIconSize + selectedTitleIconSpacing,
                    y: titleY,
                    width: min(titleTextWidth, selectedImageSide - selectIconSize - selectedTitleIconSpacing),
                    height: kFitWidth(12)
                )
                selectImgView.snp.remakeConstraints { make in
                    make.left.equalTo(titleGroupMinX)
                    make.top.equalTo(titleY + (kFitWidth(12) - selectIconSize) * 0.5)
                    make.width.height.equalTo(selectIconSize)
                }
                let targetNumberWidth = min(selectedImageSide - kFitWidth(20), max(self.numberLabelWidthSelect, selectedImageSide * 0.7))
                targetNumberFrame = CGRect(
                    x: (selectedImageSide - targetNumberWidth) * 0.5,
                    y: selectedImageSide * 0.42,
                    width: targetNumberWidth,
                    height: kFitWidth(28)
                )
            } else {
                targetTitleFrame = CGRect(x: kFitWidth(48), y: kFitWidth(52), width: kFitWidth(200), height: kFitWidth(12))
                let targetNumberWidth = min(kFitWidth(146), max(self.numberLabelWidthSelect, kFitWidth(104)))
                targetNumberFrame = CGRect(
                    x: (kFitWidth(148) - targetNumberWidth) * 0.5,
                    y: kFitWidth(70),
                    width: targetNumberWidth,
                    height: kFitWidth(28)
                )
                selectImgView.snp.remakeConstraints { make in
                    make.left.equalTo(selectIconLeft)
                    make.top.equalTo(selectIconTop)
                    make.width.height.equalTo(selectIconSize)
                }
            }

            // 勾选初始
            selectImgView.alpha = 0
            selectImgView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            titleLab.textAlignment = .left
            numberLabel.textAlignment = .center
            applyValueText(fontSize: 28)

            UIView.animate(withDuration: animationDuration,
                           delay: 0,
                           options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]) {
                self.imgView.frame = finalFrame
                self.coverView.alpha = 1
                self.coverViewForLabel.alpha = 0
                self.titleLab.frame = targetTitleFrame
                self.numberLabel.frame = targetNumberFrame
            } completion: { _ in
                guard animationToken == self.selectionAnimationToken, self.isSelect else { return }
                self.coverViewForLabel.isHidden = true
            }

            UIView.animate(withDuration: animationDuration,
                           delay: 0.04,
                           options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]) {
                self.selectImgView.alpha = 1
                self.selectImgView.transform = .identity
            } completion: { _ in
                guard animationToken == self.selectionAnimationToken, self.isSelect else { return }
                self.selectImgView.alpha = 1
                self.selectImgView.transform = .identity
            }

        }else {
            // 还原未选中（保持干净）
            [imgView, coverView, coverViewForLabel, titleLab, numberLabel, selectImgView].forEach {
                $0.layer.removeAllAnimations()
                $0.transform = .identity
            }

            imgView.layer.cornerCurve = .continuous
            imgView.layer.cornerRadius = kFitWidth(12)
            titleLab.textAlignment = .left
            numberLabel.textAlignment = .left
            applyValueText(fontSize: 20)

            if isRight {
                self.refreshForRight()
            } else {
                imgView.frame = CGRect(x: imageLeftInset, y: 0, width: imageSide, height: imageSide)
            }
            let labelX = kFitWidth(16)

            coverViewForLabel.isHidden = false
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]) {
                self.coverView.alpha = 0
                self.coverViewForLabel.alpha = 1
                self.titleLab.frame = CGRect(x: labelX, y: max(self.imageSide - kFitWidth(44), 0), width: max(self.imageSide - kFitWidth(32), kFitWidth(60)), height: kFitWidth(12))
                self.numberLabel.frame = CGRect(x: labelX, y: max(self.imageSide - kFitWidth(29), 0), width: min(self.numberLabelWidth, max(self.imageSide - kFitWidth(32), kFitWidth(44))), height: kFitWidth(20))
                self.selectImgView.alpha = 0
            } completion: { _ in
                guard animationToken == self.selectionAnimationToken, !self.isSelect else { return }
                self.titleLab.text = "体脂率"
                self.coverView.isHidden = true
                self.selectImgView.alpha = 0
            }
        }
    }
}

private extension QuestionnaireBodyFatItemVM {
    func applyValueText(fontSize: CGFloat) {
        numberLabel.attributedText = makeValueAttributedText(fontSize: fontSize)
    }

    func measuredValueTextWidth(fontSize: CGFloat) -> CGFloat {
        let rect = makeValueAttributedText(fontSize: fontSize).boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: kFitWidth(40)),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return ceil(rect.width)
    }

    func makeValueAttributedText(fontSize: CGFloat) -> NSAttributedString {
        let baseFont = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        let text = currentValueText
        let attr = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: baseFont,
                .foregroundColor: UIColor.COLOR_TEXT_WHITE
            ]
        )

        guard let regex = try? NSRegularExpression(pattern: "\\d+", options: []) else {
            return attr
        }

        let nsText = text as NSString
        let digitFont = UIFont().DDInFontMedium(fontSize: fontSize)
        regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length)).forEach {
            attr.addAttribute(.font, value: digitFont, range: $0.range)
        }
        return attr
    }
}

extension QuestionnaireBodyFatItemVM{
    func initUI() {
        addSubview(rectView)
        addSubview(imgView)
        imgView.addSubview(coverViewForLabel)
        imgView.addSubview(coverView)
        imgView.addSubview(titleLab)
        imgView.addSubview(numberLabel)
        coverView.addSubview(selectImgView)
        
        setConstrait()
        // ❌ 删掉 SnapKit 约束
        // coverView.snp.makeConstraints { ... }

        // ✅ 在 layout / 初始化时
        coverView.frame = imgView.bounds
        coverView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    func setConstrait() {
        imgView.frame = CGRect.init(x: imageLeftInset, y: 0, width: imageSide, height: imageSide)
        titleLab.frame = CGRect.init(x: kFitWidth(16), y: max(imageSide - kFitWidth(44), 0), width: max(imageSide - kFitWidth(32), kFitWidth(60)), height: kFitWidth(12))
        numberLabel.frame = CGRect.init(x: kFitWidth(16), y: max(imageSide - kFitWidth(29), 0), width: max(imageSide - kFitWidth(32), kFitWidth(44)), height: kFitWidth(20))
        rectView.frame =  CGRect.init(x: imageLeftInset, y: 0, width: imageSide, height: imageSide)
        coverViewForLabel.frame = CGRect(x: 0, y: max(imageSide - kFitWidth(60), 0), width: imageSide, height: min(kFitWidth(60), imageSide))
        
        selectImgView.snp.remakeConstraints { make in
            make.left.equalTo(selectIconLeft)
            make.top.equalTo(selectIconTop)
            make.width.height.equalTo(selectIconSize)
        }
//        coverView.snp.makeConstraints { make in
//            make.left.top.width.height.equalToSuperview()
//        }
    }
}

extension QuestionnaireBodyFatItemVM{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
//        let scale: CGFloat = 0.99
//        UIView.animate(withDuration: 0.1) {
//            self.transform = CGAffineTransform(scaleX: scale, y: scale)
//        }
        triggerImpact(feedbackGenerator, intensity: feedbackWeight)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
//        UIView.animate(withDuration: 0.1) {
//            self.transform = .identity
//        }
        if let touch = touches.first, self.bounds.contains(touch.location(in: self)) {
            triggerImpact(UIImpactFeedbackGenerator(style: .medium), intensity: 0.9)
            tapAction()
        }
    }
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesCancelled(touches, with: event)
//        UIView.animate(withDuration: 0.1) {
//            self.transform = .identity
//        }
//    }
    private func triggerImpact(_ generator: UIImpactFeedbackGenerator, intensity: CGFloat) {
        let now = Date().timeIntervalSince1970
        guard now - lastFeedbackTime > minimumFeedbackInterval else { return }
        generator.impactOccurred(intensity: intensity)
        lastFeedbackTime = now
    }
}
