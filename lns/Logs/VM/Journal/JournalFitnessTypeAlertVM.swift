//
//  JournalFitnessTypeAlertVM.swift
//  lns
//
//  Created by Elavatine on 2025/7/1.
//
import UIKit

class JournalFitnessTypeAlertVM: UIView {

    // MARK: - Layout constants
    var whiteViewHeight: CGFloat = kFitWidth(313) + WHUtils().getBottomSafeAreaHeight()
    let whiteViewTopRadius: CGFloat = kFitWidth(10)

    var itmeVmGapX = kFitWidth(20)
    var itemVmGapY = kFitWidth(12)
    let itemVmHeight = kFitWidth(40)
    let itemVmWidth  = kFitWidth(75)

    // MARK: - Data
    var confirmBlock: (([String]) -> ())?
    var sdate = Date().todayDate

    var vmArray: [PlanCreateSynDaysVM] = []
    var fitnessArray: [String] = []
    var selectFitnessType: [String] = []

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
        // 先用默认高度创建，后面 dealData() 会重算高度并设置 frame
        let vi = UIView(frame: CGRect(x: 0, y: SCREEN_HEIGHT - whiteViewHeight, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.backgroundColor = .white
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

    private lazy var cancelBtn: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.4), for: .highlighted)
        btn.addTarget(self, action: #selector(hiddenSelf), for: .touchUpInside)
        return btn
    }()

    private lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "力量训练标签"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        lab.textAlignment = .center
        return lab
    }()

    private lazy var confirmBtn: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setImage(UIImage(named: "date_fliter_confirm_img"), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.4), for: .highlighted)
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return btn
    }()

    private lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5
        return vi
    }()

    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        isHidden = true

        // 计算左右间距
        itmeVmGapX = (SCREEN_WIDHT - kFitWidth(75) * 4 - kFitWidth(18) * 2) / 3

        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public API
extension JournalFitnessTypeAlertVM {
    func showSelf() {
        // 数据可能在初始化后才返回，这里重新构建以保证有内容
       reloadDataIfNeeded()
       // 若仍无数据则不展示
       guard !vmArray.isEmpty else { return }

        isHidden = false

        bgView.isUserInteractionEnabled = false
        // 刷新选择状态（如果外部修改了 selectFitnessType）
        updateSelectStatus()
        
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
        // 更稳健的删除写法
        selectFitnessType.removeAll { $0 == "[]" || $0 == "-" }
        confirmBlock?(selectFitnessType)
    }

    @objc func nothingToDo() { /* 吞点击 */ }
}

// MARK: - Gesture
extension JournalFitnessTypeAlertVM {

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
}

// MARK: - Build UI & Data
extension JournalFitnessTypeAlertVM {

    private func initUI() {
        addSubview(bgView)
        addSubview(whiteView)

        whiteView.addSubview(cancelBtn)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(confirmBtn)
        whiteView.addSubview(lineView)

        // 先准备数据，算高度，再设置 whiteView 的 frame
        dealData()
        layoutWhiteViewFrame()
        setHeaderConstraints()
        initVmArray()

        // 初始位置放在最终停靠位置，实际展示用 transform 下移
        whiteView.transform = .identity
    }

