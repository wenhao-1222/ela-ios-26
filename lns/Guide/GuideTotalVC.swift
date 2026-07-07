//
//  GuideTotalVC.swift
//  lns
//  新的引导页
//  Created by Elavatine on 2025/6/4.
//

class GuideTotalVC: WHBaseViewVC {
    
    /// Called when the guide is finished
    var finishBlock:(() -> Void)?
    
    /// Current displayed page index
    private var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    /// Remove guide view controller and notify caller
    func dismissGuide() {
        finishBlock?()
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    lazy var progressVm: GuideTotalProgressVM = {
        let vm = GuideTotalProgressVM.init(frame: .zero)
        vm.backBlock = {[weak self] in
            guard let self = self else { return }
            if self.currentIndex > 0 {
                self.showStep(self.currentIndex - 1, animated: true)
            }
        }
        return vm
    }()
    lazy var bodyImpactVm: GuideTotalBodyImpactVM = {
        let vm = GuideTotalBodyImpactVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 1)
        }
        return vm
    }()
    lazy var dietRecordVm: GuideTotalDietRecordVM = {
        let vm = GuideTotalDietRecordVM.init(frame: .zero)
        vm.shouldAutoStartChartAnimation = false
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 2)
        }
        vm.backBlock = { [weak self] in
            self?.showStep(0, animated: true)
        }
        return vm
    }()
    lazy var proVm: GuideTotalProVM = {
        let vm = GuideTotalProVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            guard let self = self else { return }
            self.animateTransition(to: self.guidePages.count - 1)
        }
        return vm
    }()
    lazy var proReadyStartVm: GuideTotalProReadyStartVM = {
        let vm = GuideTotalProReadyStartVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.finishBlock?()
        }
        return vm
    }()
    lazy var thirdVm: GuideTotalThirdVM = {
        let vm = GuideTotalThirdVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 3)
        }
        return vm
    }()
    lazy var fourthVm: GuideTotalFourVM = {
        let vm = GuideTotalFourVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 4)
        }
        return vm
    }()
    
    lazy var fifthVm: GuideTotalFifthVM = {
        let vm = GuideTotalFifthVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.sevenVm.caloriesCircleVm.setData(currentNumber: 266)
            self?.animateTransition(to: 5)
        }
        return vm
    }()
    lazy var sixthVm: GuideTotalSixthVM = {
        let vm = GuideTotalSixthVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 6)
        }
        return vm
    }()
    lazy var sevenVm: GuideTotalSevenVM = {
        let vm = GuideTotalSevenVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 7)
        }
        return vm
    }()

    private var guidePages: [UIView] {
        return [bodyImpactVm, dietRecordVm, thirdVm, fourthVm, fifthVm, sixthVm, sevenVm, proVm, proReadyStartVm]
    }

    private func updateProgressForCurrentStep(animated: Bool = true) {
        let progressStartIndex = 2
        let wasProgressHidden = progressVm.isHidden
        if currentIndex == 0 {
            progressVm.isHidden = true
            return
        }
        if currentIndex == 1 {
            progressVm.setBackOnlyMode(true, animated: animated && !wasProgressHidden)
            progressVm.isHidden = false
            return
        }
        if currentIndex == guidePages.count - 1 {
            progressVm.setBackOnlyMode(true, animated: animated && !wasProgressHidden)
            progressVm.isHidden = false
            return
        }
        progressVm.isHidden = false
        progressVm.setStep(step: currentIndex - progressStartIndex,
                           animated: animated,
                           showsBackButton: currentIndex >= progressStartIndex)
    }
}

