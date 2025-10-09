//
//  WelcomeLaunchVC.swift
//  lns
//
//  Created by Elavatine on 2024/10/25.
//

class WelcomeLaunchVC: WHBaseViewVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    lazy var firstItemVm: WelcomeLaunchItemVM = {
        let vm = WelcomeLaunchItemVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var secondItemVm: WelcomeLaunchItemVM = {
        let vm = WelcomeLaunchItemVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: 0, height: 0))
        vm.iconImgView.setImgLocal(imgName: "launch_welcome_img_2")
        vm.titleLabel.text = "记录饮食"
        vm.setContentString(textString: "每天只需花几分钟记录你吃的食物\n系统会自动计算摄入的营养素\n清晰对比你增肌或减脂所需的营养目标")
        return vm
    }()
    lazy var thirdItemVm: WelcomeLaunchItemVM = {
        let vm = WelcomeLaunchItemVM.init(frame: CGRect.init(x: SCREEN_WIDHT*2, y: 0, width: 0, height: 0))
        vm.iconImgView.setImgLocal(imgName: "launch_welcome_img_3")
        vm.titleLabel.text = "定制化目标"
        vm.setContentString(textString: "就算不知道自己的目标摄入也无需担心\n我们会根据你的需求智能推荐营养目标")
        vm.startBtn.isHidden = false
        vm.startBtn.addTarget(self, action: #selector(startBtnAction), for: .touchUpInside)
        return vm
    }()
    lazy var pageControl: UIPageControl = {
        let cont = UIPageControl(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(120), height: kFitWidth(40)))
        cont.pageIndicatorTintColor = .COLOR_LINE_GREY//COLOR_TEXT_GREY
        cont.currentPageIndicatorTintColor = .white
        cont.numberOfPages = 3
        cont.currentPage = 0
        return cont
    }()
}

extension WelcomeLaunchVC{
    @objc func startBtnAction() {
        UserDefaults.standard.setValue("1", forKey: isLaunchWelcome)
        self.changeRootVC()
    }
}
extension WelcomeLaunchVC{
    func initUI() {
        view.addSubview(scrollViewBase)
        view.addSubview(pageControl)
        pageControl.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT-getBottomSafeAreaHeight()-kFitWidth(30))
        
//        if UIColor.isDarkModeEnabled{
//            scrollViewBase.backgroundColor = WHColor_RGB(r: 28.0/255.0, g: 28.0/255.0, b: 64.0/255.0)
//        }else{
//            scrollViewBase.backgroundColor = .THEME
//        }
//        scrollViewBase.backgroundColor = UIColor(named: "launch_bg_theme_color")
        scrollViewBase.backgroundColor = .THEME_BG_DARK
        
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.showsHorizontalScrollIndicator = false
        
        scrollViewBase.addSubview(firstItemVm)
        scrollViewBase.addSubview(secondItemVm)
        scrollViewBase.addSubview(thirdItemVm)
        
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.contentSize = CGSize.init(width: SCREEN_WIDHT*3, height: 0)
        scrollViewBase.delegate = self
    }
    
    func changeRootVC() {
        let token = UserDefaults.standard.value(forKey: token) as? String ?? ""
        if token.count > 1 {
            let uId = UserDefaults.standard.value(forKey: userId) as? String ?? ""
            UserInfoModel.shared.uId = uId
            UserInfoModel.shared.token = token
            
            UserInfoModel.shared.mealsNumber = UserDefaults.getMealsNumber()
            UserInfoModel.shared.hidden_survery_button_status = UserDefaults.getSurveryStatus()
            UserInfoModel.shared.hiddenMeaTimeStatus = UserDefaults.getLogsTimeStatus()
            UserDefaults.initWeightUnit()
            
            WHBaseViewVC().changeRootVcToTabbar()
            WidgetUtils().saveUserInfo(uId: "\(uId)", uToken: "\(token)")
        }else{
            UserInfoModel.shared.uId = ""
            UserInfoModel.shared.token = ""
            
            WHBaseViewVC().changeRootVcToWelcome()
        }
    }
}

extension WelcomeLaunchVC:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > SCREEN_WIDHT*2.02{
            UserDefaults.standard.setValue("1", forKey: isLaunchWelcome)
            self.changeRootVC()
        }else{
            let currentPage = Int((scrollView.contentOffset.x + SCREEN_WIDHT*0.5)/SCREEN_WIDHT)
            pageControl.currentPage = currentPage
            
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                if currentPage == 2 {
                    self.pageControl.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT-kFitWidth(110)-self.getBottomSafeAreaHeight())
                }else{
                    self.pageControl.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT-self.getBottomSafeAreaHeight()-kFitWidth(30))
                }
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int((scrollView.contentOffset.x + SCREEN_WIDHT*0.5)/SCREEN_WIDHT)
        pageControl.currentPage = currentPage
    }
}
