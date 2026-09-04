//
//  AICoachChatVC.swift
//  lns
//
//  AI 教练快捷问答。问题展示及可用性以后台问题列表为准。
//

import UIKit
import SnapKit

private struct AICoachChatQuestion {
    let id: Int
    let title: String
}

private enum AICoachChatOptionMode {
    case questions
    case remainingMeals
    case takeoutCuisine
}

private struct AICoachChatOption {
    let value: Int
    let title: String
    let isEnabled: Bool
}

final class AICoachChatVC: WHBaseViewVC {

    private let fallbackErrorMessage = "系统繁忙"

    private var questions: [AICoachChatQuestion] = []
    private var disabledQuestionIDs = Set<Int>()
    private var optionMode: AICoachChatOptionMode = .questions
    private var currentOptions: [AICoachChatOption] = []
    private var optionButtons: [UIButton] = []
    private var selectedQuestionID: Int?
    private var selectedRemainingMeals: Int?
    private var isRequesting = false
    private weak var typingMessageView: UIView?
    private var optionsContentWidthConstraint: Constraint?

    private lazy var messagesScrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.keyboardDismissMode = .interactive
        return view
    }()

    private lazy var messagesStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = kFitWidth(16)
        view.layoutMargins = UIEdgeInsets(top: kFitWidth(24), left: 0, bottom: kFitWidth(24), right: 0)
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()

    private lazy var optionsPanelView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_CARD_BG_WHITE
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 4
        return view
    }()

    private lazy var optionsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "选择你的回复"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private lazy var optionsScrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.alwaysBounceHorizontal = true
        view.clipsToBounds = true
        return view
    }()

    private lazy var optionsContentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        appendCoachMessage(greetingText())
        requestQuestionList()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutOptionButtons()
    }
}

// MARK: - UI

private extension AICoachChatVC {

    func configureUI() {
        view.backgroundColor = .COLOR_BG_F2
        initNavi(titleStr: "问教练", naviBgColor: .COLOR_BG_F2)
        navigationView.snp.makeConstraints { make in
            make.top.equalToSuperview()
        }

        view.addSubview(messagesScrollView)
        messagesScrollView.addSubview(messagesStackView)
        view.addSubview(optionsPanelView)
        optionsPanelView.addSubview(optionsTitleLabel)
        optionsPanelView.addSubview(optionsScrollView)
        optionsScrollView.addSubview(optionsContentView)

        let optionsPanelHeight = kFitWidth(184) + WHUtils().getBottomSafeAreaHeight()
        optionsPanelView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(optionsPanelHeight)
        }

        messagesScrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(optionsPanelView.snp.top)
        }

        messagesStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(kFitWidth(16))
            make.right.equalToSuperview().offset(kFitWidth(-16))
            make.width.equalTo(messagesScrollView.snp.width).offset(kFitWidth(-32))
        }

        optionsTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(16))
        }

        optionsScrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(optionsTitleLabel.snp.bottom).offset(kFitWidth(14))
            make.height.equalTo(kFitWidth(94))
        }

        optionsContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
            optionsContentWidthConstraint = make.width.equalTo(SCREEN_WIDHT).constraint
        }
    }

    func greetingText() -> String {
        let nickname = UserInfoModel.shared.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        if nickname.isEmpty {
            return "你好，想聊聊今天的饮食，还是有其他营养问题想问我？"
        }
        return "你好，\(nickname)，想聊聊今天的饮食，还是有其他营养问题想问我？"
    }

    func appendCoachMessage(_ text: String) {
        appendMessage(AICoachChatMessageView(text: text, direction: .coach))
    }

    func appendUserMessage(_ text: String) {
        appendMessage(AICoachChatMessageView(text: text, direction: .user))
    }

    func appendTypingMessage() {
        removeTypingMessage()
        let messageView = AICoachChatTypingMessageView()
        typingMessageView = messageView
        appendMessage(messageView)
    }

    func removeTypingMessage() {
        guard let typingMessageView = typingMessageView else { return }
        messagesStackView.removeArrangedSubview(typingMessageView)
        typingMessageView.removeFromSuperview()
        self.typingMessageView = nil
    }

    func appendMessage(_ messageView: UIView) {
        messagesStackView.addArrangedSubview(messageView)
        view.layoutIfNeeded()
        scrollMessagesToBottom(animated: true)
    }

    func scrollMessagesToBottom(animated: Bool) {
        view.layoutIfNeeded()
        let bottomOffset = max(-messagesScrollView.adjustedContentInset.top,
                               messagesScrollView.contentSize.height - messagesScrollView.bounds.height + messagesScrollView.adjustedContentInset.bottom)
        messagesScrollView.setContentOffset(CGPoint(x: 0, y: bottomOffset), animated: animated)
    }

    func displayQuestions() {
        optionMode = .questions
        currentOptions = questions.map {
            AICoachChatOption(value: $0.id,
                              title: $0.title,
                              isEnabled: !disabledQuestionIDs.contains($0.id) && !isRequesting)
        }
        rebuildOptionButtons()
    }

    func displayRemainingMealOptions() {
        optionMode = .remainingMeals
        currentOptions = (1...6).map {
            AICoachChatOption(value: $0, title: "\($0) 餐", isEnabled: !isRequesting)
        }
        rebuildOptionButtons()
    }

    func displayCuisineOptions() {
        optionMode = .takeoutCuisine
        let titles = ["中式", "西式", "日韩", "都可以", "不用了"]
        currentOptions = titles.enumerated().map {
            AICoachChatOption(value: $0.offset + 1, title: $0.element, isEnabled: !isRequesting)
        }
        rebuildOptionButtons()
    }

    func setOptionsInteractionEnabled(_ isEnabled: Bool) {
        for (index, button) in optionButtons.enumerated() {
            let optionEnabled = index < currentOptions.count ? currentOptions[index].isEnabled : false
            button.isEnabled = optionEnabled && isEnabled
            applyOptionButtonAppearance(button)
        }
    }

    func rebuildOptionButtons() {
        optionButtons.forEach { $0.removeFromSuperview() }
        optionButtons.removeAll()

        for (index, option) in currentOptions.enumerated() {
            let button = UIButton(type: .custom)
            button.tag = index
            button.setTitle(option.title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 12)
            button.titleLabel?.lineBreakMode = .byTruncatingTail
            button.layer.cornerRadius = kFitWidth(6)
            button.layer.borderWidth = 0.5
            button.isEnabled = option.isEnabled && !isRequesting
            button.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
            applyOptionButtonAppearance(button)
            optionsContentView.addSubview(button)
            optionButtons.append(button)
        }

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    func applyOptionButtonAppearance(_ button: UIButton) {
        button.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_20.cgColor
        button.backgroundColor = .clear
        button.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        button.setTitleColor(.COLOR_TEXT_TITLE_0f1214_20, for: .disabled)
        button.alpha = button.isEnabled ? 1 : 0.55
    }

    func layoutOptionButtons() {
        guard !optionButtons.isEmpty else {
            optionsContentWidthConstraint?.update(offset: max(optionsScrollView.bounds.width, SCREEN_WIDHT))
            return
        }

        let horizontalInset = kFitWidth(16)
        let horizontalSpacing = kFitWidth(12)
        let rowSpacing = kFitWidth(12)
        let buttonHeight = kFitWidth(40)
        let minimumWidth = optionMode == .remainingMeals ? kFitWidth(100) : kFitWidth(72)
        let firstRowCount = Int(ceil(Double(optionButtons.count) / 2.0))
        var rowX = [horizontalInset, horizontalInset]

        for (index, button) in optionButtons.enumerated() {
            let row = index < firstRowCount ? 0 : 1
            let title = button.title(for: .normal) ?? ""
            let measuredWidth = ceil((title as NSString).size(withAttributes: [.font: button.titleLabel?.font ?? UIFont.systemFont(ofSize: 12)]).width)
            let buttonWidth = max(minimumWidth, measuredWidth + kFitWidth(32))
            button.frame = CGRect(x: rowX[row],
                                  y: CGFloat(row) * (buttonHeight + rowSpacing),
                                  width: buttonWidth,
                                  height: buttonHeight)
            rowX[row] += buttonWidth + horizontalSpacing
        }

        let contentWidth = max(optionsScrollView.bounds.width,
                               max(rowX[0], rowX[1]) - horizontalSpacing + horizontalInset)
        optionsContentWidthConstraint?.update(offset: contentWidth)
        optionsScrollView.contentSize = CGSize(width: contentWidth, height: kFitWidth(92))
    }
}

