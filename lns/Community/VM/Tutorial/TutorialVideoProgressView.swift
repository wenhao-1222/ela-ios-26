//
//  TutorialVideoProgressView.swift
//  lns
//
//  Created by Elavatine on 2025/8/13.
//

class TutorialVideoProgressView: UIView {
    private let progressLayer = UIView()
    var progress: CGFloat = 0 {
        didSet {
            if progress.isNaN || progress.isInfinite { progress = 0 }
            progress = max(0, min(1, progress))
            setNeedsLayout()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .COLOR_GRAY_BLACK_10
        progressLayer.backgroundColor = .THEME
        addSubview(progressLayer)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        progressLayer.frame = CGRect(x: 0, y: 0, width: bounds.width * progress, height: bounds.height)
    }
}
