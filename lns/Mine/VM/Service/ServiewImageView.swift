//
//  ServiewImageView.swift
//  lns
//
//  Created by LNS2 on 2024/5/16.
//

import Foundation

class ServiewImageView: UIButton {
    
    var selfHeight = kFitWidth(108)
    var tapBlock:(()->())?
    var deleteBlock:(()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(8)
        self.clipsToBounds = true
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var imgView: UIImageView = {
        let vi = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(343), height: selfHeight))
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    
    lazy var closeImgView: UIImageView = {
        let vi = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(343), height: selfHeight))
        vi.isUserInteractionEnabled = true
        vi.setImgLocal(imgName: "img_close_icon")
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(deleteAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var coverImgView: UIImageView = {
        let vi = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(343), height: selfHeight))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor =  WHColorWithAlpha(colorStr: "000000", alpha: 0.1)
        vi.isHidden = true
        
        return vi
    }()
    
}
extension ServiewImageView{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        coverImgView.isHidden = false
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        coverImgView.isHidden = true
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        coverImgView.isHidden = true
    }
    override var isHighlighted: Bool {
       didSet {
           if isHighlighted {
               // 当按钮被高亮时，更改按钮的状态，如颜色等
               coverImgView.isHidden = false
           } else {
               // 当按钮高亮状态结束时，恢复按钮的原始状态
               coverImgView.isHidden = true
           }
       }
   }
    
    @objc func tapAction() {
         if self.tapBlock != nil{
             self.tapBlock!()
         }
        coverImgView.isHidden = true
     }
    @objc func deleteAction(){
        if self.deleteBlock != nil{
            self.deleteBlock!()
        }
    }
}

extension ServiewImageView{
    func initUI() {
        addSubview(imgView)
        addSubview(closeImgView)
        addSubview(coverImgView)
        
        setConstrait()
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        closeImgView.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
        coverImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
    }
}

