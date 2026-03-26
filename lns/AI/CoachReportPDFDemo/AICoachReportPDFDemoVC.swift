//
//  AICoachReportPDFDemoVC.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

import PDFKit
import SnapKit
import UIKit

final class AICoachReportPDFDemoVC: WHBaseViewVC {
    
    var reportId = ""
    
    private var report = AICoachReportDemoData.mock
    private var pdfFileURL: URL?
    private var hasGeneratedPDF = false

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
//        btn.addTarget(self, action: #selector(typeAction), for: .touchUpInside)
        
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

    private lazy var downloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = AICoachReportDemoPalette.themeBlue
        button.layer.cornerRadius = 28
        button.setTitle("下载", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 21, weight: .medium)
        button.addTarget(self, action: #selector(downloadAction), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        refreshTopBar()
        self.sendReportDetailRequest()
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
//        topContainerView.addSubview(dateLabel)
//        topContainerView.addSubview(arrowImageView)
        view.addSubview(dividerBand)
        view.addSubview(pdfView)
        view.addSubview(bottomBar)
        bottomBar.addSubview(bottomSeparator)
        bottomBar.addSubview(downloadButton)
        view.addSubview(loadingIndicator)
        view.addSubview(loadingLabel)

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
            make.height.equalTo(getBottomSafeAreaHeight() + 96)
        }

        bottomSeparator.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }

        downloadButton.snp.makeConstraints { make in
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
    }

    func generateAndLoadPDF() {
        loadingIndicator.startAnimating()
        loadingLabel.isHidden = false

        DispatchQueue.main.async {
            do {
                let fileURL = try AICoachReportPDFGenerator.generate(report: self.report)
                self.pdfFileURL = fileURL
                self.loadPDF(from: fileURL)
                self.downloadButton.isEnabled = true
                self.loadingIndicator.stopAnimating()
                self.loadingLabel.isHidden = true
            } catch {
                self.loadingIndicator.stopAnimating()
                self.loadingLabel.text = "PDF 生成失败"
            }
        }
    }

    func loadPDF(from url: URL) {
        guard let document = PDFDocument(url: url) else {
            loadingLabel.text = "PDF 加载失败"
            return
        }
        pdfView.document = document
        pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
        pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
    }

    @objc func downloadAction() {
        guard let pdfFileURL else { return }
        let activityVC = UIActivityViewController(activityItems: [pdfFileURL], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = downloadButton
            popover.sourceRect = downloadButton.bounds
        }
        present(activityVC, animated: true)
    }
}

extension AICoachReportPDFDemoVC{
    func sendReportDetailRequest() {
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
}

private extension AICoachReportPDFDemoVC {
    func applyReportDetailData(_ dataDict: NSDictionary) {
        report = buildReport(from: dataDict)
        refreshTopBar()
        if hasGeneratedPDF {
            generateAndLoadPDF()
        }
    }

    func buildReport(from dataDict: NSDictionary) -> AICoachReportDemoData {
        let fallback = AICoachReportDemoData.mock
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
            weightChart: fallback.weightChart,
            calorieChart: fallback.calorieChart,
            nutrientChart: fallback.nutrientChart,
            trainingChart: fallback.trainingChart,
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

    func makeNavigationDateRange(startDate: String, endDate: String, fallback: String) -> String {
        let startText = formatDate(startDate, targetFormatter: "yyyy/MM/dd")
        let endText = formatDate(endDate, targetFormatter: "yyyy/MM/dd")
        guard startText.isEmpty == false, endText.isEmpty == false else { return fallback }
        return "\(startText) – \(endText)"
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
}
