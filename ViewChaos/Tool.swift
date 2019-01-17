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


extension UIDevice{
    var modelName:String{
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce(""){identifier,element in
            guard let value = element.value as? Int8,value != 0 else{
                return identifier
            }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
        // iPod
        case "iPod1,1":                                 return "iPod touch"
        case "iPod2,1":                                 return "iPod touch 2"
        case "iPod3,1":                                 return "iPod touch 3"
        case "iPod4,1":                                 return "iPod touch 4"
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        // iPhone
        case "iPhone1,1":                               return "iPhone"
        case "iPhone1,2":                               return "iPhone 3G"
        case "iPhone2,1":                               return "iPhone 3GS"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        // iPad
        case "iPad1,1":                                 return "iPad"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) 2"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
        case "iPad7,5", "iPad7,6":                      return "iPad 6"
        // AppleTV
        case "AppleTV5,3":                              return "Apple TV"
        // Other
        case "i386", "x86_64":                          return "Simulator"
        default: return identifier
        }
    }
    
    
}

//获取设备类型，根据屏的w
enum DeviceResution{
    case Res414X896,Res375X812,Res320X568,Res414X736,Res375X667
}

extension UIDevice{
    static var screenResution:DeviceResution{
        let res = UIScreen.main.bounds
        if res.height == 896{
            return DeviceResution.Res414X896
        }
        else if res.height == 812{
             return DeviceResution.Res375X812
        }
        else if res.height == 736{
             return DeviceResution.Res375X812
        }
        else if res.height == 667{
            return DeviceResution.Res375X667
        }
        return DeviceResution.Res320X568
    }
}

