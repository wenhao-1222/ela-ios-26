//
//  ElaHealthDataConfirmAlert.swift
//  lns
//
//  Created by Codex on 2026/6/30.
//

import UIKit

final class ElaHealthDataConfirmAlert: NSObject {

    private static var agreementWindow: UIWindow?

    static func show(
        from presenter: UIViewController? = nil,
        onAgree: (() -> Void)? = nil,
        onExit: (() -> Void)? = nil,
        onPrivacy: (() -> Void)? = nil,
        onAgreement: (() -> Void)? = nil
    ) {
        DispatchQueue.main.async {
            guard let presenter = presenter ?? UIApplication.topViewController() else {
                return
            }

            let shouldUseInlineTitle: Bool
            if #available(iOS 26.0, *) {
                shouldUseInlineTitle = true
            } else {
                shouldUseInlineTitle = false
            }

            let alert = UIAlertController(
                title: shouldUseInlineTitle ? nil : "请先确认",
                message: nil,
                preferredStyle: .alert
            )
            let contentController = ElaHealthDataConfirmContentController(
                showsTitle: shouldUseInlineTitle
            )
            contentController.onPrivacy = { [weak alert, weak presenter] in
                if let onPrivacy = onPrivacy {
                    onPrivacy()
                } else {
                    guard let alert = alert, let presenter = presenter else { return }
                    openH5(
                        urlString: URL_privacy,
                        dismissing: alert,
                        from: presenter,
                        onAgree: onAgree,
                        onExit: onExit,
                        onPrivacy: onPrivacy,
                        onAgreement: onAgreement
                    )
                }
            }
            contentController.onAgreement = { [weak alert, weak presenter] in
                if let onAgreement = onAgreement {
                    onAgreement()
                } else {
                    guard let alert = alert, let presenter = presenter else { return }
                    openH5(
                        urlString: URL_agreement,
                        dismissing: alert,
                        from: presenter,
                        onAgree: onAgree,
                        onExit: onExit,
                        onPrivacy: onPrivacy,
                        onAgreement: onAgreement
                    )
                }
            }

            alert.setValue(contentController, forKey: "contentViewController")
            let exitAction = UIAlertAction(title: "退出", style: .cancel) { _ in
                onExit?()
            }
            exitAction.setValue(UIColor.COLOR_TEXT_TITLE_0f1214, forKey: "titleTextColor")

            let agreeAction = UIAlertAction(title: "同意", style: .default) { _ in
                onAgree?()
            }
            agreeAction.setValue(UIColor.THEME, forKey: "titleTextColor")

            alert.addAction(exitAction)
            alert.addAction(agreeAction)

            presenter.present(alert, animated: true)
        }
    }

    private static func openH5(
        urlString: String,
        dismissing alert: UIAlertController,
        from presenter: UIViewController,
        onAgree: (() -> Void)?,
        onExit: (() -> Void)?,
        onPrivacy: (() -> Void)?,
        onAgreement: (() -> Void)?
    ) {
        let h5VC = ElaAgreementH5ViewController()
        h5VC.urlString = urlString as NSString
        let navigationController = ElaDismissableNavigationController(rootViewController: h5VC)
        navigationController.modalPresentationStyle = .fullScreen
        h5VC.onClose = { [weak presenter] in
            agreementWindow?.isHidden = true
            agreementWindow = nil

            guard let presenter = presenter else { return }
            show(
                from: presenter,
                onAgree: onAgree,
                onExit: onExit,
                onPrivacy: onPrivacy,
                onAgreement: onAgreement
            )
        }

        guard let window = makeAgreementWindow(from: presenter) else {
            alert.dismiss(animated: true) {
                presenter.present(navigationController, animated: true)
            }
            return
        }

        agreementWindow = window
        window.rootViewController?.present(navigationController, animated: true) {
            alert.dismiss(animated: false)
        }
    }

    private static func makeAgreementWindow(from presenter: UIViewController) -> UIWindow? {
        let window: UIWindow
        if let windowScene = presenter.view.window?.windowScene {
            window = UIWindow(windowScene: windowScene)
        } else if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            window = UIWindow(windowScene: windowScene)
        } else {
            return nil
        }

        let rootController = UIViewController()
        rootController.view.backgroundColor = .clear
        window.rootViewController = rootController
        window.windowLevel = .alert + 2
        window.backgroundColor = .clear
        window.isHidden = false
        return window
    }
}

