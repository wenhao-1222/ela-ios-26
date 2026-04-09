//
//  DietPlanBuyListDateVC.swift
//  lns
//
//  Created by LNS2 on 2026/3/12.
//

import MCToast

private struct DietPlanBuyListDateOption {
    let sdate: String
    let date: Date
    var isSelected: Bool
}

class DietPlanBuyListDateVC: WHBaseViewVC {
    private let sourceDateStrings: [String]
    private var dateOptions: [DietPlanBuyListDateOption] = []
    private let onConfirm: (([String]) -> Void)?
    
    private lazy var calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "en_US_POSIX")
        cal.timeZone = TimeZone.current
        return cal
    }()
    
    private lazy var inputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private lazy var requestDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private lazy var displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "你需要哪一天的购物清单？"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    lazy var buylistButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("我的购物清单", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_DISABLE_BG_THEME, for: .disabled)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.isEnabled = false
        btn.isHidden = true
        
        btn.addTarget(self, action: #selector(buyListTapAction), for: .touchUpInside)
        
        return btn
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.contentInsetAdjustmentBehavior = .never
        table.dataSource = self
        table.delegate = self
        table.register(DietPlanBuyListDateCell.self, forCellReuseIdentifier: DietPlanBuyListDateCell.reuseId)
        return table
    }()
    
    lazy var bottomGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    lazy var topGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    lazy var bottomGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
    lazy var topGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
    private lazy var nextButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("新建购物清单", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.backgroundColor = .COLOR_BUTTON_DISABLE_BG_THEME
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextButtonTapAction), for: .touchUpInside)
        return btn
    }()
    
    init(dateStrings: [String], onConfirm: (([String]) -> Void)? = nil) {
        self.sourceDateStrings = dateStrings
        self.onConfirm = onConfirm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .COLOR_BG_F2
        initNavi(titleStr: "")
        sendBuyListRequest()
        self.navigationView.backgroundColor = .clear
        naviTitleLabel.text = ""
        dateOptions = buildDateOptions(from: sourceDateStrings)
        initUI()
        updateNextButtonState()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topGradientLayer.frame = topGradientView.bounds
        bottomGradientLayer.frame = bottomGradientView.bounds
    }
}

private extension DietPlanBuyListDateVC {
    @objc func nextButtonTapAction() {
        let selectedDates = dateOptions.filter({ $0.isSelected }).map(\.sdate)
        guard !selectedDates.isEmpty else { return }
        
        if let onConfirm = onConfirm {
            onConfirm(selectedDates)
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        let vc = DietPlanBuyListVC()
        vc.selectedDates = selectedDates
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func buyListTapAction() {
        if onConfirm != nil {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        let vc = DietPlanBuyListVC()
        vc.showCreateButton = true
        vc.createDateStrings = sourceDateStrings
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func initUI() {
        view.addSubview(titleLabel)
        view.addSubview(buylistButton)
        view.addSubview(tableView)
        view.addSubview(nextButton)
        view.addSubview(topGradientView)
        view.addSubview(bottomGradientView)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)
        topGradientView.layer.addSublayer(topGradientLayer)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(getNavigationBarHeight() + kFitWidth(56))
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(34))
        }
        buylistButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(20))
            make.left.right.equalTo(titleLabel)
            make.height.equalTo(kFitWidth(28))
        }
        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.bottom.equalTo(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(10)))
            make.height.equalTo(kFitWidth(44))
        }
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(buylistButton.snp.bottom).offset(kFitWidth(10))
            make.bottom.equalTo(nextButton.snp.top).offset(kFitWidth(-8))
        }
        topGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(tableView.snp.top)//.offset(kFitWidth(-10))
            make.height.equalTo(kFitWidth(35))
        }
        bottomGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(tableView)
            make.height.equalTo(kFitWidth(35))
        }
    }
    
    func buildDateOptions(from dateStrings: [String]) -> [DietPlanBuyListDateOption] {
        let today = calendar.startOfDay(for: Date())
        let parsed = dateStrings.compactMap { sdate -> (String, Date)? in
            guard let rawDate = inputDateFormatter.date(from: sdate) else { return nil }
            let date = calendar.startOfDay(for: rawDate)
            return (sdate, date)
        }
        
        let sorted = parsed
            .filter { $0.1 >= today }
            .sorted { $0.1 < $1.1 }
        
        var options: [DietPlanBuyListDateOption] = []
        var seen = Set<String>()
        for (sdate, date) in sorted where !seen.contains(sdate) {
            seen.insert(sdate)
            options.append(DietPlanBuyListDateOption(sdate: sdate, date: date, isSelected: true))
        }
        return options
    }
    
    func displayText(for date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "今天"
        }
        return "\(displayDateFormatter.string(from: date))，\(weekdayText(from: date))"
    }
    
    func weekdayText(from date: Date) -> String {
        let weekday = calendar.component(.weekday, from: date)
        switch weekday {
        case 1: return "周日"
        case 2: return "周一"
        case 3: return "周二"
        case 4: return "周三"
        case 5: return "周四"
        case 6: return "周五"
        case 7: return "周六"
        default: return ""
        }
    }
    
    func updateNextButtonState() {
        nextButton.isEnabled = dateOptions.contains(where: { $0.isSelected })
    }
    
    func hasValidHistoryBuyList(_ dataObj: NSDictionary) -> Bool {
        let foodsArray = dataObj["shoppingList"] as? NSArray ?? []
        let endDate = dataObj.stringValueForKey(key: "endDate")
        let today = requestDateFormatter.string(from: Date())
        return foodsArray.count > 0 && endDate.count > 0 && Date().daysDifference(from: endDate) ?? 0 <= 0//endDate <= today
    }
}

extension DietPlanBuyListDateVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dateOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DietPlanBuyListDateCell.reuseId, for: indexPath) as? DietPlanBuyListDateCell ?? DietPlanBuyListDateCell()
        let option = dateOptions[indexPath.row]
        cell.updateUI(title: displayText(for: option.date), isSelected: option.isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard dateOptions.indices.contains(indexPath.row) else { return }
        dateOptions[indexPath.row].isSelected.toggle()
        updateNextButtonState()
        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        kFitWidth(72)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(15)))
        return vi
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kFitWidth(15)
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(35)))
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return kFitWidth(35)
    }
}

extension DietPlanBuyListDateVC{
    func sendBuyListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_shopping_list, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendBuyListRequest:\(dataObj)")
            
            if self.hasValidHistoryBuyList(dataObj) {
                self.buylistButton.isEnabled = true
                self.buylistButton.isHidden = false
            } else {
                self.buylistButton.isEnabled = false
                self.buylistButton.isHidden = true
            }
        }
    }
}
