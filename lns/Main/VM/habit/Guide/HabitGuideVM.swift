//
//  HabitGuideVM.swift
//  lns
//
//  Created by LNS2 on 2026/1/16.
//


class HabitGuideVM: UIView {
    
    /// Current displayed page index
    private var currentIndex: Int = 0
    var backBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .COLOR_BG_F5
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var backButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "habit_guide_back_icon"), for: .normal)
        btn.alpha = 0
        
        btn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        scro.backgroundColor = .clear
        scro.isPagingEnabled = true
        return scro
    }()
    lazy var firstVm: HabitGuideFirstVM = {
        let vm = HabitGuideFirstVM.init(frame: .zero)
        vm.isUserInteractionEnabled = false
        vm.prepareEntranceAnimation()
        vm.tapBlock = {()in
            self.animateTransition(to: 1)
        }
        return vm
    }()
    lazy var secondVm: HabitGuideSecondVM = {
        let vm = HabitGuideSecondVM.init(frame: .zero)
        vm.tapBlock = {()in
            self.animateTransition(to: 2)
        }
        return vm
    }()
    lazy var thirdVm: HabitGuideThirdVM = {
        let vm = HabitGuideThirdVM.init(frame: .zero)
        vm.tapBlock = {()in
            self.animateTransition(to: 3)
        }
        return vm
    }()
    lazy var fourVm: HabitGuideFourVM = {
        let vm = HabitGuideFourVM.init(frame: .zero)
        vm.tapBlock = {()in
            self.animateTransition(to: 4)
        }
        return vm
    }()
    lazy var fiveVm: HabitGuideFiveVM = {
        let vm = HabitGuideFiveVM.init(frame: .zero)
        vm.tapBlock = {()in
            UIView.animate(withDuration: 0.45, delay: 0) {
                self.alpha = 0
            } completion: { _ in
                UserDefaults.set(value: "1", forKey: .rank_list_guide)
                self.isHidden = true
            }
        }
        return vm
    }()
}

extension HabitGuideVM{
    func initUI() {
        addSubview(scrollView)
        scrollView.addSubview(firstVm)
        scrollView.addSubview(secondVm)
        scrollView.addSubview(thirdVm)
        scrollView.addSubview(fourVm)
        scrollView.addSubview(fiveVm)
        
        addSubview(backButton)
        scrollView.isScrollEnabled = false
        scrollView.contentSize = CGSize.init(width: SCREEN_WIDHT*5, height: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
            self.firstVm.startEntranceAnimation()
        })
        
        backButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(13))
            make.top.equalTo(kFitWidth(38))
            make.width.height.equalTo(kFitWidth(35))
        }
    }
}


extension HabitGuideVM{
    @objc func backAction() {
        if self.currentIndex > 1{
            self.showStep(self.currentIndex - 1, animated: true)
//            self.backButton.alpha = self.currentIndex - 1 == 0 ? 0 : 1
        }else{
            self.backBlock?()
        }
    }
    /// Animates transition between guide pages
    func animateTransition(to index: Int) {
        guard index != currentIndex else { return }
        self.backButton.isUserInteractionEnabled = false
        let fromView: UIView
        switch currentIndex {
        case 0: fromView = firstVm
        case 1: fromView = secondVm
        case 2: fromView = thirdVm
        case 3: fromView = fourVm
        case 4: fromView = fiveVm
        default: fromView = fiveVm
        }

        let toView: UIView
        switch index {
        case 1: toView = secondVm
        case 2: toView = thirdVm
        case 3: toView = fourVm
        case 4: toView = fiveVm
        default: toView = fiveVm
        }
        // Prepare entrance animations for upcoming view
        switch index {
        case 1: secondVm.prepareEntranceAnimation()
        case 2: thirdVm.prepareEntranceAnimation()
        case 3: fourVm.prepareEntranceAnimation()
        case 4: fiveVm.prepareEntranceAnimation()
        default: break
        }

        toView.alpha = 0
        UIView.animate(withDuration: 0.75, delay: 0,options: .curveEaseInOut) {
            fromView.alpha = 0
        }completion: { _ in
            self.scrollView.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(index), y: 0), animated: false)
        }
        let duration = index == 1 ? 0.75 : 0.01
        
        UIView.animate(withDuration: duration, delay: 0.6,options: .curveEaseInOut) {
            toView.alpha = 1
            self.backButton.alpha = 1
        }completion: { _ in
            self.backButton.isUserInteractionEnabled = true
            switch index {
            case 1: self.secondVm.startEntranceAnimation()
            case 2: self.thirdVm.startEntranceAnimation()
            case 3: self.fourVm.startEntranceAnimation()
            case 4: self.fiveVm.startEntranceAnimation()
            default: break
            }
        }

        currentIndex = index
    }
    /// Display a specific step without cross-fade animation
    func showStep(_ index: Int, animated: Bool) {
        guard index != currentIndex else { return }

        // Ensure all pages are visible when switching without animation
        [firstVm, secondVm,thirdVm,fourVm,fiveVm].forEach { $0.alpha = 1 }

        scrollView.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(index), y: 0), animated: true)

        currentIndex = index
//        self.backButton.alpha = currentIndex > 1 ? 1 : 0
    }
}

