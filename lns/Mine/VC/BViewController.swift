//
//  BViewController.swift
//  lns
//
//  Created by Elavatine on 2025/7/18.
//

import UIKit

class BViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置透明背景（只中间显示白色框）
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3) // 可改成 .clear

        let whiteBox = UIView()
        whiteBox.backgroundColor = .white
        whiteBox.layer.cornerRadius = 16
        whiteBox.layer.shadowColor = UIColor.black.cgColor
        whiteBox.layer.shadowOpacity = 0.2
        whiteBox.layer.shadowOffset = CGSize(width: 0, height: 2)
        whiteBox.layer.shadowRadius = 5

        whiteBox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(whiteBox)

        NSLayoutConstraint.activate([
            whiteBox.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            whiteBox.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            whiteBox.widthAnchor.constraint(equalToConstant: 300),
            whiteBox.heightAnchor.constraint(equalToConstant: 200)
        ])

        let label = UILabel()
        label.text = "这是 B 页面"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center

        let closeButton = UIButton(type: .system)
        closeButton.setTitle("关闭", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [label, closeButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        whiteBox.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: whiteBox.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: whiteBox.centerYAnchor)
        ])
    }

    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
}
