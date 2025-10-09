//
//  LLMyTabbar.swift
//  swiftStudy01
//
//  Created by 刘恋 on 2019/6/6.
//  Copyright © 2019 刘恋. All rights reserved.
//

import UIKit

// 声明代理
protocol LLMyTabbarDelegate: NSObjectProtocol {
    func tabbarDidSelectedButtomFromto(tabbar: LLMyTabbar, from: Int, to: Int)
}

class LLMyTabbar: UIView {

    weak var delegate: LLMyTabbarDelegate?

    var nomarlButton = LLButton()
    var seletedButton = LLButton()
    var btnArr: [LLButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear // 玻璃必须透明

        NotificationCenter.default.addObserver(self, selector: #selector(gotoMainNotification), name: NSNotification.Name(rawValue: "gotoMain"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(gotoLogsNotification), name: NSNotification.Name(rawValue: "activePlan"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mineServiceMsgNotification), name: NSNotification.Name(rawValue: "serviceMsgUnRead"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mineServiceMsgReadNotification), name: NSNotification.Name(rawValue: "serviceMsgRead"), object: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc func gotoMainNotification() {
        DLLog(message: "跳转到首页")
        seletedButton.isSelected = false
        seletedButton.conentLab.textColor = .COLOR_TEXT_TITLE_0f1214
        seletedButton = btnArr[0]
        seletedButton.isSelected = true
        seletedButton.conentLab.textColor = .THEME
    }

    @objc func gotoLogsNotification() {
        DLLog(message: "跳转到日志")
        seletedButton.isSelected = false
        seletedButton.conentLab.textColor = .COLOR_TEXT_TITLE_0f1214
        seletedButton = btnArr[1]
        seletedButton.isSelected = true
        seletedButton.conentLab.textColor = .THEME
    }

    @objc func mineServiceMsgNotification() { btnArr.last?.redView.isHidden = false }

    @objc func mineServiceMsgReadNotification() {
        let btn = btnArr.last
        if UserInfoModel.shared.settingNewFuncRead && UserInfoModel.shared.newsListHasUnRead == false {
            btn?.redView.isHidden = true
        } else {
            btn?.redView.isHidden = false
        }
    }

    func addTabBarButtonWithItem(item: UITabBarItem) {
        let button = LLButton(type: .custom)
        addSubview(button)

        // 不再设置 UIButton 的标题，仅用自定义 conentLab
        // button.setTitle(item.title, for: .normal) // 🚫 删掉
        button.conentLab.text = item.title

        button.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        button.setTitleColor(.THEME, for: .selected)
        button.conentLab.textColor = .COLOR_TEXT_TITLE_0f1214

        button.setImage(item.image, for: .normal)
        button.setImage(item.selectedImage, for: .selected)

        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(handlePressDragEnter), for: .touchDown)

        btnArr.append(button)
    }

    @objc func handlePressDragEnter(_ sender: LLButton) {
        if seletedButton != sender {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
        }
    }

    @objc func buttonClick(_ sender: LLButton) {
        if (delegate?.responds(to: Selector(("tabbarDidSelectedButtomFromto"))) != nil) {
            delegate?.tabbarDidSelectedButtomFromto(tabbar: self, from: seletedButton.tag, to: sender.tag)
        }
        seletedButton.isSelected = false
        seletedButton.conentLab.textColor = .COLOR_TEXT_TITLE_0f1214
        sender.isSelected = true
        seletedButton = sender
        seletedButton.conentLab.textColor = .THEME
    }

    func centerClick() {
        if (delegate?.responds(to: Selector(("tabbarDidSelectedButtomFromto"))) != nil) {
            delegate?.tabbarDidSelectedButtomFromto(tabbar: self, from: seletedButton.tag, to: 1)
        }
        seletedButton = btnArr[1]
        seletedButton.isSelected = true
        seletedButton.conentLab.textColor = .THEME
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // ✅ 只布局我们自己的按钮，避免把非按钮子视图算进去
        let buttons = btnArr
        guard !buttons.isEmpty else { return }

        let count = CGFloat(buttons.count)
        let width = bounds.width / count
        let height = bounds.height

        for (idx, button) in buttons.enumerated() {
            let x = CGFloat(idx) * width
            button.frame = CGRect(x: x, y: 0, width: width, height: height)

            // 图片与文字的内排版交给 LLButton（重写了 imageRect/titleRect + conentLab）
            button.tag = idx

            if idx == 0 && seletedButton == LLButton() {
                seletedButton = button
                seletedButton.isSelected = true
                seletedButton.conentLab.textColor = .THEME
            }
        }
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // 保证点击命中到子按钮
        for vi in subviews {
            let tp = vi.convert(point, from: self)
            if vi.bounds.contains(tp) { return true }
        }
        return false
    }
}
