//
//  TestVC.swift
//  lns
//
//  Created by Elavatine on 2025/4/24.
//

import UIKit
import Kingfisher

class TestVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView!
    var dataSource: [String] = []  // 假设这是你要展示的数据源
    var imageCache = ImageCache.default  // 获取 Kingfisher 缓存
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置 tableView
        tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        
        // 加载一些初始数据
        loadInitialData()
    }
    
    func loadInitialData() {
        // 假设加载一些数据
        for i in 0..<20 {
            dataSource.append("https://example.com/image\(i).jpg") // 替换为你自己的图片URL
        }
        tableView.reloadData()
    }
    
    // UITableViewDataSource 方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // 获取图片 URL
        let imageUrlString = dataSource[indexPath.row]
        guard let imageUrl = URL(string: imageUrlString) else {
            return cell
        }
        
        // 使用 Kingfisher 加载图片，优先使用缓存
        let options: KingfisherOptionsInfo = [
            .cacheOriginalImage, // 缓存原始图像
            .transition(.fade(0.2)), // 设置过渡动画，避免闪烁
            .forceRefresh  // 如果需要强制刷新，可以设置该选项
        ]
        
        // 让 Kingfisher 从缓存中加载图片，避免重复下载
        cell.imageView?.kf.setImage(with: imageUrl, options: options)
        
        return cell
    }
    
    // 假设加载更多数据时
    func loadMoreData() {
        let newImages = ["https://example.com/image21.jpg", "https://example.com/image22.jpg"] // 替换为新的图片URL
        dataSource.append(contentsOf: newImages)
        tableView.reloadData()
    }
}
