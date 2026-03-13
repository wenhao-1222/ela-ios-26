//
//  PlanMainPlanListVM.swift
//  lns
//
//  Created by LNS2 on 2026/3/12.
//

import UIKit
import SnapKit

private let planMainMealCellReuseId = "PlanMainMealCardCell"
private let planMainHeaderReuseId = "PlanMainDayHeaderView"

struct PlanMainMealItem {
    let mealId: String
    let id : String
    let mealImage: String
    let mealName: String
    let mealType: Int
    let sn: Int
    let calories: Double
    let carbohydrate: Double
    let protein: Double
    let fat: Double
}

private struct PlanMainMealDaySection {
    let sdate: String
    let totalCalories: Double
    let totalProtein: Double
    let totalCarbohydrate: Double
    let totalFat: Double
    let meals: [PlanMainMealItem]
}

class PlanMainPlanListVM: UIView {
    var mealChangeTapBlock: ((String,String) -> Void)?
    var mealTapBlock:((PlanMainMealItem,String)->())?
    
    private let sectionInset = UIEdgeInsets(top: 0, left: kFitWidth(16), bottom: kFitWidth(24), right: kFitWidth(16))
    private let itemSpacing = kFitWidth(12)
    private var mealDaySections: [PlanMainMealDaySection] = []
    private lazy var buyListCalendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "en_US_POSIX")
        return cal
    }()
    private lazy var buyListDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-WHUtils().getTabbarHeight()))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        topGradientLayer.frame = topGradientView.bounds
//    }
    
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_progress_bg")
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFill
        return img
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "食谱"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 17, weight: .medium)
        
        return lab
    }()
    
    lazy var createPlanButton: GJVerButtonNoneFeedBack = {
        let frame = CGRect(x: kFitWidth(16),
                           y: kFitWidth(61) + statusBarHeight,
                           width: kFitWidth(106),
                           height: kFitWidth(71))
        return makeRecipeActionButton(title: "创建",
                                      imageName: "dietplan_create_icon",
                                      imageSize: CGSize(width: kFitWidth(30), height: kFitWidth(30)),
                                      frame: frame)
    }()
    lazy var buyListButton: GJVerButtonNoneFeedBack = {
        let frame = CGRect(x: kFitWidth(134),
                           y: createPlanButton.frame.minY,
                           width: createPlanButton.frame.width,
                           height: createPlanButton.frame.height)
        let imageSize = CGSize(width: kFitWidth(30), height: kFitWidth(30))
        let btn = makeRecipeActionButton(title: "购物清单",
                                         imageName: "dietplan_buy_list_icon",
                                         imageSize: imageSize,
                                         frame: frame)
        let normalImage = resizedImage(named: "dietplan_buy_list_icon", size: imageSize) ?? UIImage(named: "dietplan_buy_list_icon")
        let disabledImage = resizedImage(named: "dietplan_buy_list_disable_icon", size: imageSize) ?? UIImage(named: "dietplan_buy_list_disable_icon")
        btn.setImage(normalImage, for: .normal)
        btn.setImage(disabledImage, for: .disabled)
        return btn
    }()
    lazy var sauceButton: GJVerButtonNoneFeedBack = {
        let frame = CGRect(x: kFitWidth(252),
                           y: createPlanButton.frame.minY,
                           width: createPlanButton.frame.width,
                           height: createPlanButton.frame.height)
        return makeRecipeActionButton(title: "酱料",
                                      imageName: "dietplan_sauce_icon",
                                      imageSize: CGSize(width: kFitWidth(30), height: kFitWidth(30)),
                                      frame: frame)
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = sectionInset
        layout.minimumLineSpacing = itemSpacing
        layout.minimumInteritemSpacing = itemSpacing
        layout.headerReferenceSize = CGSize(width: SCREEN_WIDHT, height: kFitWidth(132))
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.dataSource = self
        view.delegate = self
        view.register(PlanMainMealCardCell.self, forCellWithReuseIdentifier: planMainMealCellReuseId)
        view.register(PlanMainDayHeaderView.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier: planMainHeaderReuseId)
        return view
    }()
