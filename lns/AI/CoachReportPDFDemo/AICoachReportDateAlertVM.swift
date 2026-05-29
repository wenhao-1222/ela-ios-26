//
//  AICoachReportDateAlertVM.swift
//  lns
//
//  Created by Codex on 2026/4/7.
//

import SnapKit
import UIKit

final class AICoachReportDateAlertVM: UIView, UIPickerViewDelegate, UIPickerViewDataSource {

    var confirmBlock: ((AICoachReportListItem) -> Void)?

    private let pickerHeight = min(kFitWidth(220), SCREEN_HEIGHT * 0.32)

    private var items: [AICoachReportListItem] = []
    private var selectedIndex: Int = 0

    private var whiteViewHeight: CGFloat {
        let safeBottom = WHUtils().getBottomSafeAreaHeight()
        return kFitWidth(70) + pickerHeight + kFitWidth(104) + safeBottom
    }

    private var targetDimAlpha: CGFloat {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark ? 0.55 : 0.25
        } else {
            return 0.25
        }
    }

    private var whiteViewHeightConstraint: Constraint?

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isHidden = true
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else { return }
        guard isHidden == false else { return }
        UIView.animate(withDuration: 0.2) {
            self.bgView.alpha = self.targetDimAlpha
        }
    }

    private lazy var bgView: UIView = {
        let view = UIView(frame: bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = .COLOR_ALERT_BG_BLACK
        view.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenSelf))
        view.addGestureRecognizer(tap)
        return view
    }()

    private lazy var whiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = kFitWidth(20)
        view.clipsToBounds = true
        if #available(iOS 13.0, *) {
            view.layer.cornerCurve = .continuous
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(nothingToDo))
        view.addGestureRecognizer(tap)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "选择报告"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .left
        return label
    }()

    private lazy var closeButton: ElaExpandedTapButton = {
        let button = ElaExpandedTapButton(type: .custom)
        button.hitTestEdgeInsets = .init(top: -20, left: -20, bottom: -20, right: -20)
        button.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
        button.addTarget(self, action: #selector(hiddenSelf), for: .touchUpInside)
        return button
    }()

    private lazy var closeButtonVisibleTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeButtonVisibleTapAction(_:)))
        tap.delegate = self
        return tap
    }()

    private lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .clear
        return picker
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("确定", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = .THEME
        button.layer.cornerRadius = kFitWidth(28)
        button.clipsToBounds = true
        button.enablePressEffect()
        button.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return button
    }()
}

extension AICoachReportDateAlertVM {
    func update(items: [AICoachReportListItem], selectedReportId: String) {
        self.items = items
        if let index = items.firstIndex(where: { $0.reportId == selectedReportId }) {
            selectedIndex = index
        } else {
            selectedIndex = 0
        }
        pickerView.reloadAllComponents()
        if items.isEmpty == false {
            pickerView.selectRow(selectedIndex, inComponent: 0, animated: false)
        }
        confirmButton.isEnabled = items.isEmpty == false
        confirmButton.alpha = items.isEmpty ? 0.5 : 1
        updateLayout()
    }

    func showSelf() {
        guard items.isEmpty == false else { return }

        isHidden = false
//        bgView.isUserInteractionEnabled = false
        updateLayout()

        whiteView.transform = CGAffineTransform(translationX: 0, y: whiteViewHeight)
        bgView.alpha = 0

        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: -kFitWidth(2))
            self.bgView.alpha = self.targetDimAlpha
        } completion: { _ in
//            self.bgView.isUserInteractionEnabled = true
        }

        UIView.animate(withDuration: 0.25, delay: 0.4, options: [.curveEaseInOut, .allowUserInteraction]) {
            self.whiteView.transform = .identity
        }
    }

    @objc func hiddenSelf() {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseIn, .beginFromCurrentState]) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: self.whiteViewHeight)
            self.bgView.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
    }
}

private extension AICoachReportDateAlertVM {
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        addGestureRecognizer(closeButtonVisibleTapGesture)

        whiteView.addSubview(titleLabel)
        whiteView.addSubview(closeButton)
        whiteView.addSubview(pickerView)
        whiteView.addSubview(confirmButton)

        whiteView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            whiteViewHeightConstraint = make.height.equalTo(whiteViewHeight).constraint
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(20))
            make.top.equalToSuperview().offset(kFitWidth(18))
            make.height.equalTo(kFitWidth(28))
        }

        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-kFitWidth(16))
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(kFitWidth(28))
        }

        pickerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(20))
            make.right.equalToSuperview().offset(-kFitWidth(20))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(22))
            make.height.equalTo(pickerHeight)
        }

        confirmButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(20))
            make.right.equalToSuperview().offset(-kFitWidth(20))
            make.bottom.equalToSuperview().offset(-WHUtils().getBottomSafeAreaHeight() - kFitWidth(16))
            make.height.equalTo(kFitWidth(56))
        }
    }

    func updateLayout() {
        whiteViewHeightConstraint?.update(offset: whiteViewHeight)
        layoutIfNeeded()
    }

    @objc func confirmAction() {
        guard items.indices.contains(selectedIndex) else {
            hiddenSelf()
            return
        }
        confirmBlock?(items[selectedIndex])
        hiddenSelf()
    }

    @objc func nothingToDo() {}

    @objc func closeButtonVisibleTapAction(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }
        hiddenSelf()
    }

    func closeButtonVisibleHitFrame() -> CGRect {
        let sourceLayer = whiteView.layer.presentation() ?? whiteView.layer
        return sourceLayer.convert(closeButton.frame.insetBy(dx: -20, dy: -20), to: layer)
    }
}

extension AICoachReportDateAlertVM: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer === closeButtonVisibleTapGesture else { return true }
        guard isHidden == false, closeButton.isHidden == false, closeButton.alpha > 0.01 else { return false }
        return closeButtonVisibleHitFrame().contains(touch.location(in: self))
    }
}

extension AICoachReportDateAlertVM {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        max(items.count, 1)
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        kFitWidth(44)
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        SCREEN_WIDHT - kFitWidth(40)
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8

        if items.isEmpty {
            label.text = "暂无报告"
//            label.textColor = .COLOR_TEXT_TITLE_0f1214_50
            label.font = .systemFont(ofSize: 17, weight: .regular)
            return label
        }

        let item = items[row]
        let isSelected = row == selectedIndex
        label.text = item.pickerDateRangeText
        label.font = .systemFont(ofSize: 16, weight: .semibold)
//        label.textColor = isSelected ? .THEME : .COLOR_TEXT_TITLE_0f1214_50
//        label.font = .systemFont(ofSize: 16, weight: isSelected ? .semibold : .regular)
//        if isSelected {
            setUpPickerStyleRowStyle(row: row, component: component)
//        }
        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard items.indices.contains(row) else { return }
        selectedIndex = row
//        pickerView.reloadAllComponents()
//        setUpPickerStyleRowStyle(row: row, component: component)
    }

    func setUpPickerStyleRowStyle(row:Int,component:Int) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            let label = self.pickerView.view(forRow: row, forComponent: component) as? UILabel
            if label != nil {
                label?.textColor = .THEME
//                label?.font = .systemFont(ofSize: 17, weight: .semibold)
            }
        })
    }
}
