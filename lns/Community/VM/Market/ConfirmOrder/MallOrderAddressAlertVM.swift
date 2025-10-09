//
//  MallOrderAddressAlertVM.swift
//  lns
//
//  Created by Elavatine on 2025/9/12.
//
import UIKit

class MallOrderAddressAlertVM: UIView, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Layout constants
    private let headerHeight: CGFloat = kFitWidth(55)
    private let whiteViewTopRadius: CGFloat = kFitWidth(13)

    /// bottom 操作区（已有控件）高度
    private var bottomHeight: CGFloat { bottomVm.selfHeight + WHUtils().getBottomSafeAreaHeight() }

    /// 弹层最高高度：屏幕 2/3
    private var maxWhiteHeight: CGFloat { floor(SCREEN_HEIGHT * 2.0 / 3.0) }

    /// 当前弹层高度（动态计算、受 2/3 约束）
    private var whiteViewHeight: CGFloat = 0

    /// 数据源
    private var dataSource: [AddressModel] = []
    var defaultModel = AddressModel()

    /// 选择回调（可选）
    var onSelectAddress: ((AddressModel) -> Void)?

    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        isHidden = true
        initUI()
        sendAddressListRequest()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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
        let vi = UIView()
        vi.backgroundColor = .white
        vi.layer.cornerRadius = whiteViewTopRadius
        if #available(iOS 13.0, *) { vi.layer.cornerCurve = .continuous }
        vi.layer.masksToBounds = true

        // 吞掉点击
        let tap = UITapGestureRecognizer(target: self, action: #selector(nothingToDo))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        vi.addGestureRecognizer(tap)

        // 下拉关闭（与 tableView 手势并存）
//        vi.addGestureRecognizer(sheetPan)

        return vi
    }()

    private lazy var sheetPan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        pan.cancelsTouchesInView = false
        pan.delegate = self
        return pan
    }()

    private lazy var leftTitleLab: UILabel = {
        let lab = UILabel()
        lab.text = "收件地址"
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
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F2
        return vi
    }()
    /// 地址列表
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = true
        tv.estimatedRowHeight = AddressCell.defaultHeight
        tv.rowHeight = UITableView.automaticDimension
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomHeight, right: 0)
        tv.delegate = self
        tv.dataSource = self
        tv.register(AddressCell.self, forCellReuseIdentifier: AddressCell.reuseId)
        return tv
    }()

    lazy var bottomVm: AddressListBottomVM = {
        let vm = AddressListBottomVM(frame: .zero)
        vm.addButton.setTitle("添加新地址", for: .normal)
        return vm
    }()
}

// MARK: - Public
extension MallOrderAddressAlertVM {

    func showSelf() {
        // 初始布局 & 动画前位置
        updateWhiteViewHeightForContent()
        layoutWhiteViewFrame()

        isHidden = false
        bgView.isUserInteractionEnabled = false

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

    @objc func confirmAction() { hiddenSelf() }
    @objc func nothingToDo() { /* 吞点击 */ }
}

// MARK: - Private layout
extension MallOrderAddressAlertVM {

    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)

        whiteView.addSubview(leftTitleLab)
        whiteView.addSubview(cancelBtn)
        whiteView.addSubview(lineView)
        whiteView.addSubview(tableView)
        whiteView.addSubview(bottomVm)

        setHeaderConstraints()
        setBodyConstraints()
        updateWhiteViewHeightForContent()
        layoutWhiteViewFrame()
    }

    /// 只负责计算高度（受 2/3 限制）
    private func updateWhiteViewHeightForContent() {
        // 先布局，确保 contentSize 可靠
       tableView.layoutIfNeeded()

        // 基础高度 = 头部 + 底部
        let base = headerHeight + bottomHeight
        let listHeight = tableView.contentSize.height
        let total = base + listHeight

        if total <= maxWhiteHeight {
            // 内容未超过阈值，全部展示且不允许滚动
            whiteViewHeight = total
            tableView.isScrollEnabled = false
            tableView.contentInset = .zero
        } else {
            // 内容较多，限制高度并允许滚动
            whiteViewHeight = maxWhiteHeight
            tableView.isScrollEnabled = true
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

//        // 期望列表高度（粗略估算，用于“数据很少时”让弹层不至于太高）
//        let estimatedListH = CGFloat(max(1, dataSource.count)) * AddressCell.defaultHeight
//
//        let expect = base + min(estimatedListH, maxWhiteHeight) // 列表内容不可靠，用上限保护
//        whiteViewHeight = min(maxWhiteHeight, max(base + kFitWidth(100), expect))  // 至少有点展示空间
    }

    /// 设置 frame（动画依赖 frame）
    private func layoutWhiteViewFrame() {
        // 在重新计算 frame 之前先重置 transform，避免在隐藏状态下更新高度时出现错位
        whiteView.transform = .identity
        whiteView.frame = CGRect(x: 0,
                                 y: SCREEN_HEIGHT - whiteViewHeight,
                                 width: SCREEN_WIDHT,
                                 height: whiteViewHeight)

        // 如果当前处于隐藏状态，保持白板在屏幕下以便下次动画
        if isHidden {
            whiteView.transform = CGAffineTransform(translationX: 0, y: whiteViewHeight)
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
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(kFitWidth(55))
            make.height.equalTo(kFitWidth(5))
        }
    }

    private func setBodyConstraints() {
        bottomVm.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()//.inset(WHUtils().getBottomSafeAreaHeight())
            make.height.equalTo(bottomVm.selfHeight)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomVm.snp.top)
        }
    }
}

