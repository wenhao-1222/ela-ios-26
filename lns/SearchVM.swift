//
//  SearchVM.swift
//  kxf
//
//  Created by Mac on 2024/3/7.
//

import Foundation
import UIKit
import MCToast

class SearchVM: UIView {
    
    var controller = WHBaseViewVC()
    let selfWidth = kFitWidth(335)
    var selfHeight = kFitWidth(36)
    
    var searchBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: kFitWidth(20), y: frame.origin.y, width: selfWidth, height: selfHeight))
        self.backgroundColor = .COLOR_LIGHT_GREY
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(19)
        self.clipsToBounds = true
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var textField : UITextField = {
        let text = UITextField()
        text.placeholder = "搜索"
//        text.textColor = .COLOR_TEXT_BLACK333
        text.font = .systemFont(ofSize: 15)
        text.returnKeyType = .search
        text.delegate = self
        text.autocapitalizationType = .none
        
        return text
    }()
    lazy var searchImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "search_icon")
        img.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(searchTapAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
}

extension SearchVM{
    @objc func searchTapAction(){
        if self.searchBlock != nil{
            self.searchBlock!()
        }
        self.textField.resignFirstResponder()
    }
}
extension SearchVM{
    func initUI(){
        addSubview(textField)
        addSubview(searchImgView)
        
        setConstrait()
    }
    func setConstrait() {
        textField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalTo(kFitWidth(-100))
        }
        searchImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
    }
}

extension SearchVM:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTapAction()
        
        return true
    }
}
