//
//  AddressDetailTextViewCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/12.
//

import UIKit
import SnapKit

final class AddressDetailTextViewCell: UITableViewCell, UITextViewDelegate {

    var onTextChanged: ((String) -> Void)?

    private let leftTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "详细地址"
        l.textColor = .COLOR_TEXT_TITLE_0f1214
        l.font = .systemFont(ofSize: 14, weight: .medium)
        return l
    }()

    private let textView: UITextView = {
        let tv = UITextView()
        tv.textColor = .COLOR_TEXT_TITLE_0f1214
        tv.font = .systemFont(ofSize: 14, weight: .regular)
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tv.isScrollEnabled = false
        tv.returnKeyType = .default
        tv.backgroundColor = .COLOR_CARD_BG_WHITE
        return tv
    }()

    private let placeholder: UILabel = {
        let l = UILabel()
        l.text = "具体到门牌号"
        l.textColor = .COLOR_TEXT_TITLE_0f1214_50
        l.font = .systemFont(ofSize: 14, weight: .regular)
        return l
    }()

    private let lineView: UIView = {
        let v = UIView()
        v.backgroundColor = .COLOR_LINE_F0
        return v
    }()

//    private let maxLines = 3
    private var textViewHeightConstraint: Constraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .COLOR_CARD_BG_WHITE
        contentView.addSubview(leftTitleLabel)
        contentView.addSubview(textView)
        contentView.addSubview(placeholder)
        contentView.addSubview(lineView)
        textView.delegate = self

        leftTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(12))
            make.width.lessThanOrEqualTo(70)
        }
        textView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(88))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(6))
            make.bottom.equalTo(kFitWidth(-6))
//            make.height.greaterThanOrEqualTo(51)
            textViewHeightConstraint = make.height.greaterThanOrEqualTo(51).constraint
        }
        placeholder.snp.makeConstraints { make in
            make.left.equalTo(textView).offset(4)
            make.top.equalTo(textView).offset(8)
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func update(text: String?) {
        textView.text = text ?? ""
        placeholder.isHidden = !(text?.isEmpty ?? true)
        textView.layoutIfNeeded()
        let height = max(kFitWidth(51), textView.contentSize.height)
        textViewHeightConstraint?.update(offset: height)
    }

    // MARK: - 限制最多 3 行
    func textViewDidChange(_ textView: UITextView) {
        placeholder.isHidden = !textView.text.isEmpty
        onTextChanged?(textView.text)
        let height = max(51, textView.contentSize.height)
        textViewHeightConstraint?.update(offset: height)
        if let tableView = findTableView() {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.isEmpty { return true }
        if text.isNineKeyBoard() {
            return true
        }else{
            if text.hasEmoji(){
                return false
            }
        }
        return true
    }
    private func containsEmoji(_ text: String) -> Bool {
        return text.unicodeScalars.contains { scalar in
            scalar.properties.isEmojiPresentation || (scalar.properties.isEmoji && scalar.value > 0x238C)
        }
    }
    private func findTableView() -> UITableView? {
        var view = superview
        while view != nil {
            if let tableView = view as? UITableView { return tableView }
            view = view?.superview
        }
//        onTextChanged?(textView.text)
        return nil
    }
}