//    lazy var topGradientView: UIView = {
//        let vi = UIView()
//        vi.isUserInteractionEnabled = false
//        return vi
//    }()
//    lazy var topGradientLayer: CAGradientLayer = {
//        let layer = CAGradientLayer()
//        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
//        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
//        layer.colors = [
//            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
//            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
//        ]
//        layer.locations = [0, 1]
//        return layer
//    }()
}

extension PlanMainPlanListVM {
    func updatePlanList(mealPlanItemList: NSArray, preservingScrollOffset: Bool = false) {
        let currentOffset = collectionView.contentOffset
        mealDaySections = parseSections(mealPlanItemList)
        updateBuyListButtonState()
        
        if preservingScrollOffset {
            UIView.performWithoutAnimation {
                collectionView.reloadData()
                collectionView.layoutIfNeeded()
            }
            restoreCollectionViewOffset(currentOffset)
            return
        }
        
        collectionView.reloadData()
    }
    
    func buyListDateStringsFromToday() -> [String] {
        let today = buyListCalendar.startOfDay(for: Date())
        let datePairs = mealDaySections.compactMap { section -> (String, Date)? in
            guard let date = parsedBuyListDate(from: section.sdate) else { return nil }
            return (section.sdate, date)
        }
        .filter { $0.1 >= today }
        .sorted { $0.1 < $1.1 }
        
        var uniqueDates: [String] = []
        var seen = Set<String>()
        for (sdate, _) in datePairs where !seen.contains(sdate) {
            seen.insert(sdate)
            uniqueDates.append(sdate)
        }
        return uniqueDates
    }
}

extension PlanMainPlanListVM{
    func initUI() {
        addSubview(bgImgView)
        addSubview(titleLab)
        addSubview(createPlanButton)
        addSubview(buyListButton)
        addSubview(sauceButton)
        addSubview(collectionView)
//        addSubview(topGradientView)
//        topGradientView.layer.addSublayer(topGradientLayer)
        
        buyListButton.isEnabled = false
        
        setConstrait()
    }
    func setConstrait() {
        bgImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(20)+statusBarHeight)
            make.height.equalTo(kFitWidth(25))
        }
        collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(createPlanButton.snp.bottom).offset(kFitWidth(14))
        }
//        topGradientView.snp.makeConstraints { make in
//            make.left.right.equalToSuperview()
//            make.top.equalTo(collectionView.snp.top)//.offset(kFitWidth(-20))
//            make.height.equalTo(kFitWidth(35))
//        }
    }
}

private extension PlanMainPlanListVM {
    func restoreCollectionViewOffset(_ targetOffset: CGPoint) {
        let adjustedInset = collectionView.adjustedContentInset
        let minX = -adjustedInset.left
        let maxX = max(minX, collectionView.contentSize.width + adjustedInset.right - collectionView.bounds.width)
        let minY = -adjustedInset.top
        let maxY = max(minY, collectionView.contentSize.height + adjustedInset.bottom - collectionView.bounds.height)
        
        let clampedOffset = CGPoint(x: min(max(targetOffset.x, minX), maxX),
                                    y: min(max(targetOffset.y, minY), maxY))
        collectionView.setContentOffset(clampedOffset, animated: false)
    }
    
    func parsedBuyListDate(from sdate: String) -> Date? {
        guard let date = buyListDateFormatter.date(from: sdate) else { return nil }
        return buyListCalendar.startOfDay(for: date)
    }
    
    func updateBuyListButtonState() {
        buyListButton.isEnabled = !buyListDateStringsFromToday().isEmpty
    }
    
