//
//  OverSeaMsgVC.swift
//  lns
//  海外清关信息页面
//  Created by LNS2 on 2025/12/15.
//
import UIKit
import MCToast

final class OverSeaMsgVC: WHBaseViewVC {
    
    public var msgAuthendBlock:(()->())?

    // MARK: - Config
    private let nameMaxLength = 50
    private let idMaxLength = 18
    private let middleDot = "·"
    

    // MARK: - Life
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bindActions()
    }

    // MARK: - UI
    lazy var bgBottomView: UIView = {
        let vi = UIView(frame: CGRect(x: 0,
                                      y: getNavigationBarHeight() + kFitWidth(1),
                                      width: SCREEN_WIDHT,
                                      height: kFitWidth(169)))
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.isUserInteractionEnabled = true
        return vi
    }()

    lazy var nameLab: UILabel = {
        let lab = UILabel()
        lab.text = "姓名"
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        return lab
    }()

    lazy var nameText: UITextField = {
        let text = UITextField()
        text.placeholder = "请输入真实姓名"
        text.textColor = .COLOR_TEXT_TITLE_0f1214
        text.font = .systemFont(ofSize: 14, weight: .regular)
        text.delegate = self
        text.returnKeyType = .next
        text.textContentType = nil
        text.autocorrectionType = .no
        text.spellCheckingType = .no
        return text
    }()

    lazy var lineViewOne: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LINE_F0
        return vi
    }()

    lazy var idCardLab: UILabel = {
        let lab = UILabel()
        lab.text = "身份证号"
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        return lab
    }()

    lazy var idCardText: UITextField = {
        let text = UITextField()
        text.keyboardType = .numberPad
        text.placeholder = "请输入18位身份证号码"
        text.textColor = .COLOR_TEXT_TITLE_0f1214
        text.font = .systemFont(ofSize: 14, weight: .regular)
        text.delegate = self
        text.returnKeyType = .done
        text.textContentType = nil
        text.autocorrectionType = .no
        text.spellCheckingType = .no
        text.autocapitalizationType = .allCharacters
        return text
    }()

    lazy var lineViewTwo: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LINE_F0
        return vi
    }()

    lazy var tipsLab: UILabel = {
        let lab = UILabel()
        lab.text = "你的信息将被严格保密，仅用于海关清关"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        return lab
    }()
    lazy var saveView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var saveButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("保存", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
//        btn.isEnabled = false
        btn.backgroundColor = .COLOR_BUTTON_DISABLE_BG_THEME
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        
        btn.addTarget(self, action: #selector(onSave), for: .touchUpInside)
        return btn
    }()
}

// MARK: - UI Layout
extension OverSeaMsgVC {
    func initUI() {
        initNavi(titleStr: "添加清关信息")
        self.navigationView.backgroundColor = .COLOR_CARD_BG_WHITE
        view.backgroundColor = .COLOR_BG_F2

        view.addSubview(bgBottomView)
        view.addSubview(saveView)
        bgBottomView.addSubview(nameLab)
        bgBottomView.addSubview(nameText)
        bgBottomView.addSubview(lineViewOne)
        bgBottomView.addSubview(idCardLab)
        bgBottomView.addSubview(idCardText)
        bgBottomView.addSubview(lineViewTwo)
        bgBottomView.addSubview(tipsLab)
        saveView.addSubview(saveButton)

        setConstrait()

        // 身份证键盘加工具条：X + 完成
        idCardText.inputAccessoryView = makeIDAccessoryToolbar()
    }

    func setConstrait() {
        nameLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(15))
            make.height.equalTo(kFitWidth(51))
        }
        nameText.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(102))
            make.top.height.equalTo(nameLab)
            make.right.equalTo(kFitWidth(-16))
        }
        lineViewOne.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
            make.bottom.equalTo(nameLab)
        }
        idCardLab.snp.makeConstraints { make in
            make.left.height.equalTo(nameLab)
            make.top.equalTo(lineViewOne.snp.bottom)
        }
        idCardText.snp.makeConstraints { make in
            make.left.height.equalTo(nameText)
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(idCardLab)
        }
        lineViewTwo.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(lineViewOne)
            make.bottom.equalTo(idCardLab)
        }
        tipsLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(52))
            make.bottom.equalToSuperview()
        }
        let viewHeight = self.getBottomSafeAreaHeight() > 0 ? (kFitWidth(55) + self.getBottomSafeAreaHeight()) : kFitWidth(66)
        saveView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(viewHeight)
        }
        saveButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(22))
            make.right.equalTo(kFitWidth(-22))
            make.height.equalTo(kFitWidth(44))
            make.top.equalTo(kFitWidth(11))
        }
    }
}

