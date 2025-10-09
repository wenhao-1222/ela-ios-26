//
//  FoodsListHeaderNoDataVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/23.
//


import Foundation
import UIKit

class FoodsListHeaderNoDataVM: UIView {
    
    var selfHeight = kFitWidth(58)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var searchFoodsButton: GJVerButton = {
        let btn = GJVerButton()
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.setImage(UIImage(named: "foods_search_quickly_icon"), for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT, for: .highlighted)
        
        return btn
    }()
}

extension FoodsListHeaderNoDataVM{
    func setNoDataText(text:String) {
        searchFoodsButton.setTitle("从全部食物里搜索：“\(text)”", for: .normal)
        searchFoodsButton.imagePosition(style: .left, spacing: kFitWidth(5))
    }
}

extension FoodsListHeaderNoDataVM{
    func initUI() {
        addSubview(searchFoodsButton)
        searchFoodsButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
//            make.top.height.equalToSuperview()
            make.centerY.lessThanOrEqualToSuperview()
            make.height.equalTo(kFitWidth(30))
        }
    }
}