private final class ElaDismissableNavigationController: UINavigationController {

    override func popViewController(animated: Bool) -> UIViewController? {
        guard viewControllers.count > 1 else {
            dismiss(animated: animated)
            return topViewController
        }
        return super.popViewController(animated: animated)
    }
}

private final class ElaAgreementH5ViewController: WHCommonH5VC {

    var onClose: (() -> Void)?
    private var didCallClose = false

    override func backTapAction() {
        closePage()
    }

    override func h5BackTapAction() {
        if wkWebView.canGoBack {
            wkWebView.goBack()
        } else {
            closePage()
        }
    }

    private func closePage() {
        guard !didCallClose else { return }
        didCallClose = true

        let controllerToDismiss: UIViewController = navigationController ?? self
        controllerToDismiss.dismiss(animated: true) { [onClose] in
            onClose?()
        }
    }
}

private final class ElaHealthDataConfirmContentController: UIViewController, UITextViewDelegate {

    var onPrivacy: (() -> Void)?
    var onAgreement: (() -> Void)?

    private let showsTitle: Bool
    private let titleLabel = UILabel()
    private let textView = UITextView()
    private let contentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)

    init(showsTitle: Bool) {
        self.showsTitle = showsTitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        titleLabel.text = "请先确认"
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.isHidden = !showsTitle

        textView.backgroundColor = .clear
        textView.delegate = self
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.adjustsFontForContentSizeCategory = true
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.systemBlue
        ]
        textView.attributedText = makeMessage()

        view.addSubview(titleLabel)
        view.addSubview(textView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false

        if showsTitle {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: contentInsets.bottom),
                titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentInsets.left),
                titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentInsets.right),

                textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
                textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentInsets.left),
                textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentInsets.right),
                textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -contentInsets.bottom)
            ])
        } else {
            NSLayoutConstraint.activate([
                textView.topAnchor.constraint(equalTo: view.topAnchor),
                textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: contentInsets.left),
                textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -contentInsets.right),
                textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -contentInsets.bottom)
            ])
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let targetWidth = view.bounds.width > 0 ? view.bounds.width : 250
        let contentWidth = targetWidth - contentInsets.left - contentInsets.right
        let fittingSize = CGSize(width: contentWidth, height: UIView.layoutFittingCompressedSize.height)
        let textHeight = textView.sizeThatFits(fittingSize).height
        let titleHeight = showsTitle
            ? titleLabel.sizeThatFits(fittingSize).height + 10
            : 0
        let height = titleHeight + textHeight
        preferredContentSize = CGSize(width: targetWidth, height: ceil(height))
    }

    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        switch URL.host {
        case "privacy":
            onPrivacy?()
        case "agreement":
            onAgreement?()
        default:
            return true
        }
        return false
    }

    private func makeMessage() -> NSAttributedString {
        let linkedTerms = "《\u{2060}隐\u{2060}私\u{2060}政\u{2060}策\u{2060}》\u{2060}和\u{2060}《\u{2060}用\u{2060}户\u{2060}协\u{2060}议\u{2060}》"
        let text = """
        为了给到你更准确的营养目标和建议，Elavatine 需要分析你填写的健康信息。

        你的健康数据将受到严格保护，仅用于提供相关服务。详情可查看
        \(linkedTerms)。
        """

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .left

        let attributedText = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: UIColor.secondaryLabel,
                .paragraphStyle: paragraphStyle
            ]
        )

        attributedText.addLink(text: "隐\u{2060}私\u{2060}政\u{2060}策", urlString: "elavatine-alert://privacy")
        attributedText.addLink(text: "用\u{2060}户\u{2060}协\u{2060}议", urlString: "elavatine-alert://agreement")

        return attributedText
    }
}

private extension NSMutableAttributedString {

    func addLink(text: String, urlString: String) {
        let fullText = string as NSString
        let range = fullText.range(of: text)
        guard range.location != NSNotFound else { return }

        addAttributes([
            .link: urlString,
            .foregroundColor: UIColor.systemBlue
        ], range: range)
    }
}
