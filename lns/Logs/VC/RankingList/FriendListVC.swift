//
//  FriendListVC.swift
//  lns
//
//  Created by Elavatine on 2025/6/30.
//

class FriendListVC: WHBaseViewVC {
    
    var friendDataRefreshBlock:(()->())?
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       self.navigationController?.fd_interactivePopDisabled = false
       self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
   }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        removeParallaxOverlay()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    lazy var searchVm: FriendListSearchVM = {
        let vm = FriendListSearchVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: 0, height: 0))
        vm.backgroundColor = .COLOR_BG_WHITE
        vm.searchBlock = {()in
            DLLog(message: "好友ID：\(self.searchVm.textField.text ?? "")")
            if self.searchVm.textField.text?.count ?? 0 > 0{
                if self.friendListSearchVm.suffixUid != self.searchVm.textField.text ?? ""{
                    self.friendListSearchVm.isFriendList = false
                    self.friendListSearchVm.updateFrame(originY: self.searchVm.frame.maxY)
                    self.friendListSearchVm.sendFriendQueryRequest(uid: self.searchVm.textField.text ?? "")
                }
            }else{
                if self.friendListSearchVm.suffixUid != ""{
                    self.friendListSearchVm.isFriendList = true
                    self.friendListSearchVm.updateFrame(originY: self.idVm.frame.maxY+kFitWidth(12))
                    self.friendListSearchVm.sendFriendListRequest()
                }
            }
        }
        return vm
    }()
    lazy var idVm: FriendListMyIDVM = {
        let vm = FriendListMyIDVM.init(frame: CGRect.init(x: 0, y: self.searchVm.frame.maxY, width: 0, height: 0))
        return vm
    }()
    lazy var friendListSearchVm: FriendListVM = {
        let vm = FriendListVM.init(frame: CGRect.init(x: 0, y: self.idVm.frame.maxY + kFitWidth(12), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.idVm.frame.maxY))
        vm.friendDataRefreshBlock = {()in
            self.friendDataRefreshBlock?()
        }
        return vm
    }()
}

extension FriendListVC{
    func initUI() {
        initNavi(titleStr: "添加好友")
        view.backgroundColor = .COLOR_BG_F5
        
        view.addSubview(searchVm)
        view.addSubview(idVm)
        view.addSubview(friendListSearchVm)
    }
    private func removeParallaxOverlay() {
        if let navView = self.navigationController?.view {
            for subview in navView.subviews {
                if String(describing: type(of: subview)).contains("UIParallaxOverlayView") {
                    subview.removeFromSuperview()
                }
            }
            navView.motionEffects.removeAll()
        }
    }
}
