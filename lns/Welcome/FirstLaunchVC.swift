//
//  FirstLaunchVC.swift
//  lns
//
//  Created by Elavatine on 2025/8/28.
//

import UIKit
import SnapKit
import MCToast
import AuthenticationServices


private extension UIImage {
    /// Returns an image scaled to fill the target size using aspect fill.
    func aspectFill(to size: CGSize) -> UIImage? {
        let scale = max(size.width / self.size.width, size.height / self.size.height)
        let width = self.size.width * scale
        let height = self.size.height * scale
        let originX = (size.width - width) / 2.0
        let originY = (size.height - height) / 2.0

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: CGRect(x: originX, y: originY, width: width, height: height))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}


class FirstLaunchVC: WHBaseViewVC {
    private let skipAnimation: Bool
    private let forceNeedBuildPlanOnConfirm: Bool
    private var didApplyFinalState = false
    private var didTrackGuidanceV2StartPage = false
    private var isRequestingUserGroupInit = false
    private var hasLoadedUserGroupInit = false
    private var shouldContinueAfterUserGroupInit = false
    private var userGroupInitRequestStartTime: Date?
    private let userGroupInitRequestMaxWaitTime: TimeInterval = 30.0
    private var userGroupInitRequestGeneration = 0
    private var isHealthConfirmAlertShowing = false
    
    var firstLabelTopConstraint: Constraint?
    var firstLabelTwoTopConstraint: Constraint?
    public var generator = UIImpactFeedbackGenerator(style: .light)
    public var generatorMedium = UIImpactFeedbackGenerator(style: .medium)
    
    
    let damping = 0.8
    let velocity = 0.2
    private var hapticLink: CADisplayLink?
    private var hapticFired: [Int: Bool] = [:] // 0: 25%, 1: 55%
    
    init(skipAnimation: Bool = false, forceNeedBuildPlanOnConfirm: Bool = false) {
        self.skipAnimation = skipAnimation
        self.forceNeedBuildPlanOnConfirm = forceNeedBuildPlanOnConfirm
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.skipAnimation = false
        self.forceNeedBuildPlanOnConfirm = false
        super.init(coder: coder)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if skipAnimation {
            if !didApplyFinalState {
                showFinalState()
                didApplyFinalState = true
            }
        } else {
            showAnimation()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        if skipAnimation {
            showFinalState()
            didApplyFinalState = true
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(wechatLogin),
                                               name: Notification.Name(rawValue: "wechatLogin"),
                                               object: nil)
        requestUserGroupInitIfNeeded()
        
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(showAnimation))
//        self.view.addGestureRecognizer(tap)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    lazy var bgImgView: UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        img.setImgLocal(imgName: "launch_bg_img")
        img.contentMode = .scaleAspectFill
//        img.alpha = 0
        
        return img
    }()
    lazy var bgImgViewTwo: UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        img.setImgLocal(imgName: "launch_welcome_bg")
        img.contentMode = .scaleAspectFill
//        img.isUserInteractionEnabled = true
//        img.isHidden = true
        img.alpha = 0
        
        return img
    }()
    lazy var firstLabelOne: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.text = "欢迎你来到"
        lab.font = .systemFont(ofSize: 33, weight: .semibold)
        lab.textColor = .white
        lab.textAlignment = .center
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.alpha = 0
        return lab
    }()

    lazy var firstLabelTwo: LineHeightLabel = {
        let lab = LineHeightLabel()
//        lab.text = "这是由健身人，\n为健身人打造的饮食工具" // 目标文案
        lab.text = "你的营养教练，\n让增肌减脂更可控"
        lab.font = .systemFont(ofSize: 24, weight: .semibold) // 目标样式
        lab.textColor = .white
        lab.textAlignment = .left
        lab.adjustsFontSizeToFitWidth = true
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.alpha = 0 // 初始隐藏
        return lab
    }()

    lazy var firstLogoImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "main_top_logo_cj")
        return img
    }()
    lazy var secondLogoImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "main_top_logo_cj")
        img.alpha = 0
        return img
    }()
    
    lazy var secondLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
//        lab.text = "我们会将实测有效的功能，\n全部开放供你使用，\n助你高效实现目标" // 目标文案
        lab.text = "你的营养教练，\n让增肌减脂更可控"
        lab.font = .systemFont(ofSize: 20, weight: .medium) // 目标样式
        lab.textColor = .white
        lab.textAlignment = .left
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.alpha = 0 // 初始隐藏
        return lab
    }()
    lazy var confirmButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.layer.cornerRadius = kFitWidth(27.5)
        btn.clipsToBounds = true
        btn.setTitle("开始", for: .normal)
