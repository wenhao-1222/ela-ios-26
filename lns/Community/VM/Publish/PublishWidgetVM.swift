//
//  PublishWidgetVM.swift
//  lns
//
//  Created by Elavatine on 2024/12/6.
//



class PublishWidgetItemVM: UIView {
    
    let selfHeight = kFitWidth(44)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(8)
        self.clipsToBounds = true
        
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PublishWidgetItemVM{
    func initUI() {
        
    }
}
