//
//  MainTopVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/9.
//

import Foundation
import UIKit

class MainTopVM: FeedBackView {
    
    let selfHeight = kFitWidth(56)+WHUtils().getNavigationBarHeight()
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .THEME
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var bgImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "main_top_bg")
        img.isUserInteractionEnabled = true
//        img.contentMode = .scaleAspectFit
        img.isHidden = false
        
        return img
    }()
    lazy var logoImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "main_top_logo")
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleToFill
        
        return img
    }()
    lazy var searchWhiteView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(18)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    
    lazy var searchImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "main_search_icon")
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFit
        
        return img
    }()
    lazy var textField : UITextField = {
        let text = UITextField()
        text.textColor = .COLOR_GRAY_BLACK_85
        text.font = .systemFont(ofSize: 14, weight: .regular)
        text.placeholder = "搜索食物信息"
        text.isEnabled = false
        
        return text
    }()
}

extension MainTopVM{
    @objc func tapAction(){
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
}

extension MainTopVM{
    func initUI() {
        addSubview(bgImgView)
        addSubview(logoImgView)
        addSubview(searchWhiteView)
        searchWhiteView.addSubview(searchImgView)
        searchWhiteView.addSubview(textField)
        
//        DLLog(message: "\(WHUtils.getTopSafeAreaHeight())")
//        DLLog(message: "\(WHUtils().getNavigationBarHeight())")
        
        setConstrait()
    }
    func setConstrait() {
//        if WHUtils.getTopSafeAreaHeight() > 0 {
//            bgImgView.snp.makeConstraints { make in
//                make.left.bottom.width.equalToSuperview()
//                make.height.equalToSuperview()
//            }
//        }else{
            bgImgView.snp.makeConstraints { make in
                make.left.bottom.width.equalToSuperview()
                make.height.equalTo(kFitWidth(144))
            }
//        }
        logoImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(statusBarHeight+kFitWidth(5))
            make.width.equalTo(kFitWidth(148))
            make.height.equalTo(kFitWidth(33))
        }
        searchWhiteView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(4)+WHUtils().getNavigationBarHeight())
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(36))
        }
        searchImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(16))
        }
        textField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(42))
            make.top.height.equalToSuperview()
            make.right.equalTo(kFitWidth(-40))
        }
    }
}
