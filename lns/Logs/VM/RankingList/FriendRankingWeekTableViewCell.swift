//
//  FriendRankingWeekTableViewCell.swift
//  lns
//
//  Created by Elavatine on 2025/7/4.
//


class FriendRankingWeekTableViewCell: UITableViewCell {
    
    var editBlock:((_ sourceView: UIView)->Void)?
    var showWeeklyBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var rankImgView : UIImageView = {
        let img = UIImageView()
        
        return img
    }()
    lazy var rankNumLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = UIFont().DDInFontSemiBold(fontSize: 28)
        lab.isHidden = true
        
        return lab
    }()
    lazy var headImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(20)
        img.clipsToBounds = true
        
        return img
    }()
    lazy var nickNameLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var editImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "friend_list_edit_icon")
        img.isUserInteractionEnabled = true
        img.isHidden = true
        
        return img
    }()
    lazy var editTapView: FeedBackView = {
        let vi = FeedBackView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        vi.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(editTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var totalScoreLab: LineHeightLabel = {
        let lab = LineHeightLabel()
//        lab.text = "综合分"
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        return lab
    }()
    lazy var totalScoreLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.font = UIFont().DDInFontBold(fontSize: 25)
        lab.textColor = .THEME
        
        return lab
    }()
    lazy var daysNumLab: LineHeightLabel = {
        let lab = LineHeightLabel()
//        lab.text = "记录天数"
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        return lab
    }()
    lazy var daysNumLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.font = UIFont().DDInFontBold(fontSize: 20)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        return lab
    }()
    lazy var scoreLab: LineHeightLabel = {
        let lab = LineHeightLabel()
//        lab.text = "执行评分"
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        return lab
    }()
    lazy var scoreLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.font = UIFont().DDInFontBold(fontSize: 20)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        return lab
    }()
    lazy var showFriendReport: LineHeightLabel = {
        let lab = LineHeightLabel()
//        lab.text = "查看好友周报"
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.isHidden = true
        
        return lab
    }()
    lazy var arrowImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "plan_detail_arrow_icon_right")
        img.isHidden = true
        
        return img
    }()
    lazy var showWeekyTapView: FeedBackView = {
        let vi = FeedBackView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        vi.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(weeklyReportTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5
        return vi
    }()
}

extension FriendRankingWeekTableViewCell{
    func updateUI(dict:NSDictionary,index:Int) {
        if dict.stringValueForKey(key: "nickname").isEmpty {
            rankImgView.image = nil
            headImgView.image = nil
            nickNameLabel.text = nil
            totalScoreLab.text = nil
            totalScoreLabel.text = nil
            daysNumLab.text = nil
            daysNumLabel.text = nil
            scoreLab.text = nil
            scoreLabel.text = nil
            showFriendReport.text = nil
            arrowImgView.image = nil
            editImgView.image = nil
            
            // 需要骨架的子视图：显示骨架（从左向右 Shimmer + 渐入）
            let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                     highlightColorLight: .COLOR_GRAY_E2,
                                     cornerRadius: kFitWidth(4),
                                     shimmerWidth: 0.22,
                                     shimmerDuration: 1.15)
            
            rankImgView.showSkeleton(cfg)
            headImgView.showSkeleton(cfg)
            nickNameLabel.showSkeleton(cfg)
            totalScoreLab.showSkeleton(cfg)
            totalScoreLabel.showSkeleton(cfg)
            daysNumLab.showSkeleton(cfg)
            daysNumLabel.showSkeleton(cfg)
            scoreLab.showSkeleton(cfg)
            scoreLabel.showSkeleton(cfg)
            showFriendReport.showSkeleton(cfg)
            arrowImgView.showSkeleton(cfg)
            return
        }
        
        updateConstrait()
        editImgView.isHidden = true
        editTapView.isHidden = true
        rankImgView.isHidden = true
        rankNumLabel.isHidden = true
        showFriendReport.isHidden = true
        arrowImgView.isHidden = true
        showWeekyTapView.isHidden = true
        