extension GuideTotalVC{
    /// Animates transition between guide pages
    func animateTransition(to index: Int) {
        guard index != currentIndex else { return }
        guard index >= 0, index < guidePages.count else { return }
        self.progressVm.isUserInteractionEnabled = false
        let fromView = guidePages[currentIndex]
        let toView = guidePages[index]
        // Prepare entrance animations for upcoming view
        switch index {
        case 0: bodyImpactVm.prepareEntranceAnimation()
        case 1: dietRecordVm.prepareEntranceAnimation()
        case 2: thirdVm.prepareEntranceAnimation()
        case 3: fourthVm.prepareEntranceAnimation()
        case 4: fifthVm.prepareEntranceAnimation()
        case 5: sixthVm.prepareEntranceAnimation()
        case 6: sevenVm.prepareEntranceAnimation()
        case 7: proVm.prepareEntranceAnimation()
        case 8: proReadyStartVm.prepareEntranceAnimation()
        default: break
        }

        toView.alpha = 0
        UIView.animate(withDuration: 0.75, delay: 0,options: .curveEaseInOut) {
            fromView.alpha = 0
        }completion: { _ in
            self.scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(index), y: 0), animated: false)
        }
        let duration = 0.01
        
        UIView.animate(withDuration: duration, delay: 0.6,options: .curveEaseInOut) {
            toView.alpha = 1
        }completion: { _ in
            switch index {
            case 0: self.bodyImpactVm.startEntranceAnimation()
            case 1: self.dietRecordVm.startEntranceAnimation()
            case 2: self.thirdVm.startEntranceAnimation()
            case 3: self.fourthVm.startEntranceAnimation()
            case 4: self.fifthVm.startEntranceAnimation()
            case 5: self.sixthVm.startEntranceAnimation()
            case 6: self.sevenVm.startEntranceAnimation()
            case 7: self.proVm.startEntranceAnimation()
            case 8: self.proReadyStartVm.startEntranceAnimation()
            default: break
            }
            self.progressVm.isUserInteractionEnabled = true
        }
//        UIView.animate(withDuration: 0.25, animations: {
//            fromView.alpha = 0
//        }) { _ in
//            self.scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(index), y: 0), animated: false)
//            UIView.animate(withDuration: 0.25) {
//                toView.alpha = 1
//            }
//            self.progressVm.isUserInteractionEnabled = true
//        }

        currentIndex = index
        updateProgressForCurrentStep()
        EventLogUtils().sendEventLogRequest(eventName: .PAGE_VIEW,
                                            scenarioType: .guide_view,
                                            text: "\(currentIndex+1)")
    }
    /// Display a specific step without cross-fade animation
    func showStep(_ index: Int, animated: Bool) {
        guard index != currentIndex else { return }
        guard index >= 0, index < guidePages.count else { return }

        // Ensure all pages are visible when switching without animation
        guidePages.forEach { $0.alpha = 1 }

        scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(index), y: 0), animated: true)

        currentIndex = index
        updateProgressForCurrentStep(animated: animated)
    }
}

extension GuideTotalVC{
    func layoutGuidePages() {
        for (index, page) in guidePages.enumerated() {
            page.frame = CGRect(x: SCREEN_WIDHT * CGFloat(index), y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        }
    }

    func initUI() {
        
        view.addSubview(scrollViewBase)
        view.addSubview(progressVm)
        
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.bounces = false
        scrollViewBase.delegate = self
        scrollViewBase.isScrollEnabled = false
        scrollViewBase.showsHorizontalScrollIndicator = false
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.addSubview(bodyImpactVm)
        scrollViewBase.addSubview(dietRecordVm)
        scrollViewBase.addSubview(thirdVm)
        scrollViewBase.addSubview(fourthVm)
        scrollViewBase.addSubview(fifthVm)
        scrollViewBase.addSubview(sixthVm)
        scrollViewBase.addSubview(sevenVm)
        scrollViewBase.addSubview(proVm)
        scrollViewBase.addSubview(proReadyStartVm)
        
        layoutGuidePages()
        scrollViewBase.contentSize = CGSize.init(width: SCREEN_WIDHT * CGFloat(guidePages.count), height: 0)
//        scrollViewBase.backgroundColor = UIColor(named: "color_card_bg_f5_guide")
        scrollViewBase.backgroundColor = .COLOR_BG_F5
        self.scrollViewBase.layoutIfNeeded()
        self.view.layoutIfNeeded()
        updateProgressForCurrentStep(animated: false)
    }
}

extension GuideTotalVC:UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x/SCREEN_WIDHT)
        updateProgressForCurrentStep()
    }
}
