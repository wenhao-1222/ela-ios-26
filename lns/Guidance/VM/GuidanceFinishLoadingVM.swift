//
//  GuidanceFinishLoadingVM.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

import UIKit
import SnapKit

class GuidanceFinishLoadingVM: UIView {

    var progressCompleteBlock: (() -> ())?

    private var progressTimer: Timer?
    private var displayedProgress: CGFloat = 0
    private var progressWidthConstraint: Constraint?
    private var finishHoldRemaining: TimeInterval = 0
    private var lastTickTime: CFTimeInterval = CACurrentMediaTime()
    private var hasNotifiedComplete = false

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_WHITE
        isUserInteractionEnabled = true
        isHidden = true
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopFakeProgress()
    }

    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_progress_bg")
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
    }()

    lazy var percentLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 72, weight: .semibold)
        lab.text = "0%"
        return lab
    }()

    lazy var progressTrackView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(6)
        vi.clipsToBounds = true
        return vi
    }()

    lazy var progressFillView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(6)
        vi.clipsToBounds = true
        return vi
    }()

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "计划生成中..."
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 20, weight: .semibold)
        return lab
    }()

    lazy var subTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "你的数据只属于你。"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        return lab
    }()

    lazy var descLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.text = "我们永远不会出售你的健康数据，也绝不会在未经你同意的情况下与第三方共享。\n\n你可随时删除。"
        return lab
    }()
}

extension GuidanceFinishLoadingVM {
    func showLoading() {
        isHidden = false
        resetProgress()
        startFakeProgress()
    }

    func hideLoadingView() {
        stopFakeProgress()
        isHidden = true
    }

    private func resetProgress() {
        displayedProgress = 0
        finishHoldRemaining = 0
        hasNotifiedComplete = false
        lastTickTime = CACurrentMediaTime()
        updateProgressUI(animated: false)
    }

    private func startFakeProgress() {
        stopFakeProgress()
        lastTickTime = CACurrentMediaTime()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { [weak self] _ in
            self?.tickFakeProgress()
        }
        if let timer = progressTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func stopFakeProgress() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    private func tickFakeProgress() {
        let now = CACurrentMediaTime()
        let dt = min(max(now - lastTickTime, 0.016), 0.2)
        lastTickTime = now

        if displayedProgress >= 99 {
            if finishHoldRemaining <= 0 {
                finishHoldRemaining = 0.45
            }
            finishHoldRemaining -= dt
            if finishHoldRemaining <= 0 {
                displayedProgress = 100
                updateProgressUI(animated: true)
                stopFakeProgress()
                notifyCompleteIfNeeded()
                return
            }
            updateProgressUI(animated: true)
            return
        }

        let baseSpeed: CGFloat
        switch displayedProgress {
        case 0..<35:
            baseSpeed = 30
        case 35..<65:
            baseSpeed = 18
        case 65..<85:
            baseSpeed = 11
        case 85..<95:
            baseSpeed = 6
        default:
            baseSpeed = 3
        }

        let jitter = CGFloat.random(in: -0.12...0.18)
        displayedProgress = min(displayedProgress + CGFloat(dt) * max(1, baseSpeed + jitter * 10), 99)
        updateProgressUI(animated: true)
    }

    private func updateProgressUI(animated: Bool) {
        let progress = max(0, min(Int(displayedProgress.rounded(.down)), 100))
        percentLabel.text = "\(progress)%"
        let targetWidth = (SCREEN_WIDHT - kFitWidth(64)) * displayedProgress / 100.0
        progressWidthConstraint?.update(offset: targetWidth)

        if animated {
            UIView.animate(withDuration: 0.16, delay: 0, options: .curveEaseOut) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }

    private func notifyCompleteIfNeeded() {
        guard !hasNotifiedComplete else { return }
        hasNotifiedComplete = true
        progressCompleteBlock?()
    }
}

extension GuidanceFinishLoadingVM {
    func initUI() {
        addSubview(bgImgView)
        addSubview(percentLabel)
        addSubview(progressTrackView)
        progressTrackView.addSubview(progressFillView)
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(descLabel)

        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        percentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(110))
        }

        progressTrackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(percentLabel.snp.bottom).offset(kFitWidth(34))
            make.height.equalTo(kFitWidth(12))
        }

        progressFillView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            progressWidthConstraint = make.width.equalTo(0).constraint
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(40))
            make.top.equalTo(progressTrackView.snp.bottom).offset(kFitWidth(120))
        }

        subTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(54))
        }

        descLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(kFitWidth(-40))
            make.top.equalTo(subTitleLabel.snp.bottom).offset(kFitWidth(42))
        }
    }
}
