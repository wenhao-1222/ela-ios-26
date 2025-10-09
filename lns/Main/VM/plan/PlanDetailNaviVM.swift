//
//  PlanDetailNaviVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/11.
//

import Foundation
import UIKit

class PlanDetailNaviVM: UIView {
    
    let selfHeight = kFitWidth(44)
    
    var pname = ""
    
    var deleteBlock:(()->())?
    var shareBlock:(()->())?
    var cancelBlock:(()->())?
    var updateTitleBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var backButton : NaviBackButton = {
        let btn = NaviBackButton.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(44), height: kFitWidth(44)))
        
        return btn
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColor_16(colorStr: "222222")
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        
        return lab
    }()
    lazy var titleTapView: FeedBackView = {
        let vi = FeedBackView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        vi.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(editTitleAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var deleteButton : FeedBackButton = {
        let button = FeedBackButton()
        button.setImage(UIImage(named: "plan_detail_delete_icon"), for: .normal)
        button.setTitle("删除", for: .normal)
        button.setTitleColor(.THEME, for: .normal)
        button.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        button.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        
        return button
    }()
    lazy var shareButton : FeedBackButton = {
        let button = FeedBackButton()
        button.setImage(UIImage(named: "plan_detail_share_icon"), for: .normal)
        button.setTitle("分享", for: .normal)
        button.setTitleColor(.THEME, for: .normal)
        button.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        button.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        return button
    }()
    lazy var cancelButton : FeedBackButton = {
        let button = FeedBackButton()
//        button.setImage(UIImage(named: "plan_detail_cancel_icon"), for: .normal)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(.THEME, for: .normal)
        button.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        button.isHidden = true
        button.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return button
    }()
}

extension PlanDetailNaviVM{
    @objc func deleteAction() {
        if self.deleteBlock != nil{
            self.deleteBlock!()
        }
    }
    @objc func shareAction() {
        if self.shareBlock != nil{
            self.shareBlock!()
        }
    }
    @objc func cancelAction() {
        if self.cancelBlock != nil{
            self.cancelBlock!()
        }
    }
    @objc func editTitleAction() {
        if self.updateTitleBlock != nil{
            self.updateTitleBlock!()
        }
    }
}

extension PlanDetailNaviVM{
    func initUI() {
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(deleteButton)
        addSubview(shareButton)
        addSubview(cancelButton)
        addSubview(titleTapView)
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(backButton.snp.right)
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalTo(kFitWidth(-150))
//            make.right.equalTo(deleteButton.snp.left).offset(kFitWidth(-18))
        }
        shareButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-10))
            make.top.height.equalToSuperview()
            make.width.equalTo(kFitWidth(64))
        }
        cancelButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-10))
            make.top.height.equalToSuperview()
            make.width.equalTo(kFitWidth(64))
        }
        deleteButton.snp.makeConstraints { make in
            make.right.equalTo(shareButton.snp.left).offset(kFitWidth(-6))
            make.width.top.height.equalTo(shareButton)
        }
        titleTapView.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.bottom.equalToSuperview()
        }
    }
    func changeStatus(isUpdate:Bool) {
        deleteButton.isHidden = isUpdate
        shareButton.isHidden = isUpdate
        cancelButton.isHidden = !isUpdate
        
        self.backButton.isHidden = isUpdate
        titleTapView.isHidden = !isUpdate
        
        
        if isUpdate{
            titleLabel.snp.remakeConstraints { make in
                make.left.equalTo(backButton.snp.right)
                make.centerY.lessThanOrEqualToSuperview()
                make.right.equalTo(kFitWidth(-90))
            }
        }else{
            titleLabel.snp.remakeConstraints { make in
                make.left.equalTo(backButton.snp.right)
                make.centerY.lessThanOrEqualToSuperview()
                make.right.equalTo(kFitWidth(-150))
            }
        }
//        titleLabel.text = pname
    }
}
