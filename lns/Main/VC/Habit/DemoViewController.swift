//
//  DemoViewController.swift
//  lns
//
//  Created by LNS2 on 2026/1/4.
//

import UIKit

final class DemoViewController: UIViewController {

    private let tiers = RankTier.defaultNine()

    private var unlockedMaxIndex: Int = 2 // 默认已解锁到 rank_3
    private var currentIndex: Int = 1     // 当前 rank_2

    private var resultVC: RankResultViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "段位动画 Demo"
        view.backgroundColor = .white

        resultVC = RankResultViewController(tiers: tiers, currentIndex: currentIndex, unlockedMaxIndex: unlockedMaxIndex)
        addChild(resultVC)
        view.addSubview(resultVC.view)
        resultVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resultVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            resultVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        resultVC.didMove(toParent: self)

        let up = UIButton(type: .system)
        up.setTitle("晋升", for: .normal)
        up.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        up.addTarget(self, action: #selector(onPromote), for: .touchUpInside)

        let down = UIButton(type: .system)
        down.setTitle("降级", for: .normal)
        down.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        down.addTarget(self, action: #selector(onDemote), for: .touchUpInside)

        let bar = UIStackView(arrangedSubviews: [down, up])
        bar.axis = .horizontal
        bar.spacing = 14
        bar.distribution = .fillEqually
        bar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar)

        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            bar.heightAnchor.constraint(equalToConstant: 44)
        ])

        // 初始展示
        resultVC.play(mode: .promote, fromIndex: currentIndex, toIndex: currentIndex)
    }

    @objc private func onPromote() {
        let from = currentIndex
        let to = min(currentIndex + 1, tiers.count - 1)
        guard to != from else { return }

        currentIndex = to
        unlockedMaxIndex = max(unlockedMaxIndex, to)
        resultVC.play(mode: .promote, fromIndex: from, toIndex: to)
    }

    @objc private func onDemote() {
        let from = currentIndex
        let to = max(currentIndex - 1, 0)
        guard to != from else { return }

        currentIndex = to
        resultVC.play(mode: .demote, fromIndex: from, toIndex: to)
    }
}