//        btn.setTitle("我准备好了", for: .normal)
        btn.setTitleColor(WHColor_16(colorStr: "0F1214"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.layer.opacity = 0
//        btn.isUserInteractionEnabled = false
        
        btn.enablePressEffect()
        
        btn.addTarget(self, action: #selector(startBtnAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var loginLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 1
        lab.textAlignment = .center
        lab.isUserInteractionEnabled = false
        lab.layer.opacity = 0
        let allText = "已有账号？去登录"
        let attr = NSMutableAttributedString(string: allText)
        attr.addAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], range: NSRange(location: 0, length: (allText as NSString).length))
        if let range = allText.range(of: "登录") {
            attr.addAttributes([
                .foregroundColor: UIColor.THEME
            ], range: NSRange(range, in: allText))
        }
        lab.attributedText = attr
        let tap = UITapGestureRecognizer(target: self, action: #selector(loginAction))
        lab.addGestureRecognizer(tap)
        return lab
    }()
    lazy var loginAlertVm: LoginAlertVm = {
        let vm = LoginAlertVm(frame: .zero)
        vm.weChatLoginBlock = {
            WXUtil().wxLogin()
        }
        vm.appleLoginBlock = { [weak self] in
            guard let self = self else { return }
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
        vm.phoneLoginBlock = { [weak self] in
            guard let self = self else { return }
            self.loginAlertVm.hiddenLoginView()
            let vc = LoginVC()
            if let navigationController = self.navigationController {
                navigationController.pushViewController(vc, animated: true)
            } else {
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }
        return vm
    }()
    lazy var notRegistVm: NotRegistTipsVM = {
        let vm = NotRegistTipsVM(frame: .zero)
        return vm
    }()
}

extension FirstLaunchVC{
    private func fadeInConfirmButton(duration: TimeInterval = 0.55,
                                     delay: TimeInterval = 0,
                                     completion: ((Bool) -> Void)? = nil) {
        confirmButton.layer.removeAllAnimations()
        confirmButton.layer.opacity = 0
        loginLabel.layer.removeAllAnimations()
        loginLabel.layer.opacity = 0
        loginLabel.isUserInteractionEnabled = false
//        confirmButton.isUserInteractionEnabled = true
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//            self.confirmButton.isUserInteractionEnabled = true
//        }

        let delayT = 0.5//delay
        UIView.animate(withDuration: duration,
                       delay: delayT,
                       options: [.curveEaseInOut, .beginFromCurrentState]) {
            self.confirmButton.layer.opacity = 1
            self.loginLabel.layer.opacity = 1
        } completion: { finished in
            self.loginLabel.isUserInteractionEnabled = true
            completion?(finished)
        }
    }
    
    private func showFinalState() {
        view.layoutIfNeeded()

        bgImgView.alpha = 0
        bgImgView.isHidden = true

        bgImgViewTwo.alpha = 1
        bgImgViewTwo.isHidden = false
        bgImgViewTwo.isUserInteractionEnabled = true

        firstLabelOne.alpha = 0
        firstLabelOne.isHidden = true
        firstLabelTwo.alpha = 0
        firstLabelTwo.isHidden = true
        firstLogoImgView.alpha = 0
        firstLogoImgView.isHidden = true
        firstLabelOne.transform = .identity
        firstLogoImgView.transform = .identity

        secondLogoImgView.alpha = 1
        secondLabel.alpha = 1
        fadeInConfirmButton(duration: 0.75, delay: 0.75) { _ in
            self.trackGuidanceV2StartPageIfNeeded()
        }
    }

    @objc func showAnimation() {
        generator.prepare()
        generatorMedium.prepare()
        firstLabelTwoTopConstraint?.update(offset: 0)
        firstLabelTwo.alpha = 0
        loginLabel.layer.opacity = 0
        loginLabel.isUserInteractionEnabled = false
        firstLabelOne.snp.remakeConstraints { make in
            self.firstLabelTopConstraint = make.centerY.equalToSuperview().constraint
            make.centerX.equalToSuperview()
            make.left.equalTo(kFitWidth(54))
            make.right.equalTo(kFitWidth(-54))
        }
        firstLogoImgView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(firstLabelOne.snp.bottom).offset(kFitWidth(27))
        }
        self.view.layoutIfNeeded()
        firstLabelOne.text = "欢迎你来到"
        firstLabelOne.textAlignment = .center
        firstLogoImgView.isHidden = false

        self.firstLabelOne.transform = CGAffineTransform(scaleX: 0, y: 0)
        self.firstLogoImgView.transform = CGAffineTransform(scaleX: 0, y: 0)
        self.firstLabelOne.alpha = 0
        self.firstLogoImgView.alpha = 0
        let appearTiming = UISpringTimingParameters(mass: 0.9,
                                                    stiffness: 210,
                                                    damping: 18,
                                                    initialVelocity: CGVector(dx: 0, dy: 9))
        let appearAnimator = UIViewPropertyAnimator(duration: 0, timingParameters: appearTiming)
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
//            self.generator.impactOccurred(intensity: 1)
            self.generatorMedium.impactOccurred(intensity: 1)
            self.firstLabelOne.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.firstLogoImgView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.firstLabelOne.alpha = 1
            self.firstLogoImgView.alpha = 1
        }) { _ in
            self.generator.impactOccurred(intensity: 0.8)
            UIView.animate(withDuration: 0.1, animations: {
                self.firstLabelOne.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                self.firstLogoImgView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            }) { _ in
                self.generator.impactOccurred(intensity: 0.65)
                UIView.animate(withDuration: 0.1, animations: {
                    self.firstLabelOne.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
                    self.firstLogoImgView.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
                }) { _ in
                    self.generator.impactOccurred(intensity: 0.5)
                    UIView.animate(withDuration: 0.1, animations: {
                        self.firstLabelOne.transform = CGAffineTransform(scaleX: 0.99, y: 0.99)
                        self.firstLogoImgView.transform = CGAffineTransform(scaleX: 0.99, y: 0.99)
                    }) { _ in
                        self.generator.impactOccurred(intensity: 0.2)
                        UIView.animate(withDuration: 0.1, animations: {
                            self.firstLabelOne.transform = .identity
                            self.firstLogoImgView.transform = .identity
                        }) { _ in
                            // 原来你在多段动画最后做交叉淡化的地方，改成：
                            self.moveTitleToTopWithBounce()
//                            self.moveTitleToTopWithBounceOther()

//                            // 先将文本移动到顶部位置
//                            self.firstLabelOne.snp.remakeConstraints { make in
//                                self.firstLabelTopConstraint = make.top.equalTo(kFitWidth(152)-kFitWidth(5)).constraint
//                                make.centerX.equalToSuperview()
//                                make.left.equalTo(kFitWidth(54))
//                                make.right.equalTo(kFitWidth(-54))
//                            }
//                            UIView.animate(withDuration: 0.24, delay: 0.2, options: .curveEaseInOut, animations: {
//                                self.generator.impactOccurred(intensity: 0.99)
//                                self.view.layoutIfNeeded()
//                            }){ _ in
//                                // 先将文本移动到顶部位置
//                                self.firstLabelOne.snp.remakeConstraints { make in
//                                    self.firstLabelTopConstraint = make.top.equalTo(kFitWidth(152)+kFitWidth(3.5)).constraint
//                                    make.centerX.equalToSuperview()
//                                    make.left.equalTo(kFitWidth(54))
//                                    make.right.equalTo(kFitWidth(-54))
//                                }
//                                UIView.animate(withDuration: 0.15, delay: 0.05, options: .curveEaseOut, animations: {
//                                    self.generator.impactOccurred(intensity: 0.99)
//                                    self.view.layoutIfNeeded()
//                                }){ _ in
//                                    self.firstLabelOne.snp.remakeConstraints { make in
//                                        self.firstLabelTopConstraint = make.top.equalTo(kFitWidth(152)-kFitWidth(1.2)).constraint
//                                        make.centerX.equalToSuperview()
//                                        make.left.equalTo(kFitWidth(54))
//                                        make.right.equalTo(kFitWidth(-54))
//                                    }
//                                    UIView.animate(withDuration: 0.05, delay: 0, options: .curveEaseInOut, animations: {
//                                        self.generator.impactOccurred(intensity: 0.8)
//                                        self.view.layoutIfNeeded()
//                                    }){ _ in
//                                        self.firstLabelOne.snp.remakeConstraints { make in
//                                            self.firstLabelTopConstraint = make.top.equalTo(kFitWidth(152)).constraint
//                                            make.centerX.equalToSuperview()
//                                            make.left.equalTo(kFitWidth(54))
//                                            make.right.equalTo(kFitWidth(-54))
//                                        }
//                                        UIView.animate(withDuration: 0.02, delay: 0, options: .curveEaseInOut, animations: {
//                                            self.generator.impactOccurred(intensity: 0.8)
//                                            self.view.layoutIfNeeded()
//                                        }){ _ in
//                                            UIView.animate(withDuration: 0.6, delay: 0.75, options: .curveEaseInOut, animations: {
//                                                // 位移
//                                                self.firstLabelTwoTopConstraint?.update(offset: kFitWidth(20))
//                                                self.view.layoutIfNeeded()
//                                                // 文字渐变（A->B 交叉淡化）
////                                                self.firstLabelOne.transform = CGAffineTransform(scaleX: 5, y: 3)
////                                                self.firstLogoImgView.transform = CGAffineTransform(scaleX: 5, y: 3)
//                                                // 让文字向上放大、logo 向下放大，避免重合
//                                                let labelTransform = CGAffineTransform(scaleX: 5, y: 5)
//                                                    .translatedBy(x: 0, y: -self.firstLabelOne.bounds.height*0.5)
//                                                let logoTransform = CGAffineTransform(scaleX: 5, y: 5)
//                                                    .translatedBy(x: 0, y: self.firstLogoImgView.bounds.height*0.5)
//                                                self.firstLabelOne.transform = labelTransform
//                                                self.firstLogoImgView.transform = logoTransform
//                                                self.firstLabelOne.alpha = 0
//                                                self.firstLabelTwo.alpha = 1
//                                                // logo 淡出
//                                                self.firstLogoImgView.alpha = 0
//                                            }, completion: { _ in
//                                                self.firstLogoImgView.isHidden = true
//                                                self.firstLabelOne.isHidden = true
//                                                
//                                                //1、缩小动画
////                                                DispatchQueue.main.asyncAfter(deadline: .now()+0.75, execute: {
////                                                    let finalFrame = CGRect(origin: self.bgImgView.center, size: .zero)
////                                                    self.animateBgImgView(to: finalFrame)
////                                                })
//                                                //2、背景矩阵方块显示
////                                                self.revealBackgroundWithTiles()
//                                                //3、背景淡化
//                                                self.animateBgImgViewEaseIn()
//                                            })
//                                        }
//                                    }
//                                }
//                            }
                        }
                    }
                }
            }
        }
    }
    func animateLableTwo() {
        UIView.animate(withDuration: 0.6, delay: 0.75, options: .curveEaseInOut, animations: {
            // 位移
            self.firstLabelTwoTopConstraint?.update(offset: kFitWidth(20))
            self.view.layoutIfNeeded()
            // 文字渐变（A->B 交叉淡化）
//                                                self.firstLabelOne.transform = CGAffineTransform(scaleX: 5, y: 3)
//                                                self.firstLogoImgView.transform = CGAffineTransform(scaleX: 5, y: 3)
            // 让文字向上放大、logo 向下放大，避免重合
            let labelTransform = CGAffineTransform(scaleX: 5, y: 5)
                .translatedBy(x: 0, y: -self.firstLabelOne.bounds.height*0.5)
            let logoTransform = CGAffineTransform(scaleX: 5, y: 5)
                .translatedBy(x: 0, y: self.firstLogoImgView.bounds.height*0.5)
            self.firstLabelOne.transform = labelTransform
            self.firstLogoImgView.transform = logoTransform
            self.firstLabelOne.alpha = 0
            self.firstLabelTwo.alpha = 1
            // logo 淡出
            self.firstLogoImgView.alpha = 0
        }, completion: { _ in
            self.firstLogoImgView.isHidden = true
            self.firstLabelOne.isHidden = true
            
            //1、缩小动画
//                                                DispatchQueue.main.asyncAfter(deadline: .now()+0.75, execute: {
//                                                    let finalFrame = CGRect(origin: self.bgImgView.center, size: .zero)
//                                                    self.animateBgImgView(to: finalFrame)
//                                                })
            //2、背景矩阵方块显示
//                                                self.revealBackgroundWithTiles()
            //3、背景淡化
            self.animateBgImgViewEaseIn()
        })
    }
    private func moveTitleToTopWithBounce() {
        // 目标 top，保持你原先的数值
        let targetTop = kFitWidth(152)

        // 先把当前布局固定住，作为弹跳动画的初始状态
        self.view.layoutIfNeeded()

//         一次性把标题约束改到最终位置（不做多次微调）
        //将标题约束改到目标位置，后续用轻微的 offset 来实现 3 次回弹
        self.firstLabelOne.snp.remakeConstraints { make in
            self.firstLabelTopConstraint = make.top.equalTo(targetTop).constraint
            make.centerX.equalToSuperview()
            make.left.equalTo(kFitWidth(54))
            make.right.equalTo(kFitWidth(-54))
        }

        // 使用真实弹簧曲线，阻尼 < 1 才会自然回弹
        let spring = UISpringTimingParameters(
            mass: 1.0,              // 与你前面出现动画的设定保持一致
            stiffness: 210,         // 刚度：越大回到终点越快
            damping: 14,            // 阻尼：稍小于临界阻尼会产生一到两次回弹
            initialVelocity: CGVector(dx: 0, dy: 1.2) // 初速度，正值代表向下
        )
        let animator = UIViewPropertyAnimator(duration: 0.8, timingParameters: spring)

        animator.addAnimations {
            // 让布局变化跟随弹簧
            self.view.layoutIfNeeded()
        }

        // 在首次接近终点时给一点触感（用延时比而不是绝对时间，跟随曲线进度）
//        animator.addAnimations({
//            self.generator.impactOccurred(intensity: 1.0)
//        }, delayFactor: 0.25)
//
//        // 回弹后再轻一点
//        animator.addAnimations({
//            self.generator.impactOccurred(intensity: 0.5)
//        }, delayFactor: 0.55)

        animator.addCompletion { _ in
            // 完成位移动画后，进入下一幕（文案与 logo 的交叉淡化）
            self.crossfadeToSecondCopy()
        }

        animator.startAnimation()
        generator.prepare()
        generatorMedium.prepare()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
            self.generatorMedium.impactOccurred(intensity: 0.8)
        })
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
            self.generator.impactOccurred(intensity: 0.6)
        })
        DispatchQueue.main.asyncAfter(deadline: .now()+0.4, execute: {
            self.generator.impactOccurred(intensity: 0.4)
        })
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            self.generator.impactOccurred(intensity: 0.2)
        })
    }
    private func moveTitleToTopWithBounceOther() {
        // 目标 top，保持你原先的数值
        let targetTop = kFitWidth(152)
        let firstOvershoot = targetTop - kFitWidth(8)
        let secondOvershoot = targetTop + kFitWidth(4)
        let thirdOvershoot = targetTop - kFitWidth(2)
        generator.prepare()
        generatorMedium.prepare()

        // 先把当前布局固定住，作为弹跳动画的初始状态
        self.view.layoutIfNeeded()

//         一次性把标题约束改到最终位置（不做多次微调）
        //将标题约束改到目标位置，后续用轻微的 offset 来实现 3 次回弹
        self.firstLabelOne.snp.remakeConstraints { make in
            self.firstLabelTopConstraint = make.top.equalTo(targetTop).constraint
            make.centerX.equalToSuperview()
            make.left.equalTo(kFitWidth(54))
            make.right.equalTo(kFitWidth(-54))
        }

        DispatchQueue.main.asyncAfter(deadline: .now()+0.35, execute: {
            self.generatorMedium.impactOccurred(intensity: 0.8)
        })
        DispatchQueue.main.asyncAfter(deadline: .now()+0.6, execute: {
            self.generator.impactOccurred(intensity: 0.6)
        })
        DispatchQueue.main.asyncAfter(deadline: .now()+0.8, execute: {
            self.generator.impactOccurred(intensity: 0.4)
        })
        DispatchQueue.main.asyncAfter(deadline: .now()+0.9, execute: {
            self.generator.impactOccurred(intensity: 0.2)
        })
        UIView.animateKeyframes(withDuration: 0.9, delay: 0, options: [.calculationModeCubic], animations: {
            // 第一次回弹：略微超过目标位置
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.35) {
                self.firstLabelTopConstraint?.update(offset: firstOvershoot)
                self.view.layoutIfNeeded()
//                self.generatorMedium.impactOccurred(intensity: 0.8)
            }

            // 第二次回弹：向下轻触
            UIView.addKeyframe(withRelativeStartTime: 0.35, relativeDuration: 0.25) {
                self.firstLabelTopConstraint?.update(offset: secondOvershoot)
                self.view.layoutIfNeeded()
//                self.generator.impactOccurred(intensity: 0.6)
            }

            // 第三次回弹：最终收敛前的微调
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.2) {
                self.firstLabelTopConstraint?.update(offset: thirdOvershoot)
                self.view.layoutIfNeeded()
//                self.generator.impactOccurred(intensity: 0.4)
            }

            // 收尾：稳定在最终位置
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.1) {
                self.firstLabelTopConstraint?.update(offset: targetTop)
                self.view.layoutIfNeeded()
            }
        }, completion: { _ in
            // 完成位移动画后，进入下一幕（文案与 logo 的交叉淡化）
            self.crossfadeToSecondCopy()
        })
    }

    private func crossfadeToSecondCopy() {
        // 让第二段文案整体向下“落位”一些
        self.firstLabelTwoTopConstraint?.update(offset: kFitWidth(20))
        self.view.layoutIfNeeded()

        // A->B 交叉 + 轻微分离缩放，避免重叠
        let fade = UIViewPropertyAnimator(duration: 0.6, curve: .easeInOut)
        fade.addAnimations {
            // 让文字向上放大、logo 向下放大，避免重合
            let labelTransform = CGAffineTransform(scaleX: 5, y: 5)
                .translatedBy(x: 0, y: -self.firstLabelOne.bounds.height * 0.5)
            let logoTransform = CGAffineTransform(scaleX: 5, y: 5)
                .translatedBy(x: 0, y:  self.firstLogoImgView.bounds.height * 0.5)

            self.firstLabelOne.transform = labelTransform
            self.firstLogoImgView.transform = logoTransform

            self.firstLabelOne.alpha = 0
            self.firstLogoImgView.alpha = 0
            self.firstLabelTwo.alpha = 1
            self.view.layoutIfNeeded()
        }
        fade.addCompletion { _ in
            self.firstLogoImgView.isHidden = true
            self.firstLabelOne.isHidden = true
            self.animateBgImgViewEaseIn() // 保留你原先的背景切换
        }
        fade.startAnimation()
    }

    //淡入淡出
    private func animateBgImgViewEaseIn(){
        UIView.animate(withDuration: 1.5, delay: 0.95, options: .curveEaseOut, animations: {
            self.bgImgView.alpha = 0
            self.bgImgViewTwo.alpha = 1
        }, completion: { _ in
            self.bgImgView.isHidden = true
            UIView.animate(withDuration: 0.25, delay: 0) {
                self.secondLogoImgView.alpha = 1
                self.secondLabel.alpha = 1
            }
//            UIView.animate(withDuration: 0.35, delay: 0.25) {
//                self.secondLabel.alpha = 1
//            }
            self.fadeInConfirmButton(duration: 0.55, delay: 2.0) { _ in
                self.bgImgViewTwo.isUserInteractionEnabled = true
                self.trackGuidanceV2StartPageIfNeeded()
            }
        })
    }
    //背景图片缩小
    private func animateBgImgView(to finalFrame: CGRect) {
        self.bgImgView.layer.cornerRadius = kFitWidth(32)
        self.bgImgView.clipsToBounds = true
        UIView.animate(withDuration: 0.75, delay: 0, options: .curveEaseOut, animations: {
            // 组合变换：先旋转再缩放（等比缩放时先后顺序影响不大）
            let rotate = CGAffineTransform(rotationAngle: -.pi * 0.06)
            let scale  = isIpad() ? CGAffineTransform(scaleX: 0.05, y: 0.05) : CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.bgImgView.transform = rotate.concatenating(scale)
            self.bgImgView.center = CGPoint.init(x: SCREEN_WIDHT*0.467, y: SCREEN_HEIGHT*0.368)
            self.bgImgView.alpha = isIpad() ? 0 : 0.25
            self.bgImgViewTwo.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0) {
                self.secondLogoImgView.alpha = 1
                self.bgImgView.alpha = 0
            }
            UIView.animate(withDuration: 0.35, delay: 0.25) {
                self.secondLabel.alpha = 1
//                self.bgImgView.alpha = 0
            }
            self.fadeInConfirmButton(duration: 0.55, delay: 1.5) { _ in
                self.bgImgViewTwo.isUserInteractionEnabled = true
                self.bgImgView.isHidden = true
                self.trackGuidanceV2StartPageIfNeeded()
            }
        })
    }
    //背景图片矩阵显示
    private func revealBackgroundWithTiles(rows: Int = 10, cols: Int = 10) {
//        guard let image = self.bgImgViewTwo.image else { return }
//        let tileWidth = self.bgImgView.bounds.width / CGFloat(cols)
//        let tileHeight = self.bgImgView.bounds.height / CGFloat(rows)
        
        guard let rawImage = self.bgImgViewTwo.image else { return }
        let targetSize = self.bgImgView.bounds.size
        guard let image = rawImage.aspectFill(to: targetSize) else { return }
        let tileWidth = targetSize.width / CGFloat(cols)
        let tileHeight = targetSize.height / CGFloat(rows)

        var tiles: [UIImageView] = []

        for row in 0..<rows {
            for col in 0..<cols {
                let cropRect = CGRect(x: CGFloat(col) * tileWidth * image.scale,
                                      y: CGFloat(row) * tileHeight * image.scale,
                                      width: tileWidth * image.scale,
                                      height: tileHeight * image.scale)
                if let cgImg = image.cgImage?.cropping(to: cropRect) {
                    let part = UIImage(cgImage: cgImg, scale: image.scale, orientation: image.imageOrientation)
                    let tileView = UIImageView(image: part)
                    tileView.frame = CGRect(x: CGFloat(col) * tileWidth,
                                            y: CGFloat(row) * tileHeight,
                                            width: tileWidth,
                                            height: tileHeight)
                    tileView.alpha = 0
                    self.bgImgView.insertSubview(tileView, at: 0)
                    tiles.append(tileView)
                }
            }
        }
        UIView.animate(withDuration: 0.5, delay: 1, options: [], animations: {
            self.firstLabelTwo.alpha = 0
        }, completion: nil)
        
        let shuffled = tiles.shuffled()
        for (index, tile) in shuffled.enumerated() {
            let delay = 0.02 * Double(index)
            UIView.animate(withDuration: 0.3, delay: delay, options: [], animations: {
                tile.alpha = 1
            }, completion: nil)
        }

        let totalDelay = 0.3 + 0.02 * Double(shuffled.count)
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
            self.bgImgViewTwo.isHidden = false
            self.bgImgViewTwo.alpha = 1
            self.bgImgView.isHidden = true
            tiles.forEach { $0.removeFromSuperview() }
        }
    }
}