// MARK: - Actions

private extension AICoachChatVC {

    @objc func optionButtonTapped(_ sender: UIButton) {
        guard !isRequesting,
              sender.tag >= 0,
              sender.tag < currentOptions.count else { return }

        let option = currentOptions[sender.tag]
        guard option.isEnabled else { return }

        switch optionMode {
        case .questions:
            handleQuestionSelection(id: option.value, title: option.title)
        case .remainingMeals:
            handleRemainingMealsSelection(option.value)
        case .takeoutCuisine:
            handleCuisineSelection(option.value, title: option.title)
        }
    }

    func handleQuestionSelection(id: Int, title: String) {
        selectedQuestionID = id
        disabledQuestionIDs.insert(id)
        appendUserMessage(title)

        if id == 1 {
            appendCoachMessage("你今天还打算吃几餐？")
            displayRemainingMealOptions()
            return
        }

        if id == 2 {
            displayQuestions()
            let viewController = MealAdviceVC()
            navigationController?.pushViewController(viewController, animated: true)
            return
        }

        beginAnswerRequest()
        if id == 3 {
            requestNutritionIntakeAssessment()
        } else {
            requestAnswer(questionID: id)
        }
    }

    func handleRemainingMealsSelection(_ count: Int) {
        selectedRemainingMeals = count
        appendUserMessage("\(count) 餐")
        isRequesting = true
        setOptionsInteractionEnabled(false)
        appendCoachMessage("你想吃什么类型的外卖？")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.appendCoachMessage("我会在优先满足你的营养素需求的同时，尽量满足你的喜好。")
            self.isRequesting = false
            self.displayCuisineOptions()
        }
    }

    func handleCuisineSelection(_ value: Int, title: String) {
        appendUserMessage(title)

        if value == 5 {
            disabledQuestionIDs.remove(1)
            selectedQuestionID = nil
            selectedRemainingMeals = nil
            displayQuestions()
            return
        }

        beginAnswerRequest()
        requestAnswer(questionID: 1,
                      remainingMeals: selectedRemainingMeals,
                      cuisinePreference: value)
    }

    func beginAnswerRequest() {
        isRequesting = true
        setOptionsInteractionEnabled(false)
        appendTypingMessage()
    }

    func finishAnswerRequest(messages: [String]) {
        removeTypingMessage()
        let nonemptyMessages = messages
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if nonemptyMessages.isEmpty {
            finishAnswerRequestWithError(nil)
            return
        }

        nonemptyMessages.forEach { appendCoachMessage($0) }
        isRequesting = false
        selectedQuestionID = nil
        selectedRemainingMeals = nil
        displayQuestions()
    }

    func finishAnswerRequestWithError(_ message: String?) {
        removeTypingMessage()
        let trimmedMessage = message?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        appendCoachMessage(trimmedMessage.isEmpty ? fallbackErrorMessage : trimmedMessage)

        if let selectedQuestionID = selectedQuestionID {
            disabledQuestionIDs.remove(selectedQuestionID)
        }
        isRequesting = false
        selectedQuestionID = nil
        selectedRemainingMeals = nil
        displayQuestions()
    }
}

// MARK: - Requests

private extension AICoachChatVC {

