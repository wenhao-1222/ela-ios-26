//
//  EffectsFactory.swift
//  lns
//
//  Created by LNS2 on 2026/1/4.
//

import UIKit
import CoreImage

enum EffectsFactory {

    static func grayLockedImage(from image: UIImage) -> UIImage {
        guard let cg = image.cgImage else { return image }
        let ci = CIImage(cgImage: cg)

        let f = CIFilter(name: "CIColorControls")
        f?.setValue(ci, forKey: kCIInputImageKey)
        f?.setValue(0.0, forKey: kCIInputSaturationKey)
        f?.setValue(0.08, forKey: kCIInputBrightnessKey)
        f?.setValue(1.05, forKey: kCIInputContrastKey)

        let out = f?.outputImage ?? ci
        let ctx = CIContext()

        guard let outCG = ctx.createCGImage(out, from: out.extent) else { return image }
        return UIImage(cgImage: outCG, scale: image.scale, orientation: image.imageOrientation)
    }

    static func confettiSquare(size: CGFloat) -> UIImage {
        let r = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return r.image { ctx in
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.fill(CGRect(x: 0, y: 0, width: size, height: size))
        }
    }

    static func lockIcon(size: CGFloat) -> UIImage {
        let r = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return r.image { ctx in
            let c = ctx.cgContext
            c.setFillColor(UIColor.black.withAlphaComponent(0.25).cgColor)

            let w = size
            let h = size
            let body = UIBezierPath(roundedRect: CGRect(x: w*0.22, y: h*0.46, width: w*0.56, height: h*0.42),
                                    cornerRadius: w*0.10)
            c.addPath(body.cgPath); c.fillPath()

            c.setStrokeColor(UIColor.black.withAlphaComponent(0.25).cgColor)
            c.setLineWidth(w*0.10)
            let arc = UIBezierPath()
            arc.addArc(withCenter: CGPoint(x: w*0.50, y: h*0.46),
                       radius: w*0.22,
                       startAngle: .pi,
                       endAngle: 0,
                       clockwise: true)
            c.addPath(arc.cgPath); c.strokePath()

            c.setFillColor(UIColor.black.withAlphaComponent(0.18).cgColor)
            c.fillEllipse(in: CGRect(x: w*0.46, y: h*0.60, width: w*0.08, height: w*0.08))
            c.fill(CGRect(x: w*0.49, y: h*0.66, width: w*0.02, height: h*0.12))
        }
    }

