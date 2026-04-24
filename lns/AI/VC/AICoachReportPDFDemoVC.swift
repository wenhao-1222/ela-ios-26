//
//  AICoachReportPDFDemoVC.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

import PDFKit
import MCToast
import SnapKit
import UIKit

final class AICoachReportPDFDemoVC: WHBaseViewVC {
    
    var reportId = ""
    var reportList: [AICoachReportListItem] = []
    
    private var report = AICoachReportDemoData.empty
    private var nextWeekRecommendation = AICoachReportNextWeekRecommendation.empty
    private var pdfFileURL: URL?
    private var hasGeneratedPDF = false
    private var isPDFLoaded = false
    private var shouldShowAdviceEntryForCurrentReport = false
    private var bottomBarHeightConstraint: Constraint?
    private var downloadButtonWidthConstraint: Constraint?
    private var isTopBarInteractionEnabled = false
    private var isDownloadInProgress = false

    private lazy var topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "back_arrow_black"), for: .normal)
        button.addTarget(self, action: #selector(backTapAction), for: .touchUpInside)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .semibold)
        label.textColor = AICoachReportDemoPalette.textPrimary
        label.textAlignment = .center
        label.text = report.navigationTitle
        return label
    }()

//    private lazy var dateLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 17, weight: .medium)
//        label.textColor = AICoachReportDemoPalette.textPrimary
//        label.text = report.navigationDateRange
//        return label
//    }()
//
//    private lazy var arrowImageView: UIImageView = {
//        let view = UIImageView()
//        view.image = UIImage(named: "create_plan_arrow_down")
////        view.tintColor = AICoachReportDemoPalette.textPrimary
//        return view
//    }()
    
    lazy var dateButton : GJVerButton = {
        let btn = GJVerButton.init(frame: CGRect.init(x: kFitWidth(40), y: getNavigationBarHeight(), width: SCREEN_WIDHT-kFitWidth(80), height: kFitWidth(27)))
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        btn.backgroundColor = .clear
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.imagePosition(style: .right, spacing: kFitWidth(4))
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(dateButtonTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var downloadButton : GJVerButton = {
        let btn = GJVerButton.init(frame: CGRect.init(x: kFitWidth(40), y: getNavigationBarHeight(), width: SCREEN_WIDHT-kFitWidth(80), height: kFitWidth(27)))
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        btn.backgroundColor = .clear
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.setImage(UIImage(named: "ai_coach_download_icon"), for: .normal)
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(downloadAction), for: .touchUpInside)
        
        return btn
    }()
    private lazy var dividerBand: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "F2F2F3")
        return view
    }()

    private lazy var pdfView: PDFView = {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.displaysPageBreaks = false
        view.backgroundColor = AICoachReportDemoPalette.pageBackground
        view.usePageViewController(false, withViewOptions: nil)
        return view
    }()

    private lazy var bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private lazy var bottomSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "EEEEF0")
        return view
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.hidesWhenStopped = true
        return view
    }()

    private lazy var loadingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = AICoachReportDemoPalette.textSecondary
        label.text = "正在生成PDF..."
        return label
    }()
    
    private lazy var adviceButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = AICoachReportDemoPalette.themeBlue
        button.layer.cornerRadius = 28
//        button.setTitle("下载", for: .normal)
        button.setTitle("下周摄入建议", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.enablePressEffect()
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.addTarget(self, action: #selector(adviceAction), for: .touchUpInside)

        return button
    }()

    private lazy var reportDateAlertVM: AICoachReportDateAlertVM = {
        let vm = AICoachReportDateAlertVM(frame: .zero)
        vm.confirmBlock = { [weak self] item in
            self?.handleReportSelection(item)
        }
        return vm
    }()

    private lazy var adviceAlertVM: AICoachReportAdviceAlertVM = {
        let vm = AICoachReportAdviceAlertVM(frame: .zero)
        vm.primaryActionBlock = { [weak self] recommendation, completion in
            self?.handleAdviceAlertAction(recommendation: recommendation,
                                          isOverrideMealPlan: 0,
                                          completion: completion)
        }
        vm.secondaryActionBlock = { [weak self] recommendation, completion in
            self?.handleAdviceAlertAction(recommendation: recommendation,
                                          isOverrideMealPlan: 1,
                                          completion: completion)
        }
        return vm
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        view.backgroundColor = .white
        setupUI()
        refreshTopBar()
        updateTopBarInteraction(isEnabled: false)
        updateBottomBarVisibility()
        updateAdviceButtonState(animated: false)
        sendReportListRequest()
        if reportId.isEmpty == false {
            sendReportDetailRequest()
            sendRecommendRequest()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard hasGeneratedPDF == false else { return }
        hasGeneratedPDF = true
        generateAndLoadPDF()
    }
}

private extension AICoachReportPDFDemoVC {
    func refreshTopBar() {
        titleLabel.text = report.navigationTitle
//        dateLabel.text = report.navigationDateRange
        dateButton.setTitle(report.navigationDateRange, for: .normal)
        dateButton.imagePosition(style: .right, spacing: kFitWidth(4))
    }

    func setupUI() {
        view.addSubview(topContainerView)
//        topContainerView.addSubview(backButton)
        topContainerView.addSubview(backArrowButton)
        topContainerView.addSubview(titleLabel)
        topContainerView.addSubview(dateButton)
        topContainerView.addSubview(downloadButton)
//        topContainerView.addSubview(dateLabel)
//        topContainerView.addSubview(arrowImageView)
        view.addSubview(dividerBand)
        view.addSubview(pdfView)
        view.addSubview(bottomBar)
        bottomBar.addSubview(bottomSeparator)
        bottomBar.addSubview(adviceButton)
        view.addSubview(loadingIndicator)
        view.addSubview(loadingLabel)
        view.addSubview(reportDateAlertVM)
        view.addSubview(adviceAlertVM)

        topContainerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(statusBarHeight + kFitWidth(44) + kFitWidth(27))
        }

//        backButton.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(20)
//            make.top.equalToSuperview().offset(statusBarHeight + 18)
//            make.width.height.equalTo(24)
//        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(statusBarHeight)
            make.height.equalTo(kFitWidth(44))
            make.centerX.equalToSuperview()
        }
        downloadButton.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(titleLabel)
            make.right.equalTo(kFitWidth(-12))
            make.height.equalTo(kFitWidth(30))
            downloadButtonWidthConstraint = make.width.equalTo(kFitWidth(30)).constraint
        }

