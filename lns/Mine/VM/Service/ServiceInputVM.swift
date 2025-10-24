//
//  ServiceInputVM.swift
//  lns
//
//  Created by LNS2 on 2024/6/12.
//

import Foundation
import IQKeyboardManagerSwift

class ServiceInputVM: UIView {
    
    let selfHeight = kFitWidth(64)+WHUtils().getBottomSafeAreaHeight()
    private var lineH: CGFloat { textView.font?.lineHeight ?? 20 }
    private var maxTextHeight: CGFloat { ceil(lineH * 4) + 12 }   // 4 行 + 上下内边距
    private var minTextHeight: CGFloat { ceil(lineH * 1) + 12 }   // 1 行

    var imgChoiceBlock:(()->())?
    var textSendBlock:(()->())?
    var textDidInputBlock:((CGFloat)->())?
    
    // 新增：对外回调
    var chooseAlbumBlock:(()->())?
    var chooseCameraBlock:(()->())?

    private var panelShown = false
    private let panelHeight = kFitWidth(130)
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-selfHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        initUI()
        
        IQKeyboardManager.shared.enable = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(64)))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var textBgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(12), y: kFitWidth(8), width: SCREEN_WIDHT-kFitWidth(54)-kFitWidth(22), height: kFitWidth(40)))
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        vi.layer.cornerRadius = kFitWidth(20)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var textView: UITextView = {
        let text = UITextView(frame: CGRect(x: kFitWidth(8), y: kFitWidth(4),
                                                width: SCREEN_WIDHT - kFitWidth(60) - kFitWidth(38),
                                                height: kFitWidth(40)))
        text.backgroundColor = .clear
        text.delegate = self
        text.returnKeyType = .send
        text.font = .systemFont(ofSize: 14, weight: .regular)
        text.textContainerInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        text.isScrollEnabled = false
        return text
    }()
    lazy var addBgView: UIButton = {
//        let img = UIButton.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(12)-kFitWidth(48), y: kFitWidth(8), width: kFitWidth(27), height: kFitWidth(27)))
        let img = UIButton()
        img.setImage(UIImage(named: "service_img_add_icon"), for: .normal)
//        img.setBackgroundImage(createImageWithColor(color: WHColorWithAlpha(colorStr: "000000", alpha: 0.02)), for: .highlighted)
//        img.layer.cornerRadius = kFitWidth(8)
//        img.clipsToBounds = true
        
//        img.addTarget(self, action: #selector(imgTapAction), for: .touchUpInside)
        
        return img
    }()
    lazy var imgTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(imgTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var timeLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: kFitWidth(-15), width: SCREEN_WIDHT, height: kFitWidth(15)))
        lab.text = "客服工作时间：9:00 ~ 18:00（工作日）"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.2)
        lab.backgroundColor = .white
        lab.font = .systemFont(ofSize: 8, weight: .regular)
        lab.textAlignment = .center
        lab.isHidden = true
        
        return lab
    }()
    lazy var albumButton : PlanShareButton = {
        let btn = PlanShareButton.init(frame: CGRect.init(x: kFitWidth(27), y: kFitWidth(20), width: kFitWidth(62), height: kFitWidth(85)))
        btn.imgView.setImgLocal(imgName: "service_album_icon")
        btn.contenLab.text = "照片"
        btn.contenLab.textColor = .COLOR_GRAY_BLACK_45
        btn.labelColor = .COLOR_GRAY_BLACK_45
        btn.contenLab.font = .systemFont(ofSize: 12, weight: .medium)
        btn.tapBlock = {()in
            self.tapAlbum()
        }
        
        return btn
    }()
    lazy var cameraButton : PlanShareButton = {
        let btn = PlanShareButton.init(frame: CGRect.init(x: kFitWidth(115), y: kFitWidth(20), width: kFitWidth(62), height: kFitWidth(85)))
        btn.imgView.setImgLocal(imgName: "service_camera_icon")
        btn.contenLab.text = "视频"
        btn.contenLab.textColor = .COLOR_GRAY_BLACK_45
        btn.labelColor = .COLOR_GRAY_BLACK_45
        btn.contenLab.font = .systemFont(ofSize: 12, weight: .medium)
        btn.isHidden = true
        btn.tapBlock = {()in
            self.tapCamera()
        }
        
        return btn
    }()
    // 底部附件面板（相册/拍摄 + 关闭）
    private lazy var attachPanel: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.shadowColor = UIColor.black.cgColor
