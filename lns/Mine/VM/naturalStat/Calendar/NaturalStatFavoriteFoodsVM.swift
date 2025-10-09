//
//  NaturalStatFavoriteFoodsVM.swift
//  lns
//
//  Created by LNS2 on 2024/9/13.
//

import Foundation

class NaturalStatFavoriteFoodsVM: UIView {
    
    var controller = WHBaseViewVC()
    var selfHeight = kFitWidth(204)
    
    var dataSourceArray = NSArray()
    
    var updateBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
        initUI()
        sendFavoriteFoodsRequest()
    }
    lazy var topGapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5
        
        return vi
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .bold)
        let arr = Date().currenYearMonthM
        lab.text = "\(arr[1]as? String ?? "")月最爱食物"
        return lab
    }()
    lazy var topLabel: UILabel = {
        let lab = UILabel()
        lab.backgroundColor = .THEME
        lab.layer.cornerRadius = kFitWidth(4)
        lab.clipsToBounds = true
        lab.font = .systemFont(ofSize: 10, weight: .bold)
        lab.textAlignment = .center
        lab.textColor = .white
        lab.text = "TOP5"
        return lab
    }()
    lazy var nodataLabel: UILabel = {
        let lab = UILabel()
        lab.text = "- 暂无数据 -"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.isHidden = true
        
        return lab
    }()
}

extension NaturalStatFavoriteFoodsVM{
    func initUI() {
        addSubview(topGapView)
        addSubview(titleLabel)
        addSubview(topLabel)
        addSubview(nodataLabel)
        
        setConstrait()
    }
    func setConstrait() {
        topGapView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.height.equalTo(kFitWidth(10))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
//            make.top.equalToSuperview()
            make.top.equalTo(topGapView.snp.bottom).offset(kFitWidth(20))
        }
        topLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(titleLabel)
            make.width.equalTo(kFitWidth(35))
            make.height.equalTo(kFitWidth(16))
        }
        nodataLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(50))
        }
    }
    func refreshUI() {
        for i in 0..<self.dataSourceArray.count{
            let dict = self.dataSourceArray[i]as? NSDictionary ?? [:]
            let vm = NaturalStatFavoriteFoodsItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(54)+kFitWidth(36)*CGFloat(i), width: 0, height: 0))
            
            vm.updateUI(dict: dict)
            addSubview(vm)
        }
        if self.dataSourceArray.count == 0 {
//            self.selfHeight = kFitWidth(0)
            self.selfHeight = kFitWidth(46)+kFitWidth(80)
//            self.isHidden = true
            self.nodataLabel.isHidden = false
        }else{
            self.nodataLabel.isHidden = true
            self.selfHeight = kFitWidth(54)+CGFloat(self.dataSourceArray.count)*kFitWidth(36)
        }
        
        let selfFrame = self.frame
        self.frame = CGRect.init(x: 0, y: selfFrame.origin.y, width: SCREEN_WIDHT, height: selfHeight)
        
        if self.updateBlock != nil{
            self.updateBlock!()
        }
    }
}

extension NaturalStatFavoriteFoodsVM{
    func sendFavoriteFoodsRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_stat_favorite_foods, parameters: nil,isNeedToast: true,vc: self.controller) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "sendFavoriteFoodsRequest:\(dataArray)")
            self.dataSourceArray = dataArray
            self.refreshUI()
        }
    }
}
