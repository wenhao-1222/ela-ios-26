//
//  TutorialAttr.swift
//  lns
//
//  Created by LNS2 on 2024/6/4.
//

import Foundation

enum catalogue_type {
    case catalogue_12
    case catalogue_13
    case catalogue_14
    case catalogue_15
    case catalogue_16
    case catalogue_17
    case catalogue_18
    case catalogue_7
}

class TutorialAttr {
    
    static let shared = TutorialAttr()
    
    let lineHeight = kFitWidth(18)
    let lineSpacing = kFitWidth(11)
    
    let font_11_medium = UIFont.systemFont(ofSize: 11, weight: .medium)
    let font_11_regular = UIFont.systemFont(ofSize: 11, weight: .regular)
    let font_13_medium = UIFont.systemFont(ofSize: 13, weight: .medium)
    
    let step_one_attr_array = NSMutableArray()
    let step_two_attr_array = NSMutableArray()
    let step_three_attr_array = NSMutableArray()
    let step_four_attr_array = NSMutableArray()
    let step_five_attr_array = NSMutableArray()
    
    var nutritionAttr = NSMutableAttributedString()
    var sportTipsAttr = NSMutableAttributedString()
    var sportMetsTipsAttr = NSMutableAttributedString()
    
    let tutorial_array_1 = NSMutableArray()
    let tutorial_array_2 = NSMutableArray()
    let tutorial_array_3 = NSMutableArray()
    let tutorial_array_4 = NSMutableArray()
    let tutorial_array_5 = NSMutableArray()
    let tutorial_array_6 = NSMutableArray()
    let tutorial_array_7 = NSMutableArray()
    let tutorial_array_8 = NSMutableArray()
    let tutorial_array_9 = NSMutableArray()
    let tutorial_array_10 = NSMutableArray()
    
    var dataSourceArray = NSArray()
    
    private init(){
        getContent_1_1()
        getContent_1_2()
        getContent_1_3_1()
        getContent_1_3_2()
        getContent_1_4_1()
        getContent_1_4_2()
        getContent_1_4_3()
        getContent_1_4_4()
        getContent_1_5()
        getContent_1_6()
        getContent_1_7()
        getContent_1_8()
        
        getContent_2_1()
        getContent_2_2()
        getContent_2_3()
        getContent_2_4()
        getContent_2_5()
        
        getContent_3_1()
        getContent_3_2()
        getContent_3_3()
        getContent_3_4()
        getContent_3_5()
        
        getContent_4_1()
        getContent_4_2()
        getContent_4_3_1_1()
        getContent_4_3_1_2()
        getContent_4_3_2()
        getContent_4_3_3()
        getContent_4_3_4()
        getContent_4_3_5()
        getContent_4_3_6()
        getContent_4_3_7()
        getContent_4_3_8()
        
        getContent_5_1()
        getContent_5_2()
        
        getNutritionTipsAttr()
        getSportTipsAttr()
        getSportMetsTipsAttr()
        getAttrUpate()
        dataSourceArray = getDataSource()
    }
    
