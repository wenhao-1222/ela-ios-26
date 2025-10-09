//
//  MallSpecAlertVM.swift
//  lns
//
//  Created by Elavatine on 2025/9/9.
//


class MallSpecAlertVM: UIView {
    
    // MARK: - Layout constants
    var whiteViewHeight: CGFloat = kFitWidth(55) + kFitWidth(122) + kFitWidth(55) + WHUtils().getBottomSafeAreaHeight()
    let whiteViewTopRadius: CGFloat = kFitWidth(13)
    
    var detailModel = MallDetailModel()
    var buyNum = 1
    
    var specView : SpecSelectionView?
    var groups : [SpecGroup] = [SpecGroup]()
    var selectedPairs: [(groupId: String, itemId: String,itemName:String)] = []
    var selectSpecBlock: ((String, String,String) -> Void)?
    
    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        isHidden = true
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenSelf))
        v.addGestureRecognizer(tap)
        return v
    }()
    
    private lazy var whiteView: UIView = {
        let vi = UIView(frame: CGRect(x: 0, y: SCREEN_HEIGHT - whiteViewHeight, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.backgroundColor = .white
        vi.layer.cornerRadius = whiteViewTopRadius
        if #available(iOS 13.0, *) { vi.layer.cornerCurve = .continuous }
        vi.layer.masksToBounds = true
        
        // 吞掉点击
        let tap = UITapGestureRecognizer(target: self, action: #selector(nothingToDo))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        vi.addGestureRecognizer(tap)
        
        // 下拉关闭
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
//        pan.cancelsTouchesInView = false
//        pan.delegate = self
//        vi.addGestureRecognizer(pan)
        
        return vi
    }()
    
    private lazy var scrollView: UIScrollView = {
        let sc = UIScrollView()
        sc.showsVerticalScrollIndicator = false
        sc.backgroundColor = .white
        // 允许内部滚动时也触发下拉手势
//        sc.panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(gesture:)))
//        sc.panGestureRecognizer.cancelsTouchesInView = false
//        sc.panGestureRecognizer.delegate = self
        
        return sc
    }()
    private lazy var leftTitleLab: UILabel = {
        let lab = UILabel()
        lab.text = "选择规格"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 17, weight: .medium)
        return lab
    }()
    private lazy var cancelBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.4), for: .highlighted)
        btn.addTarget(self, action: #selector(hiddenSelf), for: .touchUpInside)
        return btn
    }()
    private lazy var imgView : UIImageView = {
        let img = UIImageView()
        img.backgroundColor = .COLOR_BG_F5
        img.layer.cornerRadius = kFitWidth(12)
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        
        return img
    }()
    private lazy var priceLabel : LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        return lab
    }()
    private lazy var deliveryLabel : LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var bottomVm: MallSpecAlertBottomVM = {
        let vm = MallSpecAlertBottomVM.init(frame: .zero)
        self.buyNum = vm.number
        vm.numChangeBlock = {(isAdd)in
            if isAdd {
                if self.buyNum < self.detailModel.maxPurchaseQuantity {
                    self.buyNum += 1
                }else{
                    DLLog(message: "最大购买数量：\(self.detailModel.maxPurchaseQuantity)")
                    return
                }
            }else{
                if self.buyNum > 1{
                    self.buyNum -= 1
                }else{
                    DLLog(message: "最少购买 1 件")
                    return
                }
            }
            self.bottomVm.updateNumber(num: self.buyNum)
        }
        return vm
    }()
}

extension MallSpecAlertVM{
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
            self.bgView.alpha = 0.25
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
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        guard gesture.view === whiteView else { return }
//        guard gesture.view === whiteView || gesture.view === scrollView else { return }

