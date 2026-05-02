//
//  AICoachReportPDFGenerator.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

import UIKit

enum AICoachReportPDFGenerator {
    enum GenerationError: Error {
        case cancelled
        case failedToCreatePDFContext
        case failedToCreatePageImage
    }

    private static let layoutPageSize = CGSize(width: 960, height: 1440)
    private static let layoutPageInsets = UIEdgeInsets(top: 28, left: 28, bottom: 36, right: 28)
    // 保持标准 PDF 页面尺寸，同时用更高分辨率栅格化页面内容，
    // 这样 PDFView 放大时不会过早暴露底图像素感。
    private static let renderScale: CGFloat = 5
    // 将整页渲染拆成更小的切片，避免主线程被一次性占满，
    // 让返回按钮和页面交互能在切片间隙及时得到处理。
    private static let renderTileHeight: CGFloat = 220
    static let pageSize = layoutPageSize

    static func generateAsync(
        report: AICoachReportDemoData,
        reportId: String,
        isCancelled: @escaping () -> Bool,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                generateAsync(report: report, reportId: reportId, isCancelled: isCancelled, completion: completion)
            }
            return
        }

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
        let fileURL = makeOutputURL(report: report, reportId: reportId)
        let writer = PDFPageWriter(fileURL: fileURL, pageBounds: pageBounds)

        func finish(with result: Result<URL, Error>) {
            DispatchQueue.main.async {
                completion(result)
            }
        }

        func renderPage(at pageIndex: Int) {
            if isCancelled() {
                writer.cancel()
                finish(with: .failure(GenerationError.cancelled))
                return
            }

            if pageIndex >= pageStartOffsets.count {
                writer.finish { result in
                    finish(with: result)
                }
                return
            }

            let pageStartOffset = pageStartOffsets[pageIndex]
            let nextPageStartOffset = pageIndex + 1 < pageStartOffsets.count
                ? pageStartOffsets[pageIndex + 1]
                : contentHeight
            let visibleHeight = min(usableHeight, nextPageStartOffset - pageStartOffset)

            renderPageTiles(
                contentView: contentView,
                contentWidth: contentWidth,
                pageStartOffset: pageStartOffset,
                visibleHeight: visibleHeight,
                writer: writer,
                isCancelled: isCancelled
            ) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        renderPage(at: pageIndex + 1)
                    }
                case .failure(let error):
                    if case GenerationError.cancelled = error {
                        writer.cancel()
                    }
                    finish(with: .failure(error))
                }
            }
        }

        if writer.isReady == false {
            finish(with: .failure(GenerationError.failedToCreatePDFContext))
            return
        }

        DispatchQueue.main.async {
            renderPage(at: 0)
        }
    }

    static func existingCachedFileURL(report: AICoachReportDemoData, reportId: String) -> URL? {
        let fileURL = makeOutputURL(report: report, reportId: reportId)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
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

    private static func renderPageTiles(
        contentView: AICoachReportDemoContentView,
        contentWidth: CGFloat,
        pageStartOffset: CGFloat,
        visibleHeight: CGFloat,
        writer: PDFPageWriter,
        isCancelled: @escaping () -> Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        writer.beginPage { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success:
                DispatchQueue.main.async {
                    renderNextTile(
                        at: 0,
                        contentView: contentView,
                        contentWidth: contentWidth,
                        pageStartOffset: pageStartOffset,
                        visibleHeight: visibleHeight,
                        writer: writer,
                        isCancelled: isCancelled,
                        completion: completion
                    )
                }
            }
        }
    }

    private static func renderNextTile(
        at tileOriginY: CGFloat,
        contentView: AICoachReportDemoContentView,
        contentWidth: CGFloat,
        pageStartOffset: CGFloat,
        visibleHeight: CGFloat,
        writer: PDFPageWriter,
        isCancelled: @escaping () -> Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        if isCancelled() {
            completion(.failure(GenerationError.cancelled))
            return
        }

        if tileOriginY >= layoutPageSize.height {
            writer.endPage(completion: completion)
            return
        }

        let tileHeight = min(renderTileHeight, layoutPageSize.height - tileOriginY)

        autoreleasepool {
            let tileImage = rasterizedPageTileImage(
                contentView: contentView,
                contentWidth: contentWidth,
                pageStartOffset: pageStartOffset,
                visibleHeight: visibleHeight,
                tileOriginY: tileOriginY,
                tileHeight: tileHeight
            )

            guard let cgImage = tileImage.cgImage else {
                completion(.failure(GenerationError.failedToCreatePageImage))
                return
            }

            let tileRect = CGRect(x: 0, y: tileOriginY, width: layoutPageSize.width, height: tileHeight)
            writer.drawPageTile(cgImage, in: tileRect) { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success:
                    DispatchQueue.main.async {
                        renderNextTile(
                            at: tileOriginY + tileHeight,
                            contentView: contentView,
                            contentWidth: contentWidth,
                            pageStartOffset: pageStartOffset,
                            visibleHeight: visibleHeight,
                            writer: writer,
                            isCancelled: isCancelled,
                            completion: completion
                        )
                    }
                }
            }
        }
    }

    private static func rasterizedPageTileImage(
        contentView: AICoachReportDemoContentView,
        contentWidth: CGFloat,
        pageStartOffset: CGFloat,
        visibleHeight: CGFloat,
        tileOriginY: CGFloat,
        tileHeight: CGFloat
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = renderScale
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: layoutPageSize.width, height: tileHeight), format: format)
        return renderer.image { imageContext in
            let cgContext = imageContext.cgContext
            let tileBounds = CGRect(x: 0, y: 0, width: layoutPageSize.width, height: tileHeight)
            cgContext.setFillColor(UIColor.white.cgColor)
            cgContext.fill(tileBounds)
            cgContext.interpolationQuality = .high
            cgContext.setShouldAntialias(true)

            let pageContentRect = CGRect(
                x: layoutPageInsets.left,
                y: layoutPageInsets.top,
                width: contentWidth,
                height: visibleHeight
            )
            let tilePageRect = CGRect(
                x: 0,
                y: tileOriginY,
                width: layoutPageSize.width,
                height: tileHeight
            )
            let clipRect = pageContentRect.intersection(tilePageRect).offsetBy(dx: 0, dy: -tileOriginY)
            guard clipRect.isNull == false, clipRect.isEmpty == false else { return }

            cgContext.saveGState()
            cgContext.clip(to: clipRect)
            cgContext.translateBy(
                x: layoutPageInsets.left,
                y: layoutPageInsets.top - pageStartOffset - tileOriginY
            )
            contentView.layer.render(in: cgContext)
            cgContext.restoreGState()
        }
    }

    private static func makeOutputURL(report: AICoachReportDemoData, reportId: String) -> URL {
        let folderURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AICoachReport", isDirectory: true)
        if FileManager.default.fileExists(atPath: folderURL.path) == false {
            try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        }
        let stableName = makeStableFileName(report: report, reportId: reportId)
        return folderURL.appendingPathComponent("\(stableName).pdf")
    }

    private static func makeStableFileName(report: AICoachReportDemoData, reportId: String) -> String {
        let trimmedReportId = reportId.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedReportId.isEmpty == false {
            return "report_\(sanitizeFileNameComponent(trimmedReportId))"
        }

        let reportDate = report.reportDateRange
            .replacingOccurrences(of: "日期：", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let fallbackDate = report.navigationDateRange.trimmingCharacters(in: .whitespacesAndNewlines)
        let fileDate = reportDate.isEmpty ? fallbackDate : reportDate
        return "ELA-AI教练 \(sanitizeFileNameComponent(fileDate))"
    }

    private static func sanitizeFileNameComponent(_ value: String) -> String {
        let invalidCharacterSet = CharacterSet(charactersIn: "\\/:*?\"<>|")
        let sanitizedValue = value
            .components(separatedBy: invalidCharacterSet)
            .joined(separator: "_")
            .replacingOccurrences(of: "\n", with: "_")
            .replacingOccurrences(of: "\r", with: "_")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return sanitizedValue.isEmpty ? "default" : sanitizedValue
    }
}

