//
//  AIResultStatusModel.swift
//  lns
//
//  Created by Elavatine on 2025/3/12.
//

enum RESULT_CANCEL_STATUS {
    case normal  //正常状态
    case showAlert  //取消的弹窗已弹出，但还未选择是否取消
    case canceled //已取消
}

class AIResultStatusModel {
    
    var taskId = ""
    
    var cancelStatus = RESULT_CANCEL_STATUS.normal
    
    var resultObj = NSDictionary()
    
    func initWithTaskId(taskId:String) -> AIResultStatusModel {
        let model = AIResultStatusModel()
        model.taskId = taskId
        model.cancelStatus = .normal
        
        return model
    }
}
