//
//  WidgetTestVC.swift
//  lns
//
//  Created by Elavatine on 2025/9/5.
//


class WidgetTestVC: WHBaseViewVC {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    lazy var swiBtn: UISwitch = {
        let sw = UISwitch(frame: CGRect.init(x: kFitWidth(200), y: kFitWidth(200), width: kFitWidth(100), height: kFitWidth(44)))
        return sw
    }()
}

extension WidgetTestVC{
    func initUI() {
        initNavi(titleStr: "iOS26 控件测试")
        view.addSubview(swiBtn)
        
        let row = GlassToggleRow()//.init(frame: CGRect.init(x: 100, y: 400, width: 100, height: 50))
        row.frame = CGRect(x: 16, y: 120, width: view.bounds.width - 32, height: 56)
        row.toggle.isOn = false
        row.toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)

        view.addSubview(row)
        
        view.backgroundColor = .systemBackground
    }
    @objc private func toggleChanged(_ sender: UISwitch) {
        // 你的业务逻辑
    }
}