    private func layoutWhiteViewFrame() {
        whiteView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - whiteViewHeight, width: SCREEN_WIDHT, height: whiteViewHeight)
        whiteView.layer.cornerRadius = whiteViewTopRadius
        if #available(iOS 13.0, *) { whiteView.layer.cornerCurve = .continuous }
        whiteView.layer.masksToBounds = true
    }

    private func setHeaderConstraints()  {
        titleLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview() // 居中显示
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(55))
        }
        cancelBtn.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(55))
        }
        confirmBtn.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(cancelBtn)
        }
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(kFitWidth(55))
            make.height.equalTo(kFitWidth(5))
        }
    }

    private func dealData() {
        fitnessArray.removeAll()
        for i in 0..<ConstantModel.shared.fitness_label_array.count {
            let str = ConstantModel.shared.fitness_label_array[i] as? String ?? ""
            if str != "-" {
                fitnessArray.append(str)
            }
        }

        // 计算内容高度（按 4 列网格）
        let rows = CGFloat((fitnessArray.count + 3) / 4)
        let contentHeight = (itemVmGapY + itemVmHeight) * rows

        // 55(title区) + 5(line) + 20(内间距/缓冲) + bottomSafe + 内容
        whiteViewHeight = kFitWidth(30) + kFitWidth(60) + kFitWidth(20) + WHUtils().getBottomSafeAreaHeight() + contentHeight
    }

    private func initVmArray() {
        // 清理旧的
        for vm in vmArray { vm.removeFromSuperview() }
        vmArray.removeAll()

        var originX: CGFloat = kFitWidth(18)
        var originY: CGFloat = kFitWidth(90)

        for i in 0..<fitnessArray.count {
            let row = i / 4
            let col = i % 4
            let itemsInRow = min(4, fitnessArray.count - row * 4)
            let rowWidth = CGFloat(itemsInRow) * itemVmWidth + CGFloat(itemsInRow - 1) * itmeVmGapX
            let startX = (SCREEN_WIDHT - rowWidth) * 0.5
            originX = startX + (itemVmWidth + itmeVmGapX) * CGFloat(col)
            originY = kFitWidth(90) + (itemVmHeight + itemVmGapY) * CGFloat(row)

            let vm = PlanCreateSynDaysVM(frame: CGRect(x: originX, y: originY, width: itemVmWidth, height: itemVmHeight))
            vm.backgroundColor = .clear
            vm.isHidden = false
            vm.selectBgColor = .COLOR_BG_F5
            vm.selectContentColor = .THEME
            vm.contentLabel.text = fitnessArray[i]
            vm.days = fitnessArray[i]
            whiteView.addSubview(vm)
            vmArray.append(vm)

            vm.tapBlock = { [weak self, weak vm] in
                guard let self = self, let vm = vm else { return }
                self.judgeTypeCount(vm: vm)
            }
        }
    }
    
    /// 如果初始化时常量数据未返回，在展示前重新构建内容
    private func reloadDataIfNeeded() {
        // 如果常量还未准备好，尝试从本地缓存读取
        if ConstantModel.shared.fitness_label_array.count == 0,
           let arr = UserDefaults.getArray(forKey: .fitness_label_array) {
            ConstantModel.shared.fitness_label_array = arr as NSArray
        }

        // 若 still 无数据则直接返回
        if ConstantModel.shared.fitness_label_array.count == 0 { return }

        // 当之前构建的内容为空或数量不一致时，重新构建
        if vmArray.isEmpty || fitnessArray.count != ConstantModel.shared.fitness_label_array.count {
            dealData()
            layoutWhiteViewFrame()
            initVmArray()
        }
    }
}

// MARK: - Selection logic
extension JournalFitnessTypeAlertVM {

    func judgeTypeCount(vm: PlanCreateSynDaysVM) {
        if vm.isSelect {
            if vm.days == "休" {
                selectFitnessType.removeAll()
            }
            if selectFitnessType.count >= 2 {
                // 允许两个，超过则队列式替换
                selectFitnessType.removeFirst()
                if !selectFitnessType.contains(vm.days) {
                    selectFitnessType.append(vm.days)
                }
            } else {
                if !selectFitnessType.contains(vm.days) {
                    selectFitnessType.append(vm.days)
                }
            }
        } else {
            if let idx = selectFitnessType.firstIndex(of: vm.days) {
                selectFitnessType.remove(at: idx)
            }
        }
        updateSelectStatus()
    }

    func updateSelectStatus() {
        let hasRest = selectFitnessType.contains("休")
        for vm in vmArray {
            vm.setSelectStatus(select: selectFitnessType.contains(vm.days))
            vm.setEnableStatus(isEnable: hasRest ? false : true)
            
        }
    }
}