//        dateLabel.snp.makeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom)//.offset(24)
//            make.height.equalTo(kFitWidth(27))
//            make.centerX.equalToSuperview().offset(-7)
//        }
//
//        arrowImageView.snp.makeConstraints { make in
//            make.left.equalTo(dateLabel.snp.right).offset(8)
//            make.centerY.equalTo(dateLabel.snp.centerY)//.offset(2)
//            make.width.height.equalTo(14)
//        }

        dividerBand.snp.makeConstraints { make in
            make.top.equalTo(topContainerView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(12)
        }

        pdfView.snp.makeConstraints { make in
            make.top.equalTo(dividerBand.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomBar.snp.top)
        }

        bottomBar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            bottomBarHeightConstraint = make.height.equalTo(getBottomSafeAreaHeight() + 96).constraint
        }

        bottomSeparator.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }

        adviceButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(18)
            make.height.equalTo(56)
        }

        loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(pdfView)
            make.centerY.equalTo(pdfView).offset(-16)
        }

        loadingLabel.snp.makeConstraints { make in
            make.top.equalTo(loadingIndicator.snp.bottom).offset(12)
            make.centerX.equalTo(pdfView)
        }

        reportDateAlertVM.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        adviceAlertVM.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bottomBar.isHidden = true
        adviceButton.isHidden = true
        adviceButton.alpha = 0
    }

    func generateAndLoadPDF() {
        isPDFLoaded = false
        updateAdviceButtonState(animated: false)
        updateTopBarInteraction(isEnabled: false)
        loadingIndicator.startAnimating()
        loadingLabel.text = "正在生成PDF..."
        loadingLabel.isHidden = false

        DispatchQueue.main.async {
            do {
                let fileURL = try AICoachReportPDFGenerator.generate(report: self.report)
                self.pdfFileURL = fileURL
                self.loadPDF(from: fileURL)
                self.loadingIndicator.stopAnimating()
                self.loadingLabel.isHidden = true
                self.updateTopBarInteraction(isEnabled: true)
            } catch {
                self.loadingIndicator.stopAnimating()
                self.loadingLabel.text = "PDF 生成失败"
                self.updateTopBarInteraction(isEnabled: true)
            }
        }
    }

    func loadPDF(from url: URL) {
        guard let document = PDFDocument(url: url) else {
            loadingLabel.text = "PDF 加载失败"
            updateTopBarInteraction(isEnabled: true)
            return
        }
        pdfView.document = document
        pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
        pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
        pdfView.maxScaleFactor = pdfView.minScaleFactor * 3.5
        isPDFLoaded = true
        updateAdviceButtonState()
    }

    @objc func adviceAction() {
        guard nextWeekRecommendation.isValid else {
            MCToast.mc_text("暂无建议")
            return
        }
        adviceAlertVM.update(data: nextWeekRecommendation)
        adviceAlertVM.showSelf()
    }
    @objc func downloadAction() {
        guard isDownloadInProgress == false, let pdfFileURL else { return }
        guard presentedViewController == nil else { return }
        setDownloadLoading(true)
        let activityVC = UIActivityViewController(activityItems: [pdfFileURL], applicationActivities: nil)
        activityVC.completionWithItemsHandler = { [weak self] _, _, _, _ in
            DispatchQueue.main.async {
                self?.setDownloadLoading(false)
            }
        }
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = downloadButton
            popover.sourceRect = downloadButton.bounds
        }
        present(activityVC, animated: true)
    }

    @objc func dateButtonTapAction() {
        guard dateButton.isUserInteractionEnabled else { return }
        guard reportList.isEmpty == false else {
            sendReportListRequest()
            return
        }
        reportDateAlertVM.update(items: reportList, selectedReportId: reportId)
        reportDateAlertVM.showSelf()
    }
}

extension AICoachReportPDFDemoVC{
    func sendReportDetailRequest() {
        guard reportId.isEmpty == false else { return }
        updateTopBarInteraction(isEnabled: false)
        let param = ["id":reportId]
        WHNetworkUtil.shareManager().POST(urlString: URL_ai_coach_report_detail, parameters: param as [String : AnyObject]) { [weak self] responseObject in
            guard let self else { return }
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let foodsMsgDict = self.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendReportDetailRequest:\(foodsMsgDict)")
            DispatchQueue.main.async {
                self.applyReportDetailData(foodsMsgDict)
            }
        }
    }
    func sendRecommendRequest() {
        guard reportId.isEmpty == false else { return }
        nextWeekRecommendation = .empty
        DispatchQueue.main.async {
            self.updateAdviceButtonState()
        }
        let param = ["id":reportId]
        WHNetworkUtil.shareManager().POST(urlString: URL_ai_coach_report_recommend, parameters: param as [String : AnyObject]) { [weak self] responseObject in
            guard let self else { return }
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let foodsMsgDict = self.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendRecommendRequest:\(foodsMsgDict)")
            let recommendation = AICoachReportRecommendationBuilder.build(from: foodsMsgDict)
            DispatchQueue.main.async {
                self.nextWeekRecommendation = recommendation
                self.updateAdviceButtonState()
            }
        }
    }

    func sendReportListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_ai_coach_report_list, parameters: nil) { [weak self] responseObject in
            guard let self else { return }
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = self.getArrayFromJSONString(jsonString: dataString ?? "")
            let parsedList = AICoachReportDateTextBuilder.buildList(from: dataArray)

            DispatchQueue.main.async {
                self.reportList = parsedList
                if self.reportId.isEmpty, let firstItem = parsedList.first {
                    self.reportId = firstItem.reportId
                    self.updateBottomBarVisibility()
                    self.sendReportDetailRequest()
                    self.sendRecommendRequest()
                } else {
                    self.updateBottomBarVisibility()
                }
                self.reportDateAlertVM.update(items: parsedList, selectedReportId: self.reportId)
            }
        }
    }
}