extension OverSeaMsgVC {
    func sendIdVerifyRequest() {
        MCToast.mc_loading()
        let param = ["legalName":nameText.text,
                     "identifyNum":idCardText.text]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_id_verify, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendIdVerifyRequest:\(dataObj)")
            
            self.msgAuthendBlock?()
            self.backTapAction()
        }
    }
}

// MARK: - Actions / Bind
extension OverSeaMsgVC {

    private func bindActions() {
        nameText.addTarget(self, action: #selector(nameEditingChanged), for: .editingChanged)
        idCardText.addTarget(self, action: #selector(idEditingChanged), for: .editingChanged)

        // 你如果有导航栏右侧按钮方法，可在这里加“保存”
        // setRightNavi(title: "保存", target: self, action: #selector(onSave))
    }

    @objc private func onSave() {
        let name = normalizeName(nameText.text ?? "")
        let idNo = normalizeID(idCardText.text ?? "")

        guard !name.isEmpty else {
            MCToast.mc_text("请输入真实姓名")
            return
        }
        guard idNo.count == idMaxLength else {
            MCToast.mc_text("请输入18位身份证号")
            return
        }
        guard isValidChineseID18(idNo) else {
            MCToast.mc_text("身份证号格式或校验不正确")
            return
        }

        // TODO: 提交给后端
//        MCToast.mc_text("保存成功")
        self.sendIdVerifyRequest()
    }

    // MARK: - Name sanitize
    @objc private func nameEditingChanged() {
        // 有拼写/联想态（markedText）时不要动，避免中文输入法体验炸裂
        if nameText.markedTextRange != nil { return }

        let cursorOffset = nameText.offset(from: nameText.endOfDocument,
                                           to: nameText.selectedTextRange?.end ?? nameText.endOfDocument)

        let cleaned = normalizeName(nameText.text ?? "")
        if cleaned != nameText.text {
            nameText.text = cleaned
            if let target = nameText.position(from: nameText.endOfDocument, offset: cursorOffset) {
                nameText.selectedTextRange = nameText.textRange(from: target, to: target)
            }
        }
    }

    private func normalizeName(_ raw: String) -> String {
        // 1) 把常见“点”统一成“·”
        let dotVariants: Set<Character> = ["·", "•", "・", "･", ".", "．", "。", "∙", "⋅"]
        var s = raw.map { dotVariants.contains($0) ? Character(middleDot) : $0 }
            .reduce(into: "") { $0.append($1) }

        // 2) 只保留：汉字 + ·
        s = s.replacingRegex(pattern: "[^\\p{Han}·]", with: "")

        // 3) 合并连续 ·
        while s.contains("··") { s = s.replacingOccurrences(of: "··", with: "·") }

        // 4) 去掉首尾 ·
        s = s.trimmingCharacters(in: CharacterSet(charactersIn: "·"))

        // 5) 截断长度
        if s.count > nameMaxLength { s = String(s.prefix(nameMaxLength)) }
        return s
    }

    // MARK: - ID sanitize
    @objc private func idEditingChanged() {
        if idCardText.markedTextRange != nil { return }

        let cursorOffset = idCardText.offset(from: idCardText.endOfDocument,
                                             to: idCardText.selectedTextRange?.end ?? idCardText.endOfDocument)

        let cleaned = normalizeID(idCardText.text ?? "")
        if cleaned != idCardText.text {
            idCardText.text = cleaned
            if let target = idCardText.position(from: idCardText.endOfDocument, offset: cursorOffset) {
                idCardText.selectedTextRange = idCardText.textRange(from: target, to: target)
            }
        }
    }
    func judgeButtonStatus() {
//        if idCardText.text?.count == 18 && nameText.text?.count ?? 0 > 0{
//            self.saveButton.isEnabled = true
//        }else{
//            self.saveButton.isEnabled = false
//        }
    }

    private func normalizeID(_ raw: String) -> String {
        // 只保留数字和 X/x
        var s = raw.uppercased().replacingRegex(pattern: "[^0-9X]", with: "")
        if s.count > idMaxLength { s = String(s.prefix(idMaxLength)) }

        // 规则：前17位必须数字；X只能出现在第18位
        if s.contains("X") {
            // 只允许最后一位是 X
            if let idx = s.firstIndex(of: "X") {
                let pos = s.distance(from: s.startIndex, to: idx)
                if pos != 17 {
                    // 把非末位的 X 删除
                    s.remove(at: idx)
                }
            }
            // 可能有多个 X：只保留最后一位那个（且必须在末尾）
            while s.dropLast().contains("X") {
                if let bad = s.dropLast().firstIndex(of: "X") {
                    s.remove(at: bad)
                } else { break }
            }
        }

        // 如果长度 >= 18，确保前17位都是数字（多余的非数字已经被过滤了）
        if s.count >= 18 {
            let first17 = String(s.prefix(17))
            if first17.replacingRegex(pattern: "[0-9]", with: "").isEmpty == false {
                // 理论上不会进来（因为前面已经过滤），保底
                s = first17.replacingRegex(pattern: "[^0-9]", with: "") + String(s.suffix(1))
            }
        }

        return s
    }

    // MARK: - ID validation
    private func isValidChineseID18(_ id: String) -> Bool {
        guard id.count == 18 else { return false }

        let upper = id.uppercased()
        let first17 = String(upper.prefix(17))
        let last1 = String(upper.suffix(1))

        // 前17位必须是数字
        guard first17.replacingRegex(pattern: "^[0-9]{17}$", with: "") == "" else { return false }
        // 末位必须是数字或X
        guard last1.replacingRegex(pattern: "^[0-9X]$", with: "") == "" else { return false }

        // 出生日期校验（YYYYMMDD）
        let yyyy = String(upper[upper.index(upper.startIndex, offsetBy: 6)..<upper.index(upper.startIndex, offsetBy: 10)])
        let mm   = String(upper[upper.index(upper.startIndex, offsetBy: 10)..<upper.index(upper.startIndex, offsetBy: 12)])
        let dd   = String(upper[upper.index(upper.startIndex, offsetBy: 12)..<upper.index(upper.startIndex, offsetBy: 14)])

        guard isValidDate(year: yyyy, month: mm, day: dd) else { return false }

        // 校验位（ISO 7064 MOD 11-2）
        let weights = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
        let mapping = ["1","0","X","9","8","7","6","5","4","3","2"]

        var sum = 0
        for (i, ch) in first17.enumerated() {
            guard let d = Int(String(ch)) else { return false }
            sum += d * weights[i]
        }
        let mod = sum % 11
        let check = mapping[mod]
        return check == last1
    }

    private func isValidDate(year: String, month: String, day: String) -> Bool {
        guard let y = Int(year), let m = Int(month), let d = Int(day) else { return false }
        guard (1900...2100).contains(y), (1...12).contains(m), (1...31).contains(d) else { return false }

        var comp = DateComponents()
        comp.year = y
        comp.month = m
        comp.day = d

        let cal = Calendar(identifier: .gregorian)
        guard let date = cal.date(from: comp) else { return false }

        // 防止 20250231 这种被自动进位的情况：反向比对组件
        let back = cal.dateComponents([.year, .month, .day], from: date)
        guard back.year == y, back.month == m, back.day == d else { return false }

        // 出生日期不能在未来
        return date <= Date()
    }

    // MARK: - Accessory toolbar (X + Done)
    private func makeIDAccessoryToolbar() -> UIToolbar {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: 44))

        let xItem = UIBarButtonItem(title: "X", style: .plain, target: self, action: #selector(insertX))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneTapped))

        bar.items = [xItem, flex, done]
        return bar
    }

    @objc private func insertX() {
        // 只允许在第18位输入 X：也就是当前已有17位数字时
        let current = normalizeID(idCardText.text ?? "")
        guard current.count == 17 else { return }
        idCardText.text = current + "X"
        idEditingChanged()
    }

    @objc private func doneTapped() {
        view.endEditing(true)
    }

}

// MARK: - UITextFieldDelegate
extension OverSeaMsgVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameText {
            idCardText.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nameText {
            nameText.text = normalizeName(nameText.text ?? "")
        } else if textField == idCardText {
            idCardText.text = normalizeID(idCardText.text ?? "")
        }
        judgeButtonStatus()
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        // 删除放行
        if string.isEmpty { return true }

        // 禁止 emoji（包括第三方键盘 primaryLanguage 为空的情况）
        if textField.textInputMode?.primaryLanguage == "emoji" ||
            textField.textInputMode?.primaryLanguage == nil ||
            string.containsEmoji() {
            return false
        }

        if textField == idCardText {
            // 身份证号：尽量在这里就拦截，减少闪烁
            let current = textField.text ?? ""
            guard let swiftRange = Range(range, in: current) else { return false }
            let candidate = current.replacingCharacters(in: swiftRange, with: string)

            let cleaned = normalizeID(candidate)
            textField.text = cleaned
            // 手动接管后返回 false
            return false
        }

        // 姓名：允许输入，后面 editingChanged 统一清洗
        return true
    }
}

// MARK: - Helpers
private extension String {
    func replacingRegex(pattern: String, with replacement: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return self }
        let range = NSRange(self.startIndex..<self.endIndex, in: self)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacement)
    }
}