//        v.layer.shadowOpacity = 0.08
//        v.layer.shadowRadius = 10
        v.layer.shadowOffset = CGSize(width: 0, height: -2)
        v.isHidden = true

        v.addSubview(cameraButton)
        v.addSubview(albumButton)

        // 简单布局（不用 SnapKit 也行）
        let w = SCREEN_WIDHT
//        v.frame = CGRect(x: 0, y: kFitWidth(64), width: w, height: panelHeight)
        v.frame = CGRect(x: 0,
                            y: whiteView.frame.height - panelHeight,
                            width: w,
                            height: panelHeight)
        v.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]

        // 轻微分割线
        let line = UIView(frame: CGRect(x: 0, y: 0, width: w, height: 0.5))
        line.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06)
        v.addSubview(line)

        return v
    }()

}

extension ServiceInputVM{
    @objc func imgTapAction() {
//        if self.imgChoiceBlock != nil{
//            self.imgChoiceBlock!()
//        }
        textView.resignFirstResponder()
        toggleAttachPanel(show: !panelShown)
    }
    @objc private func tapAlbum() {
        hideAttachPanel()
        chooseAlbumBlock?()
    }

    @objc private func tapCamera() {
        hideAttachPanel()
        chooseCameraBlock?()
    }
    private func setAddButton(rotated: Bool) {
        let angle: CGFloat = rotated ? (.pi / 4) : 0   // 45°
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState]) {
            self.addBgView.transform = rotated ? CGAffineTransform(rotationAngle: angle) : .identity
        }
    }

    private func toggleAttachPanel(show: Bool) {
        guard panelShown != show else { return }
        panelShown = show

        let baseH = kFitWidth(64)
        let targetH = show ? (baseH + panelHeight) : baseH
        let oldBarH = whiteView.frame.height
        let delta   = targetH - oldBarH

        // 展开前：先把面板放到将要贴的底部 y（当前是 oldBarH）
        if show {
            attachPanel.isHidden = false
            attachPanel.alpha = 0
            attachPanel.transform = .identity
            attachPanel.frame.origin.y = oldBarH - panelHeight
            // 从下面滑入：预置一个向下的位移
            attachPanel.transform = CGAffineTransform(translationX: 0, y: panelHeight)
        }

        let angle: CGFloat = show ? (.pi / 4) : 0

        UIView.animate(withDuration: 0.28,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState]) {

            // 1) whiteView 高度变化
            var wv = self.whiteView.frame
            wv.size.height = targetH
            self.whiteView.frame = wv

            // 2) 整个输入条随之上顶/落下
            var selfF = self.frame
            selfF.origin.y -= delta
            selfF.size.height = targetH + WHUtils().getBottomSafeAreaHeight()
            self.frame = selfF

            // 3) 面板滑入/滑出（相对 bottom，不再“跳”）
            if show {
                self.attachPanel.alpha = 1
                self.attachPanel.transform = .identity
            } else {
                self.attachPanel.alpha = 0
                self.attachPanel.transform = CGAffineTransform(translationX: 0, y: self.panelHeight)
            }

            // 4) “＋”旋转
            self.addBgView.transform = show ? CGAffineTransform(rotationAngle: angle) : .identity

        } completion: { _ in
            if !show {
                self.attachPanel.isHidden = true
            }
            // 结束时把面板的 frame.y 固定到目标底部（targetH）
            self.attachPanel.transform = .identity
            self.attachPanel.frame.origin.y = self.whiteView.frame.height - self.panelHeight
        }
    }

    @objc func hideAttachPanel() {
        if panelShown == false { return }
        toggleAttachPanel(show: false)
    }
}
extension ServiceInputVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(textBgView)
        textBgView.addSubview(textView)
        whiteView.addSubview(addBgView)
        whiteView.addSubview(imgTapView)
        whiteView.addSubview(attachPanel)
        whiteView.addSubview(timeLabel)
        