        totalScoreLab.text = "综合分"
        daysNumLab.text = "记录天数"
        scoreLab.text = "执行评分"
        showFriendReport.text = "查看好友周报"
        arrowImgView.setImgLocal(imgName: "plan_detail_arrow_icon_right")
        editImgView.setImgLocal(imgName: "friend_list_edit_icon")
        
        if index < 3 {
            rankImgView.isHidden = false
            if index == 0 {
                rankImgView.setImgLocal(imgName: "friend_list_first")
            }else if index == 1{
                rankImgView.setImgLocal(imgName: "friend_list_second")
            }else{
                rankImgView.setImgLocal(imgName: "friend_list_third")
            }
        }else{
            rankNumLabel.isHidden = false
            rankNumLabel.text = "\(index+1)"
        }
        editImgView.isHidden = dict.stringValueForKey(key: "uid") == UserInfoModel.shared.uId
        editTapView.isHidden = dict.stringValueForKey(key: "uid") == UserInfoModel.shared.uId
        showFriendReport.isHidden = dict.stringValueForKey(key: "uid") == UserInfoModel.shared.uId
        arrowImgView.isHidden = dict.stringValueForKey(key: "uid") == UserInfoModel.shared.uId
        showWeekyTapView.isHidden = dict.stringValueForKey(key: "uid") == UserInfoModel.shared.uId
        
        nickNameLabel.text = dict.stringValueForKey(key: "nickname")
        headImgView.setImgUrl(urlString: dict.stringValueForKey(key: "headimgurl"))
        totalScoreLabel.text = dict.stringValueForKey(key: "totalScore")
        
        var daysAttr = NSMutableAttributedString(string: dict.stringValueForKey(key: "logDays"))
        var daysUnitAttr = NSMutableAttributedString(string: "天")
        daysUnitAttr.yy_font = .systemFont(ofSize: 11, weight: .regular)
        daysUnitAttr.yy_color = .COLOR_TEXT_TITLE_0f1214_50
        
        daysAttr.append(daysUnitAttr)
        daysNumLabel.attributedText = daysAttr
        
        var scoreAttr = NSMutableAttributedString(string: dict.stringValueForKey(key: "score"))
        var scoreUnitAttr = NSMutableAttributedString(string: "分")
        scoreUnitAttr.yy_font = .systemFont(ofSize: 11, weight: .regular)
        scoreUnitAttr.yy_color = .COLOR_TEXT_TITLE_0f1214_50
        
        scoreAttr.append(scoreUnitAttr)
        scoreLabel.attributedText = scoreAttr
        
        // 3) 最后统一把骨架优雅淡出 + 内容淡入
        [rankImgView, headImgView, nickNameLabel,totalScoreLab,totalScoreLabel, daysNumLab,daysNumLabel,scoreLab,scoreLabel,showFriendReport,arrowImgView,editImgView].forEach { $0.hideSkeletonWithCrossfade() }
    }
    @objc func editTapAction() {
        self.editBlock?(editImgView)
    }
    @objc func weeklyReportTapAction() {
        self.showWeeklyBlock?()
    }
}

