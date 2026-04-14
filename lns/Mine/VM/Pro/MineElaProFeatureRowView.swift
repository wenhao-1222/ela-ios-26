//
//  MineElaProFeatureRowView.swift
//  lns
//
//  Created by LNS2 on 2026/4/14.
//

class MineElaProFeatureRowView: UIView {
   private let feature: MineElaProFeature
   private let showsDivider: Bool
   
   init(feature: MineElaProFeature, showsDivider: Bool) {
       self.feature = feature
       self.showsDivider = showsDivider
       super.init(frame: .zero)
       initUI()
   }
   
   required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
   
   private lazy var iconImageView: UIImageView = {
       let img = UIImageView()
       img.setImgLocal(imgName: feature.iconName)
       img.contentMode = .scaleAspectFit
       return img
   }()
   
   private lazy var titleLabel: UILabel = {
       let lab = UILabel()
       lab.text = feature.title
       lab.textColor = .COLOR_TEXT_TITLE_0f1214
       lab.font = .systemFont(ofSize: 14, weight: .semibold)
       lab.numberOfLines = 0
       return lab
   }()
   
   private lazy var subTitleLabel: UILabel = {
       let lab = UILabel()
       lab.text = feature.subtitle
       lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
       lab.font = .systemFont(ofSize: 12, weight: .regular)
       lab.numberOfLines = 0
       lab.isHidden = feature.subtitle == nil
       return lab
   }()
   
   private lazy var separatorView: UIView = {
       let vi = UIView()
       vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_10
       vi.isHidden = !showsDivider
       return vi
   }()
}

private extension MineElaProFeatureRowView {
   func initUI() {
       addSubview(iconImageView)
       addSubview(titleLabel)
       addSubview(subTitleLabel)
       addSubview(separatorView)
       
       iconImageView.snp.makeConstraints { make in
           make.left.equalTo(kFitWidth(18))
           make.width.height.equalTo(kFitWidth(30))
           if feature.subtitle == nil {
               make.centerY.equalToSuperview()
           } else {
               make.centerY.equalToSuperview().offset(kFitWidth(-2))
           }
       }
       
       titleLabel.snp.makeConstraints { make in
           make.left.equalTo(iconImageView.snp.right).offset(kFitWidth(16))
           make.right.equalTo(kFitWidth(-20))
           if feature.subtitle == nil {
               make.top.equalToSuperview().offset(kFitWidth(24))
               make.bottom.equalToSuperview().offset(-kFitWidth(24))
           } else {
               make.top.equalToSuperview().offset(kFitWidth(18))
           }
       }
       
       if feature.subtitle == nil {
           subTitleLabel.snp.makeConstraints { make in
               make.left.right.equalTo(titleLabel)
               make.top.equalTo(titleLabel.snp.bottom)
               make.height.equalTo(0)
           }
       } else {
           subTitleLabel.snp.makeConstraints { make in
               make.left.right.equalTo(titleLabel)
               make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
               make.bottom.equalToSuperview().offset(-kFitWidth(12))
           }
       }
       
       separatorView.snp.makeConstraints { make in
           make.left.equalTo(titleLabel)
           make.right.equalToSuperview().offset(-kFitWidth(20))
           make.bottom.equalToSuperview()
           make.height.equalTo(0.5)
       }
   }
}
