//
//  Guide0820AgreementLegalTextView.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit

/// 隐私页底部协议说明文本。
final class Guide0820AgreementLegalTextView: UITextView {
    /// 打开协议页面回调。
    private let onOpenAgreement: (Guide0820AgreementType) -> Void

    /// 创建协议说明文本。
    /// - Parameter onOpenAgreement: 打开协议页面回调。
    init(onOpenAgreement: @escaping (Guide0820AgreementType) -> Void) {
        self.onOpenAgreement = onOpenAgreement
        super.init(frame: .zero, textContainer: nil)
        initUI()
    }

    /// 不支持 storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension Guide0820AgreementLegalTextView {
    /// 初始化文本视图样式。
    func initUI() {
        backgroundColor = .clear
        delegate = self
        isEditable = false
        isScrollEnabled = false
        isSelectable = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bounces = false
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
        linkTextAttributes = [
            .foregroundColor: UIColor.THEME
        ]
        attributedText = makeAttributedText()
    }

    /// 生成带协议链接的富文本。
    /// - Returns: 协议说明富文本。
    func makeAttributedText() -> NSAttributedString {
        let text = "继续即表示你同意我们的《服务条款》和《隐私政策》。"
        let attributedText = NSMutableAttributedString(string: text)
        let fullRange = NSRange(location: 0, length: (text as NSString).length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.minimumLineHeight = kFitWidth(16.5)
        paragraphStyle.maximumLineHeight = kFitWidth(16.5)

        attributedText.addAttributes([
            .font: UIFont.systemFont(ofSize: kFitWidth(11), weight: .regular),
            .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_50,
            .paragraphStyle: paragraphStyle
        ], range: fullRange)

        attributedText.guide0820AddLink("服务条款", urlString: "guide0820://user-agreement")
        attributedText.guide0820AddLink("隐私政策", urlString: "guide0820://privacy-policy")
        return attributedText
    }

    /// 处理协议链接点击。
    /// - Parameter url: 被点击的链接。
    /// - Returns: 是否继续交给系统处理。
    func handleLink(_ url: URL) -> Bool {
        switch url.host {
        case "user-agreement":
            onOpenAgreement(.userAgreement)
        case "privacy-policy":
            onOpenAgreement(.privacyPolicy)
        default:
            return true
        }
        return false
    }
}

extension Guide0820AgreementLegalTextView: UITextViewDelegate {
    /// iOS 10 及以上链接点击回调。
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        handleLink(URL)
    }

    /// 兼容旧版链接点击回调。
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange) -> Bool {
        handleLink(URL)
    }
}
