//
//  ArticlesVC.swift
//  lns
//
//  Created by Elavatine on 2025/8/15.
//


class ArticlesVC: WHBaseViewVC {
    
    let tableView = UITableView()
    var isLoading = true
    // 模拟数据源（真实项目用你的接口结果）
    var items: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
}

extension ArticlesVC{
    func initUI() {
        initNavi(titleStr: "骨架屏测试")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ArticlesTableViewCell.self, forCellReuseIdentifier: "ArticlesTableViewCell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.top.equalTo(getNavigationBarHeight())
        }

        // 初始：加载中
        isLoading = true
        tableView.reloadForSkeleton()

        // 异步获取数据后：
//        fetchArticles()
        
        // 异步获取数据后（示例 1.2s）：
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.2) { [weak self] in
            guard let self = self else { return }
            self.items = (0..<8).map { i in
                return [
                    "orderId": "NO.\(1000+i)",
                    "title": "这是标题 \(i+1)",
                    "subtitle": "副标题，最多两行，看看效果 \(i+1)",
                    "coverInfo": ["orderListImageOssUrl": "https://picsum.photos/seed/\(i)/180/180"],
                    "ctime": "2025-08-10 12:34:56",
                    "status": ["1","2","3"].randomElement()!,
                    "payAmount": "99.00",
                    "discountAmount": "10.00",
                    "rebindingQuota": 1.0,
                    "phoneName": "iPhone 15 Pro",
                    "timeExpire": "\(Int(Date().addingTimeInterval(180).timeIntervalSince1970))"
                ]
            }
            self.isLoading = false
            self.tableView.reloadData()                // ✅ 切到真实数据
        }
    }
}

extension ArticlesVC:UITableViewDelegate,UITableViewDataSource{
    // MARK: UITableViewDataSource
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 5  // 加载中时显示固定数量的“骨架行”
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ArticlesTableViewCell", for: indexPath) as! ArticlesTableViewCell
//            cell.updateUI(dict: [:], isLoading: self.isLoading)
            
            let cell = tableView.dequeueReusableCell(
                        withIdentifier: "ArticlesTableViewCell",
                        for: indexPath
                    ) as! ArticlesTableViewCell

                    if isLoading {
                        cell.updateUI(dict: [:], isLoading: true)  // ✅ 显示骨架
                    } else {
                        let dict = items[indexPath.row] as NSDictionary
                        cell.updateUI(dict: dict, isLoading: false)
                    }
            
            return cell
        }
}
