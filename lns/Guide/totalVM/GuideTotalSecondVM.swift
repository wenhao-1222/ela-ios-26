//
//  GuideTotalSecondVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/6.
//


class GuideTotalSecondVM: UIView {
    
    var selfHeight = SCREEN_HEIGHT
    /// speed for views moving right to left (points per second)
    var leftSpeed: CGFloat = 8
    /// speed for views moving left to right (points per second)
    var rightSpeed: CGFloat = 13
//2250 × 262 pixels
    private lazy var row1 = createRow(imageName: "guide_second_img_1", direction: .left)
    private lazy var row2 = createRow(imageName: "guide_second_img_2", direction: .right)
    private lazy var row3 = createRow(imageName: "guide_second_img_3", direction: .left)
    private lazy var row4 = createRow(imageName: "guide_second_img_4", direction: .right)

    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GuideTotalSecondVM{
    func initUI() {
        
        addSubview(row1)
        addSubview(row2)
        addSubview(row3)
        addSubview(row4)

        row1.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(kFitWidth(1125))
            make.height.equalTo(kFitWidth(131))
        }
        row2.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalTo(row1.snp.bottom)
            make.width.equalTo(kFitWidth(1125))
            make.height.equalTo(row1)
        }
        row3.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(row2.snp.bottom)
            make.width.equalTo(kFitWidth(1125))
            make.height.equalTo(row1)
        }
        row4.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalTo(row3.snp.bottom)
            make.width.equalTo(kFitWidth(1125))
            make.height.equalTo(row1)
        }

        layoutIfNeeded()
        startAnimation()
    }

    enum MoveDirection {
        case left
        case right
    }

    private func createRow(imageName: String, direction: MoveDirection) -> UIView {
        let container = UIView()
        container.clipsToBounds = true

        let img1 = UIImageView()
        img1.contentMode = .scaleAspectFill
        img1.setImgLocal(imgName: imageName)
        let img2 = UIImageView()
        img2.contentMode = .scaleAspectFill
        img2.setImgLocal(imgName: imageName)

        container.addSubview(img1)
        container.addSubview(img2)

        img1.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(kFitWidth(562.5))
            
            switch direction {
            case .left:
                make.left.equalToSuperview()
            case .right:
                make.right.equalToSuperview()
            }
        }
        img2.snp.makeConstraints { make in
            make.top.bottom.width.equalTo(img1)
            switch direction {
            case .left:
                make.left.equalTo(img1.snp.right)
            case .right:
                make.right.equalTo(img1.snp.left)
            }
        }
        return container
    }

    private func startAnimation() {
        scroll(view: row1, direction: .left, speed: leftSpeed)
        scroll(view: row2, direction: .right, speed: rightSpeed)
        scroll(view: row3, direction: .left, speed: leftSpeed)
        scroll(view: row4, direction: .right, speed: rightSpeed)
    }

    private func scroll(view: UIView, direction: MoveDirection, speed: CGFloat) {
        let distance = view.bounds.width
        guard distance > 0 else { return }
        let duration = Double(distance / speed)
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = 0
        animation.toValue = direction == .left ? -distance : distance
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        view.layer.add(animation, forKey: "scroll")
    }
}
