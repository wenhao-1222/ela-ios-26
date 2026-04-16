//
//  MineElaProVC.swift
//  lns
//
//  Created by Codex on 2026/4/14.
//

import UIKit
import SnapKit

struct MineElaProFeature {
    let iconName: String
    let title: String
    let subtitle: String?
}

class MineElaProVC: WHBaseViewVC {
    private let coachFeatures: [MineElaProFeature] = [
        MineElaProFeature(iconName: "survey_subscription_coach_ic_01",
                          title: "每周复盘",
                          subtitle: "结合饮食训练变化，系统复盘进度"),
        MineElaProFeature(iconName: "survey_subscription_coach_ic_02",
                          title: "卡点预警",
                          subtitle: "多维数据早发现，瓶颈前先介入"),
        MineElaProFeature(iconName: "survey_subscription_coach_ic_03",
                          title: "体重去噪",
                          subtitle: "分清真实进度，减少结果焦虑"),
        MineElaProFeature(iconName: "survey_subscription_coach_ic_04",
                          title: "持续微调",
                          subtitle: "越用越懂你，你只需照做")
    ]
    
    private let mealPlanFeatures: [MineElaProFeature] = [
        MineElaProFeature(iconName: "survey_subscription_mealplan_ic_01",
                          title: "定制每周食谱",
                          subtitle: "每天不重样，照着吃就行"),
        MineElaProFeature(iconName: "survey_subscription_mealplan_ic_02",
                          title: "消除选择困难",
                          subtitle: "不用每天纠结吃什么"),
        MineElaProFeature(iconName: "survey_subscription_mealplan_ic_03",
                          title: "平衡家庭与健康饮食",
                          subtitle: "和家人同桌，也能精准对齐目标"),
        MineElaProFeature(iconName: "survey_subscription_mealplan_ic_04",
                          title: "节省外卖支出",
                          subtitle: "每月省下上千元外卖费用"),
        MineElaProFeature(iconName: "survey_subscription_mealplan_ic_05",
                          title: "整理购物清单",
                          subtitle: "提前列好未来一周所需食材"),
        MineElaProFeature(iconName: "survey_subscription_mealplan_ic_06",
                          title: "快速记录",
                          subtitle: "无需手动搜索，一键把每餐加入日志")
    ]
    
    private let moreFeatures: [MineElaProFeature] = [
        MineElaProFeature(iconName: "survey_subscription_more_ic_01",
                          title: "无广告",
                          subtitle: nil),
        MineElaProFeature(iconName: "survey_subscription_more_ic_02",
                          title: "解锁AI识图上限",
                          subtitle: nil)
    ]
    
    private lazy var contentView: UIView = {
        let vi = UIView()
        return vi
    }()
    
    private lazy var heroCardView: MineElaProHeroCardView = {
        let vi = MineElaProHeroCardView()
        vi.planTapBlock = { [weak self] in
            let vc = MineSubscriptionPlanVC()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        return vi
    }()
    
    private lazy var coachSectionView = MineElaProSectionBlockView(title: "ELA PRO 将帮助你：",
                                                                   features: coachFeatures)
    private lazy var mealPlanSectionView = MineElaProSectionBlockView(title: "以及ELA 智能饮食计划：",
                                                                      features: mealPlanFeatures)
    private lazy var moreSectionView = MineElaProSectionBlockView(title: "和更多：",
                                                                  features: moreFeatures)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        topGradientLayer.frame = topGradientView.bounds
//        bottomGradientLayer.frame = bottomGradientView.bounds
//    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        bottomGradientLayer.colors = [
//            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
//            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
//        ]
//        topGradientLayer.colors = [
//            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
//            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
//        ]
//    }
    
//    lazy var bottomGradientView: UIView = {
//        let vi = UIView()
//        vi.isUserInteractionEnabled = false
//        return vi
//    }()
//    lazy var topGradientView: UIView = {
//        let vi = UIView()
//        vi.isUserInteractionEnabled = false
//        return vi
//    }()
//    lazy var bottomGradientLayer: CAGradientLayer = {
//        let layer = CAGradientLayer()
//        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
//        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
//        layer.colors = [
//            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
//            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
//        ]
//        layer.locations = [0, 1]
//        return layer
//    }()
//    lazy var topGradientLayer: CAGradientLayer = {
//        let layer = CAGradientLayer()
//        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
//        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
//        layer.colors = [
//            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
//            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
//        ]
//        layer.locations = [0, 1]
//        return layer
//    }()
}

private extension MineElaProVC {
    func initUI() {
        initNavi(titleStr: "我的 ELA PRO", naviBgColor: .COLOR_BG_F2)
        view.backgroundColor = .COLOR_BG_F2
        scrollViewBase.backgroundColor = .COLOR_BG_F2
        
        view.addSubview(scrollViewBase)
        scrollViewBase.addSubview(contentView)
        
//        view.addSubview(topGradientView)
//        view.addSubview(bottomGradientView)
//        bottomGradientView.layer.addSublayer(bottomGradientLayer)
//        topGradientView.layer.addSublayer(topGradientLayer)
        
        contentView.addSubview(heroCardView)
        contentView.addSubview(coachSectionView)
        contentView.addSubview(mealPlanSectionView)
        contentView.addSubview(moreSectionView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollViewBase)
        }
        
        heroCardView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(25))
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(120))
        }
        
        coachSectionView.snp.makeConstraints { make in
            make.top.equalTo(heroCardView.snp.bottom).offset(kFitWidth(28))
            make.left.right.equalTo(heroCardView)
        }
        
        mealPlanSectionView.snp.makeConstraints { make in
            make.top.equalTo(coachSectionView.snp.bottom).offset(kFitWidth(28))
            make.left.right.equalTo(heroCardView)
        }
        
        moreSectionView.snp.makeConstraints { make in
            make.top.equalTo(mealPlanSectionView.snp.bottom).offset(kFitWidth(28))
            make.left.right.equalTo(heroCardView)
            make.bottom.equalToSuperview().offset(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(20)))
        }
//        topGradientView.snp.makeConstraints { make in
//            make.left.right.equalToSuperview()
//            make.top.equalTo(scrollViewBase.snp.top)
//            make.height.equalTo(kFitWidth(35))
//        }
//        bottomGradientView.snp.makeConstraints { make in
//            make.left.right.equalToSuperview()
//            make.bottom.equalTo(scrollViewBase)
//            make.height.equalTo(kFitWidth(35))
////            make.top.equalTo(scrollView.snp.bottom).offset(kFitWidth(-35))
//        }
    }
}
