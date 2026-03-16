//
//  DietPlanCreateManualTargetVM.swift
//  lns
//
//  Created by Codex on 2026/3/16.
//

import SnapKit

class DietPlanCreateManualTargetVM: UIView {

    var backTapBlock: (() -> ())?
    var saveTapBlock: ((String) -> ())?

    private var keyboardBottomOffset: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .COLOR_BG_F2
        isHidden = true
        initUI()
        observeKeyboard()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    lazy var backButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "habit_guide_back_icon"), for: .normal)
        btn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return btn
    }()

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "手动编辑目标"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    lazy var inputContainer: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(12)
        vi.layer.borderWidth = 1
        vi.layer.borderColor = UIColor.THEME.cgColor
        vi.clipsToBounds = true
        return vi
    }()

    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.textColor = .COLOR_TEXT_TITLE_0f1214
        tf.font = .systemFont(ofSize: 16, weight: .regular)
        tf.keyboardType = .numberPad
        tf.tintColor = .THEME
        tf.delegate = self
        tf.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        return tf
    }()

    lazy var clearButton: UIButton = {
        let btn = UIButton(type: .custom)
        if let image = UIImage(systemName: "xmark.circle.fill") {
            btn.setImage(image, for: .normal)
            btn.tintColor = .COLOR_TEXT_TITLE_0f1214_20
        }
        btn.isHidden = true
        btn.addTarget(self, action: #selector(clearTapAction), for: .touchUpInside)
        return btn
    }()

    lazy var saveButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("保存目标", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        btn.isEnabled = false
        return btn
    }()

    private var saveButtonBottomConstraint: Constraint?
}

extension DietPlanCreateManualTargetVM {
    func initUI() {
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(inputContainer)
        inputContainer.addSubview(textField)
        inputContainer.addSubview(clearButton)
        addSubview(saveButton)

        backButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12.5))
            make.top.equalTo(statusBarHeight + kFitWidth(5))
            make.width.height.equalTo(kFitWidth(35))
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(72))
        }

        inputContainer.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(58))
            make.height.equalTo(kFitWidth(44))
        }

        textField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.bottom.equalToSuperview()
            make.right.equalTo(clearButton.snp.left).offset(kFitWidth(-12))
        }

        clearButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(kFitWidth(-14))
            make.width.height.equalTo(kFitWidth(24))
        }

        saveButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(44))
            self.saveButtonBottomConstraint = make.bottom.equalTo(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(10))).constraint
        }
    }

    func configure(initialValue: String) {
        textField.text = initialValue
        updateSaveButtonState()
        clearButton.isHidden = initialValue.isEmpty
    }

    func focusInput() {
        textField.becomeFirstResponder()
    }

    func resignInput() {
        textField.resignFirstResponder()
    }

    func observeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func updateSaveButtonState() {
        let value = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        saveButton.isEnabled = !value.isEmpty
        clearButton.isHidden = value.isEmpty
    }

    @objc func textDidChange() {
        let raw = textField.text ?? ""
        let filtered = raw.filter { $0.isNumber }
        if filtered != raw {
            textField.text = filtered
        }
        updateSaveButtonState()
    }

    @objc func clearTapAction() {
        textField.text = ""
        updateSaveButtonState()
    }

    @objc func backAction() {
        resignInput()
        backTapBlock?()
    }

    @objc func saveAction() {
        let value = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !value.isEmpty else {
            return
        }
        resignInput()
        saveTapBlock?(value)
    }

    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        else {
            return
        }

        let keyboardFrame = convert(frameValue.cgRectValue, from: nil)
        let overlap = max(bounds.maxY - keyboardFrame.minY, 0)
        keyboardBottomOffset = overlap > 0 ? overlap + kFitWidth(12) : 0
        saveButtonBottomConstraint?.update(offset: -(keyboardBottomOffset + WHUtils().getBottomSafeAreaHeight() + kFitWidth(10)))

        UIView.animate(withDuration: duration.doubleValue) {
            self.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
            return
        }
        keyboardBottomOffset = 0
        saveButtonBottomConstraint?.update(offset: -(WHUtils().getBottomSafeAreaHeight() + kFitWidth(10)))
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }
    }
}

extension DietPlanCreateManualTargetVM: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignInput()
        return true
    }
}