    func parseSections(_ source: NSArray) -> [PlanMainMealDaySection] {
        var sections: [PlanMainMealDaySection] = []
        
        for obj in source {
            let dayDict = obj as? NSDictionary ?? [:]
            let mealsArray = dayDict["meals"] as? NSArray ?? []
            var meals: [PlanMainMealItem] = []
            
            for mealObj in mealsArray {
                let mealDict = mealObj as? NSDictionary ?? [:]
                let item = PlanMainMealItem(
                    mealId: mealDict.stringValueForKey(key: "mealId"),
                    id: mealDict.stringValueForKey(key: "id"),
                    mealImage: mealDict.stringValueForKey(key: "mealImage"),
                    mealName: mealDict.stringValueForKey(key: "mealName"),
                    mealType: Int(mealDict.doubleValueForKey(key: "mealType")),
                    sn: Int(mealDict.doubleValueForKey(key: "sn")),
                    calories: mealDict.doubleValueForKey(key: "calories"),
                    carbohydrate: mealDict.doubleValueForKey(key: "carbohydrate"),
                    protein: mealDict.doubleValueForKey(key: "protein"),
                    fat: mealDict.doubleValueForKey(key: "fat")
                )
                meals.append(item)
            }
            
            meals.sort { lhs, rhs in
                if lhs.sn == rhs.sn {
                    return lhs.mealId < rhs.mealId
                }
                return lhs.sn < rhs.sn
            }
            
            let section = PlanMainMealDaySection(
                sdate: dayDict.stringValueForKey(key: "sdate"),
                totalCalories: dayDict.doubleValueForKey(key: "totalCalories"),
                totalProtein: dayDict.doubleValueForKey(key: "totalProtein"),
                totalCarbohydrate: dayDict.doubleValueForKey(key: "totalCarbohydrate"),
                totalFat: dayDict.doubleValueForKey(key: "totalFat"),
                meals: meals
            )
            sections.append(section)
        }
        
        return sections
    }
    
    func isLargeCard(for indexPath: IndexPath) -> Bool {
        let count = mealDaySections[indexPath.section].meals.count
        return count % 2 == 1 && indexPath.item == count - 1
    }
    
    func mealTypeText(for meal: PlanMainMealItem) -> String {
//        switch meal.sn {
//        case 1: return "早餐"
//        case 2: return "正餐"
//        case 3: return "晚餐"
//        case 4: return "加餐"
//        default:
            switch meal.mealType {
            case 1: return "早餐"
            case 2: return "正餐"
            case 3: return "加餐"
            default: return "餐食"
            }
//        }
    }
    
    func macroText(for meal: PlanMainMealItem) -> String {
        let carb = WHUtils.convertStringToStringNoDigit("\(meal.carbohydrate)") ?? "0"
        let protein = WHUtils.convertStringToStringNoDigit("\(meal.protein)") ?? "0"
        let fat = WHUtils.convertStringToStringNoDigit("\(meal.fat)") ?? "0"
        return "\(carb)g碳水 \(protein)g蛋白 \(fat)g脂肪"
    }
}

extension PlanMainPlanListVM: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        mealDaySections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mealDaySections[section].meals.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let daySection = mealDaySections[indexPath.section]
        let meal = daySection.meals[indexPath.item]
        let isLarge = isLargeCard(for: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: planMainMealCellReuseId, for: indexPath) as? PlanMainMealCardCell ?? PlanMainMealCardCell()
        cell.updateUI(typeText: mealTypeText(for: meal),
                      imageUrl: meal.mealImage,
                      nameText: meal.mealName,
                      macroText: macroText(for: meal),
                      kcalText: "\(WHUtils.convertStringToStringNoDigit("\(meal.calories)") ?? "0") kcal",
                      isLarge: isLarge)
        cell.changeButtonTapBlock = { [weak self] in
            self?.mealChangeTapBlock?(meal.mealId,meal.id)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let daySection = mealDaySections[indexPath.section]
        let meal = daySection.meals[indexPath.item]
        self.mealTapBlock?(meal,daySection.sdate)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: planMainHeaderReuseId,
                                                                       for: indexPath) as? PlanMainDayHeaderView ?? PlanMainDayHeaderView()
            view.updateUI(section: mealDaySections[indexPath.section])
            return view
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let contentWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right
        if isLargeCard(for: indexPath) {
            return CGSize(width: contentWidth, height: kFitWidth(308))
        }
        
        let width = (contentWidth - itemSpacing) * 0.5
        return CGSize(width: width, height: kFitWidth(234))
    }
}

