//
//  GuideChatBoxVM.swift
//  lns
// guide_chat_box
//  Created by Elavatine on 2025/6/10.
//


class GuideChatBoxVM: UIView {
    
    var selfHeight = SCREEN_HEIGHT
    var nextBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT*3, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_F5
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        
//        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
