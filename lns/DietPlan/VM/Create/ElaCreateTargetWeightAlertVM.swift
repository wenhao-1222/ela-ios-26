//
//  ElaCreateTargetWeightAlertVM.swift
//  lns
//
//  Created by LNS2 on 2026/3/11.
//


enum DietPlanTargetWeightAlertType {
    case healthRisk
    case bloodLipidGoal
}

struct DietPlanTargetWeightAlertPayload {
    let type: DietPlanTargetWeightAlertType
    let recommendedWeight: Double
}


class ElaCreateTargetWeightAlertVM: UIView {

    private var panelHeight: CGFloat {
        return kFitWidth(360) + WHUtils().getBottomSafeAreaHeight()
    }
    private var panelOriginY: CGFloat {
        return SCREEN_HEIGHT - panelHeight + kFitWidth(16)
    }

    var confirmBlock: (() -> ())?
    var cancelBlock: (() -> ())?

    private var targetDimAlpha: CGFloat {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark ? 0.55 : 0.25
        }
        return 0.25
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *),
           previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle,
           !isHidden {
            UIView.animate(withDuration: 0.2) {
                self.bgView.alpha = self.targetDimAlpha
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        isHidden = true
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var bgView: UIView = {
        let v = UIView(frame: bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = .COLOR_ALERT_BG_BLACK
        v.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(cancelAction))
        v.addGestureRecognizer(tap)
        return v
    }()

    private lazy var whiteView: UIView = {
        let vi = UIView(frame: CGRect(x: 0, y: panelOriginY, width: SCREEN_WIDHT, height: panelHeight))
        vi.layer.cornerRadius = kFitWidth(24)
        vi.clipsToBounds = true
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        let tap = UITapGestureRecognizer(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        return vi
    }()

    private lazy var closeImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "date_fliter_cancel_img")
        img.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(cancelAction))
        img.addGestureRecognizer(tap)
        return img
    }()

    private lazy var titleTopLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 17, weight: .medium)
        lab.textAlignment = .center
        lab.numberOfLines = 0
        return lab
    }()

    private lazy var titleHighlightLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 17, weight: .semibold)
        lab.textAlignment = .center
        lab.numberOfLines = 0
        return lab
    }()

    private lazy var tipsLabelOne: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_60
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        lab.textAlignment = .center
        lab.numberOfLines = 0
        return lab
    }()

    private lazy var tipsLabelTwo: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_60
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        lab.textAlignment = .center
        lab.numberOfLines = 0
        return lab
    }()

    private lazy var nextButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return btn
    }()

    private lazy var cancelButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("取消", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_60, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return btn
    }()
}

extension ElaCreateTargetWeightAlertVM {
    func showView(
        type: DietPlanTargetWeightAlertType,
        confirmBlock: (() -> ())?,
        cancelBlock: (() -> ())? = nil
    ) {
        self.confirmBlock = confirmBlock
        self.cancelBlock = cancelBlock
        refreshContent(type: type)

        isHidden = false
        bgView.isUserInteractionEnabled = false
        bgView.alpha = 0
        whiteView.transform = CGAffineTransform(translationX: 0, y: panelHeight)
        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: -kFitWidth(2))
            self.bgView.alpha = self.targetDimAlpha
        } completion: { _ in
            self.bgView.isUserInteractionEnabled = true
        }
        UIView.animate(withDuration: 0.25, delay: 0.4, options: .curveEaseInOut) {
            self.whiteView.transform = .identity
        }
    }

    func hiddenView(completion: (() -> ())? = nil) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.bgView.alpha = 0
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: self.panelHeight)
        } completion: { _ in
            self.isHidden = true
            completion?()
        }
    }

    @objc private func confirmAction() {
        let block = confirmBlock
        hiddenView {
            block?()
        }
    }

    @objc private func cancelAction() {
        let block = cancelBlock
        hiddenView {
            block?()
        }
    }

    @objc private func nothingToDo() {
    }

    private func refreshContent(type: DietPlanTargetWeightAlertType) {
        switch type {
        case .healthRisk:
            titleTopLabel.text = "请更新体重目标"
            titleHighlightLabel.text = "你填写的体重可能会不利于你的健康"
        case .bloodLipidGoal:
            titleTopLabel.text = "这个体重可能会"
            titleHighlightLabel.text = "不利于你达到降低血脂的目标"
        }
        tipsLabelOne.text = "你可以选择跳过这一步"
        tipsLabelTwo.text = "我们会为你推荐一个更合理的默认目标"
    }
}

private extension ElaCreateTargetWeightAlertVM {
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)

        whiteView.addSubview(closeImgView)
        whiteView.addSubview(titleTopLabel)
        whiteView.addSubview(titleHighlightLabel)
        whiteView.addSubview(tipsLabelOne)
        whiteView.addSubview(tipsLabelTwo)
        whiteView.addSubview(nextButton)
        whiteView.addSubview(cancelButton)

        setConstraint()
    }

    func setConstraint() {
        closeImgView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.width.height.equalTo(kFitWidth(28))
        }
        titleTopLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalTo(kFitWidth(30))
            make.right.equalTo(kFitWidth(-30))
            make.top.equalTo(kFitWidth(70))
        }
        titleHighlightLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalTo(titleTopLabel)
            make.right.equalTo(titleTopLabel)
            make.top.equalTo(titleTopLabel.snp.bottom).offset(kFitWidth(12))
        }
        tipsLabelOne.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalTo(titleTopLabel)
            make.right.equalTo(titleTopLabel)
            make.top.equalTo(titleHighlightLabel.snp.bottom).offset(kFitWidth(40))
        }
        tipsLabelTwo.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalTo(titleTopLabel)
            make.right.equalTo(titleTopLabel)
            make.top.equalTo(tipsLabelOne.snp.bottom).offset(kFitWidth(8))
        }
        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.top.equalTo(tipsLabelTwo.snp.bottom).offset(kFitWidth(50))
        }
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(nextButton.snp.bottom).offset(kFitWidth(12))
            make.left.right.equalTo(nextButton)
            make.height.equalTo(kFitWidth(44))
        }
    }
}
