//
//  RankResultViewController.swift
//  lns
//
//  Created by LNS2 on 2026/1/4.
//

import UIKit

public final class RankResultViewController: UIViewController {

    public enum Mode { case promote, demote }

    private let carousel = RankCarouselView()
    private let titleLabel = UILabel()
//    private let button = UIButton(type: .system)

    private let tiers: [RankTier]
    private var currentIndex: Int
    private var unlockedMaxIndex: Int

    public init(tiers: [RankTier], currentIndex: Int, unlockedMaxIndex: Int) {
        self.tiers = tiers
        self.currentIndex = currentIndex
        self.unlockedMaxIndex = unlockedMaxIndex
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        carousel.tiers = tiers
        carousel.unlockedMaxIndex = unlockedMaxIndex
        carousel.onIndexChanged = { [weak self] idx in self?.currentIndex = idx }

        view.addSubview(carousel)
        carousel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor(white: 0.25, alpha: 1)
        titleLabel.alpha = 0

//        button.setTitle("继续", for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
//        button.backgroundColor = UIColor(red: 0.20, green: 0.63, blue: 0.97, alpha: 1.0)
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 10
//        button.alpha = 0

        view.addSubview(titleLabel)
//        view.addSubview(button)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            carousel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            carousel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            carousel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
//            carousel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.34),
            carousel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 76),
            carousel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),

//            titleLabel.topAnchor.constraint(equalTo: carousel.bottomAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: carousel.bottomAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

//            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -26),
//            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
//            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
//            button.heightAnchor.constraint(equalToConstant: 48),
        ])

        carousel.snap(to: currentIndex, animated: false)
    }
    
    public func badgeFrame(in coordinateView: UIView) -> CGRect {
        view.layoutIfNeeded()
        return carousel.centerBadgeFrame(in: coordinateView)
    }


    public func play(mode: Mode, fromIndex: Int, toIndex: Int) {
        titleLabel.alpha = 0
//        button.alpha = 0

        switch mode {
        case .promote:
            carousel.unlockedMaxIndex = max(carousel.unlockedMaxIndex, fromIndex)
            carousel.snap(to: fromIndex, animated: false)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                self.carousel.playTransition(to: toIndex, kind: .promote)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
                    self.carousel.unlockedMaxIndex = max(self.carousel.unlockedMaxIndex, toIndex)
                    self.showPromoteText(tierName: self.tiers[toIndex].name)
                }
            }

        case .demote:
            carousel.unlockedMaxIndex = max(carousel.unlockedMaxIndex, fromIndex)
            carousel.snap(to: fromIndex, animated: false)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                self.carousel.playTransition(to: toIndex, kind: .demote)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
                    self.showDemoteText()
                }
            }
        }
    }

    private func showPromoteText(tierName: String) {
        titleLabel.text = "你晋升到了 \(tierName)！"
//        button.backgroundColor = UIColor(red: 0.20, green: 0.63, blue: 0.97, alpha: 1.0)
//        button.setTitleColor(.white, for: .normal)
//        button.setTitle("继续", for: .normal)

        UIView.animate(withDuration: 0.25, delay: 0.00, options: [.curveEaseOut]) { self.titleLabel.alpha = 1 }
//        UIView.animate(withDuration: 0.25, delay: 0.10, options: [.curveEaseOut]) { self.button.alpha = 1 }
    }

    private func showDemoteText() {
        // ✅ 沮丧感：更克制、更灰
        titleLabel.text = "你上周排名下降了一个等级～"
//        button.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
//        button.setTitleColor(UIColor(white: 0.55, alpha: 1.0), for: .normal)
//        button.setTitle("继续", for: .normal)

        UIView.animate(withDuration: 0.25, delay: 0.00, options: [.curveEaseOut]) { self.titleLabel.alpha = 1 }
//        UIView.animate(withDuration: 0.25, delay: 0.10, options: [.curveEaseOut]) { self.button.alpha = 1 }
    }
}