        // 当在列表内部滚动且内容未到顶时，不处理下拉
        if gesture.view === scrollView && scrollView.contentOffset.y > 0 {
            return
        }

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
            bgView.alpha = 0.15 * (1 - progress)

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
                    self.bgView.alpha = 0.15
                }
            }
        default:
            break
        }
    }
    func updateGoodsMsg(model:MallDetailModel,imgUrl:String) {
        self.detailModel = model
        imgView.setImgUrl(urlString: imgUrl)
        deliveryLabel.text = model.deliveryNotice
        
        let attr = NSMutableAttributedString(string: "¥")
        let attrPrice = NSMutableAttributedString(string: "\(model.price_sale)")
        
        attr.yy_font = .systemFont(ofSize: 13, weight: .semibold)
        attrPrice.yy_font = .systemFont(ofSize: 18, weight: .semibold)
        attr.append(attrPrice)
        
        priceLabel.attributedText = attr
        
        updateSpecMsg(model: model)
    }
    func updateSpecMsg(model:MallDetailModel) {
        groups.removeAll()
//        var selectedPairs: [(groupId: String, itemId: String)] = []
        selectedPairs.removeAll()
        for i in 0..<model.specList.count {
            let specModel = model.specList[i]
            
            var specItem:[SpecItem] = [SpecItem]()
            for j in 0..<specModel.specValueList.count{
                let specValueModel = specModel.specValueList[j]
//                specValueModel.
//                let enabled = specValueModel.specSelectStatus && specValueModel.specHasStock
                specItem.append(.init(id: specValueModel.specValueId,
                                      title: specValueModel.specValue,
                                      isEnabled: specValueModel.specHasStock))
                if specValueModel.specSelectStatus && specValueModel.specHasStock {
                    selectedPairs.append((groupId: specModel.specId,
                                          itemId: specValueModel.specValueId,
                                          itemName:specValueModel.specValue))
                }
            }
//            groups.append(SpecGroup(title: specModel.specName, items: specItem))
            groups.append(SpecGroup(id: specModel.specId, title: specModel.specName, items: specItem))
        }
        specView?.removeFromSuperview()
        specView = nil
        // 2) 创建视图（放进你的弹窗内容区即可）
        specView = SpecSelectionView(
            groups: groups,
            config: .init(
                interItemSpacing: kFitWidth(12),         // 两两间距（可改）
                lineSpacing: kFitWidth(12),              // 换行间距（可改）
                contentInsets: UIEdgeInsets(top: 0, left: 12, bottom: kFitWidth(6), right: 12),
                tagMaxWidthRatio: 0.86,       // 单个标签最大宽度=容器宽度*比例（可改），用于“背景宽度不能超过一定宽度”
                tagCornerRadius: kFitWidth(4),
                titleFont: .systemFont(ofSize: 14, weight: .regular),
                tagFont: .systemFont(ofSize: 12, weight: .semibold),
                lineHeightMultiple: 1.5       // 文本行高 1.5 倍
            )
        )
//        whiteView.addSubview(specView!)
        scrollView.addSubview(specView!)
        specView!.translatesAutoresizingMaskIntoConstraints = false
//        specView!.onSelect = { groupId, item in
//            print("选中了组 \(groupId)：\(item.id)")
//        }
        specView!.onSelect = { [weak self] groupId, item in
//            print("选中了组 \(groupId)：\(item.id)")
            guard let self = self else { return }
            if let item = item {
                print("选中了组 \(groupId)：\(item.id)")
                if let idx = self.selectedPairs.firstIndex(where: { $0.groupId == groupId }) {
                    self.selectedPairs[idx] = (groupId: groupId,
                                               itemId: item.id,
                                               itemName: item.title)
                } else {
                    self.selectedPairs.append((groupId: groupId,
                                               itemId: item.id,
                                               itemName: item.title))
                }
                self.selectSpecBlock?(groupId, item.id, item.title)
            } else {
                print("取消选中组 \(groupId)")
                if let idx = self.selectedPairs.firstIndex(where: { $0.groupId == groupId }) {
                    self.selectedPairs.remove(at: idx)
                }
                self.selectSpecBlock?(groupId, "", "")
            }
//            if let idx = self.selectedPairs.firstIndex(where: { $0.groupId == groupId }) {
//                self.selectedPairs[idx] = (groupId: groupId,
//                                           itemId: item.id,
//                                           itemName:item.title)
//            } else {
//                self.selectedPairs.append((groupId: groupId,
//                                           itemId: item.id,
//                                           itemName:item.title))
//            }
//            self.selectSpecBlock?(groupId, item.id,item.title)
        }
        for pair in selectedPairs {
            specView?.setSelected(groupId: pair.groupId, itemId: pair.itemId)
        }
        specView!.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(20))