private extension AICoachReportPDFDemoVC {
    func applyReportDetailData(_ dataDict: NSDictionary) {
        report = buildReport(from: dataDict)
        refreshTopBar()
        reportDateAlertVM.update(items: reportList, selectedReportId: reportId)
        if hasGeneratedPDF {
            generateAndLoadPDF()
        }
    }

    func buildReport(from dataDict: NSDictionary) -> AICoachReportDemoData {
        let fallback = AICoachReportDemoData.empty
        let reportContent = dataDict["reportContent"] as? NSDictionary ?? NSDictionary()

        let startDate = preferredValue(
            reportContent.stringValueForKey(key: "startDate"),
            fallback: dataDict.stringValueForKey(key: "startDate")
        )
        let endDate = preferredValue(
            reportContent.stringValueForKey(key: "endDate"),
            fallback: dataDict.stringValueForKey(key: "endDate")
        )
        let weeklySummary = reportContent.stringValueForKey(key: "weeklySummary")
        let summaryInfo = makeSummaryInfo(
            weeklySummary: weeklySummary,
            fallbackLines: fallback.weeklySummaryLines,
            fallbackConfidence: fallback.confidenceText
        )

        let userGoal = preferredValue(reportContent.stringValueForKey(key: "userGoal"), fallback: "增肌")
        let reportTitle = preferredValue(reportContent.stringValueForKey(key: "reportTitle"), fallback: fallback.reportTitle)
        let weightLogDays = Int(reportContent.doubleValueForKey(key: "weightLogDays").rounded())
        let foodLogDays = Int(reportContent.doubleValueForKey(key: "foodLogDays").rounded())
        let fitnessLogDays = Int(reportContent.doubleValueForKey(key: "fitnessLogDays").rounded())

        return AICoachReportDemoData(
            navigationTitle: fallback.navigationTitle,
            navigationDateRange: makeNavigationDateRange(startDate: startDate, endDate: endDate, fallback: fallback.navigationDateRange),
            reportTitle: reportTitle,
            reportDateRange: makeReportDateRange(startDate: startDate, endDate: endDate, fallback: fallback.reportDateRange),
            targetText: "目标： \(userGoal)",
            completenessText: "数据完整度： 饮食\(foodLogDays)/7，体重\(weightLogDays)/7，力量训练\(fitnessLogDays)/7",
            weeklySummaryTitle: fallback.weeklySummaryTitle,
            weeklySummaryLines: summaryInfo.lines,
            confidenceText: summaryInfo.confidenceText,
            weeklyPotentialTitle: fallback.weeklyPotentialTitle,
            weeklyPotentialValue: makePercentText(
                reportContent.stringValueForKey(key: "weeklyPotentialUtilization"),
                fallback: fallback.weeklyPotentialValue
            ),
            riskTip: makeTipText(
                prefix: "潜在卡点：",
                value: reportContent.stringValueForKey(key: "potentialBottleneck"),
                fallback: fallback.riskTip
            ),
            actionTip: makeTipText(
                prefix: "最小调整动作：",
                value: reportContent.stringValueForKey(key: "minimalAdjustment"),
                fallback: fallback.actionTip
            ),
            weightChart: buildWeightChart(
                reportContent: reportContent,
                startDate: startDate,
                endDate: endDate,
                fallback: fallback.weightChart
            ),
            calorieChart: buildCalorieChart(
                reportContent: reportContent,
                startDate: startDate,
                endDate: endDate,
                fallback: fallback.calorieChart
            ),
            nutrientChart: buildNutrientChart(
                reportContent: reportContent,
                startDate: startDate,
                endDate: endDate,
                fallback: fallback.nutrientChart
            ),
            trainingChart: buildTrainingChart(
                reportContent: reportContent,
                fallback: fallback.trainingChart
            ),
            dailyComparisonTable: buildDailyComparisonTable(
                reportContent: reportContent,
                startDate: startDate,
                endDate: endDate,
                fallback: fallback.dailyComparisonTable
            ),
            weeklyInsightText: sanitizedText(reportContent.stringValueForKey(key: "weeklyInsight")),
            nextWeekTopTaskText: sanitizedText(reportContent.stringValueForKey(key: "nextWeekTopTask")),
            moreInsights: sanitizedTextArray(reportContent["moreInsights"]),
            alternativeTasks: sanitizedTextArray(reportContent["alternativeTasks"]),
            nextPageTitle: fallback.nextPageTitle,
            nextPageItems: fallback.nextPageItems
        )
    }

