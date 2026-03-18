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
    private let report = AICoachReportDemoData.mock
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

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = AICoachReportDemoPalette.textPrimary
        label.text = report.navigationDateRange
        return label
    }()

    private lazy var arrowImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        let view = UIImageView(image: UIImage(systemName: "chevron.down", withConfiguration: config))
        view.tintColor = AICoachReportDemoPalette.textPrimary
        return view
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard hasGeneratedPDF == false else { return }
        hasGeneratedPDF = true
        generateAndLoadPDF()
    }
}

private extension AICoachReportPDFDemoVC {
    func setupUI() {
        view.addSubview(topContainerView)
        topContainerView.addSubview(backButton)
        topContainerView.addSubview(titleLabel)
        topContainerView.addSubview(dateLabel)
        topContainerView.addSubview(arrowImageView)
        view.addSubview(dividerBand)
        view.addSubview(pdfView)
        view.addSubview(bottomBar)
        bottomBar.addSubview(bottomSeparator)
        bottomBar.addSubview(downloadButton)
        view.addSubview(loadingIndicator)
        view.addSubview(loadingLabel)

        topContainerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(statusBarHeight + 116)
        }

        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(statusBarHeight + 18)
            make.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(statusBarHeight + 14)
            make.centerX.equalToSuperview()
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview().offset(-7)
        }

        arrowImageView.snp.makeConstraints { make in
            make.left.equalTo(dateLabel.snp.right).offset(8)
            make.centerY.equalTo(dateLabel.snp.centerY).offset(2)
            make.width.height.equalTo(10)
        }

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
