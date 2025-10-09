//
//  QuestionnairePlanFoodsTypeVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/1.
//

import Foundation
import UIKit

class QuestionnairePlanFoodsTypeVM: UIView {
    
    var selfHeight = kFitWidth(240)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: kFitWidth(200), height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.addShadow()
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(200), height: kFitWidth(240)))
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        vi.alpha = 0
        
        return vi
    }()
    lazy var itemOneVm : QuestionnairePlanFoodsTypeItemVM = {
        let vm = QuestionnairePlanFoodsTypeItemVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.titleLabel.text = "蛋白质"
        return vm
    }()
    lazy var itemTwoVm : QuestionnairePlanFoodsTypeItemVM = {
        let vm = QuestionnairePlanFoodsTypeItemVM.init(frame: CGRect.init(x: 0, y: QuestionnairePlanFoodsTypeItemVM().selfHeight, width: 0, height: 0))
        vm.titleLabel.text = "脂肪"
        return vm
    }()
    lazy var itemThreeVm : QuestionnairePlanFoodsTypeItemVM = {
        let vm = QuestionnairePlanFoodsTypeItemVM.init(frame: CGRect.init(x: 0, y: QuestionnairePlanFoodsTypeItemVM().selfHeight*2, width: 0, height: 0))
        vm.titleLabel.text = "碳水"
        return vm
    }()
    lazy var itemFourVm : QuestionnairePlanFoodsTypeItemVM = {
        let vm = QuestionnairePlanFoodsTypeItemVM.init(frame: CGRect.init(x: 0, y: QuestionnairePlanFoodsTypeItemVM().selfHeight*3, width: 0, height: 0))
        vm.titleLabel.text = "蔬菜"
        return vm
    }()
    lazy var itemFiveVm : QuestionnairePlanFoodsTypeItemVM = {
        let vm = QuestionnairePlanFoodsTypeItemVM.init(frame: CGRect.init(x: 0, y: QuestionnairePlanFoodsTypeItemVM().selfHeight*4, width: 0, height: 0))
        vm.titleLabel.text = "水果"
        vm.lineView.isHidden = true
        return vm
    }()
    
}

extension QuestionnairePlanFoodsTypeVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(itemOneVm)
        whiteView.addSubview(itemTwoVm)
        whiteView.addSubview(itemThreeVm)
        whiteView.addSubview(itemFourVm)
        whiteView.addSubview(itemFiveVm)
    }
    func setNormal() {
        itemOneVm.selectImgView.isHidden = true
        itemOneVm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
        itemTwoVm.selectImgView.isHidden = true
        itemTwoVm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
        itemThreeVm.selectImgView.isHidden = true
        itemThreeVm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
        itemFourVm.selectImgView.isHidden = true
        itemFourVm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
        itemFiveVm.selectImgView.isHidden = true
        itemFiveVm.titleLabel.textColor = .COLOR_GRAY_BLACK_85
    }
    func setSelecteIndex(index:Int) {
        setNormal()
        switch index {
        case 1:
            itemOneVm.selectImgView.isHidden = false
            itemOneVm.titleLabel.textColor = .THEME
        case 2:
            itemTwoVm.selectImgView.isHidden = false
            itemTwoVm.titleLabel.textColor = .THEME
        case 3:
            itemThreeVm.selectImgView.isHidden = false
            itemThreeVm.titleLabel.textColor = .THEME
        case 4:
            itemFourVm.selectImgView.isHidden = false
            itemFourVm.titleLabel.textColor = .THEME
        case 5:
            itemFiveVm.selectImgView.isHidden = false
            itemFiveVm.titleLabel.textColor = .THEME
        default:
            break
        }
    }
}

class QuestionnairePlanFoodsTypeItemVM: UIView {
    let selfHeight = kFitWidth(48)
    var tapBlock:(()->())?
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: kFitWidth(200), height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
    lazy var selectImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "foods_type_selected_icon")
        img.isUserInteractionEnabled = true
        img.isHidden = true
        
        return img
    }()
    
    @objc func tapAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
    
    func initUI() {
        addSubview(titleLabel)
        addSubview(lineView)
        addSubview(selectImgView)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        selectImgView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.width.height.equalTo(kFitWidth(16))
        }
        lineView.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
    }
}
