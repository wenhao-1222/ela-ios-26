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
    lazy var thirdVm: GuideTotalThirdVM = {
        let vm = GuideTotalThirdVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 1)
        }
        return vm
    }()
    lazy var fourthVm: GuideTotalFourVM = {
        let vm = GuideTotalFourVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 2)
        }
        return vm
    }()
    
    lazy var fifthVm: GuideTotalFifthVM = {
        let vm = GuideTotalFifthVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.sevenVm.caloriesCircleVm.setData(currentNumber: 266)
            self?.animateTransition(to: 3)
        }
        return vm
    }()
    lazy var sixthVm: GuideTotalSixthVM = {
        let vm = GuideTotalSixthVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 4)
        }
        return vm
    }()
    lazy var sevenVm: GuideTotalSevenVM = {
        let vm = GuideTotalSevenVM.init(frame: .zero)
        vm.nextBlock = {() in
//            self?.animateTransition(to: 7)
//            self.prese
            self.finishBlock?()
        }
        return vm
    }()
}

extension GuideTotalVC{
    /// Animates transition between guide pages
    func animateTransition(to index: Int) {
        guard index != currentIndex else { return }
        self.progressVm.isUserInteractionEnabled = false
        let fromView: UIView
        switch currentIndex {
        case 0: fromView = thirdVm
        case 1: fromView = fourthVm
        case 2: fromView = fifthVm
        case 3: fromView = sixthVm
        default: fromView = sevenVm
        }

        let toView: UIView
        switch index {
        case 1: toView = fourthVm
        case 2: toView = fifthVm
        case 3: toView = sixthVm
        default: toView = sevenVm
        }
        // Prepare entrance animations for upcoming view
        switch index {
        case 0: thirdVm.prepareEntranceAnimation()
        case 1: fourthVm.prepareEntranceAnimation()
        case 2: fifthVm.prepareEntranceAnimation()
        case 3: sixthVm.prepareEntranceAnimation()
        case 4: sevenVm.prepareEntranceAnimation()
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
            case 0: self.thirdVm.startEntranceAnimation()
            case 1: self.fourthVm.startEntranceAnimation()
            case 2: self.fifthVm.startEntranceAnimation()
            case 3: self.sixthVm.startEntranceAnimation()
            case 4: self.sevenVm.startEntranceAnimation()
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
        progressVm.isHidden = false
        progressVm.setStep(step: index)
        EventLogUtils().sendEventLogRequest(eventName: .PAGE_VIEW,
                                            scenarioType: .guide_view,
                                            text: "\(currentIndex+1)")
    }
    /// Display a specific step without cross-fade animation
    func showStep(_ index: Int, animated: Bool) {
        guard index != currentIndex else { return }

        // Ensure all pages are visible when switching without animation
        [thirdVm, fourthVm, fifthVm, sixthVm, sevenVm].forEach { $0.alpha = 1 }

        scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(index), y: 0), animated: true)

        currentIndex = index
        progressVm.isHidden = false
        progressVm.setStep(step: index, animated: animated)
    }
}

extension GuideTotalVC{
    func layoutGuidePages() {
        let pages: [UIView] = [thirdVm, fourthVm, fifthVm, sixthVm, sevenVm]
        for (index, page) in pages.enumerated() {
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
        scrollViewBase.addSubview(thirdVm)
        scrollViewBase.addSubview(fourthVm)
        scrollViewBase.addSubview(fifthVm)
        scrollViewBase.addSubview(sixthVm)
        scrollViewBase.addSubview(sevenVm)
        
        layoutGuidePages()
        scrollViewBase.contentSize = CGSize.init(width: SCREEN_WIDHT*5, height: 0)
//        scrollViewBase.backgroundColor = UIColor(named: "color_card_bg_f5_guide")
        scrollViewBase.backgroundColor = .COLOR_BG_F5
        self.scrollViewBase.layoutIfNeeded()
        self.view.layoutIfNeeded()
        progressVm.isHidden = false
        progressVm.setStep(step: currentIndex, animated: false)
    }
}

extension GuideTotalVC:UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.progressVm.isHidden = false
        self.progressVm.setStep(step: Int(scrollView.contentOffset.x/SCREEN_WIDHT))
    }
}