//            make.right.equalTo(kFitWidth(-20))
//            make.top.equalTo(kFitWidth(55) + kFitWidth(122))
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

//        // 4) 需要“图一的高度”时，传入可用宽度即可
//        let neededHeight = specView!.requiredHeight(for: whiteView.bounds.width)
//        
//        whiteViewHeight = kFitWidth(55) + kFitWidth(122) + kFitWidth(55) + WHUtils().getBottomSafeAreaHeight() + neededHeight
        let contentWidth = whiteView.bounds.width - kFitWidth(40)
        let neededHeight = specView!.requiredHeight(for: contentWidth)

        let headerHeight = kFitWidth(55) + kFitWidth(122)
        let bottomHeight = bottomVm.selfHeight// + WHUtils().getBottomSafeAreaHeight()
        whiteViewHeight = headerHeight + bottomHeight + neededHeight
        let maxHeight = SCREEN_HEIGHT - kFitWidth(200)
        if whiteViewHeight > maxHeight {
            whiteViewHeight = maxHeight
        }
        layoutWhiteViewFrame()
        layoutIfNeeded()
        
        // 初始位置放在最终停靠位置，实际展示用 transform 下移
//        whiteView.transform = .identity
    }
}

extension MallSpecAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(leftTitleLab)
        whiteView.addSubview(cancelBtn)
        whiteView.addSubview(imgView)
        whiteView.addSubview(priceLabel)
        whiteView.addSubview(deliveryLabel)
        whiteView.addSubview(scrollView)
        
        whiteView.addSubview(bottomVm)
        
        setHeaderConstraints()
    }
    private func layoutWhiteViewFrame() {
        // 在重新计算 frame 之前先重置 transform，避免在隐藏状态下更新高度时出现错位
        whiteView.transform = .identity
        whiteView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - whiteViewHeight, width: SCREEN_WIDHT, height: whiteViewHeight)
        bottomVm.frame = CGRect.init(x: 0, y: whiteViewHeight-bottomVm.selfHeight, width: SCREEN_WIDHT, height: bottomVm.selfHeight)
        whiteView.layer.cornerRadius = whiteViewTopRadius
        if #available(iOS 13.0, *) { whiteView.layer.cornerCurve = .continuous }
        whiteView.layer.masksToBounds = true
        if isHidden {
            whiteView.transform = CGAffineTransform(translationX: 0, y: whiteViewHeight)
        } else {
//            whiteView.transform = .identity
        }
    }
    
    private func setHeaderConstraints()  {
        cancelBtn.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(55))
        }
        leftTitleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.centerY.lessThanOrEqualTo(cancelBtn)
        }
        imgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(75))
            make.width.height.equalTo(kFitWidth(90))
        }
        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(kFitWidth(17.5))
            make.top.equalTo(imgView).offset(kFitWidth(17))
        }
        deliveryLabel.snp.makeConstraints { make in
            make.left.equalTo(priceLabel)
            make.top.equalTo(priceLabel.snp.bottom).offset(kFitWidth(15))
            make.right.equalTo(kFitWidth(-10))
        }
        scrollView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(55) + kFitWidth(122))
            make.bottom.equalTo(-self.bottomVm.selfHeight)// - WHUtils().getBottomSafeAreaHeight())
        }
    }
}

extension MallSpecAlertVM: UIGestureRecognizerDelegate {
    // 允许同时识别（不阻塞 collectionView 的点按）
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // 可选：tap 不拦截按钮等 UIControl 的触摸
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer,
           touch.view is UIControl {
            return false
        }
        return true
    }
}
