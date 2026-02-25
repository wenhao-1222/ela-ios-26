//
//  DietPlanCreateNaviSegmentVM.swift
//  lns
//
//  Created by LNS2 on 2026/2/24.
//


class DietPlanCreateNaviSegmentVM: UIView {
    
    var selfWidth = (SCREEN_WIDHT - kFitWidth(56) - kFitWidth(24) - kFitWidth(15))/3
    
    override init(frame:CGRect){
        selfWidth = frame.size.width
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: selfWidth, height: kFitWidth(3)))
        self.backgroundColor = .COLOR_TEXT_TITLE_0f1214_10
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(1.5)
        self.clipsToBounds = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var progressView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214
        vi.layer.cornerRadius = kFitWidth(1.5)
        vi.clipsToBounds = true
        
        return vi
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.frame = CGRect(x: 0, y: 0, width: progressView.frame.width, height: bounds.height)
    }
}

extension DietPlanCreateNaviSegmentVM{
    func initUI() {
        addSubview(progressView)
        progressView.frame = CGRect(x: 0, y: 0, width: 0, height: bounds.height)
    }
    func updateProgress(step:Int,totalStep:Int,animate:Bool) {
        guard totalStep > 0 else {
            progressView.frame = CGRect(x: 0, y: 0, width: 0, height: bounds.height)
            return
        }
        let safeStep = max(0, min(step, totalStep))
        let ratio = CGFloat(safeStep) / CGFloat(totalStep)
        let targetWidth = bounds.width * ratio
        let updateFrame = {
            self.progressView.frame = CGRect(x: 0, y: 0, width: targetWidth, height: self.bounds.height)
        }
        if animate{
            UIView.animate(withDuration: 0.25) {
                updateFrame()
            }
        }else{
            updateFrame()
        }
    }
}
