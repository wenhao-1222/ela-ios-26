//
//  PlanSearchVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/11.
//

import Foundation
import UIKit

class PlanSearchVM: UIView {
    
    let selfHeight = kFitWidth(44)
    
    var backBlock:(()->())?
    var searchBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var seachBgView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(18)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var seachImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "main_search_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var textField: ChineseTextField = {
        let text = ChineseTextField()
        text.placeholder = "搜索饮食计划"
        text.textColor = .COLOR_GRAY_BLACK_85
        text.font = .systemFont(ofSize: 14, weight: .regular)
        text.returnKeyType = .search
        text.delegate = self
        text.textContentType = nil
        text.textNumber = 50
        
        return text
    }()
    lazy var clearImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "search_clear_icon")
        img.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clearAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var cancelButton : UIButton = {
        let btn = UIButton()
        btn.setTitle("取消", for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        return btn
    }()
}

extension PlanSearchVM{
    @objc func cancelAction() {
        if self.backBlock != nil{
            self.backBlock!()
        }
    }
    @objc func clearAction(){
        self.textField.text = ""
    }
    @objc func searchTapAction(){
        if self.searchBlock != nil{
            self.searchBlock!()
        }
        self.textField.resignFirstResponder()
    }
}
extension PlanSearchVM{
    func initUI() {
        addSubview(seachBgView)
        seachBgView.addSubview(seachImgView)
        seachBgView.addSubview(textField)
        seachBgView.addSubview(clearImgView)
        
        addSubview(cancelButton)
        
        setConstrait()
    }
    func setConstrait() {
        seachBgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
            make.height.equalTo(kFitWidth(36))
            make.width.equalTo(kFitWidth(295))
        }
        seachImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.width.height.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        textField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(36))
            make.top.height.equalToSuperview()
            make.right.equalTo(kFitWidth(-40))
        }
        clearImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-8))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
        cancelButton.snp.makeConstraints { make in
            make.right.top.height.equalToSuperview()
            make.left.equalTo(seachBgView.snp.right)
        }
    }
}

extension PlanSearchVM:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTapAction()
        
        return true
    }
}
