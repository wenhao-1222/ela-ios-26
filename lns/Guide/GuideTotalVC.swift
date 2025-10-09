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
    
    override func viewDidAppear(_ animated: Bool) {
//        firstVm.chart.startGradientAnimation()
//        super.viewDidAppear(animated)
//        firstVm.startChartAnimation()
    }
    
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
    
    lazy var firstVm: GuideTotalFirstVM = {
        let vm = GuideTotalFirstVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.secondVm.pageDisplayDate = Date()
            self?.animateTransition(to: 1)
        }
        return vm
    }()
    lazy var secondVm: GuideTotalSecondNewVM = {
        let vm = GuideTotalSecondNewVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 2)
        }
        return vm
    }()
    lazy var progressVm: GuideTotalProgressVM = {
        let vm = GuideTotalProgressVM.init(frame: .zero)
        vm.isHidden = true
        vm.backBlock = {[weak self] in
            guard let self = self else { return }
            if self.currentIndex >= 2 {
//                self.animateTransition(to: self.currentIndex-1)
                self.showStep(self.currentIndex - 1, animated: true)
            }
        }
        return vm
    }()
    lazy var thirdVm: GuideTotalThirdVM = {
        let vm = GuideTotalThirdVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 3)
        }
//        vm.nextBlock = {()in
//            DLLog(message: "下一步   4")
//            self.scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT*3, y: 0), animated: true)
//            self.progressVm.setStep(step: 4)
//        }
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
        case 0: fromView = firstVm
        case 1: fromView = secondVm
        case 2: fromView = thirdVm
        case 3: fromView = fourthVm
        case 4: fromView = fifthVm
        case 5: fromView = sixthVm
        default: fromView = sevenVm
        }

        let toView: UIView
        switch index {
        case 1: toView = secondVm
        case 2: toView = thirdVm
        case 3: toView = fourthVm
        case 4: toView = fifthVm
        case 5: toView = sixthVm
        default: toView = sevenVm
        }
        // Prepare entrance animations for upcoming view
        switch index {
        case 2: thirdVm.prepareEntranceAnimation()
        case 3: fourthVm.prepareEntranceAnimation()
        case 4: fifthVm.prepareEntranceAnimation()
        case 5: sixthVm.prepareEntranceAnimation()
        case 6: sevenVm.prepareEntranceAnimation()
        default: break
        }

        toView.alpha = 0
        UIView.animate(withDuration: 0.75, delay: 0,options: .curveEaseInOut) {
            fromView.alpha = 0
        }completion: { _ in
            self.scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(index), y: 0), animated: false)
        }
        let duration = index == 1 ? 0.75 : 0.01
        
        UIView.animate(withDuration: duration, delay: 0.6,options: .curveEaseInOut) {
            toView.alpha = 1
        }completion: { _ in
//            toView.setNeedsLayout()
//            toView.layoutIfNeeded()
            if index == 1 {
                self.secondVm.startScrollersIfNeeded()
            }
            switch index {
            case 2: self.thirdVm.startEntranceAnimation()
            case 3: self.fourthVm.startEntranceAnimation()
            case 4: self.fifthVm.startEntranceAnimation()
            case 5: self.sixthVm.startEntranceAnimation()
            case 6: self.sevenVm.startEntranceAnimation()
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
        if index >= 2 {
            progressVm.isHidden = false
            progressVm.setStep(step: index)
        } else {
            progressVm.isHidden = true
        }
        EventLogUtils().sendEventLogRequest(eventName: .PAGE_VIEW,
                                            scenarioType: .guide_view,
                                            text: "\(currentIndex+1)")
    }
    /// Display a specific step without cross-fade animation
    func showStep(_ index: Int, animated: Bool) {
        guard index != currentIndex else { return }

        // Ensure all pages are visible when switching without animation
        [firstVm, secondVm, thirdVm, fourthVm, fifthVm, sixthVm, sevenVm].forEach { $0.alpha = 1 }

        scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(index), y: 0), animated: true)

        if index == 1 {
            self.secondVm.startScrollersIfNeeded()
        }
        currentIndex = index
        if index >= 2 {
            progressVm.isHidden = false
            progressVm.setStep(step: index, animated: animated)
        } else {
            progressVm.isHidden = true
        }
    }
}

extension GuideTotalVC{
    func initUI() {
        
        view.addSubview(scrollViewBase)
        view.addSubview(progressVm)
        
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.bounces = false
        scrollViewBase.delegate = self
        scrollViewBase.isScrollEnabled = false
        scrollViewBase.showsHorizontalScrollIndicator = false
        scrollViewBase.addSubview(firstVm)
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.addSubview(secondVm)
        scrollViewBase.addSubview(thirdVm)
        scrollViewBase.addSubview(fourthVm)
        scrollViewBase.addSubview(fifthVm)
        scrollViewBase.addSubview(sixthVm)
        scrollViewBase.addSubview(sevenVm)
        
        scrollViewBase.contentSize = CGSize.init(width: SCREEN_WIDHT*7, height: 0)
    }
}

extension GuideTotalVC:UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > SCREEN_WIDHT*1.8{
            self.progressVm.isHidden = false
            self.progressVm.setStep(step: Int(scrollView.contentOffset.x/SCREEN_WIDHT))
        }else{
            self.progressVm.isHidden = true
        }
    }
}