//        textView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(8))
//            make.right.equalTo(kFitWidth(-8))
//            make.centerY.lessThanOrEqualToSuperview()
//        }
        addBgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(textView)
            make.width.height.equalTo(kFitWidth(27))
        }
        imgTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(addBgView)
            make.width.height.equalTo(kFitWidth(56))
        }
    }
}

extension ServiceInputVM{
    @objc func keyboardWillShow(notification: NSNotification) {
        self.hideAttachPanel()
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.textDidInputBlock != nil{
                self.textDidInputBlock!(keyboardSize.origin.y)
            }
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: keyboardSize.origin.y-kFitWidth(32))
            }completion: { t in
                
            }
        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.textDidInputBlock != nil{
            self.textDidInputBlock!(0)
        }
        UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
            self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT-kFitWidth(32))
        }completion: { t in
            
        }
    }
}

extension ServiceInputVM:UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == ""{
            return true
        }
        if text == "\n"{
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
                self.textSendBlock?()
                self.textView.text = ""             // 清空输入
                self.resetInputHeightToInitial()    // ← 复位高度
//                self.textView.resignFirstResponder()
            }
            return false
        }
        
        if text.isNineKeyBoard() {
            return true
        }else{
            if text.hasEmoji(){
                return false
            }
//            if text.hasEmoji() || text.containsEmoji() {
//                return false
//            }
        }

        if textView.textInputMode?.primaryLanguage == "emoji" || !((textView.textInputMode?.primaryLanguage) != nil){
            return false
        }
        if textView.text.count >= 400{
            return false
        }
        
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        // 目标高度（随内容变化，限制在 1~4 行之间）
        let fitting = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)).height
        let newH = max(minTextHeight, min(maxTextHeight, fitting))

        // 只有高度变化才调整
        let oldH = textView.frame.height
        guard abs(newH - oldH) > 0.5 else { return }

        // 调整 textView、高度容器、输入条整体高度
        var tvF = textView.frame
        tvF.size.height = newH
        textView.frame = tvF

        var bgF = textBgView.frame
        bgF.size.height = newH + kFitWidth(8) // 背景再高一点
        textBgView.frame = bgF

        var whiteF = whiteView.frame
        let baseBottomBar = kFitWidth(64)                 // 你的原始高度
        let targetBarH   = max(baseBottomBar, bgF.maxY + kFitWidth(8))
        let delta        = targetBarH - whiteF.height
        whiteF.size.height = targetBarH
        whiteView.frame = whiteF

        // 自身整体跟着变高（向上顶，不遮住底部安全区）
        var selfF = frame
        selfF.origin.y -= delta
        selfF.size.height += delta
        frame = selfF

        // 是否允许滚动
        textView.isScrollEnabled = (fitting > maxTextHeight)
    }

}
extension ServiceInputVM {

    /// 发送后把输入框和容器高度恢复到初始 1 行状态
    func resetInputHeightToInitial() {
        // 基准高度（与你现有逻辑保持一致）
        let baseBarH = kFitWidth(64)

        // 目标 textView 高度：1 行
        let targetTextH = minTextHeight   // 你前面定义的 1 行高度：ceil(lineH*1)+12

        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState]) {
            // textView
            var tv = self.textView.frame
            tv.size.height = targetTextH
            self.textView.frame = tv
            self.textView.isScrollEnabled = false

            // textBgView
            var bg = self.textBgView.frame
            bg.size.height = targetTextH + kFitWidth(8)
            self.textBgView.frame = bg

            // whiteView（输入条容器）高度回到 base
            let oldBarH = self.whiteView.frame.height
            var wv = self.whiteView.frame
            wv.size.height = baseBarH
            self.whiteView.frame = wv

            // 自身整体向下还原（与你之前的增高逻辑对称）
            let delta = baseBarH - oldBarH
            var selfF = self.frame
            selfF.origin.y -= delta    // 注意这里沿用你之前的公式
            selfF.size.height = baseBarH + WHUtils().getBottomSafeAreaHeight()
            self.frame = selfF
        }
    }
}
