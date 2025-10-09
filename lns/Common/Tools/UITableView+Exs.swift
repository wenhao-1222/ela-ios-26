//
//  UITableView+Exs.swift
//  lns
//
//  Created by Elavatine on 2025/5/20.
//

extension UITableView {
    func snapshotFullContent() -> UIImage? {
        let originalOffset = self.contentOffset
        let originalFrame = self.frame
        
        // 计算整个内容的高度
        let contentSize = self.contentSize
        UIGraphicsBeginImageContextWithOptions(contentSize, false, UIScreen.main.scale)

        // 保存原来的 scrollEnabled 状态
        let wasScrollEnabled = self.isScrollEnabled
        self.isScrollEnabled = false

        // 临时调整 frame
        self.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)

        // 绘制内容
        self.contentOffset = .zero
        self.layoutIfNeeded()
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()

        // 恢复原状
        UIGraphicsEndImageContext()
        self.contentOffset = originalOffset
        self.frame = originalFrame
        self.isScrollEnabled = wasScrollEnabled

        return image
    }
    func snapshotFullContentWithPadding(padding: CGFloat = 16,topPadding:CGFloat = 16,bottomPadding:CGFloat = 16) -> UIImage? {
        let originalOffset = self.contentOffset
        let originalFrame = self.frame
        let originalSuperview = self.superview

        let targetSize = CGSize(width: self.contentSize.width + padding * 2,
                                height: self.contentSize.height)

        // 创建一个包含白色背景和左右间距的新容器视图
        let backgroundView = UIView(frame: CGRect(origin: .zero, size: targetSize))
        backgroundView.backgroundColor = .COLOR_BG_F5//self.backgroundColor ?? .white

        // 临时设置 tableView 位置和大小
        self.frame = CGRect(x: padding, y: 0, width: self.contentSize.width, height: self.contentSize.height)
        backgroundView.addSubview(self)

        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
        backgroundView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // 恢复 tableView 到原状态
        self.removeFromSuperview()
        originalSuperview?.addSubview(self)
        self.frame = originalFrame
        self.contentOffset = originalOffset

        return snapshotImage
    }
}
