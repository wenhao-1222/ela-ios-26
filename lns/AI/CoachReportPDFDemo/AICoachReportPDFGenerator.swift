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
    // 保持标准 PDF 页面尺寸，同时用更高分辨率栅格化页面内容，
    // 这样 PDFView 放大时不会过早暴露底图像素感。
    private static let renderScale: CGFloat = 5
    static let pageSize = layoutPageSize

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

        let fileURL = makeOutputURL(report: report)
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

                autoreleasepool {
                    let pageImage = rasterizedPageImage(
                        contentView: contentView,
                        contentWidth: contentWidth,
                        pageStartOffset: pageStartOffset,
                        visibleHeight: visibleHeight
                    )
                    pageImage.draw(in: pageBounds)
                }
            }
        }

        return fileURL
    }

    private static func rasterizedPageImage(
        contentView: AICoachReportDemoContentView,
        contentWidth: CGFloat,
        pageStartOffset: CGFloat,
        visibleHeight: CGFloat
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = renderScale
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: layoutPageSize, format: format)
        return renderer.image { imageContext in
            let cgContext = imageContext.cgContext
            let pageBounds = CGRect(origin: .zero, size: layoutPageSize)
            cgContext.setFillColor(UIColor.white.cgColor)
            cgContext.fill(pageBounds)
            cgContext.interpolationQuality = .high
            cgContext.setShouldAntialias(true)

            cgContext.saveGState()
            cgContext.clip(to: CGRect(
                x: layoutPageInsets.left,
                y: layoutPageInsets.top,
                width: contentWidth,
                height: visibleHeight
            ))
            cgContext.translateBy(
                x: layoutPageInsets.left,
                y: layoutPageInsets.top - pageStartOffset
            )
            contentView.layer.render(in: cgContext)
            cgContext.restoreGState()
        }
    }

    private static func makeOutputURL(report: AICoachReportDemoData) -> URL {
        let folderURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AICoachReport", isDirectory: true)
        if FileManager.default.fileExists(atPath: folderURL.path) == false {
            try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        }
        let reportDate = report.reportDateRange
            .replacingOccurrences(of: "日期：", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let fallbackDate = report.navigationDateRange.trimmingCharacters(in: .whitespacesAndNewlines)
        let fileDate = reportDate.isEmpty ? fallbackDate : reportDate
        return folderURL.appendingPathComponent("ELA-AI教练 \(fileDate).pdf")
    }
}
