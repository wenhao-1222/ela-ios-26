//
//  WHBaseViewVC.swift
//  ttjx
//
//  Created by 文 on 2019/8/28.
//  Copyright © 2019 ttjx. All rights reserved.
//

import UIKit
import SnapKit
import MCToast
import CoreTelephony
import UMCommon

class WHBaseViewVC: ViewController {
    
    public var fatherViewController: UIViewController?
    //能否侧滑返回
    var canEdgeBack:Bool = true
    
    var navigationView = UIView()
    var naviTitleLabel     = UILabel()
    var naviBackImg        = UIImageView()
    let backView = UIView()
    
    override var shouldAutorotate: Bool{
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UserConfigModel.shared.allowedOrientations
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return UserConfigModel.shared.userInterfaceOrientation
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        UserInfoModel.shared.currentVc = self
        openInteractivePopGesture()
        MobClick.beginLogPageView(self.ClassName)
//        dealsWidgetTapAction()
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        MobClick.endLogPageView(self.ClassName)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
//        MobClick.endLogPageView(self.ClassName)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.view.isUserInteractionEnabled = true
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        MobClick.setAutoPageEnabled(true)
//        UserInfoModel.shared.currentVc = self
//        self.navigationController?.fd_interactivePopDisabled = true
        
    }
    
     override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
         if isIpad(){
             
         }else{
             let aClass:AnyClass = NSClassFromString("UITabBarButton")!
             guard let views = self.tabBarController?.tabBar.subviews else { return }
             for view in views {
                 if view.isKind(of: aClass) {
                     view.removeFromSuperview()
                 }
             }
         }
        
    }
//    override var shouldAutorotate: Bool{
//        return false
//    }
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return .portrait
//    }
    lazy var scrollViewBase : UIScrollView = {
        let vi = UIScrollView()
        vi.frame = CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight())
        vi.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        vi.showsVerticalScrollIndicator = false
        vi.contentInsetAdjustmentBehavior = .never
        
        return vi
    }()