extension FirstLaunchVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            DLLog(message: "appleIDCredential:\(appleIDCredential.description)")
            DLLog(message: "userIdentifier:\(userIdentifier)")
            UserInfoModel.shared.appleId = "\(userIdentifier)"
            sendAppleIdLoginRequest()
        case let passwordCredential as ASPasswordCredential:
            DLLog(message: "\(passwordCredential.description)")
        default:
            break
        }
    }

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        DLLog(message: "apple authorization error:\(error)")
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

extension FirstLaunchVC{
    func initUI() {
        view.addSubview(bgImgViewTwo)
        view.addSubview(bgImgView)
        
        bgImgView.addSubview(firstLabelOne)
        bgImgView.addSubview(firstLabelTwo)
        bgImgView.addSubview(firstLogoImgView)
        
        bgImgViewTwo.addSubview(secondLogoImgView)
        bgImgViewTwo.addSubview(secondLabel)
        bgImgViewTwo.addSubview(confirmButton)
        bgImgViewTwo.addSubview(loginLabel)
        
        view.addSubview(loginAlertVm)
        view.addSubview(notRegistVm)
        
        setConstrait()
//        firstLabelOne.transform = CGAffineTransform(scaleX: 5, y: 5)
//        firstLogoImgView.transform = CGAffineTransform(scaleX: 5, y: 5)
        firstLabelOne.transform = CGAffineTransform(scaleX: 0, y: 0)
        firstLogoImgView.transform = CGAffineTransform(scaleX: 0, y: 0)
        firstLabelOne.alpha = 0
        firstLogoImgView.alpha = 0
    }
    func setConstrait() {
        firstLabelOne.snp.makeConstraints { make in
//            make.top.equalTo(kFitWidth(152))
//            self.firstLabelTopConstraint = make.top.equalTo(kFitWidth(152)).constraint
            self.firstLabelTopConstraint = make.centerY.equalToSuperview().constraint
            make.centerX.equalToSuperview()
            make.left.equalTo(kFitWidth(54))
            make.right.equalTo(kFitWidth(-54))
        }
        firstLabelTwo.snp.makeConstraints { make in
            // 与 one 完全一致的布局，让两者“绑在一起移动”
//            make.top.equalTo(self.firstLabelOne) // 关键：同一条约束
            self.firstLabelTwoTopConstraint = make.top.equalTo(self.firstLabelOne).offset(0).constraint
            make.centerX.equalToSuperview()
            make.left.equalTo(kFitWidth(54))
            make.right.equalTo(kFitWidth(-16))
        }
        firstLogoImgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(firstLabelOne.snp.bottom).offset(kFitWidth(17))
        }
        secondLogoImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(25))
            make.top.equalTo(kFitWidth(516.5))
            make.width.equalTo(kFitWidth(115))
            make.height.equalTo(kFitWidth(20))
        }
        secondLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(25))
            make.top.equalTo(kFitWidth(556.5))
        }
        confirmButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(25))
            make.right.equalTo(kFitWidth(-25))
            make.top.equalTo(kFitWidth(657.5))
            make.height.equalTo(kFitWidth(55))
        }
        loginLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(kFitWidth(745))
        }
    }
}

