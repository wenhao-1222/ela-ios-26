//
//  TutorialUpdateAttr.swift
//  lns
//
//  Created by LNS2 on 2024/6/18.
//

import Foundation

extension TutorialAttr{
    func getAttrUpate() {
        getTutorial_1_1()
        getTutorial_1_2_1()
        getTutorial_1_2_2()
        getTutorial_1_3()
        getTutorial_2_1()
        getTutorial_2_2()
        getTutorial_3_1()
        getTutorial_3_2_1()
        getTutorial_3_2_2()
        getTutorial_3_3_1()
        getTutorial_3_3_2()
        getTutorial_3_3_3()
        getTutorial_3_3_4()
        getTutorial_4_1()
        getTutorial_5_1()
        getTutorial_6_1()
        getTutorial_7_1()
        getTutorial_8_1()
        getTutorial_8_2()
        getTutorial_9_1()
        getTutorial_9_2()
        getTutorial_10()
    }
    
    public func getDataSource() -> NSArray {
        return [["title":"如何获取计划/创建计划？",
                         "dataArr":tutorial_array_1],
                ["title":"如何获取/设置营养目标？",
                         "dataArr":tutorial_array_2],
                ["title":"如何执行计划/修改计划/自行记录饮食？",
                         "dataArr":tutorial_array_3],
                ["title":"如何使用创建食物，\n添加数据库里没有的食物？",
                         "dataArr":tutorial_array_4],
                ["title":"如何使用快速添加?",
                         "dataArr":tutorial_array_5],
                ["title":"如何更换计划/取消已激活的计划?",
                         "dataArr":tutorial_array_6],
                ["title":"如何分享计划?",
                         "dataArr":tutorial_array_7],
                ["title":"如何分享当日饮食? ",
                         "dataArr":tutorial_array_8],
                ["title":"如何记录身体状态，维度数据?",
                         "dataArr":tutorial_array_9],
                ["title":"如何添加小组件？",
                         "dataArr":tutorial_array_10]]
    }
    /**
      1.免费获取饮食计划，激活并执行计划
     */
    func getTutorial_1_1() {
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
        
        tutorial_array_1.add(["attr":titleAttr,
                              "bottomGap":kFitWidth(287),
                              "imgs":["tutorials_1_1_1",
                                     "tutorials_1_1_2"],
                              "steps":["步骤1",
                                      "步骤2"]])
    }
    
