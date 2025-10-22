//
//  CoursePDFCell.swift
//  lns
//
//  Created by LNS2 on 2025/10/22.
//


class CoursePDFCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .COLOR_BG_F5
        selectionStyle = .none
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    
    lazy var bgView: GradientView = {
        let view = GradientView()
        view.backgroundColor = .white
        view.layer.cornerRadius = kFitWidth(13)
        view.clipsToBounds = true
        
        return view
    }()
    lazy var downLoadImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "course_pdf_download_icon")
        
        return img
    }()
    lazy var cellTitleLab: UILabel = {
        let lab = UILabel()
        lab.text = "下载训练计划"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .semibold)
        return lab
    }()
    lazy var cellDetalLab: UILabel = {
        let lab = UILabel()
        lab.text = "说明或者简短的介绍，限制一行"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        return lab
    }()
}

extension CoursePDFCell{
    func updateUI(dict:NSDictionary) {
        cellTitleLab.text = dict.stringValueForKey(key: "title")
//        cellDetalLab.text = dict.stringValueForKey(key: "subtitle")
    }
}

extension CoursePDFCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(downLoadImgView)
        bgView.addSubview(cellTitleLab)
//        bgView.addSubview(cellDetalLab)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(13))
            make.bottom.equalToSuperview()
        }
        downLoadImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
//            make.top.equalTo(kFitWidth(21.5))
            make.centerY.lessThanOrEqualToSuperview()
//            make.bottom.equalTo(kFitWidth(-23.5))
            make.width.height.equalTo(kFitWidth(20))
        }
        cellTitleLab.snp.makeConstraints { make in
//            make.top.equalTo(kFitWidth(13))
            make.centerY.lessThanOrEqualToSuperview()
            make.left.equalTo(kFitWidth(44))
            make.height.equalTo(kFitWidth(21))
            make.right.equalTo(kFitWidth(-20))
        }
//        cellDetalLab.snp.makeConstraints { make in
//            make.top.equalTo(kFitWidth(34))
//            make.left.equalTo(kFitWidth(44))
//            make.height.equalTo(kFitWidth(16))
//            make.right.equalTo(kFitWidth(-20))
//        }
    }
}

extension CoursePDFCell{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let scale: CGFloat = 0.99
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
//        triggerImpact(feedbackGenerator, intensity: feedbackWeight)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
//        if let touch = touches.first, self.bounds.contains(touch.location(in: self)) {
////            UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.9)
//            triggerImpact(UIImpactFeedbackGenerator(style: .medium), intensity: 0.9)
//        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
//    private func triggerImpact(_ generator: UIImpactFeedbackGenerator, intensity: CGFloat) {
//        let now = Date().timeIntervalSince1970
//        guard now - lastFeedbackTime > minimumFeedbackInterval else { return }
//        generator.impactOccurred(intensity: intensity)
//        lastFeedbackTime = now
//    }
}
