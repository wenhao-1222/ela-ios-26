//
//  InviteRewardsRuleAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/21.
//

import Foundation
import UIKit
import WebKit

class InviteRewardsRuleAlertVM: UIView {
    
    let lineGap = kFitWidth(6)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "", alpha: 1)
        self.isUserInteractionEnabled = true
        self.clipsToBounds = false
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenLoginView))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        scrollView.contentSize = CGSize.init(width: 0, height: tipsLabel.frame.maxY+kFitWidth(20))
    }
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: WHUtils().getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(whiteViewTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var topLineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "D9D9D9")
        vi.layer.cornerRadius = kFitWidth(2)
        
        return vi
    }()
    lazy var topTapView : UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenLoginView))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "邀请奖励规则"
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        
        return lab
    }()
    lazy var scrollView: UIScrollView = {
        let vi = UIScrollView.init(frame: CGRect.init(x: 0, y: kFitWidth(80), width: SCREEN_WIDHT, height: SCREEN_HEIGHT - kFitWidth(70) - WHUtils().getNavigationBarHeight() - kFitWidth(72) - WHUtils().getBottomSafeAreaHeight()))
        vi.backgroundColor = .white
        
        return vi
    }()
    //var wkWebView = WKWebView()
    lazy var wkWebView: WKWebView = {
        let webView = WKWebView.init(frame: CGRect.init(x: 0, y: kFitWidth(80), width: SCREEN_WIDHT, height: SCREEN_HEIGHT - kFitWidth(70) - WHUtils().getNavigationBarHeight() - kFitWidth(72) - WHUtils().getBottomSafeAreaHeight()))
        let url = URL(string: URL_reward_rule as String)
        let request = URLRequest(url: url!)
        webView.load(request)
        
        return webView
    }()
    
    lazy var gotItButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("我知道了", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.addTarget(self, action: #selector(hiddenLoginView), for: .touchUpInside)
        return btn
    }()
    lazy var titleOneVm: InviteRewardsRuleAlertTitleVm = {
        let vm = InviteRewardsRuleAlertTitleVm.init(frame: .zero)
        vm.titleLabel.text = "活动目的"
        
        return vm
    }()
    lazy var contentLabelOne: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        let content = "本活动旨在通过激励用户邀请他人注册和使用我们的服务，增加用户数量，提高用户活跃度和用户留存率。"
        lab.attributedText = content.mc_setLineSpace(lineSpace: lineGap)
        
        return lab
    }()
    lazy var titleTwoVm: InviteRewardsRuleAlertTitleVm = {
        let vm = InviteRewardsRuleAlertTitleVm.init(frame: .zero)
        vm.titleLabel.text = "活动规则"
        
        return vm
    }()
    
    lazy var contentLabelTwo: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        let content = "· 活动期间：从2024年6月18日开始，持续90天。\n· 活动对象：所有已注册，且通过 Elavatine平台选中并验证的用户。\n· 活动奖励：用户成功邀请一位新用户注册并使用服务，邀请者可获得相应的奖励。\n· 邀请方式：用户可以通过个人邀请码邀请他人注册。\n· 奖励发放：奖励将在被邀请者成功使用邀请码注册并使用服务后具体系统并显示。"
        lab.attributedText = content.mc_setLineSpace(lineSpace: lineGap)
        
        return lab
    }()
    lazy var titleThreeVm: InviteRewardsRuleAlertTitleVm = {
        let vm = InviteRewardsRuleAlertTitleVm.init(frame: .zero)
        vm.titleLabel.text = "奖励设置"
        
        return vm
    }()
    
    lazy var contentLabelThree: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        let attr = NSMutableAttributedString.init(attributedString: ("邀请者奖励\n").mc_setLineSpace(lineSpace: lineGap))
        let attr1 = NSMutableAttributedString.init(attributedString: ("· 邀请一位新用户成功注册并使用服务，邀请者将获得1-2元奖励。\n").mc_setLineSpace(lineSpace: lineGap))
        let attr2 = NSMutableAttributedString.init(attributedString:("额外奖励\n").mc_setLineSpace(lineSpace: lineGap))
        let attr3 = NSMutableAttributedString.init(attributedString: ("· 当您邀请的用户成功通过邀请码邀请他人加入并使用我们的服务时，您也将获得奖励。").mc_setLineSpace(lineSpace: lineGap))
        
        attr.yy_font = .systemFont(ofSize: 14, weight: .medium)
        attr.yy_color = .COLOR_GRAY_BLACK_85
        
        attr1.yy_font = .systemFont(ofSize: 14, weight: .regular)
        attr1.yy_color = .COLOR_GRAY_BLACK_65
        
        attr2.yy_font = .systemFont(ofSize: 14, weight: .medium)
        attr2.yy_color = .COLOR_GRAY_BLACK_85
        
        attr3.yy_font = .systemFont(ofSize: 14, weight: .regular)
        attr3.yy_color = .COLOR_GRAY_BLACK_65
        
        attr.append(attr1)
        attr.append(attr2)
        attr.append(attr3)
        
        lab.attributedText = attr
        attr.yy_setLineSpacing(lineGap, range: NSMakeRange(0, attr.length))
        
        return lab
    }()
    
    lazy var titleFourVm: InviteRewardsRuleAlertTitleVm = {
        let vm = InviteRewardsRuleAlertTitleVm.init(frame: .zero)
        vm.titleLabel.text = "邀请名额"
        
        return vm
    }()
    lazy var contentLabelFour: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        let content = "· 每一位通过验证并参与本次活动的用户将获得一定名额，其已邀请的人数和剩余名额将在邀请奖励页面中显示。"
        lab.attributedText = content.mc_setLineSpace(lineSpace: lineGap)
        
        return lab
    }()
    
    lazy var titleFiveVm: InviteRewardsRuleAlertTitleVm = {
        let vm = InviteRewardsRuleAlertTitleVm.init(frame: .zero)
        vm.titleLabel.text = "注意事项"
        
        return vm
    }()
    lazy var contentLabelFive: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        let content = "· 活动奖励具有一定的时效性，过期无效。\n· 奖励最迟不会超过在活动结束后的一个月内以现金形式通过微信支付或其他渠道发放给邀请者。\n· 本次活动拟安排奖金200万元，派完即止。\n· 活动最终解释权归本公司所有。"
        lab.attributedText = content.mc_setLineSpace(lineSpace: lineGap)
        
        return lab
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "以上是邀请奖励活动方案的详细内容\n感谢您的支持和参与！"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()
}

