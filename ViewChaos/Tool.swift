//
//  Tool.swift
//  ViewChaosDemo
//
//  Created by Stan Hu on 2019/1/16.
//  Copyright © 2019 Qfq. All rights reserved.
//

import UIKit


extension Float{
    func format(_ f:String)->String{
        return String(format:"%\(f)",self)
    }
}
extension Double{
    func format(_ f:String)->String{
        return String(format:"%\(f)",self)
    }
}
extension CGFloat{
    func format(_ f:String)->String{
        return String(format:"%\(f)",self)
    }
}

private var NSObject_Name = 0
extension NSObject{
    @objc  var chaosName:String?{
        get{
            return objc_getAssociatedObject(self, &NSObject_Name) as? String
        }
        set{
            objc_setAssociatedObject(self, &NSObject_Name, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

private var UIWindow_Feature = "UIWindow_Feature"

extension UIWindow{
    @objc var chaosFeature:Int{
        get{
            let v = objc_getAssociatedObject(self, &UIWindow_Feature)
            if let str =  v as? String{
                if let n = Int(str)
                {
                    return n
                }
            }
            return 0
            //    return objc_getAssociatedObject(self, &UIWindow_Feature) as! Int
        }
        set{
            objc_setAssociatedObject(self, &UIWindow_Feature, "\(newValue)", objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
            //Issue1, 要添加不同的类型的属性,就要设置正确的objc_AssociationPolicy,如果是Class,就要用OBJC_ASSOCIATION_RETAIN_NONATOMIC,Int要用OBJC_ASSOCIATION_ASSIGN,String要用OBJC_ASSOCIATION_COPY_NONATOMIC
            //不然后可能会造成数据丢失或者其他异常
            //注意objc_AssociationPolicy类型一定要正确,不然可能会从内存里丢失
            //Issue 12: 在最新的Swift3里面，好像不能保存Int到AssociatedObject里面，反正每次都取不出来。我换成STRING 就OK了
        }
    }
}



private var UIView_Level = "UIView_Level"
extension UIView{
    @objc var viewLevel:Int{
        get{
            let v = objc_getAssociatedObject(self, &UIView_Level)
            if let str =  v as? String{
                if let n = Int(str)
                {
                    return n
                }
            }
            return 0
        }
        set{
            objc_setAssociatedObject(self, &UIView_Level, "\(newValue)", objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}


extension UIAlertView {
    static func setMessage(_ msg:String)->UIAlertView{
        let alert = BlockAlert()
        alert.message = msg
        return alert
    }
    
    func addAlertStyle(_ style:UIAlertViewStyle)->UIAlertView{
        self.alertViewStyle = style
        return self
    }
    
    func addTitle(_ title:String)->UIAlertView{
        self.title = title
        return self
    }
    
    func addFirstButton(_ btnTitle:String)->UIAlertView{
        self.addButton(withTitle: btnTitle)
        return self
    }
    
    func addSecondButton(_ btnTitle:String)->UIAlertView{
        self.addButton(withTitle: btnTitle)
        return self
    }
    
    func addButtons(_ btnTitles:[String])->UIAlertView{
        for title in btnTitles{
            self.addButton(withTitle: title)
        }
        return self
    }
    
    func addButtonClickEvent(_ clickButton:((_ buttonIndex:Int,_ alert:UIAlertView)->Void)?)->UIAlertView{
        if let alert = self as? BlockAlert{
            alert.completion = clickButton
        }
        return self
    }
    
    func addDidDismissEvent(_ event:((_ buttonIndex:Int,_ alert:UIAlertView)->Void)?)->UIAlertView{
        if let alert = self as? BlockAlert{
            alert.didDismissBlock = event
        }
        return self
    }
    
    func addWillDismissEvent(_ event:((_ buttonIndex:Int,_ alert:UIAlertView)->Void)?)->UIAlertView{
        if let alert = self as? BlockAlert{
            alert.willDismissBlock = event
        }
        return self
    }
    
    
    func addDidPresentEvent(_ event:((_ alert:UIAlertView)->Void)?)->UIAlertView{
        if let alert = self as? BlockAlert{
            alert.didPresentBlock = event
        }
        return self
    }
    
    func addWillPresentEvent(_ event:((_ alert:UIAlertView)->Void)?)->UIAlertView{
        if let alert = self as? BlockAlert{
            alert.willPresentBlock = event
        }
        return self
    }
    
    func addAlertCancelEvent(_ event:((_ alert:UIAlertView)->Void)?)->UIAlertView{
        if let alert = self as? BlockAlert{
            alert.alertWithCalcelBlock = event
        }
        return self
    }
    
    
    func alertWithButtonClick(_ clickButton:((_ buttonIndex:Int,_ alert:UIAlertView)->Void)?){
        if let alert = self as? BlockAlert{
            alert.completion = clickButton
            alert.show()
        }
    }
}
