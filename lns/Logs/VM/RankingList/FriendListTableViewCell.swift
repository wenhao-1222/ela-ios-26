//
//  FriendListTableViewCell.swift
//  lns
//
//  Created by Elavatine on 2025/6/30.
//


import Foundation
import SwiftUI

class FriendListTableViewCell: UITableViewCell {
    
    var addBlock:(()->())?
    var agreeBlock:(()->())?
    var disagreeBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var headImgView : UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(20)
        img.clipsToBounds = true
        
        return img
    }()
    lazy var nickNameLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        
        return lab
    }()
    lazy var idLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.isHidden = true
        
        return lab
    }()
    lazy var addButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setImage(UIImage(named: "friend_list_status_add"), for: .normal)
//        btn.isHidden = true
        btn.alpha = 0
        btn.addTarget(self, action: #selector(addTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var agreeButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setImage(UIImage(named: "friend_list_status_agree"), for: .normal)
//        btn.isHidden = true
        btn.alpha = 0
        btn.addTarget(self, action: #selector(agreeTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var disagreeButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setImage(UIImage(named: "friend_list_status_disagree"), for: .normal)
//        btn.isHidden = true
        btn.alpha = 0
        btn.addTarget(self, action: #selector(disagreeTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_20
        vi.isHidden = true
        return vi
    }()
}

extension FriendListTableViewCell{
    @objc func addTapAction() {
        self.addBlock?()
    }
    @objc func agreeTapAction() {
        self.agreeBlock?()
    }
    @objc func disagreeTapAction() {
        self.disagreeBlock?()
    }
}
extension FriendListTableViewCell{
    func updateUI(dict:NSDictionary) {
        if dict.stringValueForKey(key: "nickname").count > 0 {
            nickNameLabel.snp.remakeConstraints { make in
                make.left.equalTo(headImgView.snp.right).offset(kFitWidth(12))
                make.right.equalTo(kFitWidth(-130))
                make.centerY.lessThanOrEqualToSuperview()
            }
            idLabel.snp.remakeConstraints { make in
                make.top.equalTo(kFitWidth(40))
                make.left.equalTo(nickNameLabel)
            }
            headImgView.setImgUrl(urlString: dict.stringValueForKey(key: "headimgurl"))
            nickNameLabel.text = dict.stringValueForKey(key: "nickname")
            let status = dict.stringValueForKey(key: "status")
            DLLog(message: "status:\(status)")
            
            if dict.stringValueForKey(key: "uid") == UserInfoModel.shared.uId{
                addButton.isHidden = true
                agreeButton.isHidden = true
                disagreeButton.isHidden = true
                lineView.isHidden = false
            }else{
                if status.count > 0 {
                    addButton.setImage(UIImage(named: "friend_list_status_add"), for: .normal)
                    if dict.stringValueForKey(key: "status") == "1"{//申请中
                        addButton.setImage(UIImage(named: "friend_list_status_pending"), for: .normal)
                    }else if dict.stringValueForKey(key: "status") == "2"{//已同意
                        addButton.setImage(UIImage(named: "friend_list_status_succesd"), for: .normal)
                    }
                    addButton.isHidden = false
                    agreeButton.isHidden = true
                    disagreeButton.isHidden = true
                    lineView.isHidden = true
                }else{
                    addButton.isHidden = true
                    agreeButton.isHidden = false
                    disagreeButton.isHidden = false
                    lineView.isHidden = false
                }
            }
            // 3) 最后统一把骨架优雅淡出 + 内容淡入
            [headImgView, nickNameLabel,idLabel].forEach { $0.hideSkeletonWithCrossfade() }
            self.addButton.alpha = 0
            self.agreeButton.alpha = 0
            self.disagreeButton.alpha = 0
            UIView.animate(withDuration: 0.15, animations: {
                self.addButton.alpha = 1
                self.agreeButton.alpha = 1
                self.disagreeButton.alpha = 1
            })
        }else{
            addButton.isHidden = true
            agreeButton.isHidden = true
            disagreeButton.isHidden = true
            
            headImgView.image = nil
            nickNameLabel.text = nil
            idLabel.text = nil
            nickNameLabel.snp.remakeConstraints { make in
                make.left.equalTo(headImgView.snp.right).offset(kFitWidth(12))
                make.width.equalTo(kFitWidth(240))
                make.centerY.lessThanOrEqualToSuperview()
                make.height.equalTo(kFitWidth(18))
            }
            // 需要骨架的子视图：显示骨架（从左向右 Shimmer + 渐入）
            let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                     highlightColorLight: .COLOR_GRAY_E2,
                                     cornerRadius: kFitWidth(4),
                                     shimmerWidth: 0.22,
                                     shimmerDuration: 1.15)
            
            [headImgView, nickNameLabel,idLabel].forEach { $0.showSkeleton(cfg) }
        }
    }
}

extension FriendListTableViewCell{
    func initUI() {
        contentView.addSubview(headImgView)
        contentView.addSubview(nickNameLabel)
        contentView.addSubview(idLabel)
        contentView.addSubview(addButton)
        contentView.addSubview(agreeButton)
        contentView.addSubview(disagreeButton)
        contentView.addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        headImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(18))
            make.bottom.equalTo(kFitWidth(-18))
            make.width.height.equalTo(kFitWidth(40))
        }
        nickNameLabel.snp.makeConstraints { make in
            make.left.equalTo(headImgView.snp.right).offset(kFitWidth(12))
//            make.right.equalTo(kFitWidth(-130))
            make.width.equalTo(kFitWidth(240))
//            make.top.equalTo(kFitWidth(18))
            make.centerY.lessThanOrEqualToSuperview()
            make.height.equalTo(kFitWidth(18))
        }
        idLabel.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(40))
            make.left.equalTo(nickNameLabel)
            make.width.equalTo(kFitWidth(120))
            make.height.equalTo(kFitWidth(18))
        }
        addButton.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(18))
            make.right.equalTo(kFitWidth(-12))
            make.width.height.equalTo(kFitWidth(40))
        }
        agreeButton.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(18))
            make.right.equalTo(kFitWidth(-12))
            make.width.height.equalTo(kFitWidth(40))
        }
        disagreeButton.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(agreeButton)
            make.right.equalTo(agreeButton.snp.left).offset(kFitWidth(-12))
            make.width.height.equalTo(kFitWidth(40))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(67))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(0.5))
        }
    }
}
