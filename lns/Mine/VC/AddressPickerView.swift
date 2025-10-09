//
//  AddressPickerView.swift
//  lns
//
//  Created by Elavatine on 2025/9/12.
//

import UIKit

//public final class AddressPickerViewController: UIViewController {
class AddressPickerView: FeedBackView {

    public var onConfirm: ((AddressModel) -> Void)?
    public var onCancel: (() -> Void)?

    private let bgView = UIView()
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let headerStack = UIStackView()
    private let pickerView = UIPickerView()
    private let confirmButton = UIButton(type: .system)

    private var provinces: [AreaNode] = []
    private var cities: [AreaNode] = []
    private var areas: [AreaNode] = []

    private var provinceIndex = 0
    private var cityIndex = 0
    private var areaIndex = 0

    private let defaultAddress: AddressModel?

    public init(defaultAddress: AddressModel? = nil) {
        self.defaultAddress = defaultAddress
//        super.init(nibName: nil, bundle: nil)
//        modalPresentationStyle = .overFullScreen
//        modalTransitionStyle = .crossDissolve
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.isHidden = true
        self.backgroundColor = .clear
//    }
//    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

//    public override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        do {
            try AddressDataLoader.shared.loadIfNeeded()
            provinces = AddressDataLoader.shared.provinces
        } catch { assertionFailure("地址数据加载失败：\(error)") }

        applyDefaultSelection()
        buildUI()
        layoutUI()
        pickerView.reloadAllComponents()
        pickerView.selectRow(provinceIndex, inComponent: 0, animated: false)
        pickerView.selectRow(cityIndex, inComponent: 1, animated: false)
        pickerView.selectRow(areaIndex, inComponent: 2, animated: false)
//        animateIn()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func applyDefaultSelection() {
//        if let def = defaultAddress,
//           let pIdx = provinces.firstIndex(where: { $0.code == def.provinceCode }) {
//            provinceIndex = pIdx
//        }
        guard !provinces.isEmpty else { return }

        if let def = defaultAddress {
            if let pIdx = provinces.firstIndex(where: { $0.code == def.provinceCode }),
               !def.provinceCode.isEmpty {
                provinceIndex = pIdx
            } else if let pIdx = provinces.firstIndex(where: { $0.name == def.provinceName }) {
                provinceIndex = pIdx
            }
        }
        cities = provinces[provinceIndex].children ?? []
//        if let def = defaultAddress,
//           let cIdx = cities.firstIndex(where: { $0.code == def.cityCode }) {
//            cityIndex = cIdx
//        }
        if let def = defaultAddress {
            if let cIdx = cities.firstIndex(where: { $0.code == def.cityCode }),
               !def.cityCode.isEmpty {
                cityIndex = cIdx
            } else if let cIdx = cities.firstIndex(where: { $0.name == def.cityName }) {
                cityIndex = cIdx
            }
        }
        areas = cities[safe: cityIndex]?.children ?? []
//        if let def = defaultAddress,
//           let aIdx = areas.firstIndex(where: { $0.code == def.areaCode }) {
//            areaIndex = aIdx
//        }
        if let def = defaultAddress {
            if let aIdx = areas.firstIndex(where: { $0.code == def.areaCode }),
               !def.areaCode.isEmpty {
                areaIndex = aIdx
            } else if let aIdx = areas.firstIndex(where: { $0.name == def.areaName }) {
                areaIndex = aIdx
            }
        }
    }

    private func buildUI() {
        addSubview(bgView)
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        bgView.alpha = 0
        bgView.frame = bounds
        let tap = UITapGestureRecognizer(target: self, action: #selector(cancelTapped))
        bgView.addGestureRecognizer(tap)
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        if #available(iOS 11.0, *) {
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        containerView.layer.masksToBounds = true
//        view.addSubview(containerView)
        addSubview(containerView)

        titleLabel.text = "所在地区"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black

        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        closeButton.tintColor = .darkGray
//        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        pickerView.dataSource = self
        pickerView.delegate = self

        headerStack.axis = .horizontal
        headerStack.distribution = .fillEqually
        ["省份","城市","区县"].forEach {
            let l = UILabel()
            l.text = $0
            l.textColor = UIColor.darkGray
            l.font = .systemFont(ofSize: 14, weight: .medium)
            l.textAlignment = .center
            headerStack.addArrangedSubview(l)
        }

        confirmButton.setTitle("继续", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        confirmButton.backgroundColor = .THEME
        confirmButton.layer.cornerRadius = 22
        confirmButton.layer.masksToBounds = true
        confirmButton.enablePressEffect()
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(headerStack)
        containerView.addSubview(pickerView)
        containerView.addSubview(confirmButton)
        
        self.containerView.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
    }

    private func layoutUI() {
        containerView.snp.makeConstraints { make in
//            make.left.equalTo(16); make.right.equalTo(-16)
//            make.centerY.equalToSuperview()
            make.left.right.bottom.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(16); make.left.equalTo(16)
        }
        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(-12)
            make.width.height.equalTo(32)
        }
        headerStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(24)
        }
        pickerView.snp.makeConstraints { make in
            make.top.equalTo(headerStack.snp.bottom).offset(2)
            make.left.right.equalToSuperview()
            make.height.equalTo(180)
        }
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(pickerView.snp.bottom).offset(12)
            make.left.equalTo(16); make.right.equalTo(-16)
            make.height.equalTo(44)
//            make.bottom.equalTo(-16)
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-16)
        }
    }
    
    public func show(in view: UIView) {
        frame = view.bounds
        view.addSubview(self)
        self.snp.makeConstraints { make in make.edges.equalToSuperview() }
        isHidden = false
        animateIn()
    }

    @objc private func cancelTapped() {
        hide { [weak self] in self?.onCancel?() }
    }

    public func hide(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.bgView.alpha = 0
//            self.containerView.alpha = 0
//            self.containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.containerView.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        } completion: { _ in
            self.isHidden = true
            self.removeFromSuperview()
            completion?()
        }
    }


    private func animateIn() {
//        containerView.transform = CGAffineTransform(translationX: 0, y: 40)
        bgView.alpha = 0
        containerView.alpha = 1
//        let h = containerView.bounds.height
//        containerView.transform = CGAffineTransform(translationX: 0, y: h)
////        containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//        UIView.animate(withDuration: 0.45,
//                       delay: 0.02,
//                       usingSpringWithDamping: 0.88,
//                       initialSpringVelocity: 0.1,
//                       options: [.curveEaseOut, .allowUserInteraction]) {
//            self.bgView.alpha = 0.45
//            self.containerView.alpha = 1
//            self.containerView.transform = .identity
//        }
//        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseOut]) {
//            self.containerView.transform = .identity
//            self.containerView.alpha = 1
//        }
//        view.layoutIfNeeded()
//        let h = containerView.bounds.height
//        containerView.transform = CGAffineTransform(translationX: 0, y: h)
        UIView.animate(withDuration: 0.45,
                       delay: 0,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut]) {
            self.bgView.alpha = 1
            self.containerView.transform = CGAffineTransform(translationX: 0, y: -2)
        } completion: { _ in
            UIView.animate(withDuration: 0.25) {
                self.containerView.transform = .identity
            }
        }
    }

