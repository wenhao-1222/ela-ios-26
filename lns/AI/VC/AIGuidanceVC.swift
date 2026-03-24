//
//  AIGuidanceVC.swift
//  lns
//  AI教练  问卷
//  Created by LNS2 on 2026/3/24.
//

import UIKit
import SnapKit

class AIGuidanceVC: WHBaseViewVC {

    enum FlowStep: Hashable {
        case goal
        case goalStage
    }

    var currentIndex: Int = 0
    private var mountedSteps = Set<FlowStep>()
    private let totalSteps = 2

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }

    lazy var naviVm: DietPlanCreateNaviVM = {
        let vm = DietPlanCreateNaviVM.init(frame: .zero)
        vm.backButton.isHidden = false
        vm.backTapBlock = {[weak self] in
            guard let self = self else { return }
            if self.currentIndex == 0 {
                self.backTapAction()
                return
            }
            self.moveToStep(index: self.currentIndex - 1, animated: true)
        }
        return vm
    }()
    lazy var stepsArray: [Int] = [1,1,0]
    lazy var nextButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = .COLOR_BUTTON_DISABLE_BG_THEME
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        btn.isEnabled = false
        btn.isHidden = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextButtonTapAction), for: .touchUpInside)

        return btn
    }()
    lazy var goalVm: AIGuidanceGoalVM = {
        let vm = AIGuidanceGoalVM.init(frame: .zero)
        vm.selectedBlock = { [weak self] in
            self?.goalStageVm.refreshContentForCurrentGoal()
            self?.moveToStep(index: 1, animated: true)
        }
        return vm
    }()
    lazy var goalStageVm: AIGuidanceGoalStageVM = {
        let vm = AIGuidanceGoalStageVM.init(frame: .zero)
        vm.selectedBlock = { [weak self] in
            self?.updateNextButtonForCurrentStep()
        }
        return vm
    }()
}

extension AIGuidanceVC{
    @objc func nextButtonTapAction() {
        guard let currentStep = flowStep(for: currentIndex) else {
            return
        }

        switch currentStep {
        case .goal:
            break
        case .goalStage:
            break
        }
    }

    func flowStep(for index: Int) -> FlowStep? {
        switch index {
        case 0:
            return .goal
        case 1:
            return .goalStage
        default:
            return nil
        }
    }

    func stepView(for step: FlowStep) -> UIView? {
        switch step {
        case .goal:
            return goalVm
        case .goalStage:
            return goalStageVm
        }
    }

    func installStepViewsIfNeeded(indexes: [Int]) {
        for index in indexes {
            guard let step = flowStep(for: index),
                  let stepView = stepView(for: step) else {
                continue
            }
            mountedSteps.insert(step)
            stepView.isHidden = false
            stepView.frame = CGRect(x: SCREEN_WIDHT * CGFloat(index), y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
            guard stepView.superview == nil else {
                continue
            }
            scrollViewBase.addSubview(stepView)
        }
    }

    func moveToStep(index: Int, animated: Bool) {
        let targetIndex = max(0, index)
        currentIndex = targetIndex
        scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(targetIndex), y: 0), animated: animated)
        naviVm.updateStep(steps: stepsArray, currentStep: targetIndex)
        updateNextButtonForCurrentStep()
    }

    func updateNextButtonForCurrentStep() {
        guard let currentStep = flowStep(for: currentIndex) else {
            nextButton.isEnabled = false
            return
        }

        switch currentStep {
        case .goal:
            nextButton.isHidden = true
            nextButton.isEnabled = false
        case .goalStage:
            nextButton.isHidden = false
            nextButton.isEnabled = goalStageVm.hasSelection
        }
    }

    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(scrollViewBase)
        view.addSubview(naviVm)
        view.addSubview(nextButton)

        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.backgroundColor = .clear
        scrollViewBase.isScrollEnabled = false
        scrollViewBase.contentSize = CGSize(width: SCREEN_WIDHT * CGFloat(totalSteps), height: SCREEN_HEIGHT)

        installStepViewsIfNeeded(indexes: [0, 1])
        setConstrait()
        moveToStep(index: 0, animated: false)
    }

    func setConstrait() {
        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
        }
    }
}
