//
//  AliPlayerTest.swift
//  lns
//
//  Created by Elavatine on 2025/8/4.
//

import AliyunPlayer
import UIKit

class AliPlayerTest: UIViewController {
    
    var mAliPlayer: AliPlayer? = AliPlayer()
    var playerView = UIView()
    deinit {
            mAliPlayer?.stop()
            mAliPlayer?.destroy()
            mAliPlayer = nil
        }
    override func viewDidDisappear(_ animated: Bool) {
        mAliPlayer?.stop()
        mAliPlayer?.destroy()
        mAliPlayer = nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AliPlayerGlobalSettings.setFairPlayCertID("7069e758e56e40eabdab57683b5d815f")
        DLLog(message: "[AliPlayer] version:\(AliPlayer.getSDKVersion() ?? "")")
        playerView = UIView.init(frame: self.view.bounds)
        view.addSubview(playerView)
        mAliPlayer?.playerView = playerView
        mAliPlayer?.setTraceID(UserInfoModel.shared.uId)
//        initUI()
        aliVidStsPlay()
    }
}

extension AliPlayerTest{
    func aliVidStsPlay()  {
        let source = AVPVidStsSource()
        source.region = "cn-shanghai"
        source.vid = "60993ea3817971f080065017e1e90102"//60993ea3817971f080065017e1e90102  008cb567816071f080035017f0f90102
        source.securityToken = UserInfoModel.shared.ossSecurityToken
        source.accessKeySecret = UserInfoModel.shared.ossAccessKeySecret
        source.accessKeyId = UserInfoModel.shared.ossAccessKeyId
        
        self.mAliPlayer?.setStsSource(source)
        self.mAliPlayer?.prepare()
        mAliPlayer?.start()
    }
    func initUI() {
        let url2 = AVPUrlSource().url(with: "https://ela-test.oss-cn-shenzhen.aliyuncs.com/forum/tutorial/material/FatLoss101/3.4.mp4?Expires=1755054069&OSSAccessKeyId=STS.NXufPFpo7UPrxyHTkAhivXdC1&Signature=sR1M7SrD7LxfDjrphEn1orQBhhM%3D&security-token=CAIS7wN1q6Ft5B2yfSjIr5vALerynbAW4pKZel/5sGsUZOZat6Ho0zz2IHhMfHBoAOsfsv03mmtT7v4dlqJIRoReREvCUcZr8sz%2BSLhDgdGT1fau5Jko1bc2cArzUUahgZeCO7iLdbGwU/OpbE%2B%2B2U0X6LDmdDKkckW4OJmS8/BOZcgWWQ/KClgjA8xNdDN/tOgQN3baKYzaUHjQj3HXEVBjtydllGp78t7f%2BMCH7QfEh1CIoY185fbIQPWNa81rI%2B0wMbOc1/B3cazsyTNZ7wMwmo59kK1D/0Wg3LSaGEIDzBiaFODW/9ZzVngbAJI3AKlZtvPxuORls%2BjI7eTNxg1KIPteXla0JunisuqmdcqtMtEmD8GZX13GztGIMLTsrgogegh1HQhWet0nWBASZAIrRmOYUNjFnmrHeQC%2BUaOI/bgr2J5utTXS8MGNOkKETsfys09aGOdlPh12aE5Jhza4L/FaL1YTST49WebJF7cURQtFtKblsTfVUiBd1XxNt5X8HaiO4vhGMdykB84fidRGP8we7HFEVV3yTKm1mqSk3qmIsGE9OsDPTnzfgNftqI37CWWWmn0UlaqDCS/LWSyjQ0VCEAPnJyFPBqFgAz04FWE9Amqp4dL/Bxme3NhouLyG1T8ZCNNZhE/78hcaUC7ClgIagAGFzZXhD/EahicfUO1v9rOuDFEvwxqSMMsi8FtYVbIs5mZ3J7aHCP9VUiXgepSyTKXZyPK0NDc6l16bGNP3/eA0yUwmd4I0pY4/FI7CvNTdSokEMNrUnPnI3nl0afFnebxgjbQLNEd1pBte86cZQKlTdkO2SK8EBOSQG2pcQBpPKiAA")
//        let urlSource = AVPUrlSource().url(with: "https://vdept3.bdstatic.com/mda-rgjdp4w5ecfx9845/cae_h264/1753004436272411802/mda-rgjdp4w5ecfx9845.mp4?v_from_s=hkapp-haokan-hna&auth_key=1755059080-0-0-848c48e3f33c367bce7d637077da9d61&bcevod_channel=searchbox_feed&pd=1&cr=0&cd=0&pt=3&logid=1480184668&vid=9494902780826091103&klogid=1480184668&abtest=")
//        mAliPlayer?.setUrlSource(urlSource)
        mAliPlayer?.setUrlSource(url2)
        mAliPlayer?.prepare()
        mAliPlayer?.start()
    }
    
    
}
