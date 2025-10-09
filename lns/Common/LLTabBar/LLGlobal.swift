//
//  LLGlobal.swift
//  swiftStudy01
//
//  Created by 刘恋 on 2019/6/6.
//  Copyright © 2019 刘恋. All rights reserved.
//

import UIKit

public let kScreenWidth = UIScreen.main.bounds.size.width
public let kScreenHeight = UIScreen.main.bounds.size.height

class LLGlobal: NSObject {

}

func colorWithHexString (Color_Value:NSString, alpha: CGFloat)->UIColor{
    var  Str :NSString = Color_Value
    if Color_Value.hasPrefix("#"){
        Str=(Color_Value as NSString).substring(from: 1) as NSString
    }
    let redStr = (Str as NSString ).substring(to: 2)
    let greenStr = ((Str as NSString).substring(from: 2) as NSString).substring(to: 2)
    let blueStr = ((Str as NSString).substring(from: 4) as NSString).substring(to: 2)
    var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
    Scanner(string:redStr).scanHexInt32(&r)
    Scanner(string: greenStr).scanHexInt32(&g)
    Scanner(string: blueStr).scanHexInt32(&b)
    return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: alpha)
}


