//
//  ForumConfigModel.swift
//  lns
//
//  Created by Elavatine on 2025/1/8.
//


class ForumConfigModel {
    
    static let shared = ForumConfigModel()
    
    var reportReasonArray:[String] = [String]()
    
    var notInterestedReasonArray:[String] = [String]()
    
//    var player = ZFPlayerController()
    
    private init(){
        
    }
}

extension ForumConfigModel{
    func dealReportData(dataDict:NSDictionary) {
        DLLog(message: "ForumConfigModel dealReportData:\(dataDict)")
        let arr = dataDict["content_feedback"]as? [String] ?? [String]()
        self.reportReasonArray.append(contentsOf: arr)
//        self.reportReasonArray.append(contentsOf: arr)
//        self.reportReasonArray.append(contentsOf: arr)
//        self.reportReasonArray.append(contentsOf: arr)
//        self.reportReasonArray.append(contentsOf: arr)
        
        self.notInterestedReasonArray = dataDict["not_interested"]as? [String] ?? [String]()
    }
}