extension FirstLaunchVC{
    @objc func startBtnAction() {
        trackIOS0805GuidanceV2StartButton()
        openNetWorkServiceWithBolck { [weak self] netConnect in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard netConnect else {
                    self.presentNetworkPermissionAlert()
                    return
                }
                guard self.hasLoadedUserGroupInit else {
                    self.requestUserGroupInitIfNeeded(showLoadingToast: true)
                    return
                }
                self.showHealthConfirmAndContinue()
            }
        }
    }

    @objc private func loginAction() {
        openNetWorkServiceWithBolck { [weak self] netConnect in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if netConnect {
                    self.loginAlertVm.showLoginView()
                } else {
                    self.presentNetworkPermissionAlert()
                }
            }
        }
    }

    @objc private func wechatLogin() {
        if UserInfoModel.shared.isRegist == "yes" {
            if UserInfoModel.shared.state == 1 {
                completeLoginSuccessAndEnterApp()
            } else {
                presentAlertVcNoAction(title: "账户已申请注销！", viewController: self)
            }
        } else {
            notRegistVm.showView()
        }
    }

    private func sendAppleIdLoginRequest() {
        MCToast.mc_loading()
        let param = ["appleid": "\(UserInfoModel.shared.appleId)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_Login_appid,
                                          parameters: param as [String: AnyObject],
                                          isNeedToast: true,
                                          vc: self) { responseObject in
            DLLog(message: "\(responseObject)")

            let dataEncString = responseObject["data"] as? String ?? ""
            let dataDecString = AESEncyptUtil.aesDecrypt(hexString: dataEncString)
            let dataObj = self.getDictionaryFromJSONString(jsonString: dataDecString ?? "")
            DLLog(message: "sendAppleIdLoginRequest:\(dataObj)")

            UserInfoModel.shared.isRegist = dataObj["registered"] as? String ?? ""
            if dataObj["registered"] as? String ?? "" == "yes" {
                if dataObj.stringValueForKey(key: "state") == "1" {
                    UserInfoModel.shared.token = dataObj["token"] as? String ?? ""
                    UserInfoModel.shared.uId = dataObj["uid"] as? String ?? ""

                    UserDefaults.standard.setValue("\(dataObj["token"] as? String ?? "")", forKey: token)
                    UserDefaults.standard.setValue("\(dataObj["uid"] as? String ?? "")", forKey: userId)

                    WidgetUtils().saveUserInfo(uId: "\(dataObj["uid"] as? String ?? "")",
                                               uToken: "\(dataObj["token"] as? String ?? "")")
                    ElaProPriceVM.preloadLoggedInProductSnapshots()
                    self.completeLoginSuccessAndEnterApp()
                } else {
                    self.presentAlertVcNoAction(title: "账户已申请注销。", viewController: self)
                }
            } else {
                self.notRegistVm.showView()
            }
        }
    }
    
    private func showHealthConfirmAndContinue() {
//        ElaHealthDataConfirmAlert.show { [weak self] in
//            guard let self = self else { return }
            self.trackIOS0805GuidanceV2BeforeStartAgree()
            UserDefaults.standard.setValue("1", forKey: isLaunchWelcome)
            self.showGuide0820AndContinue()
//        } onExit: { [weak self] in
//            self?.trackIOS0805GuidanceV2BeforeStartExit()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                exit(0)
//            }
//        } onShow: { [weak self] in
//            self?.isHealthConfirmAlertShowing = true
//            self?.trackIOS0805GuidanceV2BeforeStartAlert()
//        } onDismiss: { [weak self] in
//            self?.isHealthConfirmAlertShowing = false
//        }
    }

    private func showGuide0820AndContinue() {
        if Guide0820ProgressStorage.shouldResumeGuide0820 {
            let resumeViewControllers = Guide0820StartVC.makeResumeViewControllers(includingLaunchEntry: false)
            if let navigationController = navigationController {
                navigationController.setViewControllers([self] + resumeViewControllers, animated: true)
            } else {
                let nav = UINavigationController()
                nav.setViewControllers(resumeViewControllers, animated: false)
                nav.setNavigationBarHidden(true, animated: false)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: true)
            }
            return
        }

        let guideVC = Guide0820VC()
        guideVC.finishBlock = { [weak guideVC] in
            guard let guideVC = guideVC else { return }
            let startVC = Guide0820StartVC()
            if let navigationController = guideVC.navigationController {
                navigationController.pushViewController(startVC, animated: true)
            } else {
                startVC.modalPresentationStyle = .fullScreen
                guideVC.present(startVC, animated: true)
            }
        }

        if let navigationController = navigationController {
            navigationController.pushViewController(guideVC, animated: true)
        } else {
            guideVC.modalPresentationStyle = .fullScreen
            present(guideVC, animated: true)
        }
    }

    @objc private func appDidEnterBackground() {
        guard isHealthConfirmAlertShowing else { return }
        trackIOS0805GuidanceV2BeforeStartBackground()
    }

    private func presentNetworkPermissionAlert() {
        presentAlertVc(confirmBtn: "设置",
                       message: "可以在“设置->App->无线数据”中开启“无线数据”，连接网络后才能流畅使用。",
                       title: "“Elavatine”已关闭网络权限",
                       cancelBtn: "取消",
                       handler: { [weak self] _ in
            self?.openUrl(urlString: UIApplication.openSettingsURLString)
        }, viewController: self)
    }

    private func requestUserGroupInitIfNeeded(showLoadingToast: Bool = false) {
        guard !hasLoadedUserGroupInit else {
            if showLoadingToast {
                showHealthConfirmAndContinue()
            }
            return
        }
        guard !isRequestingUserGroupInit else {
            if showLoadingToast, shouldRestartUserGroupInitRequest() {
                DLLog(message: "[UserGroupInit][FirstLaunch] request stale, restart")
                isRequestingUserGroupInit = false
                shouldContinueAfterUserGroupInit = false
                userGroupInitRequestStartTime = nil
                requestUserGroupInitIfNeeded(showLoadingToast: true)
                return
            }
            if showLoadingToast {
                shouldContinueAfterUserGroupInit = true
            }
            return
        }
        isRequestingUserGroupInit = true
        userGroupInitRequestStartTime = Date()
        userGroupInitRequestGeneration += 1
        let requestGeneration = userGroupInitRequestGeneration
        shouldContinueAfterUserGroupInit = showLoadingToast
        WHNetworkUtil.shareManager().POST(urlString: URL_user_group_init, parameters: nil) { [weak self] responseObject in
            guard let self = self else { return }
            guard self.userGroupInitRequestGeneration == requestGeneration else {
                DLLog(message: "[UserGroupInit][FirstLaunch] ignore stale success")
                return
            }
            self.isRequestingUserGroupInit = false
            self.userGroupInitRequestStartTime = nil
            let shouldContinue = self.shouldContinueAfterUserGroupInit
            self.shouldContinueAfterUserGroupInit = false
            let code = responseObject["code"] as? Int ?? -1
            let dataObj: NSDictionary
            if code == 200 {
                let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
                dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            } else {
                dataObj = NSDictionary()
            }
            self.applyUserGroupInitData(dataObj)
            self.hasLoadedUserGroupInit = true
            DLLog(message: [
                "tag": "[UserGroupInit][FirstLaunch] URL_user_group_init response",
                "code": code,
                "dataObj": dataObj,
                "rawResponse": responseObject
            ])
            if shouldContinue {
                self.showHealthConfirmAndContinue()
            }
        } failure: { [weak self] failed in
            guard let self = self else { return }
            guard self.userGroupInitRequestGeneration == requestGeneration else {
                DLLog(message: "[UserGroupInit][FirstLaunch] ignore stale failure: \(failed)")
                return
            }
            self.isRequestingUserGroupInit = false
            self.userGroupInitRequestStartTime = nil
            let shouldContinue = self.shouldContinueAfterUserGroupInit
            self.shouldContinueAfterUserGroupInit = false
            DLLog(message: "[UserGroupInit][FirstLaunch] URL_user_group_init failed: \(failed)")
            self.applyUserGroupInitData(NSDictionary())
            self.hasLoadedUserGroupInit = true
            if shouldContinue {
                self.showHealthConfirmAndContinue()
            }
        }
    }

    private func shouldRestartUserGroupInitRequest() -> Bool {
        guard let startTime = userGroupInitRequestStartTime else {
            return true
        }
        return Date().timeIntervalSince(startTime) > userGroupInitRequestMaxWaitTime
    }
    
    private func applyUserGroupInitData(_ dataObj: NSDictionary) {
        let dietImportant = dataObj.stringValueForKey(key: "user_group").isEmpty
            ? "A"
            : dataObj.stringValueForKey(key: "user_group")
        switch dietImportant.uppercased() {
        case "B":
            UserInfoModel.shared.abTestModel.diet_important = .B
        case "C":
            UserInfoModel.shared.abTestModel.diet_important = .C
        default:
            UserInfoModel.shared.abTestModel.diet_important = .A
        }
        NotificationCenter.default.post(name: NOTIFI_NAME_ABTEST, object: nil)
    }

    private func changeRootToNeedBuildPlan() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let navVc = UINavigationController(rootViewController: NeedBuildPlanVC())
        let navVc = UINavigationController(rootViewController: GuidanceVC())
