//
//  TutorialsAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/6/5.
//

import Foundation
import UIKit
//import ShowBigImg

class TutorialsAlertVM: UIView {
    
    let lineGap = kFitWidth(6)
    var dataSourceArray = NSArray()
    var controller = WHBaseViewVC()
    
    let whiteViewOriginY = WHUtils().getNavigationBarHeight()
    let whiteViewHeight = SCREEN_HEIGHT - WHUtils().getNavigationBarHeight()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "", alpha: 1)
        self.isUserInteractionEnabled = true
        self.clipsToBounds = false
        self.isHidden = true
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenLoginView))
//        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    private lazy var bgView: UIView = {
        let v = UIView(frame: bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 1.0)
        v.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenLoginView))
        v.addGestureRecognizer(tap)
        return v
    }()
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()))
//        let vi = UIView.init(frame: CGRect.init(x: 0, y: WHUtils().getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        vi.addClipCorner(corners: [.topLeft,.topRight], radius: kFitWidth(8))
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(whiteViewTapAction))
        vi.addGestureRecognizer(tap)
        
        // 创建下拉手势识别器
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        // 将手势识别器添加到view
        vi.addGestureRecognizer(panGestureRecognizer)
        
        return vi
    }()
    lazy var topLineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "D9D9D9")
        vi.layer.cornerRadius = kFitWidth(2)
        
        return vi
    }()
    lazy var topTapView : UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenLoginView))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var tableView : UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: kFitWidth(30), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()-kFitWidth(30)), style: .plain)
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.backgroundColor = .clear
        vi.bounces = false
        vi.register(TutorialTableViewCell.classForCoder(), forCellReuseIdentifier: "TutorialTableViewCell")
        vi.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
        }
        
        return vi
    }()
}

extension TutorialsAlertVM{
    @objc func showLoginView() {
        self.isHidden = false
        self.bgView.alpha = 0
        self.bgView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
//            self.whiteView.transform = CGAffineTransform(translationX: 0, y: -kFitWidth(2))
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: WHUtils().getNavigationBarHeight()+(SCREEN_HEIGHT-WHUtils().getTabbarHeight())*0.5-kFitWidth(2))
            self.bgView.alpha = 0.25
        } completion: { _ in
            self.bgView.isUserInteractionEnabled = true
            
        }
        UIView.animate(withDuration: 0.25, delay: 0.4, options: .curveEaseInOut) {
//            self.whiteView.transform = .identity
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: WHUtils().getNavigationBarHeight()+(SCREEN_HEIGHT-WHUtils().getTabbarHeight())*0.5)
        }
//        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
//            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: WHUtils().getNavigationBarHeight()+(SCREEN_HEIGHT-WHUtils().getTabbarHeight())*0.5)
//            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
//        }
   }
   @objc func hiddenLoginView() {
       UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
           self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5)
//           self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
           self.bgView.alpha = 0
       }completion: { t in
           self.isHidden = true
       }
  }
    @objc func whiteViewTapAction(){
        
    }
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        // 获取当前手势所在的view
        if let view = gesture.view {
            // 根据手势移动view的位置
            switch gesture.state {
            case .changed:
                let translation = gesture.translation(in: view)
//                DLLog(message: "translation.y:\(translation.y)")
//                DLLog(message: "view.frame.minY:\(view.frame.minY)")
//                DLLog(message: "self.whiteViewOriginY:\(self.whiteViewOriginY)")
                if translation.y < 0 && self.whiteView.frame.minY <= self.whiteViewOriginY{
                    return
                }
                view.center = CGPoint(x: view.center.x, y: view.center.y + translation.y)
                gesture.setTranslation(.zero, in: view)
                
            case .ended:
                if view.frame.minY - self.whiteViewOriginY >= kFitWidth(20){
                    self.hiddenLoginView()
                }else{
                    UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                        self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
                    }
                }
            default:
                break
            }
        }
    }
}

extension TutorialsAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(topLineView)
        whiteView.addSubview(topTapView)
        whiteView.addSubview(tableView)
        
        setConstrait()
        layoutWhiteViewFrame()
        // 初始位置放在最终停靠位置，实际展示用 transform 下移
        whiteView.transform = .identity
    }
    
    private func layoutWhiteViewFrame() {
//        whiteView.frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight)
//        whiteView.layer.cornerRadius = whiteViewTopRadius
        if #available(iOS 13.0, *) { whiteView.layer.cornerCurve = .continuous }
        whiteView.layer.masksToBounds = true
    }
    func setConstrait() {
        topLineView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(18))
            make.width.equalTo(kFitWidth(43))
            make.height.equalTo(kFitWidth(4))
            make.centerX.lessThanOrEqualToSuperview()
        }
        topTapView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(kFitWidth(40))
        }
    }
    func setDataArray(array:NSArray) {
        self.dataSourceArray = array
        self.tableView.reloadData()
        self.showLoginView()
    }
}

extension TutorialsAlertVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TutorialTableViewCell")as! TutorialTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "TutorialTableViewCell", for: indexPath) as? TutorialTableViewCell
        
        let dataDict = dataSourceArray[indexPath.row]as? NSDictionary ?? [:]
//        let dataArr = dataDict["dataArr"]as? NSArray ?? []
//        let dict = dataArr[indexPath.row] as? NSDictionary ?? [:]
        cell?.updateUI(dict: dataDict)
        
        cell?.imgTapBlock = {(imgView)in
            let showController = ShowBigImgController(imgs: [imgView.image!], img: imgView.image!,isNavi: true)
//            showController.modalPresentationStyle = .overFullScreen
//            self.controller.present(showController, animated: false, completion: nil)
            self.controller.navigationController?.pushViewController(showController, animated: true)
        }
        return cell ?? TutorialTableViewCell()
    }
}