//    lazy var backArrowButton : GJVerButton = {
//        let btn = GJVerButton()
//        btn.setImage(UIImage(named: "back_arrow"), for: .normal)
//        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
//        btn.setImage(UIImage(named: "back_arrow_highlight"), for: .highlighted)
//        btn.addTarget(self, action: #selector(backTapAction), for: .touchUpInside)
//        return btn
//    }()
    
    lazy var backArrowButton: NaviBackButton = {
        let btn = NaviBackButton.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: kFitWidth(44), height: kFitWidth(44)))
        btn.tapBlock = {()in
            self.backTapAction()
        }
        return btn
    }()
    
    func initNavigationView(){
       self.view.addSubview(navigationView)
        navigationView.backgroundColor = UIColor.white
       navigationView.snp.makeConstraints { (frame) in
           frame.width.equalTo(SCREEN_WIDHT)
           frame.height.equalTo(getNavigationBarHeight())
           frame.left.equalTo(0)
           frame.top.equalTo(0)
       }
        
        navigationView.addSubview(naviTitleLabel)
        naviTitleLabel.textColor = WHColor_TextBlack()
        naviTitleLabel.font = UIFont.systemFont(ofSize: 15)
        naviTitleLabel.textAlignment = NSTextAlignment.center
        naviTitleLabel.snp.makeConstraints { (frame) in
            frame.width.equalTo(SCREEN_WIDHT)
            frame.height.equalTo(44)
            frame.left.equalToSuperview()
            frame.top.equalToSuperview().offset(statusBarHeight)
        }
        
        navigationView.addSubview(naviBackImg)
        naviBackImg.isUserInteractionEnabled = true
        naviBackImg.image = UIImage.init(named: "back_arrow_black")
        naviBackImg.snp.makeConstraints { (frame) in
            frame.leftMargin.equalToSuperview().offset(kFitWidth(24))
            frame.centerY.equalTo(statusBarHeight + 22)
            frame.width.equalTo(kFitWidth(19))
            frame.height.equalTo(kFitWidth(19))
        }
        let backTap = UITapGestureRecognizer()
        backTap.addTarget(self, action: #selector(backTapAction))
        naviBackImg.addGestureRecognizer(backTap)
   }
    func randomInteger(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
//MARK: 禁用侧滑返回
    @objc func enableInteractivePopGesture(){
        if let popGesture = self.navigationController?.interactivePopGestureRecognizer {
            popGesture.isEnabled = false
        }
    }
    @objc func openInteractivePopGesture(){
        if let popGesture = self.navigationController?.interactivePopGestureRecognizer {
            popGesture.isEnabled = true
//            popGesture.
            
        }
    }
    //禁止同时点击
    func setupExclusiveTouch(in view: UIView) {
        view.isExclusiveTouch = true
        for subview in view.subviews {
            setupExclusiveTouch(in: subview)
        }
    }
    func changeRootVcToTabbar() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if isIpad(){
            let newRootVC = MainTabBarController()
            appDelegate.switchRootViewController(to: newRootVC)
        }else{
            let newRootVC = WHTabBarVC()
            appDelegate.switchRootViewController(to: newRootVC)
        }
    }
    func changeRootVcToLogin() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let newRootVC = LNSLoginVC()
        let newRootVC = LLNaviViewController(rootViewController: LNSLoginVC())
        appDelegate.switchRootViewController(to: newRootVC)
    }
    func changeRootVcToWelcome() {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let newRootVC = LLNaviViewController(rootViewController: WelcomeVC())
//        appDelegate.switchRootViewController(to: newRootVC)
        let navVc = UINavigationController(rootViewController: WelcomeVC())
//        appDelegate.window?.rootViewController = navVc
        appDelegate.switchRootViewController(to: navVc)
    }
    @objc func backTapAction(){
        if (self.navigationController != nil) {
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true) {
            }
        }
    }
    @objc func singleTapAction(){
        self.view.resignFirstResponder()
    }
    
    func presentAlertVc(confirmBtn:String, message:String, title:String, cancelBtn:String?,textAlignLeft:Bool? = false, handler:@escaping(UIAlertAction) ->Void, viewController:UIViewController) {
        let alertVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if cancelBtn != nil{
            let cancelAction = UIAlertAction(title: cancelBtn, style: .default, handler: { (action)in

            })
            alertVc.addAction(cancelAction)
            cancelAction.setTextColor(WHColorWithAlpha(colorStr: "007AFF", alpha: 0.6))
        }
        
        let okAction = UIAlertAction(title: confirmBtn, style: .default, handler: { (action)in

            handler(action)
        })
        alertVc.addAction(okAction)
        if textAlignLeft == true{
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.lineSpacing = 5.0
            let attributes = NSMutableAttributedString(string: message)
            attributes.yy_paragraphStyle = paragraphStyle
            attributes.yy_font = .systemFont(ofSize: 14)
            alertVc.setValue(attributes, forKey: "attributedMessage")
        }
        
        viewController.present(alertVc, animated:true, completion:nil)
    }
    func presentAlertVc(confirmBtn:String, message:String, title:String, cancelBtn:String?,textAlignLeft:Bool? = false, handler:@escaping(UIAlertAction) ->Void, cancelHandler:@escaping(UIAlertAction) ->Void,viewController:UIViewController) {
        let alertVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if cancelBtn != nil{
            let cancelAction = UIAlertAction(title: cancelBtn, style: .default, handler:{ (action)in

                cancelHandler(action)
          })
            alertVc.addAction(cancelAction)
            cancelAction.setTextColor(WHColorWithAlpha(colorStr: "007AFF", alpha: 0.6))
        }
        
        let okAction = UIAlertAction(title: confirmBtn, style: .default, handler: { (action)in

            handler(action)
        })
        alertVc.addAction(okAction)
        if textAlignLeft == true{
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.lineSpacing = 5.0
            let attributes = NSMutableAttributedString(string: message)
            attributes.yy_paragraphStyle = paragraphStyle
            attributes.yy_font = .systemFont(ofSize: 14)
            alertVc.setValue(attributes, forKey: "attributedMessage")
        }
        
        viewController.present(alertVc, animated:true, completion:nil)
    }
    func presentAlertVcNoAction(title:String, viewController:UIViewController) {
        let alertVc = UIAlertController(title: title, message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "确定", style: .cancel) { action in

        }
        alertVc.addAction(cancelAction)
        
        viewController.present(alertVc, animated:true, completion:nil)
    }
    
    func getWidthOfString(string:String,font:UIFont,height:CGFloat) -> CGFloat {
        let dict = NSDictionary.init(object: font, forKey: NSAttributedString.Key.font as NSCopying)
        
        let rect = (string as NSString).boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: height), options: [.truncatesLastVisibleLine,.usesLineFragmentOrigin,.usesFontLeading], attributes: dict as! [NSAttributedString.Key : Any], context: nil) as CGRect
        
        
        return rect.size.width
    }
    
    func getHeightOfString(string:String,font:UIFont,width:CGFloat) -> CGFloat {
        let dict = NSDictionary.init(object: font, forKey: NSAttributedString.Key.font as NSCopying)
        
        let rect = (string as NSString).boundingRect(with: CGSize.init(width: width, height: CGFloat.greatestFiniteMagnitude), options: [.truncatesLastVisibleLine,.usesLineFragmentOrigin,.usesFontLeading], attributes: dict as! [NSAttributedString.Key : Any], context: nil) as CGRect
        
        
        return rect.size.height
    }
    func fixOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        }
     
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let rect = CGRect(origin: .zero, size: image.size)
        image.draw(in: rect)
        let fixedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
     
        return fixedImage ?? image
    }

    //MARK: 自定义UIView的四个圆角
    func setRoundedCorners(view: UIView, topLeft: CGFloat, topRight: CGFloat, bottomRight: CGFloat, bottomLeft: CGFloat) {
        let path = UIBezierPath()
     
        // 左上角
        path.move(to: CGPoint(x: topLeft, y: 0))
        path.addLine(to: CGPoint(x: topLeft, y: topLeft))
        path.addLine(to: CGPoint(x: 0, y: topLeft))
     
        // 右上角
        path.move(to: CGPoint(x: view.bounds.width - topRight, y: 0))
        path.addLine(to: CGPoint(x: view.bounds.width, y: 0))
        path.addLine(to: CGPoint(x: view.bounds.width, y: topRight))
        path.addLine(to: CGPoint(x: view.bounds.width - topRight, y: topRight))
     
        // 右下角
        path.move(to: CGPoint(x: view.bounds.width - bottomRight, y: view.bounds.height))
        path.addLine(to: CGPoint(x: view.bounds.width, y: view.bounds.height))
        path.addLine(to: CGPoint(x: view.bounds.width, y: view.bounds.height - bottomRight))
        path.addLine(to: CGPoint(x: view.bounds.width - bottomRight, y: view.bounds.height - bottomRight))
     
        // 左下角
        path.move(to: CGPoint(x: bottomLeft, y: view.bounds.height))
        path.addLine(to: CGPoint(x: bottomLeft, y: view.bounds.height - bottomLeft))
        path.addLine(to: CGPoint(x: 0, y: view.bounds.height - bottomLeft))
     
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        view.layer.mask = shape
    }

    //MARK: - 判断是否为手机号
    func judgePhoneNumber (phoneNum:String?) -> Bool {
        let patternTemp = "^1[0-9]{10}$"
        if NSPredicate(format: "SELF MATCHES %@", patternTemp).evaluate(with: phoneNum) {
            return true
        }
        return false
    }
    func judgeEmail(email:String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            
        do {
            let regex = try NSRegularExpression(pattern: emailRegex)
            
            if regex.matches(in: email, range: NSRange(location: 0, length: email.count)).isEmpty == false {
                return true
            } else {
                return false
            }
        } catch {
            print("Error creating regular expression")
            return false
        }
    }
    func isMatch(_ regex: String, _ input: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[^A-Za-z0-9\\u4E00-\\u9FA5\(regex)]")
            let results = regex.matches(in: input, range: NSRange(input.startIndex..., in: input))
            return results.count > 0
        } catch {
            // 如果有错误，返回false，并处理错误（例如打印）
            print("Invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    func isMatchPattern(_ regex: String, _ input: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: input, range: NSRange(input.startIndex..., in: input))
            return results.count > 0
        } catch {
            // 如果有错误，返回false，并处理错误（例如打印）
            print("Invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    //是否安装APP
    func isInstallation(urlString:String?) -> Bool {
        let url = URL(string: urlString!)
        if url == nil {
            return false
        }
        if UIApplication.shared.canOpenURL(url!) {
            return true
        }
        return false
    }
    /// 检测是否开启联网
    func openNetWorkServiceWithBolck(action :@escaping ((Bool)->())) {
        let cellularData = CTCellularData()
        cellularData.cellularDataRestrictionDidUpdateNotifier = { (state) in
            if state == CTCellularDataRestrictedState.restrictedStateUnknown || state == CTCellularDataRestrictedState.notRestricted {
                action(true)
            } else {
                action(false)
            }
            cellularData.cellularDataRestrictionDidUpdateNotifier = nil
        }
//        let state = cellularData.restrictedState
//        if state == CTCellularDataRestrictedState.restrictedStateUnknown ||  state == CTCellularDataRestrictedState.notRestricted {
//            action(true)
//        } else {
//            action(false)
//        }
    }

    //MARK: - 限制手机输入11位
    @objc func phoneTextDidChange(sender:UITextField) {
        guard let _:UITextRange = sender.markedTextRange else {
            if (sender.text!as NSString).length > 11 {
                sender.text = (sender.text!as NSString).substring(to: 11)
            }
            return
        }
    }
    func deepCopy(view: UIView) -> UIView? {
        let data = NSKeyedArchiver.archivedData(withRootObject: view)
        let viewCopy = NSKeyedUnarchiver.unarchiveObject(with: data) as? UIView
        return viewCopy
    }
    //JSONString转换为字典
    func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        let jsonData:Data = jsonString.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }
    //JSONString转换为数组
    func getArrayFromJSONString(jsonString:String) ->NSArray{
        if jsonString == "" || jsonString.isBlank || !jsonString.contains("["){
            return []
        }
//        DLLog(message: "jsonString : \(jsonString)")
        let jsonData:Data = jsonString.data(using: .utf8)!
        let array = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if array != nil {
            return array as! NSArray
        }
        return array as! NSArray
    }
    
//    字典转换为JSONString
    func getJSONStringFromDictionary(dictionary:NSDictionary) -> String {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            print("无法解析出JSONString")
            return ""
        }
        let data : NSData! = try? JSONSerialization.data(withJSONObject: dictionary, options: []) as NSData?
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
    }
//    数组转换为JSONString
    func getJSONStringFromArray(array:NSArray) ->String{
          if !JSONSerialization.isValidJSONObject(array) {
               print("无法解析出JSONString")
               return""
          }
          let data :NSData! = try!JSONSerialization.data(withJSONObject: array, options: [])as  NSData?
          let JSONString = NSString(data: data as Data, encoding:String.Encoding.utf8.rawValue)
          return JSONString!as String
     }
    
    //导航栏高度
    func getNavigationBarHeight() -> CGFloat {
//        return getTopSafeAreaHeight()+64
        if isIpad(){
            return statusBarHeight + 56
        }
        return statusBarHeight + 44
    }
    //tabbar高度
    func getTabbarHeight() -> CGFloat {
        return getBottomSafeAreaHeight() + 49
//        return (statusBarHeight==44 ? 83 : 49)
    }
    //顶部的安全距离   不包括状态栏
    func getTopSafeAreaHeight() -> CGFloat {
        var topPadding = CGFloat(0)
        let scene = UIApplication.shared.connectedScenes.first
        guard let windowScene = scene as? UIWindowScene else { return 0 }
        guard let window = windowScene.windows.first else { return 0 }
        topPadding = window.safeAreaInsets.top
        return topPadding - 20
    }
    //底部的安全距离
    func getBottomSafeAreaHeight() -> CGFloat {
        var bottomPadding = CGFloat(0)
        
//        if #available(iOS 11.0, *) {
//            let window = UIApplication.shared.keyWindow
//            bottomPadding = window?.safeAreaInsets.bottom ?? 0
//        } else {
//            // Fallback on earlier versions
//        }
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else { return 0 }
            bottomPadding = window.safeAreaInsets.bottom
        } else if #available(iOS 11.0, *) {
            guard let window = UIApplication.shared.windows.first else { return 0 }
            bottomPadding = window.safeAreaInsets.bottom
        }
        return bottomPadding
