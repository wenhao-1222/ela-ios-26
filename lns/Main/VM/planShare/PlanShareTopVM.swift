//
//  PlanShareTopVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/16.
//

import Foundation
import UIKit

class PlanShareTopVM: UIView {
    
    let selfHeight = kFitWidth(332)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgImgView: UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: kFitWidth(0), y: kFitWidth(0), width: self.frame.size.width, height: kFitWidth(320)))
        img.setImgLocal(imgName: "plan_share_bg_img")
        return img
    }()
    
    lazy var nameVm : PlanShareDetailsNameVM = {
        let vm = PlanShareDetailsNameVM.init(frame: CGRect.init(x: (self.frame.width-kFitWidth(280))*0.5, y: kFitWidth(88), width: kFitWidth(280), height: kFitWidth(28)))
        
        return vm
    }()
    lazy var contentWhiteView : PlanShareDetailsContentVM = {
        let vm  = PlanShareDetailsContentVM.init(frame: CGRect.init(x: (self.frame.width-kFitWidth(280))*0.5, y: kFitWidth(124), width: kFitWidth(280), height: kFitWidth(170)))
        
        return vm
    }()
}
extension PlanShareTopVM{
    func updateUI(dict:NSDictionary) {
        nameVm.refreshUI(name: dict["nickname"]as? String ?? "用户名称", avatar: dict["avatar"]as? String ?? "")
        contentWhiteView.refreshUI(dict: dict)
    }
    func refreshUIForLogs(dict:NSDictionary){
        nameVm.refreshUI(name: dict["nickname"]as? String ?? "用户名称", avatar: dict["avatar"]as? String ?? "")
        contentWhiteView.refreshUIForLogs(dict: dict)
    }
}

extension PlanShareTopVM{
    func initUI() {
        addSubview(bgImgView)
        bgImgView.addSubview(nameVm)
        bgImgView.addSubview(contentWhiteView)
        
        
    }
}