    static func placeholderBadge(size: CGFloat) -> UIImage {
        let r = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return r.image { ctx in
            let c = ctx.cgContext
            c.setFillColor(UIColor(white: 0.92, alpha: 1).cgColor)
            c.fillEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))
            c.setStrokeColor(UIColor(white: 0.78, alpha: 1).cgColor)
            c.setLineWidth(6)
            c.strokeEllipse(in: CGRect(x: 6, y: 6, width: size-12, height: size-12))
        }
    }

    // MARK: - ✅ 宝石崩裂：把“原图”切成晶面碎片（contentsRect + 晶面 mask + 高光）

    static func makeGemImageShards(image: UIImage,
                                   in targetRect: CGRect,
                                   grid: Int,
                                   contentScale: CGFloat) -> [CALayer] {
        guard let cg = image.cgImage else { return [] }

//        let n = max(6, min(grid, 12))
//        let rows = n
//        let cols = n
        // grid 代表“想要的碎片数量级”，在此基础上求一个接近的 rows/cols 组合
        let targetPieces = max(2, min(grid, 64))
        let searchUpperBound = max(3, Int(ceil(sqrt(Double(targetPieces)))) + 3)

        var bestRows = 2
        var bestCols = 2
        var bestDiff = Int.max

        for rows in 2...searchUpperBound {
            for cols in 2...searchUpperBound {
                let count = rows * cols
                let diff = abs(count - targetPieces)

                if diff < bestDiff || (diff == bestDiff && count < bestRows * bestCols) {
                    bestDiff = diff
                    bestRows = rows
                    bestCols = cols
                }
            }
        }

        let rows = bestRows
        let cols = bestCols

        var shards: [CALayer] = []
        shards.reserveCapacity(rows * cols)

        for r in 0..<rows {
            for c in 0..<cols {
                let u0 = CGFloat(c) / CGFloat(cols)
                let v0 = CGFloat(r) / CGFloat(rows)
                let u1 = CGFloat(c + 1) / CGFloat(cols)
                let v1 = CGFloat(r + 1) / CGFloat(rows)

                let pieceW = targetRect.width / CGFloat(cols)
                let pieceH = targetRect.height / CGFloat(rows)
                let frame = CGRect(
                    x: targetRect.minX + CGFloat(c) * pieceW,
                    y: targetRect.minY + CGFloat(r) * pieceH,
                    width: pieceW,
                    height: pieceH
                )

                let layer = CALayer()
                layer.frame = frame
                layer.contents = cg
                layer.contentsScale = contentScale
                layer.contentsGravity = .resizeAspectFill
                layer.masksToBounds = true
                layer.contentsRect = CGRect(x: u0, y: v0, width: (u1 - u0), height: (v1 - v0))

                // 晶面 mask（多边形，像宝石切面）
                let mask = CAShapeLayer()
                mask.frame = layer.bounds
                mask.path = gemFacetPath(in: layer.bounds).cgPath
                layer.mask = mask

                // 亮边（折射边）
                layer.borderWidth = 0.65
                layer.borderColor = UIColor.white.withAlphaComponent(0.22).cgColor

                // 晶面高光（随机方向渐变）
                let shine = CAGradientLayer()
                shine.frame = layer.bounds
                shine.colors = [
                    UIColor.white.withAlphaComponent(0.26).cgColor,
                    UIColor.white.withAlphaComponent(0.00).cgColor
                ]
                shine.startPoint = CGPoint(x: CGFloat.random(in: 0.0...0.35), y: CGFloat.random(in: 0.0...0.35))
                shine.endPoint   = CGPoint(x: CGFloat.random(in: 0.65...1.0), y: CGFloat.random(in: 0.65...1.0))
                shine.opacity = 1.0
                shine.compositingFilter = "screenBlendMode"
                layer.addSublayer(shine)

                // 轻微 3D 倾斜（更像“崩裂的宝石块”）
                var t3d = CATransform3DIdentity
                t3d.m34 = -1.0 / 650.0
                let ax = CGFloat.random(in: -0.14...0.14)
                let ay = CGFloat.random(in: -0.18...0.18)
                t3d = CATransform3DRotate(t3d, ax, 1, 0, 0)
                t3d = CATransform3DRotate(t3d, ay, 0, 1, 0)
                layer.transform = t3d

                // 性能（碎片很多时很重要）
                layer.shouldRasterize = true
                layer.rasterizationScale = contentScale

                shards.append(layer)
            }
        }

        return shards
    }

    private static func gemFacetPath(in rect: CGRect) -> UIBezierPath {
        let w = rect.width
        let h = rect.height
        let cx = w * 0.5
        let cy = h * 0.5

        let n = Int.random(in: 5...9)

        var pts: [(angle: CGFloat, p: CGPoint)] = []
        pts.reserveCapacity(n)

        for i in 0..<n {
            let base = (CGFloat(i) / CGFloat(n)) * (CGFloat.pi * 2)
            let jitter = CGFloat.random(in: -0.22...0.22) * (CGFloat.pi * 2 / CGFloat(n))
            let ang = base + jitter

            let rx = (w * 0.52) * CGFloat.random(in: 0.78...1.02)
            let ry = (h * 0.52) * CGFloat.random(in: 0.78...1.02)

            var x = cx + cos(ang) * rx
            var y = cy + sin(ang) * ry

            x = min(max(x, 0), w)
            y = min(max(y, 0), h)

            pts.append((ang, CGPoint(x: x, y: y)))
        }

        pts.sort { $0.angle < $1.angle }
        var final = pts.map { $0.p }

        // 随机斜切插点，让边更“切割感”
        if final.count >= 5, Bool.random() {
            let idx = Int.random(in: 0..<(final.count))
            let a = final[idx]
            let b = final[(idx + 1) % final.count]
            let t = CGFloat.random(in: 0.35...0.65)
            let cut = CGPoint(
                x: a.x + (b.x - a.x) * t + CGFloat.random(in: -2...2),
                y: a.y + (b.y - a.y) * t + CGFloat.random(in: -2...2)
            )
            final.insert(cut, at: idx + 1)
        }

        let path = UIBezierPath()
        path.move(to: final[0])
        for i in 1..<final.count { path.addLine(to: final[i]) }
        path.close()
        return path
    }
}

private extension UIColor {
    func darker(_ amount: CGFloat) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: max(0, r - amount), green: max(0, g - amount), blue: max(0, b - amount), alpha: a)
    }
}