//        return (getTabbarHeight() - 49)
    }
    /// 底部安全区高度
    static func safeDistanceBottom() -> CGFloat {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else { return 0 }
            return window.safeAreaInsets.bottom
        } else if #available(iOS 11.0, *) {
            guard let window = UIApplication.shared.windows.first else { return 0 }
            return window.safeAreaInsets.bottom
        }
        return 0;
    }

    func openUrl(urlString:String){
        if let url = URL(string: urlString) {
            //根据iOS系统版本，分别处理
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                })
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
//    func getCurrentController() -> UIViewController? {
//           guard let window = UIApplication.shared.windows.first else {
//               return nil
//           }
//           var tempView: UIView?
//           for subview in window.subviews.reversed() {
//               if subview.classForCoder.description() == "UILayoutContainerView" {
//                   tempView = subview
//                   break
//               }
//           }
//           
//           if tempView == nil {
//               tempView = window.subviews.last
//           }
//           
//           var nextResponder = tempView?.next
//           var next: Bool {
//               return !(nextResponder is UIViewController) || nextResponder is UINavigationController || nextResponder is UITabBarController
//           }
//
//           while next{
//               tempView = tempView?.subviews.first
//               if tempView == nil {
//                   return nil
//               }
//               nextResponder = tempView!.next
//           }
//           return nextResponder as? UIViewController
//       }
}

