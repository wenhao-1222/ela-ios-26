//
//  JournalShareTopVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/10.
//

import Foundation
import UIKit

class JournalShareTopVM: UIView {
    
    let selfHeight = kFitWidth(332)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var themeBgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(320), height: kFitWidth(60)))
        vi.backgroundColor = .THEME
        return vi
    }()
    lazy var bgImgView: UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: kFitWidth(0), y: kFitWidth(0), width: self.frame.size.width, height: kFitWidth(320)))
        img.setImgLocal(imgName: "logs_share_bg_img")

        return img
    }()
    lazy var sloganLabel: UILabel = {
        let lab = UILabel()
//        lab.text = "你身边的专业健康指导"
//        lab.text = "专业饮食记录方案"
//        lab.text = "专业健身饮食记录"
//        lab.text = "专业饮食记录平台"
        lab.text = "专业饮食记录系统"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 13)
        return lab
    }()
    lazy var nameVm : PlanShareDetailsNameVM = {
        let vm = PlanShareDetailsNameVM.init(frame: CGRect.init(x: (self.frame.width-kFitWidth(280))*0.5, y: kFitWidth(78), width: kFitWidth(280), height: kFitWidth(28)))
        
        return vm
    }() 
//    lazy var contentWhiteView : PlanShareDetailsContentVM = {
//        let vm  = PlanShareDetailsContentVM.init(frame: CGRect.init(x: (self.frame.width-kFitWidth(280))*0.5, y: kFitWidth(124), width: kFitWidth(280), height: kFitWidth(170)))
//        
//        return vm
//    }()
    
    lazy var contentWhiteNewView : JournalShareDetailsContentVM = {
        let vm  = JournalShareDetailsContentVM.init(frame: CGRect.init(x: (self.frame.width-kFitWidth(280))*0.5, y: kFitWidth(130), width: kFitWidth(280), height: kFitWidth(200)))
        
        return vm
    }()
}
extension JournalShareTopVM{
    func updateUI(dict:NSDictionary) {
        nameVm.refreshUI(name: dict["nickname"]as? String ?? "用户名称", avatar: dict["avatar"]as? String ?? "")
//        contentWhiteView.refreshUI(dict: dict)
        contentWhiteNewView.updateUI()
    }
    func refreshUIForLogs(dict:NSDictionary){
        nameVm.refreshUI(name: dict["nickname"]as? String ?? "用户名称", avatar: dict["avatar"]as? String ?? "")
//        contentWhiteView.refreshUIForLogsNew(dict: dict)
        contentWhiteNewView.refreshUIForLogsNew(dict: dict)
        
        DLLog(message: "refreshUIForLogs:\(dict)")
    }
}

extension JournalShareTopVM{
    func initUI() {
        addSubview(themeBgView)
        addSubview(bgImgView)
        bgImgView.addSubview(sloganLabel)
        bgImgView.addSubview(nameVm)
//        bgImgView.addSubview(contentWhiteView)
        bgImgView.addSubview(contentWhiteNewView)
        
        sloganLabel.snp.makeConstraints { make in
            make.bottom.equalTo(nameVm.snp.top).offset(kFitWidth(-10))
            make.centerX.lessThanOrEqualToSuperview()
        }
    }
}
