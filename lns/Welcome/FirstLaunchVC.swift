//
//  FirstLaunchVC.swift
//  lns
//  
//  Created by Elavatine on 2025/8/28.
//

import SnapKit


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
    
    var firstLabelTopConstraint: Constraint?
    var firstLabelTwoTopConstraint: Constraint?
    public var generator = UIImpactFeedbackGenerator(style: .light)
    public var generatorMedium = UIImpactFeedbackGenerator(style: .medium)
    
    
    let damping = 0.8
    let velocity = 0.2
    private var hapticLink: CADisplayLink?
    private var hapticFired: [Int: Bool] = [:] // 0: 25%, 1: 55%
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(showAnimation))
//        self.view.addGestureRecognizer(tap)
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
        lab.text = "这是由健身人，\n为健身人打造的饮食工具" // 目标文案
        lab.font = .systemFont(ofSize: 24, weight: .semibold) // 目标样式
        lab.textColor = .white
        lab.textAlignment = .left
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.alpha = 0 // 初始隐藏
        return lab
    }()

    lazy var firstLogoImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "main_top_logo_launch")
        return img
    }()
    lazy var secondLogoImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "main_top_logo_launch")
        img.alpha = 0
        return img
    }()
    
    lazy var secondLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.text = "我们会将所有实测有效的功能，\n全部免费开放供你使用，\n帮助你高效实现目标" // 目标文案
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
        btn.backgroundColor = .COLOR_BG_WHITE
        btn.layer.cornerRadius = kFitWidth(27)
        btn.clipsToBounds = true
        btn.setTitle("我准备好了", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.alpha = 0
        
        btn.enablePressEffect()
        
        btn.addTarget(self, action: #selector(startBtnAction), for: .touchUpInside)
        
        return btn
    }()
}

extension FirstLaunchVC{
    @objc func showAnimation() {
        generator.prepare()
        generatorMedium.prepare()
        firstLabelTwoTopConstraint?.update(offset: 0)
        firstLabelTwo.alpha = 0
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
            UIView.animate(withDuration: 0.55, delay: 2.0) {
                self.confirmButton.alpha = 1
            }completion: { _ in
                self.bgImgViewTwo.isUserInteractionEnabled = true
                
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
            UIView.animate(withDuration: 0.55, delay: 1.5) {
                self.confirmButton.alpha = 1
            }completion: { _ in
                self.bgImgViewTwo.isUserInteractionEnabled = true
                self.bgImgView.isHidden = true
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
            make.right.equalTo(kFitWidth(-54))
        }
        firstLogoImgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(firstLabelOne.snp.bottom).offset(kFitWidth(17))
        }
        secondLogoImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(25))
            make.top.equalTo(getTopSafeAreaHeight()+kFitWidth(432))
            make.width.equalTo(kFitWidth(115))
            make.height.equalTo(kFitWidth(20))
        }
        secondLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(25))
            make.top.equalTo(secondLogoImgView.snp.bottom).offset(kFitWidth(20))
        }
        confirmButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(25))
            make.right.equalTo(kFitWidth(-25))
            make.top.equalTo(secondLabel.snp.bottom).offset(kFitWidth(29))
            make.height.equalTo(kFitWidth(54))
        }
    }
}

extension FirstLaunchVC{
    @objc func startBtnAction() {
        UserDefaults.standard.setValue("1", forKey: isLaunchWelcome)
        self.changeRootVC()
    }
    func changeRootVC() {
        let token = UserDefaults.standard.value(forKey: token) as? String ?? ""
        if token.count > 1 {
            let uId = UserDefaults.standard.value(forKey: userId) as? String ?? ""
            UserInfoModel.shared.uId = uId
            UserInfoModel.shared.token = token
            
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
