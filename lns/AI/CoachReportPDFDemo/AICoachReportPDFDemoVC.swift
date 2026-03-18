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

    private lazy var pdfView: PDFView = {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.backgroundColor = AICoachReportDemoPalette.background
        view.usePageViewController(false, withViewOptions: nil)
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
        button.setTitle("下载 PDF", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.addTarget(self, action: #selector(downloadAction), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    private lazy var shareNavButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("分享", for: .normal)
        button.setTitleColor(AICoachReportDemoPalette.themeBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.addTarget(self, action: #selector(downloadAction), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AICoachReportDemoPalette.background
        setupNavigation()
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
    func setupNavigation() {
        initNavigationView()
        naviTitleLabel.text = "AI 教练分析"
        navigationView.addSubview(shareNavButton)
        shareNavButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(naviTitleLabel)
            make.height.equalTo(30)
        }
    }

    func setupUI() {
        view.addSubview(pdfView)
        view.addSubview(downloadButton)
        view.addSubview(loadingIndicator)
        view.addSubview(loadingLabel)

        pdfView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(downloadButton.snp.top).offset(-16)
        }

        downloadButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-(getBottomSafeAreaHeight() + 18))
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
                self.shareNavButton.isEnabled = true
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