    func requestQuestionList() {
        isRequesting = true
        currentOptions = []
        rebuildOptionButtons()

        WHNetworkUtil.shareManager().POST(
            urlString: URL_ai_coach_question_list,
            parameters: [:],
            isNeedToast: false,
            responseError: { [weak self] response in
                self?.handleQuestionListFailure(message: self?.serverMessage(from: response))
            },
            success: { [weak self] response in
                guard let self = self else { return }
                let parsedQuestions = self.parseQuestions(from: response)
                guard !parsedQuestions.isEmpty else {
                    self.handleQuestionListFailure(message: nil)
                    return
                }
                self.questions = parsedQuestions
                self.isRequesting = false
                self.displayQuestions()
            },
            failure: { [weak self] _ in
                self?.handleQuestionListFailure(message: nil)
            }
        )
    }

    func handleQuestionListFailure(message: String?) {
        isRequesting = false
        currentOptions = []
        rebuildOptionButtons()
        let trimmedMessage = message?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        appendCoachMessage(trimmedMessage.isEmpty ? fallbackErrorMessage : trimmedMessage)
    }

    func requestAnswer(questionID: Int,
                       remainingMeals: Int? = nil,
                       cuisinePreference: Int? = nil) {
        var parameters: [String: AnyObject] = ["id": questionID as NSNumber]
        if let remainingMeals = remainingMeals {
            parameters["restMealNum"] = remainingMeals as NSNumber
        }
        if let cuisinePreference = cuisinePreference {
            parameters["takeoutCuisinePreference"] = cuisinePreference as NSNumber
        }

        performAnswerRequest(urlString: URL_ai_coach_ask, parameters: parameters)
    }

    func requestNutritionIntakeAssessment() {
        performAnswerRequest(urlString: URL_ai_coach_nutrition_intake_assessment,
                             parameters: [:])
    }

    func performAnswerRequest(urlString: String, parameters: [String: AnyObject]) {
        WHNetworkUtil.shareManager().POST(
            urlString: urlString,
            parameters: parameters,
            isNeedToast: false,
            timeOut: 60,
            responseError: { [weak self] response in
                self?.finishAnswerRequestWithError(self?.serverMessage(from: response))
            },
            success: { [weak self] response in
                guard let self = self else { return }
                self.finishAnswerRequest(messages: self.answerMessages(from: response))
            },
            failure: { [weak self] _ in
                self?.finishAnswerRequestWithError(nil)
            }
        )
    }

    func parseQuestions(from response: [String: AnyObject]) -> [AICoachChatQuestion] {
        let payload = decodedPayload(from: response)
        let rawQuestions: [Any]
        if let dictionary = payload as? NSDictionary {
            rawQuestions = dictionary["questionList"] as? [Any] ?? []
        } else if let array = payload as? [Any] {
            rawQuestions = array
        } else {
            rawQuestions = []
        }

        return rawQuestions.compactMap { rawQuestion in
            guard let dictionary = rawQuestion as? NSDictionary else { return nil }
            let id: Int
            if let number = dictionary["id"] as? NSNumber {
                id = number.intValue
            } else if let string = dictionary["id"] as? String, let parsedID = Int(string) {
                id = parsedID
            } else {
                return nil
            }
            let title = (dictionary["question"] as? String ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty else { return nil }
            return AICoachChatQuestion(id: id, title: title)
        }
    }

    func answerMessages(from response: [String: AnyObject]) -> [String] {
        guard let payload = decodedPayload(from: response) else { return [] }
        if let string = payload as? String {
            return [string]
        }
        if let array = payload as? [Any] {
            return array.compactMap { $0 as? String }
        }
        guard let dictionary = payload as? NSDictionary else { return [] }

        for key in ["answerList", "answers", "messages"] {
            if let values = dictionary[key] as? [Any] {
                let messages = values.compactMap { value -> String? in
                    if let string = value as? String { return string }
                    if let item = value as? NSDictionary {
                        return item["content"] as? String ?? item["answer"] as? String
                    }
                    return nil
                }
                if !messages.isEmpty { return messages }
            }
        }

        for key in ["answer", "content", "assessment", "result"] {
            if let value = dictionary[key] as? String, !value.isEmpty {
                return [value]
            }
        }

        let compositeKeys = ["summary", "dataText", "situation", "conclusion", "advice", "suggestion"]
        let compositeMessages = compositeKeys.compactMap { key -> String? in
            guard let value = dictionary[key] as? String, !value.isEmpty else { return nil }
            return value
        }
        return compositeMessages
    }

    func decodedPayload(from response: [String: AnyObject]) -> Any? {
        if let dictionary = response["data"] as? NSDictionary {
            return dictionary
        }
        if let array = response["data"] as? NSArray {
            return array.map { $0 }
        }
        guard let encryptedData = response["data"] as? String,
              !encryptedData.isEmpty else { return nil }

        let decryptedData = AESEncyptUtil.aesDecrypt(hexString: encryptedData) ?? encryptedData
        guard let data = decryptedData.data(using: .utf8) else { return decryptedData }
        if let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
            return object
        }
        return decryptedData
    }

