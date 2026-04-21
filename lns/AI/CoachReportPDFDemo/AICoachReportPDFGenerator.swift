//
//  AICoachReportPDFGenerator.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

import UIKit

enum AICoachReportPDFGenerator {
    private static let layoutPageSize = CGSize(width: 960, height: 1440)
    private static let layoutPageInsets = UIEdgeInsets(top: 28, left: 28, bottom: 36, right: 28)
    // 以更高分辨率栅格化页面，避免 PDFView 放大后过快暴露底图像素感。
    private static let renderScale: CGFloat = 4
    static let pageSize = CGSize(
        width: layoutPageSize.width * renderScale,
        height: layoutPageSize.height * renderScale
    )

    static func generate(report: AICoachReportDemoData) throws -> URL {
        let contentWidth = layoutPageSize.width - layoutPageInsets.left - layoutPageInsets.right
        let usableHeight = layoutPageSize.height - layoutPageInsets.top - layoutPageInsets.bottom
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
                cgContext.setFillColor(UIColor.white.cgColor)
                cgContext.fill(pageBounds)
                cgContext.interpolationQuality = .high
                cgContext.setShouldAntialias(true)

                cgContext.saveGState()
                cgContext.clip(to: CGRect(
                    x: layoutPageInsets.left * renderScale,
                    y: layoutPageInsets.top * renderScale,
                    width: contentWidth * renderScale,
                    height: visibleHeight * renderScale
                ))
                cgContext.translateBy(
                    x: layoutPageInsets.left * renderScale,
                    y: layoutPageInsets.top * renderScale - pageStartOffset * renderScale
                )
                cgContext.scaleBy(x: renderScale, y: renderScale)
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