    func getTutorial_1_2_1(){
        let titleAttr = NSMutableAttributedString(string: "1.2 自定义制作计划\n")
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
        
        tutorial_array_1.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(278),
                                 "imgs":["tutorials_4_1_1",
                                        "tutorials_4_1_2"],
                                   "steps":["步骤1",
                                           "步骤2-4"]])
    }
    func getTutorial_1_2_2(){
        let titleAttr = NSMutableAttributedString(string: " 分享计划给其他用户\n")
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        titleAttr.yy_lineSpacing = lineSpacing
        
        tutorial_array_1.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(33),
                                 "button":["title":"(请参照 7.如何分享计划？)",
                                           "catalogue":catalogue_type.catalogue_7]])
    }
    func getTutorial_1_3(){
        let titleAttr = NSMutableAttributedString(string: "1.3 接收计划用户的操作\n")
        let step1 = NSMutableAttributedString(string: "自动接收计划：将分享码复制在剪切板，进入 Elavatine 软件后将自动唤醒弹窗，点击确认导入该计划即可")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step1)
        
        titleAttr.yy_lineSpacing = lineSpacing
        step1.yy_minimumLineHeight = lineHeight
        
        titleAttr.append(step1)
        
        tutorial_array_1.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(256),
                                 "imgs":["tutorials_4_3_1",
                                        "tutorials_4_3_2"]])
    }
    
    func getTutorial_2_1(){
        let titleAttr = NSMutableAttributedString(string: "2.1 填写问卷获取营养目标\n")
        let step1 = NSMutableAttributedString(string: "步骤 1：前往日志页-")
        let step2 = NSMutableAttributedString(string: "点击免费获取计划\n")
        let step3 = NSMutableAttributedString(string: "步骤 2：填写完整问卷，")
        let step4 = NSMutableAttributedString(string: "并选择我只需要营养目标\n")
        let step5 = NSMutableAttributedString(string: "步骤 3：点击激活目标\n")
        let step6 = NSMutableAttributedString(string: "如需更换目标")
        let step7 = NSMutableAttributedString(string: "：直接重复步骤1，2，3即可，或参照（2.2）")
        
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
        
        tutorial_array_2.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(287),
                                 "imgs":["tutorials_2_1_1",
                                        "tutorials_2_1_2",
                                         "tutorials_2_1_3"],
                                 "steps":["步骤1",
                                         "步骤2",
                                          "步骤3"]])
    }
    func getTutorial_2_2(){
        let titleAttr = NSMutableAttributedString(string: "2.2 设定营养目标\n")
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
        
        tutorial_array_2.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(287),
                                 "imgs":["tutorials_3_1_1",
                                        "tutorials_3_1_2"],
                                   "steps":["步骤1",
                                           "步骤2"]])
    }
    
    
    func getTutorial_3_1(){
        let titleAttr = NSMutableAttributedString(string: "3.1 激活计划\n")
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
        
        tutorial_array_3.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(287),
                                 "imgs":["tutorials_1_2_3",
                                         "tutorials_1_2_1",
                                        "tutorials_1_2_2"],
                                 "steps":["步骤1",
                                         "步骤2.1",
                                          "步骤2.2"]])
    }
    func getTutorial_3_2_1(){
        let titleAttr = NSMutableAttributedString(string: "3.2 执行计划\n")
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
        
        tutorial_array_3.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(277),
                                 "imgs":["tutorials_1_3_1_1",
                                         "tutorials_1_3_1_2",
                                         "tutorials_1_3_1_3"],
                                 "steps":["左右滑动翻页",
                                         "点击翻页",
                                          "选择日期翻页"]])
    }
    func getTutorial_3_2_2(){
        let step1 = NSMutableAttributedString(string: "执行计划")
        var step2 = NSMutableAttributedString(string: "：食用完该食物之后点击列表右边的")
        
        step2 = createAttributedStringWithImage(image: UIImage.init(named: "tutorials_eat_icon")!, text: "：食用完该食物之后点击列表右边的")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step2)
        
        step1.yy_minimumLineHeight = lineHeight
        step2.yy_minimumLineHeight = lineHeight
        
        step1.append(step2)
        
        tutorial_array_3.add(["attr":step1,
                                 "bottomGap":kFitWidth(268),
                                 "imgs":["tutorials_1_3_2"]])
    }
    func getTutorial_3_3_1() {
        let titleAttr = NSMutableAttributedString(string: "3.3 添加/删减/修改食物\n")
        let step1 = NSMutableAttributedString(string: "添加食物")
        var step2 = NSMutableAttributedString(string: "：如某餐吃了计划以外的食物，或根据营养目标自行添加食物的用户，可通过点击该餐右上角的")
        let step3 = NSMutableAttributedString(string: "进入搜索页，随后使用顶部的搜索栏搜索到该食物，点击食物，选择摄入的单位和数量点击“添加”即可。")
        
        step2 = createAttributedStringWithImage(image: UIImage.init(named: "tutorials_add_icon")!, text: "：如某餐吃了计划以外的食物，或根据营养目标自行添加食物的用户，可通过点击该餐右上角的")
        
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
        
        
        tutorial_array_3.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(257),
                                 "imgs":["tutorials_1_4_1",
                                        "tutorials_1_4_2",
                                        "tutorials_1_4_3"]])
    }
    func getTutorial_3_3_2(){
        let step1 = NSMutableAttributedString(string: "删减食物")
        let step2 = NSMutableAttributedString(string: "：如该餐内有没吃的食物，可在日志列表内左滑该食物进行删除")
        
//        step2 = createAttributedStringWithImage(image: UIImage.init(named: "tutorials_eat_icon")!, text: "：食用完该食物之后点击列表右边的")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step2)
        
        step1.yy_minimumLineHeight = lineHeight
        step2.yy_minimumLineHeight = lineHeight
        
        step1.append(step2)
        
        tutorial_array_3.add(["attr":step1,
                                 "bottomGap":kFitWidth(276),
                                 "imgs":["tutorials_1_4_4",
                                        "tutorials_1_4_4_2",
                                        "tutorials_1_4_4_3"],
                                 "steps":["单项删除",
                                         "批量删除_步骤1",
                                          "批量删除_步骤2"]])
    }
    func getTutorial_3_3_3(){
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
        
        tutorial_array_3.add(["attr":step1,
                                 "bottomGap":kFitWidth(257),
                                 "imgs":["tutorials_1_4_5",
                                        "tutorials_1_4_6"]])
    }
    func getTutorial_3_3_4(){
        let step1 = NSMutableAttributedString(string: "偏离计划")
        var step2 = NSMutableAttributedString(string: "：添加/删减/修改食物可能会导致您无法填满/超出您的营养目标进度。")
        
//        step2 = createAttributedStringWithImage(image: UIImage.init(named: "tutorials_eat_icon")!, text: "：食用完该食物之后点击列表右边的")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_11_medium, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step2)
        
        step1.yy_minimumLineHeight = lineHeight
        step2.yy_minimumLineHeight = lineHeight
        
        step1.append(step2)
        
        tutorial_array_3.add(["attr":step1,
                                 "bottomGap":kFitWidth(22),
                                 "imgs":[]])
    }
    
    func getTutorial_4_1(){
        let titleAttr = NSMutableAttributedString(string: "")
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
        
        tutorial_array_4.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(287),
                                 "imgs":["tutorials_1_5_1",
                                        "tutorials_1_5_2",
                                        "tutorials_1_5_3"],
                                 "steps":["",
                                         "点击直接输入/修改",
                                          ""]])
    }
    func getTutorial_5_1(){
        let titleAttr = NSMutableAttributedString(string: "")
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
        
        tutorial_array_5.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(287),
                                 "imgs":["tutorials_1_6_1",
                                        "tutorials_1_6_2",
                                        "tutorials_1_6_3"],
                                 "steps":["",
                                         "",
                                          "点击直接输入/修改"]])
    }
    func getTutorial_6_1(){
        let titleAttr = NSMutableAttributedString(string: "")
        let step1 = NSMutableAttributedString(string: "如需更换新计划")
        let step2 = NSMutableAttributedString(string: "：直接重复（1.1）即可。激活新计划将会清空日志内今日之后的所有计划，新计划从今日开始覆盖。\n")
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
        
        tutorial_array_6.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(268),
                                 "imgs":["tutorials_1_7_1",
                                        "tutorials_1_7_2",
                                        "tutorials_1_7_3"]])
    }
    
    func getTutorial_7_1(){
        let titleAttr = NSMutableAttributedString(string: "")
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
        
        tutorial_array_7.add(["attr":titleAttr,
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
    func getTutorial_8_1(){
        let titleAttr = NSMutableAttributedString(string: "")
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
        
        tutorial_array_8.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(268),
                                 "imgs":["tutorials_1_8_1",
                                        "tutorials_1_8_2"]])
    }
    func getTutorial_8_2(){
        let titleAttr = NSMutableAttributedString(string: "如何接收别人分享的计划\n")
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        titleAttr.yy_lineSpacing = lineSpacing
        
        tutorial_array_8.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(33),
                                 "button":["title":"(请参照 1.3)",
                                           "catalogue":catalogue_type.catalogue_13]])
    }
    
    func getTutorial_9_1(){
        let titleAttr = NSMutableAttributedString(string: "9.1 记录数据\n")
        let step1 = NSMutableAttributedString(string: "步骤 1：在“首页”体重数据栏/体重维度栏旁边的“+”进入添加数据页面\n步骤 2：填写任意数据或上传图片并点击保存\n每天每种数据只能记录一次，如重复上传将以最后一个数据为准")
        
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step1)
        
        titleAttr.yy_lineSpacing = lineSpacing
        step1.yy_minimumLineHeight = lineHeight
        
        titleAttr.append(step1)
        
        tutorial_array_9.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(291),
                                  "imgs":["tutorials_5_1_1",
                                         "tutorials_5_1_2"],
                                    "steps":["步骤1",
                                            "步骤2"]])
    }
    func getTutorial_9_2(){
        let titleAttr = NSMutableAttributedString(string: "9.2 查看数据\n")
        let step1 = NSMutableAttributedString(string: "在“首页”点击体重数据栏/体重维度栏\n您可以通过对比身体状况、数据变化以及历史饮食日志，调整并优化计划，以找到最适合的饮食方案")
        
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step1)
        
        titleAttr.yy_lineSpacing = lineSpacing
        step1.yy_minimumLineHeight = lineHeight
        
        titleAttr.append(step1)
        
        tutorial_array_9.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(24)])
    }
    func getTutorial_10(){
        let titleAttr = NSMutableAttributedString(string: "")
        var step1 = NSMutableAttributedString(string: "1.长按桌面空白区域\n")
        let step2 = NSMutableAttributedString(string: "2.点击左上角的 “+” 号\n")
        let step3 = NSMutableAttributedString(string: "3.点击搜索输入框，输入“ELavatine”搜索\n")
        let step4 = NSMutableAttributedString(string: "4.选择“Elavatine”，左后滑动选择小组件样式\n")
        let step5 = NSMutableAttributedString(string: "5.点击“添加小组件按钮”即可")
        
        setAttr(color: .COLOR_GRAY_BLACK_85, font: font_13_medium, attr: titleAttr)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step1)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step2)
        setAttr(color: .COLOR_GRAY_BLACK_65, font: font_11_regular, attr: step3)
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
        
        tutorial_array_10.add(["attr":titleAttr,
                                 "bottomGap":kFitWidth(280),
                                 "imgs":["tutorials_1_8_1",
                                        "tutorials_1_8_2"]])
    }
    
}
