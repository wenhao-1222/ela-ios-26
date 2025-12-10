//
//  ServiceOrderAlertVM.swift
//  lns
//
//  Created by LNS2 on 2025/12/10.
//


import UIKit

class ServiceOrderAlertVM: UIView {
    
    // MARK: - Layout constants
    var whiteViewHeight: CGFloat = kFitWidth(278) + WHUtils().getBottomSafeAreaHeight()
    let whiteViewTopRadius: CGFloat = kFitWidth(10)
    let itemHeight = kFitWidth(136)
    
    var orderListDataArray = NSArray()
    
    var tapBlock:((NSDictionary)->())?
    
    /// 蒙层目标透明度：浅色 0.15，深色 0.85
    private var targetDimAlpha: CGFloat {
        return traitCollection.userInterfaceStyle == .dark ? 0.55 : 0.15
    }
    // 主题变更时（例如从浅色切到深色）同步调整蒙层透明度
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *),
           previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle,
           !isHidden {
            UIView.animate(withDuration: 0.2) {
                self.bgView.alpha = self.targetDimAlpha
            }
        }
    }
    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        isHidden = true
        initUI()
        
        sendOrderListRequest()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - UI
    private lazy var bgView: UIView = {
        let v = UIView(frame: bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = .COLOR_ALERT_BG_BLACK
        v.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenSelf))
        v.addGestureRecognizer(tap)
        return v
    }()
    
    private lazy var whiteView: UIView = {
        // 先用默认高度创建，后面 dealData() 会重算高度并设置 frame
        let vi = UIView(frame: CGRect(x: 0, y: SCREEN_HEIGHT - whiteViewHeight, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = whiteViewTopRadius
        if #available(iOS 13.0, *) { vi.layer.cornerCurve = .continuous }
        vi.layer.masksToBounds = true
        
        // 吞掉点击
        let tap = UITapGestureRecognizer(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        // 下拉关闭
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        vi.addGestureRecognizer(pan)
        
        return vi
    }()
    private lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LINE_F0
        return vi
    }()
    private lazy var cancelBtn: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.4), for: .highlighted)

        return btn
    }()
    
    private lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "选择要咨询的订单"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        lab.textAlignment = .center
        return lab
    }()
    
    lazy var tableView: UITableView = {
        let vi = UITableView(frame: CGRect.init(x: 0, y: kFitWidth(55), width: SCREEN_WIDHT, height: whiteViewHeight-kFitWidth(55)-WHUtils().getBottomSafeAreaHeight()), style: .plain)
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        
        vi.delegate = self
        vi.dataSource = self
        vi.rowHeight = UITableView.automaticDimension
        vi.separatorStyle = .none
        vi.register(ServiceOrderTableViewCell.classForCoder(), forCellReuseIdentifier: "ServiceOrderTableViewCell")
        
        
        return vi
    }()
    lazy var noDataView : TableViewNoDataVM = {
        let vi = TableViewNoDataVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
        vi.isHidden = true
        vi.noDataLabel.text = "- 暂无订单 -"
        vi.noDataLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        
        return vi
    }()
}

// MARK: - Public API
extension ServiceOrderAlertVM {
    func showSelf() {
        isHidden = false

        bgView.isUserInteractionEnabled = false
        
        // 初态：whiteView 在最终停靠位，先整体下移隐藏；蒙层透明
        whiteView.transform = CGAffineTransform(translationX: 0, y: whiteViewHeight)
        bgView.alpha = 0

        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: -kFitWidth(2))
            self.bgView.alpha = self.targetDimAlpha
        } completion: { _ in
            self.bgView.isUserInteractionEnabled = true
            
        }
        UIView.animate(withDuration: 0.25, delay: 0.4, options: .curveEaseInOut) {
            self.whiteView.transform = .identity
        }
    }

    @objc func hiddenSelf() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: self.whiteViewHeight)
            self.bgView.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
    }

    @objc func confirmAction() {
        hiddenSelf()
    }

    @objc func nothingToDo() { /* 吞点击 */ }
}

// MARK: - Gesture
extension ServiceOrderAlertVM {

    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        guard gesture.view === whiteView else { return }

        let translation = gesture.translation(in: whiteView)
        gesture.setTranslation(.zero, in: whiteView)

        switch gesture.state {
        case .changed:
            // 只允许向下拖动（ty >= 0）
            let currentTy = whiteView.transform.ty
            var newTy = currentTy + translation.y
            newTy = max(0, min(whiteViewHeight, newTy))
            whiteView.transform = CGAffineTransform(translationX: 0, y: newTy)

            // 同步调低蒙层
            let progress = min(1, max(0, newTy / whiteViewHeight))
            bgView.alpha = self.targetDimAlpha * (1 - progress)

        case .ended, .cancelled, .failed:
            let ty = whiteView.transform.ty
            let velocity = gesture.velocity(in: whiteView).y
            let threshold = kFitWidth(50)

            // 根据拖动距离或下滑速度决定收起
            if ty >= threshold || velocity > 800 {
                hiddenSelf()
            } else {
                // 回弹
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                    self.whiteView.transform = .identity
                    self.bgView.alpha = self.targetDimAlpha
                }
            }
        default:
            break
        }
    }
}

extension ServiceOrderAlertVM :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noDataView.isHidden = orderListDataArray.count > 0 ? true : false
        return orderListDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceOrderTableViewCell") as? ServiceOrderTableViewCell
        
        let dict = orderListDataArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUI(dict: dict)
        cell?.lineView.isHidden = indexPath.row == orderListDataArray.count - 1 ? true : false
        cell?.sendTapBlock = {()in
            DLLog(message: "发送订单")
            self.tapBlock?(dict)
            self.hiddenSelf()
        }
        
        return cell ?? ServiceOrderTableViewCell()
    }
}

extension ServiceOrderAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(cancelBtn)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(lineView)
        
        whiteView.addSubview(tableView)
        tableView.addSubview(noDataView)
        noDataView.center = CGPoint.init(x: self.tableView.frame.width * 0.5, y: self.tableView.frame.height*0.5)
        
        layoutWhiteViewFrame()
        setConstrait()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(54))
        }
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
            make.top.equalTo(kFitWidth(54))
        }
        cancelBtn.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(55))
        }
    }
    private func layoutWhiteViewFrame() {
        whiteView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - whiteViewHeight, width: SCREEN_WIDHT, height: whiteViewHeight)
        whiteView.layer.cornerRadius = whiteViewTopRadius
        if #available(iOS 13.0, *) { whiteView.layer.cornerCurve = .continuous }
        whiteView.layer.masksToBounds = true
    }
    func updateFrame() {
        if self.orderListDataArray.count > 4 {
            whiteViewHeight = itemHeight * 4 + kFitWidth(55) + WHUtils().getBottomSafeAreaHeight()
        }else if self.orderListDataArray.count > 2{
            whiteViewHeight = itemHeight * CGFloat(orderListDataArray.count) + kFitWidth(55) + WHUtils().getBottomSafeAreaHeight()
        }
        
        layoutWhiteViewFrame()
        tableView.frame = CGRect.init(x: 0, y: kFitWidth(55), width: SCREEN_WIDHT, height: whiteViewHeight-kFitWidth(55)-WHUtils().getBottomSafeAreaHeight())
    }
}


extension ServiceOrderAlertVM{
    func sendOrderListRequest() {
        let param = ["status": "3"]
        WHNetworkUtil.shareManager().POST(urlString: URL_forum_order_list, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendOrderListRequest:\(dataArr)")
            
            self.orderListDataArray = dataArr
            self.updateFrame()
            self.tableView.reloadData()
        }
    }
}
