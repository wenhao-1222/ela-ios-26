//
//  AICoachReportPDFGenerator.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

import UIKit

enum AICoachReportPDFGenerator {
    static let pageSize = CGSize(width: 595, height: 842)
    private static let pageInsets = UIEdgeInsets(top: 18, left: 24, bottom: 18, right: 24)

    static func generate(report: AICoachReportDemoData) throws -> URL {
        let contentWidth = pageSize.width - pageInsets.left - pageInsets.right
        let usableHeight = pageSize.height - pageInsets.top - pageInsets.bottom
        let contentView = AICoachReportDemoContentView(
            report: report,
            contentWidth: contentWidth,
            firstPageUsableHeight: usableHeight
        )
        let contentHeight = contentView.fittingHeight()
        contentView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight)
        contentView.layoutIfNeeded()

        let pageBounds = CGRect(origin: .zero, size: pageSize)
        let pageStartOffsets = contentView.pageStartOffsets(usableHeight: usableHeight)

        let fileURL = makeOutputURL()
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)

        try renderer.writePDF(to: fileURL) { context in
            for (pageIndex, pageStartOffset) in pageStartOffsets.enumerated() {
                let nextPageStartOffset = pageIndex + 1 < pageStartOffsets.count
                    ? pageStartOffsets[pageIndex + 1]
                    : contentHeight
                let visibleHeight = min(usableHeight, nextPageStartOffset - pageStartOffset)

                context.beginPage()
                let cgContext = context.cgContext
                cgContext.setFillColor(AICoachReportDemoPalette.pageBackground.cgColor)
                cgContext.fill(pageBounds)

                cgContext.saveGState()
                cgContext.clip(to: CGRect(
                    x: pageInsets.left,
                    y: pageInsets.top,
                    width: contentWidth,
                    height: visibleHeight
                ))
                cgContext.translateBy(
                    x: pageInsets.left,
                    y: pageInsets.top - pageStartOffset
                )
                contentView.layer.render(in: cgContext)
                cgContext.restoreGState()
            }
        }

        return fileURL
    }

    private static func makeOutputURL() -> URL {
        let folderURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AICoachReportPDFDemo", isDirectory: true)
        if FileManager.default.fileExists(atPath: folderURL.path) == false {
            try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        }

        return folderURL.appendingPathComponent("ai-coach-analysis-report.pdf")
    }
}
