//
//  FoodsListFooterVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/25.
//

import Foundation
import UIKit

class FoodsListFooterVM: UIView {
    
    var selfHeight = kFitWidth(100)+WHUtils().getBottomSafeAreaHeight()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var contentLabel: UILabel = {
        let lab = UILabel()
        lab.text = "- 已加载全部数据 -"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()
    lazy var searchFoodsButton: GJVerButton = {
        let btn = GJVerButton()
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.setImage(UIImage(named: "foods_search_quickly_icon"), for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT, for: .highlighted)
        btn.isHidden = true
        
        return btn
    }()
}

extension FoodsListFooterVM{
    func setNoDataText(text:String) {
        if text.count > 0 {
            searchFoodsButton.isHidden = false
            contentLabel.isHidden = true
            searchFoodsButton.setTitle("从全部食物里搜索：“\(text)”", for: .normal)
            searchFoodsButton.imagePosition(style: .left, spacing: kFitWidth(5))
        }else{
            searchFoodsButton.isHidden = true
            contentLabel.isHidden = false
        }
    }
}

extension FoodsListFooterVM{
    func initUI() {
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(kFitWidth(-12)-WHUtils().getBottomSafeAreaHeight())
        }
        addSubview(searchFoodsButton)
        searchFoodsButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
//            make.top.height.equalToSuperview()
            make.centerY.lessThanOrEqualToSuperview()
            make.height.equalTo(kFitWidth(30))
        }
    }
}
