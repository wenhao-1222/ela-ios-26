//
//  WaterAlertSetVC.swift
//  lns
//
//  Created by Elavatine on 2025/5/26.
//

import UIKit

class WaterAlertSetVC: WHBaseViewVC, UITableViewDataSource, UITableViewDelegate {
    var times:[String] = []
    lazy var tableView:UITableView = {
        let tv = UITableView(frame: CGRect(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight()), style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.tableFooterView = UIView()
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        initNavi(titleStr: "喝水提醒")
        self.navigationView.addSubview(addButton)
        
        times = UserDefaults.getWaterAlerts()
        view.addSubview(tableView)
        
        addButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-10))
            make.width.equalTo(kFitWidth(88))
            make.height.equalTo(kFitWidth(44))
            make.centerY.lessThanOrEqualTo(self.naviTitleLabel)
        }
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction))
    }
    lazy var addButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("添加提醒", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        return btn
    }()

    @objc func addAction(){
        let alert = UIAlertController(title: "选择时间", message: "\n", preferredStyle: .actionSheet)
        let picker = UIDatePicker(frame: CGRect(x: 0, y: 20, width: alert.view.bounds.width-20, height: 150))
        picker.datePickerMode = .time
        if #available(iOS 13.4, *) { picker.preferredDatePickerStyle = .wheels }
        alert.view.addSubview(picker)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            let comps = Calendar.current.dateComponents([.hour,.minute], from: picker.date)
            let str = String(format: "%02d:%02d", comps.hour ?? 0, comps.minute ?? 0)
            self.times.append(str)
            self.save()
        }))
        present(alert, animated: true)
    }

    func save(){
        UserDefaults.setWaterAlerts(times: times)
        tableView.reloadData()
        WaterAlertManager.shared.refreshWaterAlerts()
    }

    //MARK: table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return times.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = times[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            times.remove(at: indexPath.row)
            save()
        }
    }
}