//    @objc private func closeTapped() {
//        dismiss(animated: true) { [weak self] in self?.onCancel?() }
//    }

    @objc private func confirmTapped() {
        let p = provinces[provinceIndex]
        let c = cities[safe: cityIndex]
        let a = areas[safe: areaIndex]
        let model = AddressModel()
        model.provinceCode = p.code; model.provinceName = p.name
        model.cityCode = c?.code ?? ""; model.cityName = c?.name ?? ""
        model.areaCode = a?.code ?? ""; model.areaName = a?.name ?? ""
//        dismiss(animated: true) { [weak self] in self?.onConfirm?(model) }
        hide { [weak self] in self?.onConfirm?(model) }
    }
}

extension AddressPickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int { 3 }
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component { case 0: return provinces.count; case 1: return cities.count; default: return areas.count }
    }
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        pickerView.bounds.width / 3.0
    }
//    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat { 36 }
//    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        switch component { case 0: return provinces[row].name
//        case 1: return cities[safe: row]?.name
//        default: return areas[safe: row]?.name }
//    }
    // 调高行高，给两行留空间
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 52 // 你也可以用 48~60 之间按需调整
    }

    public func pickerView(_ pickerView: UIPickerView,
                           viewForRow row: Int,
                           forComponent component: Int,
                           reusing view: UIView?) -> UIView {

        let label: UILabel
        if let v = view as? UILabel {
            label = v
        } else {
            label = UILabel()
            label.textAlignment = .center
            label.numberOfLines = 2                      // 允许两行
            label.lineBreakMode = .byWordWrapping
            label.adjustsFontSizeToFitWidth = true       // 如果两行仍放不下会尽量缩小
            label.minimumScaleFactor = 0.8               // 缩小下限（可调）
        }

        // 计算当前列的宽度，给 label 一个合适的 frame（UIPickerView 不用 Auto Layout）
        let compWidth = pickerView.rowSize(forComponent: component).width
        let compHeight = pickerView.rowSize(forComponent: component).height
        label.frame = CGRect(x: 0, y: 0, width: compWidth - 12, height: compHeight)

        // 设置文本
        let text: String
        switch component {
        case 0: text = provinces[row].name
        case 1: text = cities[safe: row]?.name ?? ""
        default: text = areas[safe: row]?.name ?? ""
        }
        label.font = .systemFont(ofSize: 16, weight: .regular)

        // 简单的自适配：特别长时稍微减小字体
        if text.count > 12 { label.font = .systemFont(ofSize: 15) }
        if text.count > 16 { label.font = .systemFont(ofSize: 14) }

        label.text = text
        return label
    }
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            provinceIndex = row
            cities = provinces[row].children ?? []; cityIndex = 0
            areas = cities.first?.children ?? []; areaIndex = 0
            pickerView.reloadComponent(1); pickerView.reloadComponent(2)
            pickerView.selectRow(0, inComponent: 1, animated: true)
            pickerView.selectRow(0, inComponent: 2, animated: true)
        case 1:
            cityIndex = row
            areas = cities[safe: row]?.children ?? []; areaIndex = 0
            pickerView.reloadComponent(2)
            pickerView.selectRow(0, inComponent: 2, animated: true)
        case 2: areaIndex = row
        default: break
        }
    }
}

private extension Array {
    subscript (safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