    func serverMessage(from response: [String: AnyObject]) -> String? {
        if let message = response["message"] as? String {
            return message
        }
        if let message = response["message"] as? NSNumber {
            return message.stringValue
        }
        return nil
    }
}

// MARK: - Message views

private enum AICoachChatMessageDirection {
    case coach
    case user
}

private final class AICoachChatMessageView: UIView {

    init(text: String, direction: AICoachChatMessageDirection) {
        super.init(frame: .zero)

        let bubbleView = UIView()
        bubbleView.backgroundColor = direction == .coach ? .COLOR_CARD_BG_WHITE : .COLOR_TEXT_TITLE_0f1214_05
        bubbleView.layer.cornerRadius = kFitWidth(12)
        if direction == .coach {
            bubbleView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner]
        } else {
            bubbleView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
        }

        let label = UILabel()
        label.numberOfLines = 0
        label.text = text
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 14)
        label.setContentCompressionResistancePriority(.required, for: .vertical)

        addSubview(bubbleView)
        bubbleView.addSubview(label)

        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: kFitWidth(14),
                                                              left: kFitWidth(16),
                                                              bottom: kFitWidth(14),
                                                              right: kFitWidth(16)))
        }
        bubbleView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.95)
            if direction == .coach {
                make.left.equalToSuperview()
                make.right.lessThanOrEqualToSuperview()
            } else {
                make.right.equalToSuperview()
                make.left.greaterThanOrEqualToSuperview()
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class AICoachChatTypingMessageView: UIView {

    private let indicator = AICoachChatTypingIndicatorView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let bubbleView = UIView()
        bubbleView.backgroundColor = .COLOR_CARD_BG_WHITE
        bubbleView.layer.cornerRadius = kFitWidth(12)
        bubbleView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner]

        addSubview(bubbleView)
        bubbleView.addSubview(indicator)

        bubbleView.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.width.equalTo(kFitWidth(76))
            make.height.equalTo(kFitWidth(42))
        }
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(kFitWidth(42))
            make.height.equalTo(kFitWidth(10))
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            indicator.stopAnimating()
        } else {
            indicator.startAnimating()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class AICoachChatTypingIndicatorView: UIView {

    private var dots: [UIView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        for index in 0..<3 {
            let dot = UIView()
            dot.backgroundColor = .COLOR_TEXT_TITLE_0f1214_50
            dot.layer.cornerRadius = kFitWidth(3)
            addSubview(dot)
            dot.snp.makeConstraints { make in
                make.left.equalTo(CGFloat(index) * kFitWidth(15))
                make.centerY.equalToSuperview()
                make.width.height.equalTo(kFitWidth(6))
            }
            dots.append(dot)
        }
    }

    func startAnimating() {
        for (index, dot) in dots.enumerated() {
            let animation = CAKeyframeAnimation(keyPath: "opacity")
            animation.values = [0.25, 1, 0.25]
            animation.keyTimes = [0, 0.5, 1]
            animation.duration = 0.9
            animation.beginTime = CACurrentMediaTime() + Double(index) * 0.15
            animation.repeatCount = .infinity
            dot.layer.add(animation, forKey: "aiCoachTyping")
        }
    }

    func stopAnimating() {
        dots.forEach { $0.layer.removeAnimation(forKey: "aiCoachTyping") }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
