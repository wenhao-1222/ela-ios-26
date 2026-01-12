//
//  HonorDonationPreviewView.swift
//  lns
//
//  Created by LNS2 on 2026/1/12.
//

import Photos
import MCToast

class HonorDonationPreviewView: UIView {
    
    private let msgBaseSize = CGSize(width: kFitWidth(375), height: kFitWidth(812))
    private let msgContainer = UIView()
    private let buttonStack = UIStackView()
    private let closeButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    private let dataDict: NSDictionary
    private let originFrame: CGRect
    private let originFrameProvider: (() -> CGRect?)?
    private var isAnimating = false
    
    private lazy var msgVm: HonorDonationMsgVM = {
        let vm = HonorDonationMsgVM(frame: CGRect(origin: .zero, size: msgBaseSize))
        return vm
    }()
    
    init(
            dict: NSDictionary,
            originFrame: CGRect,
            originFrameProvider: (() -> CGRect?)? = nil
        ) {
        self.dataDict = dict
        self.originFrame = originFrame
        self.originFrameProvider = originFrameProvider
        super.init(frame: .zero)
        setupUI()
        updateContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    private func setupUI() {
        backgroundColor = .COLOR_BG_F2
        
        addSubview(msgContainer)
        msgContainer.addSubview(msgVm)
        addSubview(buttonStack)
        
        buttonStack.axis = .horizontal
        buttonStack.spacing = kFitWidth(16)
        buttonStack.distribution = .fillEqually
        
        closeButton.setTitle("关闭", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: kFitWidth(16), weight: .medium)
        closeButton.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        closeButton.backgroundColor = .COLOR_BG_WHITE
        closeButton.layer.cornerRadius = kFitWidth(24)
        closeButton.layer.borderWidth = kFitWidth(1)
        closeButton.layer.borderColor = UIColor.COLOR_LINE_F0.cgColor
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        
        saveButton.setTitle("保存到手机", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: kFitWidth(16), weight: .medium)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .THEME
        saveButton.layer.cornerRadius = kFitWidth(24)
        saveButton.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        
        buttonStack.addArrangedSubview(closeButton)
        buttonStack.addArrangedSubview(saveButton)
        
        msgVm.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(msgBaseSize.width)
            make.height.equalTo(msgBaseSize.height)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(32))
            make.right.equalToSuperview().offset(kFitWidth(-32))
            make.bottom.equalToSuperview().offset(-kFitWidth(24))
            make.height.equalTo(kFitWidth(48))
        }
    }
    
    private func updateContent() {
        msgVm.updateUI(dict: dataDict)
    }
    
    private func updateLayout() {
        let safeInsets = safeAreaInsets
        let availableWidth = bounds.width - kFitWidth(32)
        let availableHeight = bounds.height
            - safeInsets.top
            - safeInsets.bottom
            - kFitWidth(24)
            - kFitWidth(48)
            - kFitWidth(24)
        
        let scale = min(
            availableWidth / msgBaseSize.width,
            availableHeight / msgBaseSize.height
        )
        let displaySize = CGSize(
            width: msgBaseSize.width * scale,
            height: msgBaseSize.height * scale
        )
        
        msgContainer.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(safeInsets.top + kFitWidth(24))
            make.width.equalTo(displaySize.width)
            make.height.equalTo(displaySize.height)
        }
        
        buttonStack.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(32))
            make.right.equalToSuperview().offset(kFitWidth(-32))
            make.bottom.equalToSuperview().offset(-kFitWidth(24) - safeInsets.bottom)
            make.height.equalTo(kFitWidth(48))
        }
        
        msgVm.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    func msgContainerFrame(in view: UIView) -> CGRect {
        return msgContainer.convert(msgContainer.bounds, to: view)
    }

    func prepareForPresentation() {
        setMessageHidden(true)
        setChromeAlpha(0)
    }
    
    func finishPresentation() {
        setMessageHidden(false)
        setChromeAlpha(1)
    }
    
    private func setChromeAlpha(_ alpha: CGFloat) {
        buttonStack.alpha = alpha
        backgroundColor = UIColor.COLOR_BG_F2.withAlphaComponent(alpha)
    }

    private func setMessageHidden(_ hidden: Bool) {
        msgContainer.alpha = hidden ? 0 : 1
    }
    @objc private func closeAction() {
//        removeFromSuperview()
        guard !isAnimating else { return }
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.keyWindow else {
            removeFromSuperview()
            return
        }
        let targetFrame = originFrameProvider?() ?? originFrame
        let snapshot = msgContainer.snapshotView(afterScreenUpdates: true) ?? UIView()
        snapshot.frame = msgContainer.convert(msgContainer.bounds, to: window)
        window.addSubview(snapshot)
        isAnimating = true
        setMessageHidden(true)
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseInOut]
        ) {
            snapshot.frame = targetFrame
            self.setChromeAlpha(0)
        } completion: { _ in
            snapshot.removeFromSuperview()
            self.isAnimating = false
            self.removeFromSuperview()
        }
    }
    
    @objc private func saveAction() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                if status == .restricted || status == .denied {
                    self.presentPhotoDeniedAlert()
                } else {
                    MCToast.mc_loading(duration: 30)
                    let image = self.makeSnapshotImage()
                    UIImageWriteToSavedPhotosAlbum(
                        image,
                        self,
                        #selector(self.saveImage(image:didFinishSavingWithError:contextInfo:)),
                        nil
                    )
                }
            }
        }
    }
    
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        MCToast.mc_remove()
        if error != nil {
            MCToast.mc_text("保存失败。")
        } else {
            MCToast.mc_text("已保存到系统相册")
        }
    }
    
    private func presentPhotoDeniedAlert() {
        guard let topVC = UIApplication.topViewController() else { return }
        let alert = UIAlertController(
            title: "提示",
            message: "无访问相册权限，是否去打开权限?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "打开", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }))
        topVC.present(alert, animated: true)
    }
    
    private func makeSnapshotImage() -> UIImage {
        let renderVm = HonorDonationMsgVM(frame: CGRect(origin: .zero, size: msgBaseSize))
        renderVm.updateUI(dict: dataDict)
        renderVm.headImgView.image = msgVm.headImgView.image
        renderVm.layoutIfNeeded()
        return renderVm.mc_makeImage()
    }
}
