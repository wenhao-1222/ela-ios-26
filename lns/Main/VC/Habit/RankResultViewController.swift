//
//  RankResultViewController.swift
//  lns
//
//  Created by LNS2 on 2026/1/4.
//

import UIKit

public protocol RankResultViewControllerDelegate: AnyObject {
    func rankResultViewControllerDidRequestDismiss(_ controller: RankResultViewController,
                                                   badgeFrame: CGRect,
                                                   badgeImage: UIImage?)
}

public final class RankResultViewController: UIViewController {

    public enum Mode { case promote, demote }
    public weak var delegate: RankResultViewControllerDelegate?
    public var scoreText: String? { didSet { updateScoreLabel() } }

    private let gradientLayer = CAGradientLayer()
    private let contentStack = UIStackView()
    private let carousel = RankCarouselView()
    private let subtitleLabel = UILabel()
    private let scoreLabel = UILabel()
    private let badgeShadowView = UIView()
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
        configureBackground()
                configureCarousel()
                configureTexts()
                setupLayout()
                setupGestures()
        carousel.snap(to: currentIndex, animated: false)
        updateContentForCurrentTier()
    }
    public override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          gradientLayer.frame = view.bounds
          badgeShadowView.layer.cornerRadius = badgeShadowView.bounds.width / 2
      }

    public func badgeFrame(in coordinateView: UIView) -> CGRect {
        view.layoutIfNeeded()
        return carousel.centerBadgeFrame(in: coordinateView)
    }

    public func currentBadgeImage() -> UIImage? {
       guard tiers.indices.contains(currentIndex) else { return nil }
       return tiers[currentIndex].image
   }
    public func updateCurrentIndex(currentIndex:Int){
        carousel.unlockedMaxIndex = max(carousel.unlockedMaxIndex, currentIndex)
        carousel.snap(to: currentIndex, animated: false)
    }

    public func play(mode: Mode, fromIndex: Int, toIndex: Int) {
        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        scoreLabel.alpha = scoreText == nil ? 0 : 1

        switch mode {
        case .promote:
            carousel.unlockedMaxIndex = max(carousel.unlockedMaxIndex, fromIndex)
            carousel.snap(to: fromIndex, animated: false)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                self.carousel.playTransition(to: toIndex, kind: .promote)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
                    self.carousel.unlockedMaxIndex = max(self.carousel.unlockedMaxIndex, toIndex)
                    self.showPromoteText(tierName: self.tiers[toIndex].name, targetIndex: toIndex)
                }
            }

        case .demote:
            carousel.unlockedMaxIndex = max(carousel.unlockedMaxIndex, fromIndex)
            carousel.snap(to: fromIndex, animated: false)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                self.carousel.playTransition(to: toIndex, kind: .demote)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
                    self.showDemoteText(targetIndex: toIndex)
                }
            }
        }
    }
    // MARK: - Private
    private func configureBackground() {
        gradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0).cgColor,
            UIColor.white.cgColor
        ]
        gradientLayer.locations = [0.0, 0.4, 1.0]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func configureCarousel() {
        carousel.tiers = tiers
        carousel.unlockedMaxIndex = unlockedMaxIndex
        carousel.onIndexChanged = { [weak self] idx in
            self?.currentIndex = idx
            self?.updateContentForCurrentTier()
        }
        carousel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureTexts() {
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = UIColor(white: 0.12, alpha: 1)
        titleLabel.numberOfLines = 0
        titleLabel.alpha = 0

        subtitleLabel.textAlignment = .center
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = UIColor(white: 0.35, alpha: 1)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.alpha = 0

        scoreLabel.textAlignment = .center
        scoreLabel.font = .systemFont(ofSize: 30, weight: .bold)
        scoreLabel.textColor = UIColor(red: 0.26, green: 0.55, blue: 0.97, alpha: 1)
        scoreLabel.alpha = 0

        contentStack.axis = .vertical
        contentStack.spacing = 6
        contentStack.alignment = .center
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subtitleLabel)
        contentStack.addArrangedSubview(scoreLabel)
    }

    private func setupLayout() {
        badgeShadowView.translatesAutoresizingMaskIntoConstraints = false
        badgeShadowView.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        badgeShadowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.18).cgColor
        badgeShadowView.layer.shadowOffset = CGSize(width: 0, height: 8)
        badgeShadowView.layer.shadowRadius = 26
        badgeShadowView.layer.shadowOpacity = 1

        view.addSubview(badgeShadowView)
        view.addSubview(carousel)
        view.addSubview(contentStack)

        NSLayoutConstraint.activate([
            carousel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            carousel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            carousel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            carousel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.42),
            
            badgeShadowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            badgeShadowView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110),
            badgeShadowView.centerYAnchor.constraint(equalTo: carousel.centerYAnchor),
            badgeShadowView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.62),
            badgeShadowView.heightAnchor.constraint(equalTo: badgeShadowView.widthAnchor),
        
            contentStack.topAnchor.constraint(equalTo: carousel.bottomAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(onBackgroundTapped(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func updateContentForCurrentTier() {
        guard tiers.indices.contains(currentIndex) else { return }
        let tier = tiers[currentIndex]

        let topText = "恭喜你进入榜单 top \(tier.id)"
        let attributed = NSMutableAttributedString(string: topText)
        if let range = topText.range(of: "top \(tier.id)") {
            let nsRange = NSRange(range, in: topText)
            attributed.addAttributes([
                .foregroundColor: UIColor(red: 0.26, green: 0.55, blue: 0.97, alpha: 1)
            ], range: nsRange)
        }
        titleLabel.attributedText = attributed
        subtitleLabel.text = "将进入\(tier.name)排行榜"
        if scoreText == nil {
            scoreLabel.alpha = 0
        }
    }

    private func updateScoreLabel() {
        if let scoreText {
            scoreLabel.text = scoreText
            scoreLabel.alpha = 1
        } else {
            scoreLabel.text = nil
            scoreLabel.alpha = 0
        }
    }

    private func showPromoteText(tierName: String, targetIndex: Int) {
        updateContentForCurrentTier()
        if scoreText == nil {
            scoreLabel.text = "+\(tiers[targetIndex].id * 10) 积分"
            scoreLabel.alpha = 1
        }

        UIView.animate(withDuration: 0.25, delay: 0.00, options: [.curveEaseOut]) {
            self.titleLabel.alpha = 1
            self.subtitleLabel.alpha = 1
            self.scoreLabel.alpha = self.scoreLabel.text == nil ? 0 : 1
        }
        UIView.animate(withDuration: 0.25, delay: 0.00, options: [.curveEaseOut]) { self.titleLabel.alpha = 1 }
//        UIView.animate(withDuration: 0.25, delay: 0.10, options: [.curveEaseOut]) { self.button.alpha = 1 }
    }

//    private func showDemoteText() {
//        // ✅ 沮丧感：更克制、更灰
//        titleLabel.text = "你上周排名下降了一个等级～"
//        button.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
//        button.setTitleColor(UIColor(white: 0.55, alpha: 1.0), for: .normal)
//        button.setTitle("继续", for: .normal)
    private func showDemoteText(targetIndex: Int) {
        updateContentForCurrentTier()
        titleLabel.text = "你上周排名下降了一个等级～"
        subtitleLabel.text = "保持习惯，下周卷土重来"
        if scoreText == nil {
            scoreLabel.text = "-\(max(1, tiers[targetIndex].id) * 5) 积分"
            scoreLabel.alpha = 1
        }
        UIView.animate(withDuration: 0.25, delay: 0.00, options: [.curveEaseOut]) {
            self.titleLabel.alpha = 1
            self.subtitleLabel.alpha = 1
            self.scoreLabel.alpha = self.scoreLabel.text == nil ? 0 : 1
        }
//        UIView.animate(withDuration: 0.25, delay: 0.00, options: [.curveEaseOut]) { self.titleLabel.alpha = 1 }
//        UIView.animate(withDuration: 0.25, delay: 0.10, options: [.curveEaseOut]) { self.button.alpha = 1 }
    }
    @objc private func onBackgroundTapped(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: view)
        if let containerFrame = contentStack.superview?.convert(contentStack.frame, to: view), containerFrame.contains(point) {
            return
        }
        if carousel.frame.contains(point) { return }
        if let badgeFrame = badgeFrame(in: view) as CGRect? {
            delegate?.rankResultViewControllerDidRequestDismiss(self,
                                                                badgeFrame: badgeFrame,
                                                                badgeImage: currentBadgeImage())
        }
    }
}
