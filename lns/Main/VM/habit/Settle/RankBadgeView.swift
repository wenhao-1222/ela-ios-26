//
//  RankBadgeView.swift
//  lns
//
//  Created by LNS2 on 2026/1/22.
//

import UIKit

final class RankBadgeView: NaturalDampedShakeImageView {

    private static let ciContext = CIContext(options: nil)
    /// 当前等比缩放
    private(set) var currentScale: CGFloat = 1.0

    /// 进入时倾斜角（模拟加速惯性）
    var enterTiltAngle: CGFloat = 8 * .pi / 180
    private let originalImage: UIImage?
  private var grayscaleImage: UIImage?
  private lazy var primaryColor: UIColor? = Self.averageColor(from: originalImage)

  override init(image: UIImage?) {
      self.originalImage = image
      super.init(image: image)
  }

  required init?(coder: NSCoder) {
      self.originalImage = nil
      super.init(coder: coder)
  }
    func setScale(_ scale: CGFloat) {
        currentScale = scale
        apply(scale: scale, angle: 0)
    }

    func setTiltForEnter(_ enabled: Bool) {
        apply(scale: currentScale, angle: enabled ? enterTiltAngle : 0)
    }

    func shakeInPlace(completion: (() -> Void)? = nil) {
        shakeThreeTimesAndStopUIKit(scale: currentScale, completion: completion)
    }
    
    func setGrayscale(_ enabled: Bool) {
        guard let originalImage else { return }
        if enabled {
            if grayscaleImage == nil {
                grayscaleImage = Self.makeGrayscaleImage(from: originalImage)
            }
            image = grayscaleImage ?? originalImage
        } else {
            image = originalImage
        }
    }

    func flashGlow(completion: (() -> Void)? = nil) {
        guard let primaryColor else {
            completion?()
            return
        }

        layer.shadowColor = primaryColor.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = 24
        layer.shadowOpacity = 0

        UIView.animate(
            withDuration: 0.18,
            delay: 0,
            options: [.curveEaseOut, .beginFromCurrentState]
        ) {
            self.layer.shadowOpacity = 0.85
        } completion: { _ in
            UIView.animate(
                withDuration: 0.18,
                delay: 0.05,
                options: [.curveEaseIn, .beginFromCurrentState]
            ) {
                self.layer.shadowOpacity = 0
            } completion: { _ in
                completion?()
            }
        }
    }
    /// 在某个 baseAngle 上做阻尼摇晃（UIKit keyframes）
    private func shakeAround(baseAngle: CGFloat, scale: CGFloat, completion: (() -> Void)? = nil) {
        let a = maxAngle
        let angles: [CGFloat] = [
            0,
            -a,
            a * 0.75,
            -a * 0.45,
            a * 0.25,
            -a * 0.12,
            0
        ]

        // 从 baseAngle 开始（保持倾斜，不回正）
        transform = makeBottomPivotTransform(scale: scale, angle: baseAngle)

        UIView.animateKeyframes(
            withDuration: totalDuration,
            delay: 0,
            options: [.calculationModeCubic, .beginFromCurrentState]
        ) {
            let n = angles.count - 1
            for i in 0..<n {
                let start = Double(i) / Double(n)
                let dur = 1.0 / Double(n)
                UIView.addKeyframe(withRelativeStartTime: start, relativeDuration: dur) {
                    self.transform = self.makeBottomPivotTransform(scale: scale, angle: baseAngle + angles[i + 1])
                }
            }
        } completion: { _ in
            self.transform = self.makeBottomPivotTransform(scale: scale, angle: baseAngle)
            completion?()
        }
    }
    private static func makeGrayscaleImage(from image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        guard let filter = CIFilter(name: "CIColorControls") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(0, forKey: kCIInputSaturationKey)
        guard let output = filter.outputImage else { return nil }
        guard let cgImage = ciContext.createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    private static func averageColor(from image: UIImage?) -> UIColor? {
        guard let image, let ciImage = CIImage(image: image) else { return nil }
        let extent = ciImage.extent
        guard let filter = CIFilter(name: "CIAreaAverage") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgRect: extent), forKey: kCIInputExtentKey)
        guard let output = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let outputExtent = CGRect(x: 0, y: 0, width: 1, height: 1)
        ciContext.render(
            output,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: outputExtent,
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )
        return UIColor(
            red: CGFloat(bitmap[0]) / 255,
            green: CGFloat(bitmap[1]) / 255,
            blue: CGFloat(bitmap[2]) / 255,
            alpha: CGFloat(bitmap[3]) / 255
        )
    }
}