private final class PDFPageWriter {
    private let queue = DispatchQueue(label: "com.lns.aiCoachReport.pdfWriter", qos: .utility)
    private let fileURL: URL
    private let tempFileURL: URL
    private let pageBounds: CGRect
    private let context: CGContext?
    private var hasFinished = false

    var isReady: Bool {
        context != nil
    }

    init(fileURL: URL, pageBounds: CGRect) {
        self.fileURL = fileURL
        self.pageBounds = pageBounds
        self.tempFileURL = fileURL.deletingLastPathComponent()
            .appendingPathComponent("tmp-\(UUID().uuidString).pdf")

        var mediaBox = pageBounds
        self.context = CGContext(tempFileURL as CFURL, mediaBox: &mediaBox, nil)
    }

    func beginPage(completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async {
            guard self.hasFinished == false else {
                completion(.failure(AICoachReportPDFGenerator.GenerationError.cancelled))
                return
            }
            guard let context = self.context else {
                completion(.failure(AICoachReportPDFGenerator.GenerationError.failedToCreatePDFContext))
                return
            }

            context.beginPDFPage(nil)
            context.setFillColor(UIColor.white.cgColor)
            context.fill(self.pageBounds)
            completion(.success(()))
        }
    }

    func drawPageTile(_ cgImage: CGImage, in rect: CGRect, completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async {
            guard self.hasFinished == false else {
                completion(.failure(AICoachReportPDFGenerator.GenerationError.cancelled))
                return
            }
            guard let context = self.context else {
                completion(.failure(AICoachReportPDFGenerator.GenerationError.failedToCreatePDFContext))
                return
            }

            context.interpolationQuality = .high
            context.draw(cgImage, in: rect)
            completion(.success(()))
        }
    }

    func endPage(completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async {
            guard self.hasFinished == false else {
                completion(.failure(AICoachReportPDFGenerator.GenerationError.cancelled))
                return
            }
            guard let context = self.context else {
                completion(.failure(AICoachReportPDFGenerator.GenerationError.failedToCreatePDFContext))
                return
            }

            context.endPDFPage()
            completion(.success(()))
        }
    }

    func finish(completion: @escaping (Result<URL, Error>) -> Void) {
        queue.async {
            guard self.hasFinished == false else {
                completion(.failure(AICoachReportPDFGenerator.GenerationError.cancelled))
                return
            }
            self.hasFinished = true
            self.context?.closePDF()

            do {
                if FileManager.default.fileExists(atPath: self.fileURL.path) {
                    try FileManager.default.removeItem(at: self.fileURL)
                }
                try FileManager.default.moveItem(at: self.tempFileURL, to: self.fileURL)
                completion(.success(self.fileURL))
            } catch {
                try? FileManager.default.removeItem(at: self.tempFileURL)
                completion(.failure(error))
            }
        }
    }

    func cancel() {
        queue.async {
            guard self.hasFinished == false else { return }
            self.hasFinished = true
            self.context?.closePDF()
            try? FileManager.default.removeItem(at: self.tempFileURL)
        }
    }
}
