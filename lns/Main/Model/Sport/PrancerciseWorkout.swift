struct PrancerciseWorkout {

    var id = ""
    var name = ""
    var source = 2 //1   APP 记录的     2   APPle 健康APP
    
    var start: Date
    var end: Date
    var duration = "0"
    var calories = ""

//  init(start: Date, end: Date) {
//    self.start = start
//    self.end = end
//  }
    
    init(calories:String){
        self.calories = calories
        self.source = 2
        self.duration = "0.1"
        self.start = Date().addingTimeInterval(-1)
        self.end = Date()
    }
    
//    var duration : String{
//        return WHUtils.convertStringToStringOneDigit("\((second/60).rounded())") ?? "0"
//    }

  var second: TimeInterval {
    return end.timeIntervalSince(start)
  }
    
    mutating func getStartDate() {
//        let secondsAgo = -self.duration.floatValue*60
//        if let startDate = Calendar.current.date(byAdding: .second, value: Int(secondsAgo), to: Date()) {
        let secondsAgo = Int(self.duration.floatValue * 60)
        if let startDate = Calendar.current.date(byAdding: .second, value: -secondsAgo, to: self.end) {
            // 输出 secondsAgo 秒前的时间
            print(startDate)
            self.start = startDate
        }
    }
}