extension InviteRewardsRuleAlertVM{
    @objc func showLoginView() {
        self.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: WHUtils().getNavigationBarHeight()+(SCREEN_HEIGHT-WHUtils().getTabbarHeight())*0.5)
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        }
   }
   @objc func hiddenLoginView() {
       UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
           self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5)
           self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
       }completion: { t in
           self.isHidden = true
       }
  }
    @objc func whiteViewTapAction(){
        
    }
}

extension InviteRewardsRuleAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(topLineView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(scrollView)
        whiteView.addSubview(gotItButton)
        whiteView.addSubview(topTapView)
        whiteView.addSubview(wkWebView)
        
//        scrollView.addSubview(titleOneVm)
//        scrollView.addSubview(contentLabelOne)
//        scrollView.addSubview(titleTwoVm)
//        scrollView.addSubview(contentLabelTwo)
//        scrollView.addSubview(titleThreeVm)
//        scrollView.addSubview(contentLabelThree)
//        scrollView.addSubview(titleFourVm)
//        scrollView.addSubview(contentLabelFour)
//        scrollView.addSubview(titleFiveVm)
//        scrollView.addSubview(contentLabelFive)
//        scrollView.addSubview(tipsLabel)
        
        whiteView.addClipCorner(corners: [.topLeft,.topRight], radius: kFitWidth(16))
        setConstrait()
        
        setNeedsLayout()
    }
    
    func setConstrait() {
        topLineView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(18))
            make.width.equalTo(kFitWidth(43))
            make.height.equalTo(kFitWidth(4))
            make.centerX.lessThanOrEqualToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(40))
            make.centerX.lessThanOrEqualToSuperview()
        }
        topTapView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(kFitWidth(40))
        }
        gotItButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(kFitWidth(-12)-WHUtils().getBottomSafeAreaHeight())
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(48))
        }
//        titleOneVm.snp.makeConstraints { make in
//            make.left.top.equalToSuperview()
//            make.height.equalTo(titleOneVm.selfHeight)
//        }
//        contentLabelOne.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(16))
//            make.top.equalTo(titleOneVm.snp.bottom).offset(kFitWidth(10))
//            make.width.equalTo(kFitWidth(343))
//        }
//        titleTwoVm.snp.makeConstraints { make in
//            make.left.height.equalTo(titleOneVm)
//            make.top.equalTo(contentLabelOne.snp.bottom).offset(kFitWidth(20))
//        }
//        contentLabelTwo.snp.makeConstraints { make in
//            make.left.right.equalTo(contentLabelOne)
//            make.top.equalTo(titleTwoVm.snp.bottom).offset(kFitWidth(10))
//        }
//        titleThreeVm.snp.makeConstraints { make in
//            make.left.height.equalTo(titleOneVm)
//            make.top.equalTo(contentLabelTwo.snp.bottom).offset(kFitWidth(20))
//        }
//        contentLabelThree.snp.makeConstraints { make in
//            make.right.equalTo(contentLabelOne)
//            make.left.equalTo(kFitWidth(28))
//            make.top.equalTo(titleThreeVm.snp.bottom).offset(kFitWidth(10))
//        }
//        titleFourVm.snp.makeConstraints { make in
//            make.left.height.equalTo(titleOneVm)
//            make.top.equalTo(contentLabelThree.snp.bottom).offset(kFitWidth(20))
//        }
//        contentLabelFour.snp.makeConstraints { make in
//            make.left.right.equalTo(contentLabelOne)
//            make.top.equalTo(titleFourVm.snp.bottom).offset(kFitWidth(10))
//        }
//        titleFiveVm.snp.makeConstraints { make in
//            make.left.height.equalTo(titleOneVm)
//            make.top.equalTo(contentLabelFour.snp.bottom).offset(kFitWidth(20))
//        }
//        contentLabelFive.snp.makeConstraints { make in
//            make.left.right.equalTo(contentLabelOne)
//            make.top.equalTo(titleFiveVm.snp.bottom).offset(kFitWidth(10))
//        }
//        tipsLabel.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
//            make.top.equalTo(contentLabelFive.snp.bottom).offset(kFitWidth(40))
//        }
    }
}