//MARK: 处理小组件点击进来的事件
extension WHBaseViewVC{
    @objc func dealsWidgetTapAction() {
//        self.presentAlertVcNoAction(title: "\(WidgetUtils().readMealsData())", viewController: self)
        if WidgetUtils().readMealsData() >= 0 && UserInfoModel.shared.token.count > 2{
            let vc = FoodsListNewVC()
            vc.sourceType = .logs
            self.navigationController?.pushViewController(vc, animated: true)
            WidgetMsgModel.shared.mealsIndex = WidgetUtils().readMealsData()
            WidgetUtils().saveMealsData(mealsIndex: -1)
        }else if WidgetMsgModel.shared.mealsIndex > 0 && UserInfoModel.shared.token.count > 2{
//        if WidgetMsgModel.shared.mealsIndex > 0 && UserInfoModel.shared.token.count > 2{
            DLLog(message: "dealsWidgetTapAction:\(WidgetMsgModel.shared.mealsIndex)  -- uid:\(UserInfoModel.shared.token)")
            let vc = FoodsListNewVC()
            vc.sourceType = .logs
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension WHBaseViewVC{
    func initNavi(titleStr:String,naviBgColor:UIColor? = .white,isWhite:Bool? = false){
        let naviView = UIView()
        view.addSubview(naviView)
        naviView.backgroundColor = naviBgColor
        naviView.isUserInteractionEnabled = true
        naviView.snp.makeConstraints { (frame) in
            frame.width.equalToSuperview()
            frame.height.equalTo(getNavigationBarHeight())
        }
        
        navigationView = naviView
        
        let bottomGap = 22 - kFitWidth(10)
        
        let backArrowImg = UIImageView()
        backArrowImg.isHidden = true
        naviView.addSubview(backArrowImg)
        
        backArrowImg.snp.makeConstraints { (frame) in
            frame.width.equalTo(kFitWidth(20))
            frame.height.equalTo(kFitWidth(20))
            frame.left.equalTo(kFitWidth(15))
            frame.centerY.lessThanOrEqualTo(statusBarHeight+kFitWidth(22))
//            frame.bottom.equalToSuperview().offset(-bottomGap)
        }
        backArrowImg.isUserInteractionEnabled = true
        naviBackImg = backArrowImg
        
        backView.backgroundColor = .clear
        naviView.addSubview(backView)
        backView.isHidden = true
        backView.isUserInteractionEnabled = true
        backView.snp.makeConstraints { (frame) in
            frame.width.height.equalTo(kFitWidth(50))
            frame.center.lessThanOrEqualTo(backArrowImg)
        }
        naviView.addSubview(backArrowButton)
        
        backArrowButton.snp.makeConstraints { make in
            make.width.height.equalTo(kFitWidth(44))
            make.top.equalTo(statusBarHeight)
            make.left.equalTo(kFitWidth(2))
        }
        
        let backArrowTap = UITapGestureRecognizer()
        backArrowTap.addTarget(self, action: #selector(backTapAction))
        backView.addGestureRecognizer(backArrowTap)
        
        let titleLabel = UILabel()
        naviView.addSubview(titleLabel)
        titleLabel.text = titleStr
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.snp.makeConstraints { (frame) in
            frame.centerY.equalTo(backArrowImg)
//            frame.left.equalTo(backArrowImg.snp.right).offset(kFitWidth(30))
            frame.centerX.lessThanOrEqualToSuperview()
        }
        naviTitleLabel = titleLabel
        
        if isWhite ?? false {
            backArrowImg.image = UIImage.init(named: "back_arrow_white_icon")
            titleLabel.textColor = .white
            backArrowButton.backImgView.setImgLocal(imgName: "back_arrow_white_icon")
            naviTitleLabel.textColor = .white
        }else{
            backArrowImg.image = UIImage.init(named: "back_arrow")
            titleLabel.textColor = WHColor_16(colorStr: "222222")
        }
    }
    
//    func createVCObjectFromString(className:String) -> UIViewController{
//        let nameSpace = Bundle.main.infoDictionary!["CFBundleExecutable"] as? String
//        let classType:AnyClass? = NSClassFromString(nameSpace! + "." + className)
//        let viewController = classType as! UIViewController.Type
//        
//        return viewController.init()
//    }
    func createVCObjectFromString(className:String) -> UIViewController?{
        guard let nameSpace = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String,
              let classType = NSClassFromString(nameSpace + "." + className) as? UIViewController.Type else {
            return nil
        }

        return classType.init()
    }
        
    
    func isPurnInt(string: String) -> Bool {
        let scan: Scanner = Scanner(string: string)

        var val:Int = 0
        return scan.scanInt(&val) && scan.isAtEnd
    }
}

//extension WHBaseViewVC:UIGestureRecognizerDelegate{
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if self.navigationController?.viewControllers.count == 1{
//            return false
//        }
//        return self.canEdgeBack
//    }
//}
