//
//  LogsEditHeadView.swift
//  lns
//
//  Created by LNS2 on 2024/4/30.
//

import Foundation
import UIKit

class LogsEditHeadView: UIView {
    
    let selfHeight = kFitWidth(40)
    
    var isSelect = false
    var tapBlock:((Bool)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var selecImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "logs_edit_all_normal")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var choiceBtn : GJVerButton = {
        let btn = GJVerButton()
        btn.setTitle("全选", for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.45), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.25), for: .highlighted)
//        btn.imagePosition(style: .left, spacing: kFitWidth(4))
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        return btn
    }()
    lazy var tapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
}

extension LogsEditHeadView{
    @objc func tapAction() {
        isSelect = !isSelect
        
        selecImgView.setCheckState(isSelect,
                                  checkedImageName: "logs_edit_selected",
                                  uncheckedImageName: "logs_edit_all_normal")
        
        if self.tapBlock != nil{
            self.tapBlock!(self.isSelect)
        }
    }
    func setSelectStatus(isAllSelect:Bool) {
        isSelect = isAllSelect
        
        selecImgView.setCheckState(isSelect,
                                  checkedImageName: "logs_edit_selected",
                                  uncheckedImageName: "logs_edit_all_normal")
    }
}
extension LogsEditHeadView{
    func initUI() {
        addSubview(selecImgView)
        addSubview(choiceBtn)
        addSubview(tapView)
        
        selecImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(14))
            make.bottom.equalTo(kFitWidth(0))
            make.width.height.equalTo(kFitWidth(23))
        }
        choiceBtn.snp.makeConstraints { make in
            make.left.equalTo(selecImgView.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(selecImgView)
        }
        
        tapView.snp.makeConstraints { make in
            make.left.top.height.equalToSuperview()
            make.right.equalTo(choiceBtn).offset(kFitWidth(20))
        }
    }
}