    func preferredValue(_ value: String, fallback: String) -> String {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedValue.isEmpty == false {
            return trimmedValue
        }
        return fallback.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func sanitizedText(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func sanitizedTextArray(_ value: Any?) -> [String] {
        let items = value as? [Any] ?? []
        return items
            .compactMap { ($0 as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
    }

    func makeNavigationDateRange(startDate: String, endDate: String, fallback: String) -> String {
        let rangeText = AICoachReportDateTextBuilder.navigationDateRangeText(startDate: startDate, endDate: endDate)
        return rangeText.isEmpty ? fallback : rangeText
    }

    func makeReportDateRange(startDate: String, endDate: String, fallback: String) -> String {
        let startText = formatDate(startDate, targetFormatter: "yyyy年MM月dd日")
        let endText = formatDate(endDate, targetFormatter: "yyyy年MM月dd日")
        guard startText.isEmpty == false, endText.isEmpty == false else { return fallback }
        return "日期： \(startText) – \(endText)"
    }

    func formatDate(_ dateString: String, targetFormatter: String) -> String {
        let trimmedDate = dateString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedDate.isEmpty == false else { return "" }
        return Date().changeDateFormatter(dateString: trimmedDate, formatter: "yyyy-MM-dd", targetFormatter: targetFormatter)
    }

    func updateTopBarInteraction(isEnabled: Bool) {
        isTopBarInteractionEnabled = isEnabled
        refreshTopBarButtonState()
    }

    func setDownloadLoading(_ isLoading: Bool) {
        isDownloadInProgress = isLoading
        downloadButton.transform = .identity
        downloadButton.setTitle(isLoading ? "下载中" : nil, for: .normal)
        downloadButton.setImage(isLoading ? nil : UIImage(named: "ai_coach_download_icon"), for: .normal)
        downloadButton.contentEdgeInsets = isLoading
            ? UIEdgeInsets(top: 0, left: kFitWidth(8), bottom: 0, right: kFitWidth(8))
            : .zero
        downloadButtonWidthConstraint?.update(offset: isLoading ? kFitWidth(70) : kFitWidth(30))
        view.layoutIfNeeded()
        refreshTopBarButtonState()
    }

    func refreshTopBarButtonState() {
        let isDateEnabled = isTopBarInteractionEnabled && !isDownloadInProgress
        let isDownloadEnabled = isDateEnabled && pdfFileURL != nil

        downloadButton.isEnabled = isDownloadEnabled
        downloadButton.isUserInteractionEnabled = isDownloadEnabled
        downloadButton.alpha = isDownloadInProgress ? 1 : (isDownloadEnabled ? 1 : 0.5)

        dateButton.isEnabled = isDateEnabled
        dateButton.isUserInteractionEnabled = isDateEnabled
        dateButton.alpha = isDateEnabled ? 1 : 0.6
    }

    func updateBottomBarVisibility() {
        shouldShowAdviceEntryForCurrentReport = reportList.first?.reportId == reportId || reportList.isEmpty
        updateAdviceButtonState(animated: false)
    }

    func updateAdviceButtonState(animated: Bool = true) {
        let isEnabled = nextWeekRecommendation.isValid
        adviceButton.isEnabled = isEnabled
        let shouldShowButton = shouldShowAdviceEntryForCurrentReport && isPDFLoaded && isEnabled
        let targetHeight = shouldShowButton ? getBottomSafeAreaHeight() + 96 : 0

        if shouldShowButton {
            adviceButton.alpha = 0.5
        }

        guard animated else {
            bottomBarHeightConstraint?.update(offset: targetHeight)
            bottomBar.isHidden = !shouldShowButton
            adviceButton.isHidden = !shouldShowButton
            adviceButton.alpha = shouldShowButton ? 1 : 0
            view.layoutIfNeeded()
            return
        }

        if shouldShowButton {
            let needsFadeIn = bottomBar.isHidden || adviceButton.isHidden || adviceButton.alpha < 1
            bottomBar.isHidden = false
            adviceButton.isHidden = false
            if needsFadeIn {
                adviceButton.alpha = 0
            }
            bottomBarHeightConstraint?.update(offset: targetHeight)
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.curveEaseInOut, .allowUserInteraction]) {
                self.view.layoutIfNeeded()
                self.adviceButton.alpha = 1
            }
        } else {
            guard bottomBar.isHidden == false || adviceButton.isHidden == false else {
                bottomBarHeightConstraint?.update(offset: targetHeight)
                view.layoutIfNeeded()
                return
            }
            bottomBarHeightConstraint?.update(offset: targetHeight)
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: [.curveEaseInOut, .allowUserInteraction]) {
                self.view.layoutIfNeeded()
                self.adviceButton.alpha = 0
            } completion: { _ in
                self.adviceButton.isHidden = true
                self.bottomBar.isHidden = true
            }
        }
    }

    func handleAdviceAlertAction(
        recommendation: AICoachReportNextWeekRecommendation,
        isOverrideMealPlan: Int,
        completion: @escaping (Bool) -> Void
    ) {
        guard recommendation.status != .maintain else {
            adviceAlertVM.hiddenSelf()
            completion(false)
            return
        }

        guard let calories = recommendation.caloriesValue,
              let carbohydrate = recommendation.carbohydrateValue,
              let protein = recommendation.proteinValue,
              let fat = recommendation.fatValue else {
            completion(false)
            return
        }

        let roundedCalories = Int(calories.rounded())
        let roundedCarbohydrate = Int(carbohydrate.rounded())
        let roundedProtein = Int(protein.rounded())
        let roundedFat = Int(fat.rounded())

        let caloriesText = "\(roundedCalories)"
        let carbohydrateText = "\(roundedCarbohydrate)"
        let proteinText = "\(roundedProtein)"
        let fatText = "\(roundedFat)"

        let param: [String: AnyObject] = [
            "isOverrideMealPlan": NSNumber(value: isOverrideMealPlan),
            "calories": NSNumber(value: roundedCalories),
            "carbohydrate": NSNumber(value: roundedCarbohydrate),
            "protein": NSNumber(value: roundedProtein),
            "fat": NSNumber(value: roundedFat)
        ]

        WHNetworkUtil.shareManager().POST(urlString: URL_ai_coach_report_recommend_update,
                                          parameters: param) { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                QuestinonaireMsgModel.shared.calories = caloriesText
                QuestinonaireMsgModel.shared.carbohydrates = carbohydrateText
                QuestinonaireMsgModel.shared.protein = proteinText
                QuestinonaireMsgModel.shared.fats = fatText
                QuestinonaireMsgModel.shared.caloriesNumber = caloriesText
                QuestinonaireMsgModel.shared.carbohydratesNumber = carbohydrateText
                QuestinonaireMsgModel.shared.proteinNumber = proteinText
                QuestinonaireMsgModel.shared.fatsNumber = fatText
                QuestinonaireMsgModel.shared.caloriesNumberFromServer = caloriesText
                QuestinonaireMsgModel.shared.carbohydratesNumberFromServer = carbohydrateText
                QuestinonaireMsgModel.shared.proteinNumberFromServer = proteinText
                QuestinonaireMsgModel.shared.fatsNumberFromServer = fatText

                NutritionDefaultModel.shared.saveGoals(dict: [
                    "calories": caloriesText,
                    "carbohydrates": carbohydrateText,
                    "proteins": proteinText,
                    "fats": fatText
                ])
                LogsSQLiteManager.getInstance().refreshDataTarget(sDate: Date().nextDay(days: 0),
                                                                  caloriTar: QuestinonaireMsgModel.shared.calories,
                                                                  proteinTar: QuestinonaireMsgModel.shared.protein,
                                                                  carboTar: QuestinonaireMsgModel.shared.carbohydrates,
                                                                  fatsTar: QuestinonaireMsgModel.shared.fats)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
//                self.sendRecommendRequest()
                completion(true)
            }
        } failure: { _ in
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }

    func handleReportSelection(_ item: AICoachReportListItem) {
        guard item.reportId.isEmpty == false else { return }
        guard item.reportId != reportId else { return }

        reportId = item.reportId
        isPDFLoaded = false
        nextWeekRecommendation = .empty
        updateAdviceButtonState(animated: false)
        updateBottomBarVisibility()
        pdfFileURL = nil
        setDownloadLoading(false)
        pdfView.document = nil
        loadingLabel.text = "正在加载报告..."
        loadingLabel.isHidden = false
        loadingIndicator.startAnimating()
        sendReportDetailRequest()
        sendRecommendRequest()
    }

    func makeSummaryInfo(
        weeklySummary: String,
        fallbackLines: [String],
        fallbackConfidence: String
    ) -> (lines: [String], confidenceText: String) {
        let trimmedSummary = weeklySummary.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedSummary.isEmpty == false else {
            return (fallbackLines, fallbackConfidence)
        }

        if let confidenceRange = trimmedSummary.range(of: "数据综合置信度") {
            let summaryText = String(trimmedSummary[..<confidenceRange.lowerBound])
                .trimmingCharacters(in: CharacterSet(charactersIn: "。 \n"))
            let confidenceText = String(trimmedSummary[confidenceRange.lowerBound...])
                .trimmingCharacters(in: CharacterSet(charactersIn: "。 \n"))
            return (
                summaryText.isEmpty ? fallbackLines : [summaryText],
                confidenceText.isEmpty ? fallbackConfidence : confidenceText
            )
        }

        let lines = trimmedSummary
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
        return (lines.isEmpty ? fallbackLines : lines, fallbackConfidence)
    }

    func makePercentText(_ value: String, fallback: String) -> String {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedValue.isEmpty == false else { return fallback }
        return trimmedValue.hasSuffix("%") ? trimmedValue : "\(trimmedValue)%"
    }

    func makeTipText(prefix: String, value: String, fallback: String) -> String {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedValue.isEmpty == false else { return fallback }
        if trimmedValue.hasPrefix(prefix) {
            return trimmedValue
        }
        return "\(prefix)\(trimmedValue)"
    }

    func buildWeightChart(
        reportContent: NSDictionary,
        startDate: String,
        endDate: String,
        fallback: AICoachReportLineChartData
    ) -> AICoachReportLineChartData {
        let weightPack = reportContent["weightPack"] as? NSDictionary ?? NSDictionary()
        let axisSlots = makeWeeklyAxisSlots(
            startDate: startDate,
            endDate: endDate,
            fallbackLabels: fallback.entries.map(\.axisLabel)
        )
        let weightByDate = makeWeightValueMap(weightPack: weightPack)

        let entries = axisSlots.map { slot in
            let weightValue = weightByDate[slot.key]
            return AICoachReportLinePoint(
                axisLabel: slot.label,
                plottedValue: weightValue,
                valueText: weightValue.map { formatChartNumber($0) } ?? ""
            )
        }

        let validValues = entries.compactMap(\.plottedValue)
        let axisConfig = makeWeightAxisConfig(values: validValues, fallback: fallback)

        return AICoachReportLineChartData(
            yAxisTexts: axisConfig.yAxisTexts,
            minValue: axisConfig.minValue,
            maxValue: axisConfig.maxValue,
            entries: entries,
            footerRows: makeWeightFooterRows(weightPack: weightPack, validValues: validValues, fallback: fallback.footerRows)
        )
    }

    func buildCalorieChart(
        reportContent: NSDictionary,
        startDate: String,
        endDate: String,
        fallback: AICoachReportBarChartData
    ) -> AICoachReportBarChartData {
        let caloriesPack = reportContent["caloriesPack"] as? NSDictionary ?? NSDictionary()
        let axisSlots = makeWeeklyAxisSlots(
            startDate: startDate,
            endDate: endDate,
            fallbackLabels: fallback.entries.map(\.axisLabel)
        )
        let calorieByDate = makeCalorieValueMap(caloriesPack: caloriesPack)

        let entries = axisSlots.map { slot in
            AICoachReportBarPoint(axisLabel: slot.label, value: calorieByDate[slot.key])
        }

        let validValues = entries.compactMap(\.value)
        let axisConfig = makeCalorieAxisConfig(values: validValues, fallback: fallback)

        return AICoachReportBarChartData(
            yAxisTexts: axisConfig.yAxisTexts,
            maxValue: axisConfig.maxValue,
            entries: entries,
            footerRows: makeCalorieFooterRows(caloriesPack: caloriesPack, validValues: validValues, fallback: fallback.footerRows)
        )
    }

    func buildNutrientChart(
        reportContent: NSDictionary,
        startDate: String,
        endDate: String,
        fallback: AICoachReportGroupedBarChartData
    ) -> AICoachReportGroupedBarChartData {
        let nutrientsPack = reportContent["nutrientsPack"] as? NSDictionary ?? NSDictionary()
        let axisSlots = makeWeeklyAxisSlots(
            startDate: startDate,
            endDate: endDate,
            fallbackLabels: fallback.entries.map(\.axisLabel)
        )
        let nutrientsByDate = makeNutrientValueMap(nutrientsPack: nutrientsPack)

        let entries = axisSlots.map { slot in
            let values = nutrientsByDate[slot.key] ?? [nil, nil, nil]
            return AICoachReportGroupedBarPoint(
                axisLabel: slot.label,
                values: values.map { $0 ?? 0 }
            )
        }

        let allValues = nutrientsByDate.values.flatMap { $0 }.compactMap { $0 }
        let axisConfig = makeNutrientAxisConfig(values: allValues, fallback: fallback)

        return AICoachReportGroupedBarChartData(
            yAxisTexts: axisConfig.yAxisTexts,
            maxValue: axisConfig.maxValue,
            entries: entries,
            legendItems: makeNutrientLegendItems(nutrientsPack: nutrientsPack, fallback: fallback.legendItems)
        )
    }

    func buildTrainingChart(
        reportContent: NSDictionary,
        fallback: AICoachReportTrainingCardData
    ) -> AICoachReportTrainingCardData {
        let fitnessPack = reportContent["fitnessPack"] as? NSDictionary ?? NSDictionary()
        let bodyPartList = (fitnessPack["bodyPartList"] as? NSArray)?
            .compactMap { $0 as? NSDictionary } ?? []

        let items = bodyPartList.map { item in
            AICoachReportTrainingItem(
                title: item.stringValueForKey(key: "part"),
                count: Int(item.doubleValueForKey(key: "num").rounded()),
                maxCount: 1
            )
        }.filter { $0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false }

        let maxCount = max(items.map(\.count).max() ?? 0, 1)
        let normalizedItems = items.map {
            AICoachReportTrainingItem(title: $0.title, count: $0.count, maxCount: maxCount)
        }
        let columns = splitTrainingItems(normalizedItems)
        let workoutDays = Int(fitnessPack.doubleValueForKey(key: "workoutDays").rounded())
        let restDays = Int(fitnessPack.doubleValueForKey(key: "restDays").rounded())

        return AICoachReportTrainingCardData(
            title: fallback.title,
            leftItems: columns.left,
            rightItems: columns.right,
            bottomLeftText: "本周训练天数： \(workoutDays) 天",
            bottomRightText: "休息天数： \(restDays) 天"
        )
    }

    func buildDailyComparisonTable(
        reportContent: NSDictionary,
        startDate: String,
        endDate: String,
        fallback: AICoachReportWeekTableData
    ) -> AICoachReportWeekTableData {
        let axisSlots = makeWeeklyAxisSlots(
            startDate: startDate,
            endDate: endDate,
            fallbackLabels: fallback.rows.map { $0.values.first ?? "-" }
        )
        let weightPack = reportContent["weightPack"] as? NSDictionary ?? NSDictionary()
        let caloriesPack = reportContent["caloriesPack"] as? NSDictionary ?? NSDictionary()
        let nutrientsPack = reportContent["nutrientsPack"] as? NSDictionary ?? NSDictionary()
        let weekDataPack = reportContent["weekDataPack"] as? NSDictionary ?? NSDictionary()

        let weightByDate = makeWeightValueMap(weightPack: weightPack)
        let calorieByDate = makeCalorieValueMap(caloriesPack: caloriesPack)
        let nutrientsByDate = makeNutrientValueMap(nutrientsPack: nutrientsPack)
        let weekDataByDate = makeWeekDataItemMap(weekDataPack: weekDataPack)

        let rows = axisSlots.map { slot in
            let weekItem = weekDataByDate[slot.key]
            let nutrients = nutrientsByDate[slot.key] ?? [nil, nil, nil]

            return AICoachReportWeekTableRow(values: [
                slot.label,
                displayText(weekItem?.weight ?? weightByDate[slot.key]),
                displayText(weekItem?.calories ?? calorieByDate[slot.key]),
                displayText(weekItem?.protein ?? nutrients[1]),
                displayText(weekItem?.carbohydrate ?? nutrients[0]),
                displayText(weekItem?.fat ?? nutrients[2]),
                displayText(weekItem?.fitnessLabel)
            ])
        }

        return AICoachReportWeekTableData(
            title: fallback.title,
            columnTitles: fallback.columnTitles,
            rows: rows
        )
    }

    func makeWeeklyAxisSlots(
        startDate: String,
        endDate: String,
        fallbackLabels: [String]
    ) -> [(key: String, label: String)] {
        let calendar = Calendar(identifier: .gregorian)

        if let start = parseReportDate(startDate) {
            return (0..<7).compactMap { offset in
                guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
                return (weightDataKey(from: date), weightAxisLabel(from: date))
            }
        }

        if let end = parseReportDate(endDate) {
            return (0..<7).compactMap { offset in
                guard let date = calendar.date(byAdding: .day, value: offset - 6, to: end) else { return nil }
                return (weightDataKey(from: date), weightAxisLabel(from: date))
            }
        }

        return fallbackLabels.enumerated().map { index, label in
            (key: "\(index)", label: label)
        }
    }

    func splitTrainingItems(_ items: [AICoachReportTrainingItem]) -> (left: [AICoachReportTrainingItem], right: [AICoachReportTrainingItem]) {
        guard items.isEmpty == false else { return ([], []) }
        let leftCount = Int(ceil(Double(items.count) / 2.0))
        let leftItems = Array(items.prefix(leftCount))
        let rightItems = Array(items.dropFirst(leftCount))
        return (leftItems, rightItems)
    }

    func makeWeightValueMap(weightPack: NSDictionary) -> [String: CGFloat] {
        let weeklyWeightData = (weightPack["weeklyWeightData"] as? NSArray)?
            .compactMap { $0 as? NSDictionary } ?? []

        var weightByDate: [String: CGFloat] = [:]
        weeklyWeightData.forEach { item in
            let rawDate = preferredValue(
                item.stringValueForKey(key: "sdate"),
                fallback: item.stringValueForKey(key: "ctime")
            )
            let normalizedDate = normalizedWeightDataKey(rawDate)
            guard normalizedDate.isEmpty == false else { return }
            weightByDate[normalizedDate] = CGFloat(item.doubleValueForKey(key: "weight"))
        }
        return weightByDate
    }

    func makeCalorieValueMap(caloriesPack: NSDictionary) -> [String: CGFloat] {
        let weeklyCaloriesData = (caloriesPack["weeklyCaloriesData"] as? NSArray)?
            .compactMap { $0 as? NSDictionary } ?? []

        var calorieByDate: [String: CGFloat] = [:]
        weeklyCaloriesData.forEach { item in
            let rawDate = preferredValue(
                item.stringValueForKey(key: "sdate"),
                fallback: item.stringValueForKey(key: "ctime")
            )
            let normalizedDate = normalizedWeightDataKey(rawDate)
            guard normalizedDate.isEmpty == false else { return }
            calorieByDate[normalizedDate] = CGFloat(item.doubleValueForKey(key: "calories"))
        }
        return calorieByDate
    }

    func makeNutrientValueMap(nutrientsPack: NSDictionary) -> [String: [CGFloat?]] {
        let weeklyNutrientsData = (nutrientsPack["weeklyNutrientsData"] as? NSArray)?
            .compactMap { $0 as? NSDictionary } ?? []

        var nutrientsByDate: [String: [CGFloat?]] = [:]
        weeklyNutrientsData.forEach { item in
            let rawDate = preferredValue(
                item.stringValueForKey(key: "sdate"),
                fallback: item.stringValueForKey(key: "ctime")
            )
            let normalizedDate = normalizedWeightDataKey(rawDate)
            guard normalizedDate.isEmpty == false else { return }
            nutrientsByDate[normalizedDate] = [
                item["carbohydrate"] == nil ? nil : CGFloat(item.doubleValueForKey(key: "carbohydrate")),
                item["protein"] == nil ? nil : CGFloat(item.doubleValueForKey(key: "protein")),
                item["fat"] == nil ? nil : CGFloat(item.doubleValueForKey(key: "fat"))
            ]
        }
        return nutrientsByDate
    }

    func makeWeekDataItemMap(weekDataPack: NSDictionary) -> [String: (weight: CGFloat?, calories: CGFloat?, protein: CGFloat?, carbohydrate: CGFloat?, fat: CGFloat?, fitnessLabel: String?)] {
        let weekDataItemList = (weekDataPack["weekDataItemList"] as? NSArray)?
            .compactMap { $0 as? NSDictionary } ?? []

        var result: [String: (weight: CGFloat?, calories: CGFloat?, protein: CGFloat?, carbohydrate: CGFloat?, fat: CGFloat?, fitnessLabel: String?)] = [:]
        weekDataItemList.forEach { item in
            let normalizedDate = normalizedWeightDataKey(item.stringValueForKey(key: "sdate"))
            guard normalizedDate.isEmpty == false else { return }
            result[normalizedDate] = (
                item["weight"] == nil ? nil : CGFloat(item.doubleValueForKey(key: "weight")),
                item["calories"] == nil ? nil : CGFloat(item.doubleValueForKey(key: "calories")),
                item["protein"] == nil ? nil : CGFloat(item.doubleValueForKey(key: "protein")),
                item["carbohydrate"] == nil ? nil : CGFloat(item.doubleValueForKey(key: "carbohydrate")),
                item["fat"] == nil ? nil : CGFloat(item.doubleValueForKey(key: "fat")),
                item.stringValueForKey(key: "fitnessLabel")
            )
        }
        return result
    }

    func makeWeightAxisConfig(
        values: [CGFloat],
        fallback: AICoachReportLineChartData
    ) -> (yAxisTexts: [String], minValue: CGFloat, maxValue: CGFloat) {
        guard let minValue = values.min(), let maxValue = values.max() else {
            return (["80", "60", "40", "20", "0"], 0, 80)
        }

        let range = max(maxValue - minValue, 0.1)
        let padding = max(range * 0.25, 0.8)
        let axisMin = floor((minValue - padding) * 10) / 10
        let axisMax = ceil((maxValue + padding) * 10) / 10
        let step = (axisMax - axisMin) / 3
        let yAxisTexts = (0...3).map { index in
            formatChartNumber(axisMax - CGFloat(index) * step)
        }

        return (yAxisTexts, axisMin, axisMax)
    }

    func makeWeightFooterRows(
        weightPack: NSDictionary,
        validValues: [CGFloat],
        fallback: [AICoachReportFooterRow]
    ) -> [AICoachReportFooterRow] {
        let averageValue = weightPack.doubleValueForKey(key: "thisWeekAvgKg")
        let fluctuationValue = weightPack.doubleValueForKey(key: "weeklyWeightFluctuationRate")
        let deltaKg = weightPack.doubleValueForKey(key: "deltaKg")
        let deltaPercent = weightPack.doubleValueForKey(key: "deltaPercent")
        let trendText = weightPack.stringValueForKey(key: "trendText").trimmingCharacters(in: .whitespacesAndNewlines)

        let derivedAverage = validValues.isEmpty ? 0 : Double(validValues.reduce(0, +)) / Double(validValues.count)
        let thisWeekAverage = averageValue > 0 ? averageValue : derivedAverage

        guard thisWeekAverage > 0 else { return fallback }

        let previousAverage = previousWeekAverage(
            currentAverage: thisWeekAverage,
            deltaKg: deltaKg,
            trendText: trendText
        )
        let summaryText = weightTrendSummary(
            deltaKg: deltaKg,
            deltaPercent: deltaPercent,
            trendText: trendText
        )

        var rows: [AICoachReportFooterRow] = [
            .init(
                leftText: "本周体重均值：\(formatChartNumber(thisWeekAverage)) kg",
                rightText: "周内波动：\(formatPercentNumber(fluctuationValue))%"
            )
        ]

        if previousAverage > 0 {
            rows.append(.init(leftText: "上周体重均值：\(formatChartNumber(previousAverage)) kg", rightText: nil))
        }

        if summaryText.isEmpty == false {
            rows.append(.init(leftText: summaryText, rightText: nil))
        }

        return rows.isEmpty ? fallback : rows
    }

    func makeCalorieAxisConfig(
        values: [CGFloat],
        fallback: AICoachReportBarChartData
    ) -> (yAxisTexts: [String], maxValue: CGFloat) {
        guard let maxValue = values.max(), maxValue > 0 else {
            return (fallback.yAxisTexts, fallback.maxValue)
        }

        let scaledMax = ceil(maxValue * 1.15)
        let step = max(ceil(scaledMax / 3 / 100) * 100, 100)
        let axisMax = step * 3
        let yAxisTexts = stride(from: Int(axisMax), through: 0, by: -Int(step)).map { "\($0)" }
        return (yAxisTexts, axisMax)
    }

    func makeNutrientAxisConfig(
        values: [CGFloat],
        fallback: AICoachReportGroupedBarChartData
    ) -> (yAxisTexts: [String], maxValue: CGFloat) {
        guard let maxValue = values.max(), maxValue > 0 else {
            return (fallback.yAxisTexts, fallback.maxValue)
        }

        let scaledMax = ceil(maxValue * 1.15)
        let step = max(ceil(scaledMax / 3 / 10) * 10, 10)
        let axisMax = step * 3
        let yAxisTexts = stride(from: Int(axisMax), through: 0, by: -Int(step)).map { "\($0)" }
        return (yAxisTexts, axisMax)
    }

    func makeNutrientLegendItems(
        nutrientsPack: NSDictionary,
        fallback: [AICoachReportLegendItem]
    ) -> [AICoachReportLegendItem] {
        let carbohydrateAvg = nutrientsPack.doubleValueForKey(key: "carbohydrateAvgG")
        let carbohydratePercent = nutrientsPack.doubleValueForKey(key: "carbohydratePercent")
        let proteinAvg = nutrientsPack.doubleValueForKey(key: "proteinAvgG")
        let proteinPercent = nutrientsPack.doubleValueForKey(key: "proteinPercent")
        let fatAvg = nutrientsPack.doubleValueForKey(key: "fatAvgG")
        let fatPercent = nutrientsPack.doubleValueForKey(key: "fatPercent")

        let items: [AICoachReportLegendItem] = [
            .init(
                title: "碳水 \(formatChartNumber(carbohydrateAvg))g",
                valueText: "\(formatChartNumber(carbohydrateAvg))g",
                percentText: "\(formatPercentNumber(carbohydratePercent))%",
                color: AICoachReportDemoPalette.nutrientPurple
            ),
            .init(
                title: "蛋白质 \(formatChartNumber(proteinAvg))g",
                valueText: "\(formatChartNumber(proteinAvg))g",
                percentText: "\(formatPercentNumber(proteinPercent))%",
                color: AICoachReportDemoPalette.nutrientYellow
            ),
            .init(
                title: "脂肪 \(formatChartNumber(fatAvg))g",
                valueText: "\(formatChartNumber(fatAvg))g",
                percentText: "\(formatPercentNumber(fatPercent))%",
                color: AICoachReportDemoPalette.nutrientOrange
            )
        ]

        let hasValidData =
            carbohydrateAvg > 0 || carbohydratePercent > 0 ||
            proteinAvg > 0 || proteinPercent > 0 ||
            fatAvg > 0 || fatPercent > 0
        return hasValidData ? items : fallback
    }

    func makeCalorieFooterRows(
        caloriesPack: NSDictionary,
        validValues: [CGFloat],
        fallback: [AICoachReportFooterRow]
    ) -> [AICoachReportFooterRow] {
        let averageValue = caloriesPack.doubleValueForKey(key: "thisWeekAvgKcal")
        let weekendValue = caloriesPack.doubleValueForKey(key: "weekendAvgKcal")
        let workdayValue = caloriesPack.doubleValueForKey(key: "workdayAvgKcal")
        let deltaKcal = caloriesPack.doubleValueForKey(key: "deltaKcal")
        let deltaPercent = caloriesPack.doubleValueForKey(key: "deltaPercent")
        let trendText = caloriesPack.stringValueForKey(key: "trendText").trimmingCharacters(in: .whitespacesAndNewlines)

        let derivedAverage = validValues.isEmpty ? 0 : Double(validValues.reduce(0, +)) / Double(validValues.count)
        let thisWeekAverage = averageValue > 0 ? averageValue : derivedAverage

        guard thisWeekAverage > 0 else { return fallback }

        var rows: [AICoachReportFooterRow] = [
            .init(leftText: "本周热量摄入均值：\(formatChartNumber(thisWeekAverage)) kcal", rightText: nil)
        ]

        if weekendValue > 0 || workdayValue > 0 {
            rows.append(
                .init(
                    leftText: "周末：\(formatChartNumber(weekendValue))kcal",
                    rightText: "工作日：\(formatChartNumber(workdayValue))kcal"
                )
            )
        }

        let summaryText = calorieTrendSummary(
            deltaKcal: deltaKcal,
            deltaPercent: deltaPercent,
            trendText: trendText
        )
        if summaryText.isEmpty == false {
            rows.append(.init(leftText: summaryText, rightText: nil))
        }

        return rows.isEmpty ? fallback : rows
    }

    func previousWeekAverage(currentAverage: Double, deltaKg: Double, trendText: String) -> Double {
        if trendText.contains("增加") {
            return max(0, currentAverage - deltaKg)
        }
        if trendText.contains("下降") {
            return currentAverage + deltaKg
        }
        return currentAverage
    }

    func weightTrendSummary(deltaKg: Double, deltaPercent: Double, trendText: String) -> String {
        if trendText.contains("无变化") || abs(deltaKg) < 0.0001 {
            return "本周体重对比上周无变化"
        }
        guard trendText.isEmpty == false else { return "" }

        let deltaText = formatChartNumber(deltaKg)
        let percentText = formatPercentNumber(deltaPercent)
        return "本周体重对比上周\(trendText)\(deltaText) kg（\(percentText)%）"
    }

    func calorieTrendSummary(deltaKcal: Double, deltaPercent: Double, trendText: String) -> String {
        if trendText.contains("持平") || abs(deltaKcal) < 0.0001 {
            return "本周热量摄入对比上周持平"
        }
        guard trendText.isEmpty == false else { return "" }

        let deltaText = formatChartNumber(deltaKcal)
        let percentText = formatPercentNumber(deltaPercent)
        return "本周热量摄入对比上周\(trendText)\(deltaText) kcal（\(percentText)%）"
    }

    func parseReportDate(_ dateString: String) -> Date? {
        let normalizedDate = normalizedWeightDataKey(dateString)
        guard normalizedDate.isEmpty == false else { return nil }

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: normalizedDate)
    }

    func normalizedWeightDataKey(_ rawDate: String) -> String {
        let trimmedDate = rawDate.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedDate.isEmpty == false else { return "" }

        if trimmedDate.count >= 10 {
            let prefixDate = String(trimmedDate.prefix(10))
            if parseWeightDateText(prefixDate) != nil {
                return prefixDate
            }
        }

        if parseWeightDateText(trimmedDate) != nil {
            return trimmedDate
        }

        return ""
    }

    func parseWeightDateText(_ dateText: String) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateText)
    }

    func weightDataKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func weightAxisLabel(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }

    func formatChartNumber(_ value: CGFloat) -> String {
        formatChartNumber(Double(value))
    }

    func formatChartNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    func formatPercentNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    func displayText(_ value: CGFloat?) -> String {
        guard let value else { return "-" }
        return formatChartNumber(value)
    }

    func displayText(_ value: String?) -> String {
        let trimmedValue = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmedValue.isEmpty || trimmedValue == "缺失" {
            return "-"
        }
        return trimmedValue
    }
}
