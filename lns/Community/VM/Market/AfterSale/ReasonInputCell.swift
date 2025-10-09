//
//  ReasonInputCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/19.
//

import UIKit

final class ReasonInputCell: UITableViewCell, UITextViewDelegate {
    static let reuseID = "ReasonInputCell"
    private let limit = 50
    var onTextChanged: ((String)->Void)?

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "原因"
        l.font = .systemFont(ofSize: 16, weight: .medium)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.95, alpha: 1)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 24, right: 12) // 留出底部计数空间
        tv.isScrollEnabled = false // 让 tableView 自动增高
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let placeholderLabel: UILabel = {
        let l = UILabel()
        l.text = "输入中"
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 16)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let countLabel: UILabel = {
        let l = UILabel()
        l.text = "0/50"
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(containerView)
        containerView.addSubview(textView)
        containerView.addSubview(placeholderLabel)
        containerView.addSubview(countLabel)
        textView.delegate = self

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            textView.topAnchor.constraint(equalTo: containerView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            // 占位在 textView 内部的左上角
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 10),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 16),

            // 计数在右下角（放在容器内）
            countLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            countLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(text: String?) {
        textView.text = text
        updateUI()
    }

    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        // 字数限制（支持粘贴）
        if textView.text.count > limit {
            let end = textView.text.index(textView.text.startIndex, offsetBy: limit)
            textView.text = String(textView.text[..<end])
        }
        updateUI()
        onTextChanged?(textView.text)

        // 触发 tableView 动态高度刷新
        if let tv = parentTableView() {
            UIView.setAnimationsEnabled(false)
            tv.beginUpdates()
            tv.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 预判键入是否超限（更顺滑）
        let current = textView.text as NSString
        let newText = current.replacingCharacters(in: range, with: text)
        return newText.count <= limit
    }

    private func updateUI() {
        placeholderLabel.isHidden = !(textView.text?.isEmpty ?? true)
        countLabel.text = "\(textView.text.count)/\(limit)"
    }

    private func parentTableView() -> UITableView? {
        var v: UIView? = self
        while v != nil {
            if let t = v as? UITableView { return t }
            v = v?.superview
        }
        return nil
    }
}
