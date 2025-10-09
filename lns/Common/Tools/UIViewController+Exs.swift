//
//  UIViewController+Exs.swift
//  ttjx
//
//  Created by 文 on 2020/4/1.
//  Copyright © 2020 ttjx. All rights reserved.
//

import UIKit

extension UIViewController{
    // MARK:返回className
    var ClassName:String{
        get{
            let name =  type(of: self).description()
            if(name.contains(".")){
                return name.components(separatedBy: ".")[1];
            }else{
                return name;
            }
            
        }
    }
    
}
