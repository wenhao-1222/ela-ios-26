//
//  AICoachPreVC.swift
//  lns
//  AI教练报告 前置页
//  Created by LNS2 on 2026/3/25.
//

import UIKit
import SnapKit

class AICoachPreVC: WHBaseViewVC {

    private lazy var preDaysVM: AICoachPreDaysVM = {
        let view = AICoachPreDaysVM(frame: .zero)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        sendCoachLaunchRequest()
    }

    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_ai_pre_bg")
        img.contentMode = .scaleAspectFit
        return img
    }()
    lazy var circleImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_ai_pre_circle_icon")
        return img
    }()
}

extension AICoachPreVC{
    func initUI() {
        view.addSubview(bgImgView)
        initNavi(titleStr: "AI教练")
        view.backgroundColor = .COLOR_BG_F2
        navigationView.backgroundColor = .clear
        view.addSubview(circleImgView)

        view.addSubview(preDaysVM)
        setConstrait()
    }
    func setConstrait() {
        bgImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        circleImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(133.5))
            make.width.height.equalTo(kFitWidth(250))
        }
        preDaysVM.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(circleImgView.snp.bottom).offset(kFitWidth(20))
            make.height.equalTo(preDaysVM.selfHeight)
        }
    }
}

extension AICoachPreVC{
    func sendCoachLaunchRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_ai_coach_launch, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let foodsMsgDict = self.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendCoachLaunchRequest:\(foodsMsgDict)")
            self.updatePreDaysUI(dataDict: foodsMsgDict)
        }
    }
}

private extension AICoachPreVC {
    func updatePreDaysUI(dataDict: NSDictionary) {
        guard let progressBar = dataDict["progressBar"] as? [NSDictionary], progressBar.isEmpty == false else {
            return
        }

        let sortedProgressBar = progressBar.sorted { left, right in
            let leftDate = Date().changeDateStringToDate(dateString: left["date"] as? String ?? "", formatter: "yyyy-MM-dd")
            let rightDate = Date().changeDateStringToDate(dateString: right["date"] as? String ?? "", formatter: "yyyy-MM-dd")
            return leftDate < rightDate
        }

        let firstIncompleteIndex = sortedProgressBar.firstIndex {
            ($0["completeStatus"] as? Int ?? 0) == 0
        }

        let items = sortedProgressBar.enumerated().map { index, item -> AICoachPreDaysVM.DayItem in
            let dateString = item["date"] as? String ?? ""
            let completeStatus = item["completeStatus"] as? Int ?? 0
            let state: AICoachPreDaysVM.DayState

            if completeStatus == 1 || completeStatus == 2 {
                state = .completed
            } else if index == firstIncompleteIndex {
                state = .current
            } else {
                state = .pending
            }

            return .init(title: weekdayShortText(from: dateString), state: state, completeStatus: completeStatus)
        }

        let reportAfterDays = items.filter { $0.state == .pending }.count

        DispatchQueue.main.async {
            self.preDaysVM.configure(items: items, reportAfterDays: reportAfterDays)
        }
    }

    func weekdayShortText(from dateString: String) -> String {
        let date = Date().changeDateStringToDate(dateString: dateString, formatter: "yyyy-MM-dd")
        switch Calendar.current.component(.weekday, from: date) {
        case 1: return "日"
        case 2: return "一"
        case 3: return "二"
        case 4: return "三"
        case 5: return "四"
        case 6: return "五"
        case 7: return "六"
        default: return ""
        }
    }
}
