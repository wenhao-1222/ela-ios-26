//
//  TutorialMenuVM.swift
//  lns
//
//  Created by Elavatine on 2024/12/26.
//



class TutorialMenuVM: UIView {
    
    var selfHeight = kFitWidth(64)
    var dataSourceArray:[ForumTutorialModel] = [ForumTutorialModel]()
    
    var currentIndex = 0
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: kFitWidth(16), y: frame.origin.y, width: SCREEN_WIDHT-kFitWidth(32), height: selfHeight))
        self.backgroundColor = .white//WHColor_16(colorStr: "2C2C2C")
        self.layer.cornerRadius = kFitWidth(12)
//        self.clipsToBounds = true
        self.isUserInteractionEnabled = true
        self.isSkeletonable = true
        initUI()
    }
    lazy var lastVm: TutorialMenuItemVM = {
        let vm = TutorialMenuItemVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.tapBlock = {()in
            DLLog(message: "上一个")
        }
        return vm
    }()
    lazy var nextVm: TutorialMenuItemVM = {
        let vm = TutorialMenuItemVM.init(frame: CGRect.init(x: self.lastVm.frame.maxX, y: 0, width: 0, height: 0))
        vm.detailLabel.text = "下一个"
        vm.detailLabel.textAlignment = .right
        vm.rightArrowImg.isHidden = false
        vm.leftArrowImg.isHidden = true
        
        vm.titleLabel.textAlignment = .right
        vm.tapBlock = {()in
            DLLog(message: "下一个 >")
        }
        return vm
    }()
    lazy var lineTopView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LINE_GREY//WHColor_16(colorStr: "3D3D3D")
        
        return vi
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LINE_GREY//WHColor_16(colorStr: "3D3D3D")
        vi.layer.cornerRadius = kFitWidth(0.5)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var lineBottomView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F5F6F8")
        
        return vi
    }()
}

extension TutorialMenuVM{
    func updateUI(model:ForumTutorialModel) {
        hideSkeleton()
        if self.dataSourceArray.count == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                self.updateUI(model: model)
            })
            return
        }
        for i in 0..<self.dataSourceArray.count{
            let mo = self.dataSourceArray[i]
            if mo.id == model.id{
                self.currentIndex = i
                break
            }
        }
        
        if currentIndex == 0 {
//            self.lastVm.isHidden = true
            self.lastVm.hiddenSelf(isHidden: true)
            self.lastVm.leftArrowImg.isHidden = true
        }else{
//            self.lastVm.isHidden = false
            let lastModel = self.dataSourceArray[currentIndex-1]
            self.lastVm.updateUI(model: lastModel)
            self.lastVm.hiddenSelf(isHidden: false)
            self.lastVm.leftArrowImg.isHidden = false
        }
        if self.currentIndex == self.dataSourceArray.count - 1{
//            self.nextVm.isHidden = true
            self.nextVm.hiddenSelf(isHidden: true)
            self.nextVm.rightArrowImg.isHidden = true
        }else{
//            self.nextVm.isHidden = false
            let nextModel = self.dataSourceArray[currentIndex+1]
            self.nextVm.updateUI(model: nextModel)
            self.nextVm.hiddenSelf(isHidden: false)
            self.nextVm.rightArrowImg.isHidden = false
        }
    }
    
    func dealDataArray(dataArray:NSArray) {
        self.dataSourceArray.removeAll()
        let arrTemp = NSArray(array: dataArray)
        for i in 0..<arrTemp.count{
            let currentTutoArray = arrTemp[i]as? NSArray ?? []
            for j in 0..<currentTutoArray.count{
                let model = currentTutoArray[j]as? ForumTutorialModel ?? ForumTutorialModel()
                self.dataSourceArray.append(model)
            }
        }
    }
}

extension TutorialMenuVM{
    func initUI() {
        addSubview(lastVm)
        addSubview(nextVm)
        addSubview(lineTopView)
        addSubview(lineView)
        addSubview(lineBottomView)
        lineTopView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
            make.centerX.lessThanOrEqualToSuperview()
        }
        lineView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(1))
            make.height.equalTo(kFitWidth(34))
        }
        lineBottomView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(SCREEN_WIDHT)
            make.height.equalTo(kFitWidth(8))
        }
    }
}