    /**
      1.免费获取饮食计划，激活并执行计划
     */
    func getContent_1_1() {
        let titleAttr = NSMutableAttributedString(string: "1.1 填写问卷获取计划\n")
        let step1 = NSMutableAttributedString(string: "步骤 1：前往日志页-")
        let step2 = NSMutableAttributedString(string: "点击免费获取计划\n")
        let step3 = NSMutableAttributedString(string: "步骤 2：填写完整问卷，")
        let step4 = NSMutableAttributedString(string: "并选择需要饮食计划")
        
        titleAttr.yy_lineSpacing = lineSpacing
        step1.yy_minimumLineHeight = lineHeight
        step2.yy_lineSpacing = kFitWidth(4)
        step3.yy_lineSpacing = kFitWidth(4)
        step3.yy_minimumLineHeight = lineHeight
        step4.yy_lineSpacing = kFitWidth(4)
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step2)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step3)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step4)
        
        titleAttr.append(step1)
        titleAttr.append(step2)
        titleAttr.append(step3)
        titleAttr.append(step4)
        
        step_one_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(287),
                                 "imgs":["tutorials_1_1_1",
                                        "tutorials_1_1_2"],
                                 "steps":["步骤1",
                                         "步骤2"]])
    }
    
    func getContent_1_2() {
        let titleAttr = NSMutableAttributedString(string: "1.2 激活计划\n")
        var step1 = NSMutableAttributedString(string: "步骤 1：在计划列表点击刚刚保存的计划（如果没有自动转跳到计划列表，请点击日志右上角")
        let step2 = NSMutableAttributedString(string: "手动进入）\n")
        let step3 = NSMutableAttributedString(string: "步骤 2：点击页面底部的“")
        let step4 = NSMutableAttributedString(string: "激活计划")
        let step5 = NSMutableAttributedString(string: "”")
        
        titleAttr.yy_lineSpacing = lineSpacing
        
        step1 = createAttributedStringWithImage(image: UIImage.init(named: "tutorials_plan_list_icon")!, text: "步骤 1：在计划列表点击刚刚保存的计划（如果没有自动转跳到计划列表，请点击日志右上角")
        step1.yy_minimumLineHeight = lineHeight
        step2.yy_minimumLineHeight = lineHeight
        step3.yy_minimumLineHeight = lineHeight
        step4.yy_minimumLineHeight = lineHeight
        step5.yy_minimumLineHeight = lineHeight
        
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step2)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step3)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step4)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step5)
        
        titleAttr.append(step1)
        titleAttr.append(step2)
        titleAttr.append(step3)
        titleAttr.append(step4)
        titleAttr.append(step5)
        
        step_one_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(287),
                                 "imgs":["tutorials_1_2_3",
                                         "tutorials_1_2_1",
                                        "tutorials_1_2_2"],
                                 "steps":["步骤1",
                                         "步骤2.1",
                                          "步骤2.2"]])
    }
    func getContent_1_3_1(){
        let titleAttr = NSMutableAttributedString(string: "1.3 执行计划\n")
        let step1 = NSMutableAttributedString(string: "查看计划")
        let step2 = NSMutableAttributedString(string: "：点击激活后计划会从当日开始显示在日志列表中，可通过前后翻页查看前一天/后一天的饮食计划")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step2)
        
        titleAttr.yy_lineSpacing = lineSpacing
        step1.yy_minimumLineHeight = lineHeight
        step2.yy_minimumLineHeight = lineHeight
        
        titleAttr.append(step1)
        titleAttr.append(step2)
        
        step_one_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(277),
                                 "imgs":["tutorials_1_3_1_1",
                                         "tutorials_1_3_1_2",
                                         "tutorials_1_3_1_3"],
                                 "steps":["左右滑动翻页",
                                         "点击翻页",
                                          "选择日期翻页"]])
    }
    func getContent_1_3_2(){
        let step1 = NSMutableAttributedString(string: "执行计划")
        var step2 = NSMutableAttributedString(string: "：食用完该食物之后点击列表右边的")
        
        step2 = createAttributedStringWithImage(image: UIImage.init(named: "tutorials_eat_icon")!, text: "：食用完该食物之后点击列表右边的")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step2)
        
        step1.yy_minimumLineHeight = lineHeight
        step2.yy_minimumLineHeight = lineHeight
        
        step1.append(step2)
        
        step_one_attr_array.add(["attr":step1,
                                 "bottomGap":kFitWidth(268),
                                 "imgs":["tutorials_1_3_2"]])
    }
    func getContent_1_4_1() {
        let titleAttr = NSMutableAttributedString(string: "1.4 添加/删减/修改食物\n")
        let step1 = NSMutableAttributedString(string: "添加食物")
        var step2 = NSMutableAttributedString(string: "：如某餐吃了计划以外的食物，可通过点击该餐右上角的")
        let step3 = NSMutableAttributedString(string: "进入搜索页，随后使用顶部的搜索栏搜索到该食物，点击食物，选择摄入的单位和数量点击“添加”即可。")
        
        step2 = createAttributedStringWithImage(image: UIImage.init(named: "tutorials_add_icon")!, text: "：如某餐吃了计划以外的食物，可通过点击该餐右上角的")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step2)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step3)
        
        step1.yy_minimumLineHeight = lineHeight
        step2.yy_minimumLineHeight = lineHeight
        step3.yy_minimumLineHeight = lineHeight
        
        titleAttr.append(step1)
        titleAttr.append(step2)
        titleAttr.append(step3)
        
        
        step_one_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(257),
                                 "imgs":["tutorials_1_4_1",
                                        "tutorials_1_4_2",
                                        "tutorials_1_4_3"]])
    }
    func getContent_1_4_2(){
        let step1 = NSMutableAttributedString(string: "删减食物")
        var step2 = NSMutableAttributedString(string: "：如该餐内有没吃的食物，可在日志列表内左滑该食物进行删除")
        
//        step2 = createAttributedStringWithImage(image: UIImage.init(named: "tutorials_eat_icon")!, text: "：食用完该食物之后点击列表右边的")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step2)
        
        step1.yy_minimumLineHeight = lineHeight
        step2.yy_minimumLineHeight = lineHeight
        
        step1.append(step2)
        
        step_one_attr_array.add(["attr":step1,
                                 "bottomGap":kFitWidth(276),
                                 "imgs":["tutorials_1_4_4",
                                        "tutorials_1_4_4_2",
                                        "tutorials_1_4_4_3"],
                                 "steps":["单项删除",
                                         "批量删除_步骤1",
                                          "批量删除_步骤2"]])
    }
    func getContent_1_4_3(){
        let step1 = NSMutableAttributedString(string: "修改食物数量")
        var step2 = NSMutableAttributedString(string: "：如果实际吃的食物比计划安排的多/少，可在点击完")
        var step3 = NSMutableAttributedString(string: "之后点击该食物进入食物详情，并根据实际摄入修改食物数量（份量）")
        
        step2 = createAttributedStringWithImage(image: UIImage.init(named: "tutorials_eat_icon")!, text: "：如果实际吃的食物比计划安排的多/少，可在点击完")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step2)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step3)
        
        step1.yy_minimumLineHeight = lineHeight
        step2.yy_minimumLineHeight = lineHeight
        step3.yy_minimumLineHeight = lineHeight
        
        step1.append(step2)
        step1.append(step3)
        
        step_one_attr_array.add(["attr":step1,
                                 "bottomGap":kFitWidth(257),
                                 "imgs":["tutorials_1_4_5",
                                        "tutorials_1_4_6"]])
    }
    func getContent_1_4_4(){
        let step1 = NSMutableAttributedString(string: "偏离计划")
        var step2 = NSMutableAttributedString(string: "：添加/删减/修改食物可能会导致您无法填满/超出您的营养目标进度。")
        
//        step2 = createAttributedStringWithImage(image: UIImage.init(named: "tutorials_eat_icon")!, text: "：食用完该食物之后点击列表右边的")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step2)
        
        step1.yy_minimumLineHeight = lineHeight
        step2.yy_minimumLineHeight = lineHeight
        
        step1.append(step2)
        
        step_one_attr_array.add(["attr":step1,
                                 "bottomGap":kFitWidth(22),
                                 "imgs":[]])
    }
    func getContent_1_5(){
        let titleAttr = NSMutableAttributedString(string: "1.5 创建食物\n")
        let step1 = NSMutableAttributedString(string: "如果数据库中没有您想要的食物")
        let step2 = NSMutableAttributedString(string: "，可以在搜索页点击左上角的“创建食物”，填写食物名字，单位，营养成分，（系统会自动为您计算出该食物的卡路里，也可以手动填写）并点击保存。随后在食物搜索页，我的食物栏目下点击该食物添加即可")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step2)
        
        titleAttr.yy_lineSpacing = lineSpacing
        step1.yy_minimumLineHeight = lineHeight
        step2.yy_minimumLineHeight = lineHeight
        
        titleAttr.append(step1)
        titleAttr.append(step2)
        
        step_one_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(287),
                                 "imgs":["tutorials_1_5_1",
                                        "tutorials_1_5_2",
                                        "tutorials_1_5_3"],
                                 "steps":["",
                                         "点击直接输入/修改",
                                          ""]])
    }
    func getContent_1_6(){
        let titleAttr = NSMutableAttributedString(string: "1.6 快速添加\n")
        let step1 = NSMutableAttributedString(string: "如果想快速添加已知营养素的食物")
        let step2 = NSMutableAttributedString(string: "，可通过点击该餐右上角的“加号”进入搜索页，随后在搜索页点击右上角的“")
        let step3 = NSMutableAttributedString(string: "快速添加")
        let step4 = NSMutableAttributedString(string: "”，填写该食物的营养成分（系统会自动为您计算出该食物的卡路里，若只知道卡路里，不知道营养素，可只手动填写卡路里）并点击添加即可")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step2)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step3)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step4)
        
        titleAttr.yy_lineSpacing = lineSpacing
        step1.yy_minimumLineHeight = lineHeight
        step2.yy_minimumLineHeight = lineHeight
        step3.yy_minimumLineHeight = lineHeight
        step4.yy_minimumLineHeight = lineHeight
        
        titleAttr.append(step1)
        titleAttr.append(step2)
        titleAttr.append(step3)
        titleAttr.append(step4)
        
        step_one_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(287),
                                 "imgs":["tutorials_1_6_1",
                                        "tutorials_1_6_2",
                                        "tutorials_1_6_3"],
                                 "steps":["",
                                         "",
                                          "点击直接输入/修改"]])
    }
    func getContent_1_7(){
        let titleAttr = NSMutableAttributedString(string: "1.7 更换计划/清空计划列表\n")
        let step1 = NSMutableAttributedString(string: "如需更换新计划")
        let step2 = NSMutableAttributedString(string: "：直接重复（1.1，1.2）即可。激活新计划将会清空日志内今日之后的所有计划，新计划从今日开始覆盖。\n")
        let step3 = NSMutableAttributedString(string: "如需清空计划列表")
        var step4 = NSMutableAttributedString(string: "：在“我的”页面点击右上角的")
        let step5 = NSMutableAttributedString(string: "点击重置日志列表并根据需求重置即可")
        
        step4 = createAttributedStringWithImage(image: UIImage(named: "tutorials_setting_icon")!, text:"：在“我的”页面点击右上角的" )
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step2)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step3)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step4)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step5)
        
        titleAttr.yy_lineSpacing = lineSpacing
        step1.yy_minimumLineHeight = lineHeight
        step2.yy_minimumLineHeight = lineHeight
        step3.yy_minimumLineHeight = lineHeight
        step4.yy_minimumLineHeight = lineHeight
        step5.yy_minimumLineHeight = lineHeight
        
        titleAttr.append(step1)
        titleAttr.append(step2)
        titleAttr.append(step3)
        titleAttr.append(step4)
        titleAttr.append(step5)
        
        step_one_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(268),
                                 "imgs":["tutorials_1_7_1",
                                        "tutorials_1_7_2",
                                        "tutorials_1_7_3"]])
    }
    func getContent_1_8(){
        let titleAttr = NSMutableAttributedString(string: "1.8 分享当日饮食\n")
        var step4 = NSMutableAttributedString(string: "在日志内需要分享饮食的日期点击右上角的")
        let step5 = NSMutableAttributedString(string: "，点击“保存图片”或分享到其他平台即可自动生成计划长图。")
        
        step4 = createAttributedStringWithImage(image: UIImage(named: "tutorials_share_icon")!, text:"在日志内需要分享饮食的日期点击右上角的" )
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step4)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step5)
        
        titleAttr.yy_lineSpacing = lineSpacing
        step4.yy_minimumLineHeight = lineHeight
        step5.yy_minimumLineHeight = lineHeight
        
        titleAttr.append(step4)
        titleAttr.append(step5)
        
        step_one_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(268),
                                 "imgs":["tutorials_1_8_1",
                                        "tutorials_1_8_2"]])
    }
    func getContent_2_1(){
        let titleAttr = NSMutableAttributedString(string: "2.1 填写问卷获取营养目标\n")
        let step1 = NSMutableAttributedString(string: "步骤 1：前往日志页-")
        let step2 = NSMutableAttributedString(string: "点击免费获取计划\n")
        let step3 = NSMutableAttributedString(string: "步骤 2：填写完整问卷，")
        let step4 = NSMutableAttributedString(string: "并选择我只需要营养目标\n")
        let step5 = NSMutableAttributedString(string: "步骤 3：点击激活目标\n")
        let step6 = NSMutableAttributedString(string: "如需更换目标")
        let step7 = NSMutableAttributedString(string: "：直接重复步骤1，2，3即可，或参照（3.1）")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step2)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step3)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step4)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step5)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step6)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step7)
        
        titleAttr.yy_lineSpacing = lineSpacing
        step1.yy_minimumLineHeight = lineHeight
        step2.yy_minimumLineHeight = lineHeight
        step3.yy_minimumLineHeight = lineHeight
        step4.yy_minimumLineHeight = lineHeight
        step5.yy_minimumLineHeight = lineHeight
        step6.yy_minimumLineHeight = lineHeight
        step7.yy_minimumLineHeight = lineHeight
        
        titleAttr.append(step1)
        titleAttr.append(step2)
        titleAttr.append(step3)
        titleAttr.append(step4)
        titleAttr.append(step5)
        titleAttr.append(step6)
        titleAttr.append(step7)
        
        step_two_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(287),
                                 "imgs":["tutorials_2_1_1",
                                        "tutorials_2_1_2",
                                         "tutorials_2_1_3"],
                                 "steps":["步骤1",
                                         "步骤2",
                                          "步骤3"]])
    }
    func getContent_2_2(){
        let titleAttr = NSMutableAttributedString(string: "2.2 添加/删减/修改食物")
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        titleAttr.yy_lineSpacing = lineSpacing
        
        step_two_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(53),
                                 "button":["title":"(请参照1.4)",
                                           "catalogue":catalogue_type.catalogue_14]])
    }
    
    func getContent_2_3(){
        let titleAttr = NSMutableAttributedString(string: "2.3 创建食物")
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        titleAttr.yy_lineSpacing = lineSpacing
        
        step_two_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(53),
                                 "button":["title":"(请参照1.5)",
                                           "catalogue":catalogue_type.catalogue_15]])
    }
    func getContent_2_4(){
        let titleAttr = NSMutableAttributedString(string: "2.4 快速添加")
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        titleAttr.yy_lineSpacing = lineSpacing
        
        step_two_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(53),
                                 "button":["title":"(请参照1.6)",
                                           "catalogue":catalogue_type.catalogue_16]])
    }
    func getContent_2_5(){
        let titleAttr = NSMutableAttributedString(string: "2.5 分享当日饮食")
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        titleAttr.yy_lineSpacing = lineSpacing
        
        step_two_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(53),
                                 "button":["title":"(请参照1.8)",
                                           "catalogue":catalogue_type.catalogue_18]])
    }
    func getContent_3_1(){
        let titleAttr = NSMutableAttributedString(string: "3.1 设定营养目标\n")
        var step1 = NSMutableAttributedString(string: "步骤 1：在“首页”点击左上角的")
        let step2 = NSMutableAttributedString(string: "\n步骤 2：填写自己的营养目标并点击保存\n")
        let step3 = NSMutableAttributedString(string: "如需更换目标：直接重复步骤1，2即可，或参照（2.1）")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        step1 = createAttributedStringWithImage(image: UIImage(named: "tutorials_edit_icon")!, text: "步骤 1：在“首页”点击左上角的")
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_regular, attr: step2)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step3)
        
        titleAttr.yy_lineSpacing = lineSpacing
        step1.yy_minimumLineHeight = lineHeight
        step2.yy_minimumLineHeight = lineHeight
        step3.yy_minimumLineHeight = lineHeight
        
        titleAttr.append(step1)
        titleAttr.append(step2)
        titleAttr.append(step3)
        
        step_three_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(287),
                                 "imgs":["tutorials_3_1_1",
                                        "tutorials_3_1_2"],
                                   "steps":["步骤1",
                                           "步骤2"]])
    }
    
    func getContent_3_2(){
        let titleAttr = NSMutableAttributedString(string: "3.2 添加/删减/修改食物")
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        titleAttr.yy_lineSpacing = lineSpacing
        
        step_three_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(53),
                                 "button":["title":"(请参照1.4)",
                                           "catalogue":catalogue_type.catalogue_14]])
    }
    
    func getContent_3_3(){
        let titleAttr = NSMutableAttributedString(string: "3.3 创建食物")
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        titleAttr.yy_lineSpacing = lineSpacing
        
        step_three_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(53),
                                 "button":["title":"(请参照1.5)",
                                           "catalogue":catalogue_type.catalogue_15]])
    }
    func getContent_3_4(){
        let titleAttr = NSMutableAttributedString(string: "3.4 快速添加")
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        titleAttr.yy_lineSpacing = lineSpacing
        
        step_three_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(53),
                                 "button":["title":"(请参照1.6)",
                                           "catalogue":catalogue_type.catalogue_16]])
    }
    func getContent_3_5(){
        let titleAttr = NSMutableAttributedString(string: "3.5 分享当日饮食")
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        titleAttr.yy_lineSpacing = lineSpacing
        
        step_three_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(53),
                                 "button":["title":"(请参照1.8)",
                                           "catalogue":catalogue_type.catalogue_18]])
    }
    
    func getContent_4_1(){
        let titleAttr = NSMutableAttributedString(string: "4.1 自定义制作计划\n")
        let step1 = NSMutableAttributedString(string: "步骤 1：在“我的”页面点击右上方的“制作计划”\n")
        var step2 = NSMutableAttributedString(string: "步骤 2：通过滑动或点击进度条选择该计划的时长，并通过\n点击")
        var step3 = NSMutableAttributedString(string: "选择需要编辑的日期\n步骤3：通过点击")
        let step4 = NSMutableAttributedString(string: "添加1-6餐的食物\n步骤4：输入计划名称并点击保存计划\n")
        let step5 = NSMutableAttributedString(string: "如需要复制当日饮食到其他日期")
        let step6 = NSMutableAttributedString(string: "：点击同步用餐，并勾选需要粘贴的日期并点击确认同步")
        
        step2 = createAttributedStringWithImage(image: UIImage(named: "tutorials_down_arrow_icon")!, text: "步骤 2：通过滑动或点击进度条选择该计划的时长，并通过\n点击")
        step3 = createAttributedStringWithImage(image: UIImage(named: "tutorials_add_icon")!, text: "选择需要编辑的日期\n步骤3：通过点击")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step2)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step3)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step4)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step5)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step6)
        
        titleAttr.yy_lineSpacing = lineSpacing
        step1.yy_minimumLineHeight = lineHeight
        step2.yy_minimumLineHeight = lineHeight
        step3.yy_minimumLineHeight = lineHeight
        step4.yy_minimumLineHeight = lineHeight
        step5.yy_minimumLineHeight = lineHeight
        step6.yy_minimumLineHeight = lineHeight
        
        titleAttr.append(step1)
        titleAttr.append(step2)
        titleAttr.append(step3)
        titleAttr.append(step4)
        titleAttr.append(step5)
        titleAttr.append(step6)
        
        step_four_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(278),
                                 "imgs":["tutorials_4_1_1",
                                        "tutorials_4_1_2"],
                                   "steps":["步骤1",
                                           "步骤2-4"]])
    }
    func getContent_4_2(){
        let titleAttr = NSMutableAttributedString(string: "4.2 分享计划给其他用户\n")
        let step1 = NSMutableAttributedString(string: "步骤 1：在“我的”页面点击头像下方的“")
        var step2 = NSMutableAttributedString(string: "”\n步骤 2：点击需要分享的计划进入计划详情\n步骤3：点击右上角的")
        let step3 = NSMutableAttributedString(string: "\n步骤4：点击屏幕下方的“复制分享码”并将分享码转发给需要分享计划的用户\n")
        let step4 = NSMutableAttributedString(string: "需分享计划到社交媒体/非Elavatine用户")
        let step5 = NSMutableAttributedString(string: "：如：在分享计划页面点击右下角的“保存图片”即可生成计划长图，其他用户可以通过长图底部的分享码使用您分享的计划。")
        let step6 = NSMutableAttributedString(string: "饮食计划")
        
        step2 = createAttributedStringWithImage(image: UIImage(named: "tutorials_share_icon_theme")!, text: "”\n步骤 2：点击需要分享的计划进入计划详情\n步骤3：点击右上角的")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step2)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step3)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step4)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step5)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step6)
        
        titleAttr.yy_lineSpacing = lineSpacing
        step1.yy_minimumLineHeight = lineHeight
        step2.yy_minimumLineHeight = lineHeight
        step3.yy_minimumLineHeight = lineHeight
        step4.yy_minimumLineHeight = lineHeight
        step5.yy_minimumLineHeight = lineHeight
        step6.yy_minimumLineHeight = lineHeight
        
        titleAttr.append(step1)
        titleAttr.append(step6)
        titleAttr.append(step2)
        titleAttr.append(step3)
        titleAttr.append(step4)
        titleAttr.append(step5)
        
        step_four_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(278),
                                 "imgs":["tutorials_4_2_1",
                                        "tutorials_4_2_2",
                                         "tutorials_4_2_3",
                                         "tutorials_4_2_4"],
                                   "steps":["步骤1",
                                           "步骤2",
                                            "步骤3",
                                            "步骤4"]])
    }
    
    func getContent_4_3_1_1(){
        let titleAttr = NSMutableAttributedString(string: "4.3 接收计划用户的操作\n4.3.1 接收计划\n")
//        let titleAttr1 = NSMutableAttributedString(string: "")
        let step1 = NSMutableAttributedString(string: "自动接收计划：将分享码复制在剪切板，进入 Elavatine 软件后将自动唤醒弹窗，点击确认导入该计划即可")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step1)
        
        titleAttr.yy_lineSpacing = lineSpacing
        step1.yy_minimumLineHeight = lineHeight
        
        titleAttr.append(step1)
        
        step_four_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(256),
                                 "imgs":["tutorials_4_3_1",
                                        "tutorials_4_3_2"]])
    }
    func getContent_4_3_1_2(){
        //手动导入计划：
        let step1 = NSMutableAttributedString(string: "手动导入计划：")
        let step2 = NSMutableAttributedString(string: "如果没有自动唤醒弹窗，请在“我的”页面点击头像下方的“")
        let step3 = NSMutableAttributedString(string: "饮食计划")
        let step4 = NSMutableAttributedString(string: "”，随后点击左上方的“")
        let step5 = NSMutableAttributedString(string: "导入计划")
        let step6 = NSMutableAttributedString(string: "”，输入分享码后点击")
        let step7 = NSMutableAttributedString(string: "确认导入该计划")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step2)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step3)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step4)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step5)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step6)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step7)
        
        step1.yy_minimumLineHeight = lineHeight
        step2.yy_minimumLineHeight = lineHeight
        step3.yy_minimumLineHeight = lineHeight
        step4.yy_minimumLineHeight = lineHeight
        step5.yy_minimumLineHeight = lineHeight
        step6.yy_minimumLineHeight = lineHeight
        step7.yy_minimumLineHeight = lineHeight
        
        step1.append(step2)
        step1.append(step3)
        step1.append(step4)
        step1.append(step5)
        step1.append(step6)
        step1.append(step7)
        
        step_four_attr_array.add(["attr":step1,
                                 "bottomGap":kFitWidth(8)])
    }
    func getContent_4_3_2(){
        let titleAttr = NSMutableAttributedString(string: "4.3.2 激活计划")
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        titleAttr.yy_lineSpacing = lineSpacing
        
        step_four_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(53),
                                 "button":["title":"(请参照1.2)",
                                           "catalogue":catalogue_type.catalogue_12]])
    }
    
    func getContent_4_3_3(){
        let titleAttr = NSMutableAttributedString(string: "4.3.3 执行计划")
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        titleAttr.yy_lineSpacing = lineSpacing
        
        step_four_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(53),
                                 "button":["title":"(请参照1.3)",
                                           "catalogue":catalogue_type.catalogue_13]])
    }
    func getContent_4_3_4(){
        let titleAttr = NSMutableAttributedString(string: "4.3.4 添加/删减/修改食物")
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        titleAttr.yy_lineSpacing = lineSpacing
        
        step_four_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(53),
                                 "button":["title":"(请参照1.4)",
                                           "catalogue":catalogue_type.catalogue_14]])
    }
    func getContent_4_3_5(){
        let titleAttr = NSMutableAttributedString(string: "4.3.5 创建食物")
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        titleAttr.yy_lineSpacing = lineSpacing
        
        step_four_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(53),
                                 "button":["title":"(请参照1.5)",
                                           "catalogue":catalogue_type.catalogue_15]])
    }
    func getContent_4_3_6(){
        let titleAttr = NSMutableAttributedString(string: "4.3.6 快速添加")
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        titleAttr.yy_lineSpacing = lineSpacing
        
        step_four_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(53),
                                 "button":["title":"(请参照1.6)",
                                           "catalogue":catalogue_type.catalogue_16]])
    }
    func getContent_4_3_7(){
        let titleAttr = NSMutableAttributedString(string: "4.3.7 更换计划/清空计划列表")
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        titleAttr.yy_lineSpacing = lineSpacing
        
        step_four_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(53),
                                 "button":["title":"(请参照1.7)",
                                           "catalogue":catalogue_type.catalogue_17]])
    }
    func getContent_4_3_8(){
        let titleAttr = NSMutableAttributedString(string: "4.3.8 分享当日饮食")
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        titleAttr.yy_lineSpacing = lineSpacing
        
        step_four_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(53),
                                 "button":["title":"(请参照1.8)",
                                           "catalogue":catalogue_type.catalogue_18]])
    }
    
    func getContent_5_1(){
        let titleAttr = NSMutableAttributedString(string: "5.1 记录数据\n")
        let step1 = NSMutableAttributedString(string: "步骤 1：在“首页”体重数据栏/体重维度栏旁边的“+”进入添加数据页面\n步骤 2：填写任意数据或上传图片并点击保存\n每天每种数据只能记录一次，如重复上传将以最后一个数据为准")
        
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step1)
        
        titleAttr.yy_lineSpacing = lineSpacing
        step1.yy_minimumLineHeight = lineHeight
        
        titleAttr.append(step1)
        
        step_five_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(291),
                                  "imgs":["tutorials_5_1_1",
                                         "tutorials_5_1_2"],
                                    "steps":["步骤1",
                                            "步骤2"]])
    }
    func getContent_5_2(){
        let titleAttr = NSMutableAttributedString(string: "5.2 查看数据\n")
        let step1 = NSMutableAttributedString(string: "在“首页”点击体重数据栏/体重维度栏\n您可以通过对比身体状况、数据变化以及历史饮食日志，调整并优化计划，以找到最适合的饮食方案")
        
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step1)
        
        titleAttr.yy_lineSpacing = lineSpacing
        step1.yy_minimumLineHeight = lineHeight
        
        titleAttr.append(step1)
        
        step_five_attr_array.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(24)])
    }
    public func getNutritionTipsAttr(){
        let titleAttr = NSMutableAttributedString(string: "·手动输入\n")
        let step1 = NSMutableAttributedString(string: "自行设定您的卡路里、蛋白质、碳水化合物、脂肪目标，适合")
        let step2 = NSMutableAttributedString(string: "具备基础营养知识的用户")
        let step3 = NSMutableAttributedString(string: "。")
        let step4 = NSMutableAttributedString(string: "·智能推荐\n")
        let step5 = NSMutableAttributedString(string: "我们基于您的需求为您设定卡路里、蛋白质、碳水化合物、脂肪目标，适合")
        let step6 = NSMutableAttributedString(string: "各类人群")
        let step7 = NSMutableAttributedString(string: "。\n\n")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: .systemFont(ofSize: 14, weight: .medium), attr: titleAttr)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: .systemFont(ofSize: 14, weight: .regular), attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: .systemFont(ofSize: 14, weight: .medium), attr: step2)
        step2.yy_backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: .systemFont(ofSize: 14, weight: .regular), attr: step3)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: .systemFont(ofSize: 14, weight: .medium), attr: step4)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: .systemFont(ofSize: 14, weight: .regular), attr: step5)
        setAttr(color: .COLOR_GRAY_BLACK_85, font: .systemFont(ofSize: 14, weight: .medium), attr: step6)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: .systemFont(ofSize: 14, weight: .regular), attr: step7)
        step6.yy_backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
        
        titleAttr.yy_lineSpacing = kFitWidth(8)
        step1.yy_minimumLineHeight = kFitWidth(20)
        step2.yy_minimumLineHeight = kFitWidth(20)
        step3.yy_minimumLineHeight = kFitWidth(20)
        step4.yy_lineSpacing = lineSpacing
        step5.yy_minimumLineHeight = kFitWidth(20)
        step6.yy_minimumLineHeight = kFitWidth(20)
        step7.yy_minimumLineHeight = kFitWidth(20)
        
        step4.append(step5)
        step4.append(step6)
        step4.append(step7)
        step4.append(titleAttr)
        step4.append(step1)
        step4.append(step2)
        step4.append(step3)
        
        nutritionAttr = step4
    }
    public func getSportTipsAttr(){
        let gotPlanAttr1 = NSMutableAttributedString(string: "*")
        let gotPlanAttr2 = NSMutableAttributedString(string: "如你使用的是系统生成的目标，则")
        let gotPlanAttr3 = NSMutableAttributedString(string: "无需额外记录运动消耗")
        let gotPlanAttr4 = NSMutableAttributedString(string: "，因为你的营养目标内已包含：增肌/减脂所需的盈余/缺口、基础代谢 (BMR) ，和运动+日常消耗 (EAT+NEAT)。")
        
        setAttr(color: .COLOR_GRAY_BLACK_65, font: .systemFont(ofSize: 16, weight: .medium), attr: gotPlanAttr1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: .systemFont(ofSize: 14, weight: .regular), attr: gotPlanAttr2)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: .systemFont(ofSize: 14, weight: .regular), attr: gotPlanAttr3)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: .systemFont(ofSize: 14, weight: .regular), attr: gotPlanAttr4)
        gotPlanAttr3.yy_backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
        
        gotPlanAttr1.append(gotPlanAttr2)
        gotPlanAttr1.append(gotPlanAttr3)
        gotPlanAttr1.append(gotPlanAttr4)
        
        sportTipsAttr = gotPlanAttr1
    }
    
    public func getSportMetsTipsAttr(){
        let attr = NSMutableAttributedString(string: "·METs(人体代谢当量)\n")
        let step1 = NSMutableAttributedString(string: "METs 是一种用来衡量身体活动能量消耗的单位。\nMET 值越高表示能量消耗越多。1MET 被定义为人在安静休息时每公斤体重每分钟消耗的能量，约为 3.5 毫升氧气(mL Oz/kg/min)或每小时每公斤1千卡(kcal/kg/h)。\n运动净消耗(kcal) = (MET-1)x体重(kg)x 时间(小时)\n\n")
        let step2 = NSMutableAttributedString(string: "*")
        let step3 = NSMutableAttributedString(string: "运动净消耗：仅计算运动带来的额外能量消耗，不包括运动期间身体的基础代谢消耗。\n\n")
        
        let gotPlanAttr1 = NSMutableAttributedString(string: "*")
        let gotPlanAttr2 = NSMutableAttributedString(string: "如你使用的是系统生成的目标，则")
        let gotPlanAttr3 = NSMutableAttributedString(string: "无需额外记录运动消耗")
        let gotPlanAttr4 = NSMutableAttributedString(string: "，因为你的营养目标内已包含：增肌/减脂所需的盈余/缺口、基础代谢 (BMR) ，和运动+日常消耗 (EAT+NEAT)。")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: .systemFont(ofSize: 16, weight: .medium), attr: attr)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: .systemFont(ofSize: 14, weight: .regular), attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: .systemFont(ofSize: 16, weight: .medium), attr: step2)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: .systemFont(ofSize: 14, weight: .regular), attr: step3)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: .systemFont(ofSize: 16, weight: .medium), attr: gotPlanAttr1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: .systemFont(ofSize: 14, weight: .regular), attr: gotPlanAttr2)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: .systemFont(ofSize: 14, weight: .regular), attr: gotPlanAttr3)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: .systemFont(ofSize: 14, weight: .regular), attr: gotPlanAttr4)
        gotPlanAttr3.yy_backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
        
        attr.append(step1)
        attr.append(step2)
        attr.append(step3)
        attr.append(gotPlanAttr1)
        attr.append(gotPlanAttr2)
        attr.append(gotPlanAttr3)
        attr.append(gotPlanAttr4)
        
        sportMetsTipsAttr = attr
    }
    
    func createAttributedStringWithImage(image: UIImage, text: String) -> NSMutableAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: (UIFont.systemFont(ofSize: 11, weight: .regular).capHeight - image.size.height).rounded() / 2, width: image.size.width, height: image.size.height)
        let attachmentString = NSMutableAttributedString(attachment: attachment)
        
        let string = NSMutableAttributedString(string: text)
        string.append(attachmentString)
        
        return string
    }
    func setAttr(color:UIColor,font:UIFont,attr:NSMutableAttributedString) {
        attr.yy_font = font
        attr.yy_color = color
    }
}
