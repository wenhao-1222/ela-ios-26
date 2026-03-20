//
//  GuidanceProVC.swift
//  lns
//
//  Created by LNS2 on 2026/3/19.
//

import UIKit
import SnapKit

class GuidanceProVC: WHBaseViewVC {

    private enum ContentStep {
        case intro
        case trial
        case promise
    }

    var nextBlock: (() -> Void)?

    private let topBackgroundView = GuidanceProFlowBackgroundView()
    private let contentContainerView = UIView()
    private let topContentVM = GuidanceProTopVM()
    private let trialContentVM = GuidanceProTrialVM()
    private let promiseContentVM = GuidanceProPromiseVM()
    private var currentStep: ContentStep = .intro

    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("下一步", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        button.layer.cornerRadius = kFitWidth(22)
        button.clipsToBounds = true
        button.enablePressEffect()
        button.addTarget(self, action: #selector(nextButtonTapAction), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        topBackgroundView.startAnimatingIfNeeded()
        if currentStep == .intro {
            topContentVM.startBubbleFloatingAnimationIfNeeded()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        topBackgroundView.pauseAnimating()
        topContentVM.stopBubbleFloatingAnimation()
    }
}

private extension GuidanceProVC {
    func initUI() {
        view.backgroundColor = .white
        scrollViewBase.removeFromSuperview()

        view.addSubview(topBackgroundView)
        view.addSubview(contentContainerView)
        view.addSubview(nextButton)

        contentContainerView.addSubview(topContentVM)
        contentContainerView.addSubview(trialContentVM)
        contentContainerView.addSubview(promiseContentVM)

        topBackgroundView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(SCREEN_HEIGHT * 0.46)
        }

        contentContainerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(kFitWidth(126) + statusBarHeight)
            make.height.equalTo(kFitWidth(560))
        }

        topContentVM.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        trialContentVM.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        promiseContentVM.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-kFitWidth(22))
        }

        trialContentVM.isHidden = true
        trialContentVM.alpha = 0
        promiseContentVM.isHidden = true
        promiseContentVM.alpha = 0
    }

    @objc func nextButtonTapAction() {
        switch currentStep {
        case .intro:
            showTrialContent()
        case .trial:
            showPromiseContent()
        case .promise:
            nextBlock?()
        }
    }

    func showTrialContent() {
        guard currentStep == .intro else { return }

        currentStep = .trial
        topContentVM.stopBubbleFloatingAnimation()
        transition(from: topContentVM, to: trialContentVM)
    }

    func showPromiseContent() {
        guard currentStep == .trial else { return }

        currentStep = .promise
        transition(from: trialContentVM, to: promiseContentVM)
    }

    func transition(from currentView: UIView, to nextView: UIView) {
        nextView.isHidden = false
        nextView.alpha = 0
        nextView.transform = CGAffineTransform(translationX: kFitWidth(28), y: 0)

        UIView.animate(
            withDuration: 0.32,
            delay: 0,
            options: [.curveEaseInOut, .beginFromCurrentState]
        ) {
            currentView.alpha = 0
            currentView.transform = CGAffineTransform(translationX: -kFitWidth(28), y: 0)
            nextView.alpha = 1
            nextView.transform = .identity
        } completion: { _ in
            currentView.isHidden = true
            currentView.alpha = 1
            currentView.transform = .identity
        }
    }
}