// MARK: - UITableView
extension MallOrderAddressAlertVM {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { dataSource.count }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AddressCell.reuseId, for: indexPath) as? AddressCell else {
            return UITableViewCell()
        }
        let model = dataSource[indexPath.row]
        let chosen = (model.id == defaultModel.id) || (model.isDefault && defaultModel.id.isEmpty)
        cell.config(model: model, chosen: chosen)
        cell.onTapCheck = { [weak self] in
            guard let self = self else { return }
            self.defaultModel = model
            self.tableView.reloadData()
            self.onSelectAddress?(model)   // 需要时回调给外部
            self.hiddenSelf()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSource[indexPath.row]
        defaultModel = model
        tableView.reloadData()
        onSelectAddress?(model)
        self.hiddenSelf()
    }
}

// MARK: - 下滑关闭的手势处理（考虑 tableView 内部滚动）
extension MallOrderAddressAlertVM {

    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: whiteView)
        let velocity = gesture.velocity(in: whiteView).y

        // 如果 tableView 尚未滚到顶部，且是向下拖动，则不处理，让列表先滚
        if translation.y > 0, tableView.contentOffset.y > 0 {
            return
        }

        // 只响应向下拖动
        if translation.y < 0 { return }

        gesture.setTranslation(.zero, in: whiteView)

        switch gesture.state {
        case .changed:
            let currentTy = whiteView.transform.ty
            var newTy = currentTy + translation.y
            newTy = max(0, min(whiteViewHeight, newTy))
            whiteView.transform = CGAffineTransform(translationX: 0, y: newTy)

            let progress = min(1, max(0, newTy / whiteViewHeight))
            bgView.alpha = 0.25 * (1 - progress)

        case .ended, .cancelled, .failed:
            let ty = whiteView.transform.ty
            let threshold = kFitWidth(60)
            if ty >= threshold || velocity > 800 {
                hiddenSelf()
            } else {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                    self.whiteView.transform = CGAffineTransform(translationX: 0, y: self.whiteViewHeight)//.identity
                    self.bgView.alpha = 0.25
                }
            }
        default:
            break
        }
    }
}

// MARK: - Gesture Delegate
extension MallOrderAddressAlertVM: UIGestureRecognizerDelegate {
    /// 允许同时识别（不阻塞 tableView 的点按/滚动）
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    /// tap 不拦截按钮等 UIControl 的触摸
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer,
           touch.view is UIControl {
            return false
        }
        return true
    }
}

// MARK: - Network
extension MallOrderAddressAlertVM {

    /// 获取地址并刷新页面
    func sendAddressListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_user_address_list, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "") as? [NSDictionary] ?? []
            DLLog(message: "sendAddressListRequest:\(dataArray)")

            var list: [AddressModel] = []
            var defaultIdx: Int? = nil

            for (idx, dict) in dataArray.enumerated() {
                let model = AddressModel().dealModelWithDict(dict: dict)
                list.append(model)
                list.append(model)
                list.append(model)
                list.append(model)
                list.append(model)
                if model.isDefault {
                    defaultIdx = idx
//                    self.defaultModel = model
                }
            }

            self.dataSource = list
            if let i = defaultIdx {
                self.defaultModel = list[i]
                self.onSelectAddress?(self.defaultModel)
            }

            // 刷新 UI
            self.tableView.reloadData()
            self.updateWhiteViewHeightForContent()
            self.layoutWhiteViewFrame()
        }
    }
}