//        let navVc = UINavigationController(rootViewController: GuidanceProVC())
//        let navVc = UINavigationController(rootViewController: GuidanceProPurchasedVC())
        navVc.setNavigationBarHidden(true, animated: false)

        view.layoutIfNeeded()
        let transitionSnapshot = view.snapshotView(afterScreenUpdates: false)
        appDelegate.switchRootViewController(to: navVc,
                                             from: self,
                                             transitionSnapshot: transitionSnapshot,
                                             preRenderNewRootBeforeTransition: true)

        // 保留原实现但不再执行：上面已经通过统一入口完成 root 切换。
        // 同一个 navVc 被连续设置两次 root，容易让 UIWindow 长时间停在 UITransitionView 中间态。
//        UIView.transition(with: appDelegate.window!, duration: 0.35, options: .transitionCrossDissolve, animations: {
//            appDelegate.window!.rootViewController = navVc
//        }) { _ in
//            self.removeFromParent()
//        }
    }
    private func trackGuidanceV2StartPageIfNeeded() {
        guard !didTrackGuidanceV2StartPage else { return }
        didTrackGuidanceV2StartPage = true
        EventLogUtils().sendGuidanceV2PageView(pageIndex: "1", pageTitle: "开始页", bizType: "")
    }

    private func trackIOS0805GuidanceV2StartButton() {
        EventLogUtils().sendIOS0805GuidanceV2EventLog(eventName: .CLICK_BUTTON,
                                                      scenarioType: .ios0805_guidance_v2_start_button)
    }

    private func trackIOS0805GuidanceV2BeforeStartAlert() {
        EventLogUtils().sendIOS0805GuidanceV2EventLog(eventName: .PAGE_VIEW,
                                                      scenarioType: .ios0805_guidance_v2_before_start_alert)
    }

    private func trackIOS0805GuidanceV2BeforeStartExit() {
        EventLogUtils().sendIOS0805GuidanceV2EventLog(eventName: .CLICK_BUTTON,
                                                      scenarioType: .ios0805_guidance_v2_before_start_exit)
    }

    private func trackIOS0805GuidanceV2BeforeStartAgree() {
        EventLogUtils().sendIOS0805GuidanceV2EventLog(eventName: .CLICK_BUTTON,
                                                      scenarioType: .ios0805_guidance_v2_before_start_agree)
    }

    private func trackIOS0805GuidanceV2BeforeStartBackground() {
        EventLogUtils().sendIOS0805GuidanceV2EventLog(eventName: .PAGE_VIEW,
                                                      scenarioType: .ios0805_guidance_v2_before_start_background)
    }

    func changeRootVC() {
        let token = UserDefaults.standard.value(forKey: token) as? String ?? ""
        if token.count > 1 {
            let uId = UserDefaults.standard.value(forKey: userId) as? String ?? ""
            UserInfoModel.shared.uId = uId
            UserInfoModel.shared.token = token
            ElaProPriceVM.preloadLoggedInProductSnapshots()
            
            UserInfoModel.shared.mealsNumber = UserDefaults.getMealsNumber()
            UserInfoModel.shared.hidden_survery_button_status = UserDefaults.getSurveryStatus()
            UserInfoModel.shared.hiddenMeaTimeStatus = UserDefaults.getLogsTimeStatus()
            UserDefaults.initWeightUnit()
            
            WHBaseViewVC().changeRootVcToTabbar()
            WidgetUtils().saveUserInfo(uId: "\(uId)", uToken: "\(token)")
        }else{
            UserInfoModel.shared.uId = ""
            UserInfoModel.shared.token = ""
            
            WHBaseViewVC().changeRootVcToWelcome()
        }
    }
}