private extension PlanMainPlanListVM {
    func makeRecipeActionButton(title: String,
                                imageName: String,
                                imageSize: CGSize,
                                frame: CGRect) -> GJVerButtonNoneFeedBack {
        let btn = GJVerButtonNoneFeedBack()
        btn.frame = frame
        btn.setTitle(title, for: .normal)
        let image = resizedImage(named: imageName, size: imageSize) ?? UIImage(named: imageName)
        btn.setImage(image, for: .normal)
        btn.setImage(image, for: .disabled)
        btn.backgroundColor = .COLOR_CARD_BG_WHITE
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        btn.layer.cornerRadius = kFitWidth(16)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.layoutIfNeeded()
        btn.imagePosition(style: .top, spacing: kFitWidth(8))
        return btn
    }
    
    func resizedImage(named: String, size: CGSize) -> UIImage? {
        guard let image = UIImage(named: named),
              size.width > 0,
              size.height > 0 else { return nil }
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

private final class PlanMainDayHeaderView: UICollectionReusableView {
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    private let caloriesValueLabel = PlanMainDayHeaderView.makeValueLabel()
    private let proteinValueLabel = PlanMainDayHeaderView.makeValueLabel()
    private let carbohydrateValueLabel = PlanMainDayHeaderView.makeValueLabel()
    private let fatValueLabel = PlanMainDayHeaderView.makeValueLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUI(section: PlanMainMealDaySection) {
        dayLabel.text = dateText(from: section.sdate)
        caloriesValueLabel.text = WHUtils.convertStringToStringNoDigit("\(section.totalCalories)") ?? "0"
        proteinValueLabel.text = "\(WHUtils.convertStringToStringNoDigit("\(section.totalProtein)") ?? "0")g"
        carbohydrateValueLabel.text = "\(WHUtils.convertStringToStringNoDigit("\(section.totalCarbohydrate)") ?? "0")g"
        fatValueLabel.text = "\(WHUtils.convertStringToStringNoDigit("\(section.totalFat)") ?? "0")g"
    }
}

private extension PlanMainDayHeaderView {
    static func makeValueLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }
    
    static func makeTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        return label
    }
    
    func metricItem(valueLabel: UILabel, title: String) -> UIView {
        let view = UIView()
        let titleLabel = Self.makeTitleLabel(text: title)
        
        view.addSubview(valueLabel)
        view.addSubview(titleLabel)
        
        valueLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(28))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(valueLabel.snp.bottom).offset(kFitWidth(2))
            make.height.equalTo(kFitWidth(21))
        }
        return view
    }
    
    func initUI() {
        addSubview(dayLabel)
        
        let rowStack = UIStackView(arrangedSubviews: [
            metricItem(valueLabel: caloriesValueLabel, title: "卡路里"),
            metricItem(valueLabel: proteinValueLabel, title: "蛋白质"),
            metricItem(valueLabel: carbohydrateValueLabel, title: "碳水"),
            metricItem(valueLabel: fatValueLabel, title: "脂肪")
        ])
        rowStack.axis = .horizontal
        rowStack.alignment = .fill
        rowStack.distribution = .fillEqually
        rowStack.spacing = 0
        addSubview(rowStack)
        
        dayLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.lessThanOrEqualTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(12))
            make.height.equalTo(kFitWidth(32))
        }
        rowStack.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalToSuperview().offset(kFitWidth(-8))
            make.height.equalTo(kFitWidth(58))
        }
    }
    
    func dateText(from sdate: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.calendar = Calendar(identifier: .gregorian)
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: sdate) else {
            return sdate
        }
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "M月d日"
        dayFormatter.calendar = Calendar(identifier: .gregorian)
        dayFormatter.locale = Locale(identifier: "zh_CN")
        
        return "\(dayFormatter.string(from: date))，\(weekdayText(from: date))"
    }
    
    func weekdayText(from date: Date) -> String {
        let week = Calendar(identifier: .gregorian).component(.weekday, from: date)
        switch week {
        case 1: return "星期日"
        case 2: return "星期一"
        case 3: return "星期二"
        case 4: return "星期三"
        case 5: return "星期四"
        case 6: return "星期五"
        case 7: return "星期六"
        default: return ""
        }
    }
}