extension FriendRankingWeekTableViewCell{
    func initUI() {
        contentView.addSubview(rankImgView)
        contentView.addSubview(rankNumLabel)
        contentView.addSubview(headImgView)
        contentView.addSubview(nickNameLabel)
        contentView.addSubview(editImgView)
        contentView.addSubview(editTapView)
        contentView.addSubview(totalScoreLab)
        contentView.addSubview(totalScoreLabel)
        contentView.addSubview(daysNumLab)
        contentView.addSubview(daysNumLabel)
        contentView.addSubview(scoreLab)
        contentView.addSubview(scoreLabel)
        contentView.addSubview(showFriendReport)
        contentView.addSubview(arrowImgView)
        contentView.addSubview(showWeekyTapView)
        contentView.addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait()  {
        rankImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(15))
            make.width.equalTo(kFitWidth(36))
            make.height.equalTo(kFitWidth(49))
        }
        rankNumLabel.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(10))
            make.centerX.lessThanOrEqualTo(rankImgView)
        }
        headImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(88))
            make.top.equalTo(kFitWidth(19.5))
            make.width.height.equalTo(kFitWidth(40))
        }
        nickNameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(135))
            make.centerY.lessThanOrEqualTo(headImgView)
            make.right.equalTo(kFitWidth(-51.5))
        }
        
        editImgView.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(nickNameLabel)
            make.right.equalTo(kFitWidth(-16))
            make.width.equalTo(kFitWidth(6))
            make.height.equalTo(kFitWidth(40))
        }
        editTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(editImgView)
            make.width.height.equalTo(kFitWidth(40))
        }
        totalScoreLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(rankImgView)
            make.top.equalTo(kFitWidth(79))
            make.width.equalTo(kFitWidth(40))
            make.height.equalTo(kFitWidth(16))
        }
        totalScoreLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(totalScoreLab)
            make.top.equalTo(totalScoreLab.snp.bottom).offset(kFitWidth(2))
            make.width.equalTo(kFitWidth(40))
            make.height.equalTo(kFitWidth(16))
        }
        daysNumLab.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(totalScoreLab)
            make.left.equalTo(headImgView).offset(kFitWidth(3))
            make.width.equalTo(kFitWidth(68))
            make.height.equalTo(kFitWidth(16))
        }
        daysNumLabel.snp.makeConstraints { make in
            make.left.equalTo(daysNumLab)
            make.top.equalTo(daysNumLab.snp.bottom).offset(kFitWidth(7))
            make.width.equalTo(kFitWidth(30))
            make.height.equalTo(kFitWidth(16))
        }
        scoreLab.snp.makeConstraints { make in
            make.left.equalTo(daysNumLab.snp.right).offset(kFitWidth(32))
            make.centerY.lessThanOrEqualTo(daysNumLab)
            make.width.equalTo(kFitWidth(68))
            make.height.equalTo(kFitWidth(16))
        }
        scoreLabel.snp.makeConstraints { make in
            make.left.equalTo(scoreLab)
            make.centerY.lessThanOrEqualTo(daysNumLabel)
            make.width.equalTo(kFitWidth(30))
            make.height.equalTo(kFitWidth(16))
        }
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(kFitWidth(-47.5))
            make.width.height.equalTo(kFitWidth(20))
        }
        showFriendReport.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(arrowImgView)
            make.right.equalTo(arrowImgView.snp.left).offset(kFitWidth(-4))
        }
        showWeekyTapView.snp.makeConstraints { make in
            make.left.equalTo(showFriendReport)
            make.right.equalToSuperview()
            make.centerY.lessThanOrEqualTo(showFriendReport)
            make.height.equalTo(kFitWidth(40))
        }
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(kFitWidth(-15))
            make.height.equalTo(kFitWidth(1))
        }
    }
    func updateConstrait() {
        totalScoreLab.text = "综合分"
        daysNumLab.text = "记录天数"
        scoreLab.text = "执行评分"
        totalScoreLab.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualTo(rankImgView)
            make.top.equalTo(kFitWidth(79))
        }
        totalScoreLabel.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualTo(totalScoreLab)
            make.top.equalTo(totalScoreLab.snp.bottom).offset(kFitWidth(2))
        }
        daysNumLab.snp.remakeConstraints { make in
            make.centerY.lessThanOrEqualTo(totalScoreLab)
            make.left.equalTo(headImgView).offset(kFitWidth(3))
        }
        daysNumLabel.snp.remakeConstraints { make in
            make.left.equalTo(daysNumLab)
            make.top.equalTo(daysNumLab.snp.bottom).offset(kFitWidth(7))
        }
        scoreLab.snp.remakeConstraints { make in
            make.left.equalTo(daysNumLab.snp.right).offset(kFitWidth(32))
            make.centerY.lessThanOrEqualTo(daysNumLab)
        }
        scoreLabel.snp.remakeConstraints { make in
            make.left.equalTo(scoreLab)
            make.centerY.lessThanOrEqualTo(daysNumLabel)
        }
    }
}
