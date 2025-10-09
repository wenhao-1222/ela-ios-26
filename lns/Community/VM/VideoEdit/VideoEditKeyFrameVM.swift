//
//  VideoEditKeyFrameVM.swift
//  lns
//  关键帧
//  Created by Elavatine on 2025/2/19.
//


class VideoEditKeyFrameVM: UIView {
    
    var selfWidth = kFitWidth(0)
    var selfHeight = kFitWidth(120)
    var imgWidth = kFitWidth(0)
    
    var valueChangedBlock:((Float)->())?
    
    var lastChangeTimeStamp = Date().timeStampMill.intValue
    var lastPercent = CGFloat(0)
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(4)
        self.clipsToBounds = true
        
        selfWidth = frame.size.width
        selfHeight = frame.size.height
        imgWidth = selfWidth*0.1
        
        initUI()
        let panGest: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGest.delegate = self
        currentImgView.addGestureRecognizer(panGest)
//        VideoUtils().getFrameForSeconds(seconds: 24.26, videoUrl: VideoEditModel.shared.videoUrl) { img in
//            if img != nil{
//                self.currentImgView.image = img
//            }
//        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var currentImgView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = kFitWidth(4)
        img.clipsToBounds = true
        img.layer.borderColor = UIColor.white.cgColor
        img.layer.borderWidth = kFitWidth(2)
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFill
        
        return img
    }()
    lazy var slider : UISlider = {
        let vi = UISlider()
        vi.minimumValue = 0
        vi.maximumValue = 1
        vi.value = 0
        vi.isContinuous = true
        vi.backgroundColor = .THEME
        vi.addTarget(self, action: #selector(sliderValueChanged(sender: )), for: .valueChanged)
        return vi
    }()
}

extension VideoEditKeyFrameVM{
    func initUI() {
        if VideoEditModel.shared.keyFramesLoad {
            for vi in self.subviews{
                vi.removeFromSuperview()
            }
            
            for i in 0..<VideoEditModel.shared.keyFrames.count{
                let imgView = UIImageView.init(frame: CGRect.init(x: imgWidth*CGFloat(i), y: 0, width: imgWidth, height: selfHeight))
                addSubview(imgView)
                imgView.contentMode = .scaleAspectFill
                imgView.clipsToBounds = true
                
                let img = VideoEditModel.shared.keyFrames[i]
                imgView.image = img
            }
            
            addSubview(currentImgView)
//            addSubview(slider)
            
            currentImgView.image = VideoEditModel.shared.keyFrames.first
            currentImgView.snp.makeConstraints { make in
                make.left.top.bottom.equalToSuperview()
                make.width.equalTo(imgWidth)
            }
//            slider.snp.makeConstraints { make in
//                make.left.equalTo(imgWidth*0.5)
//                make.right.equalTo(-imgWidth*0.5)
//                make.height.equalTo(imgWidth*0.2)
//                make.centerY.lessThanOrEqualToSuperview()
//            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                self.initUI()
            })
        }
    }
}

extension VideoEditKeyFrameVM:UIGestureRecognizerDelegate{
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        switch gesture.state {
        case .began, .changed:
            let translation = gesture.translation(in: view)
            var newCenterX = view.center.x + translation.x
            if newCenterX < imgWidth*0.5 {
                newCenterX = imgWidth*0.5
            }else if newCenterX > selfWidth - imgWidth*0.5{
                newCenterX = selfWidth - imgWidth*0.5
            }
            view.center = CGPoint(x: newCenterX, y: view.center.y)// + translation.y)
            valueChanged(newPoint: newCenterX)
            gesture.setTranslation(.zero, in: view)
        default:
            break
        }
    }
    @objc func sliderValueChanged(sender:UISlider) {
        let currentValue = sender.value
        DLLog(message: "sliderValueChanged:   \(currentValue)")
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // 获取触摸点
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        DLLog(message: "touchesBegan:\(location)")
        
        var newCenterX = location.x
        if newCenterX < imgWidth*0.5 {
            newCenterX = imgWidth*0.5
        }else if newCenterX > selfWidth - imgWidth*0.5{
            newCenterX = selfWidth - imgWidth*0.5
        }
        currentImgView.center = CGPoint(x: newCenterX, y: selfHeight*0.5)
        valueChanged(newPoint: newCenterX)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    func valueChanged(newPoint:CGFloat) {
        if Date().timeStampMill.intValue > self.lastChangeTimeStamp + 100{
            self.lastChangeTimeStamp = Date().timeStampMill.intValue
            var percent = (newPoint - imgWidth*0.5)/(selfWidth-imgWidth)
            percent = percent < 0 ? 0 : percent
            percent = percent > 1 ? 1 : percent
            DLLog(message: "valueChanged:\(percent)")
//            percent = CGFloat(String(format: "%.f", percent).floatValue)
            if self.lastPercent != percent{
                self.lastPercent = percent
                self.valueChangedBlock?(Float(percent))
            }
        }
    }
}
