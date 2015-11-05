//
//  Stuff.swift
//  ViewChaosDemo
//
//  Created by Tyrant on 11/5/15.
//  Copyright © 2015 Qfq. All rights reserved.
//


import UIKit


let ScreenWidth = UIScreen.mainScreen().bounds.width
let ScreenHeight = UIScreen.mainScreen().bounds.height
let SystemVersion:Double = Double(UIDevice.currentDevice().systemVersion)!
let APPVersion: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
let Scale = ScreenWidth / 320.0
let VcWillMoveToSuperview = "vcWillMoveToSuperview"
let VcWillRemoveSubview = "vcWillRemoveSubview"
let VcDidAddSubview = "vcDidAddSubview"
let handleTraceView = "handleTraceView"
let handleTraceContraints = "handleTraceContraints"
let handleTraceAddSubView = "handleTraceAddSubView"
let handleTraceShow = "handleTraceShow"
let handleTraceRemoveView = "handleTraceRemoveView"
let handleTraceRemoveSubView = "handleTraceRemoveSubView"

func createInstanseFromString(className:String)->NSObject!{
    let classType: AnyClass! = NSClassFromString(className)
    let objType = classType as? NSObject.Type
    assert(objType != nil, "class not found,please check className")
    return objType!.init()
}


typealias Task = (cancel:Bool)->()
func delay(time:NSTimeInterval,task:()->())->Task?{
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC)))
    func dispatch_later(block:()->()){
        dispatch_after(delayTime, dispatch_get_main_queue(), block)
    }
    var closure:dispatch_block_t? = task
    var result:Task?
    let delayClosure:Task = {
        cancel in
        if let internalClosure = closure{
            if cancel == false{
                dispatch_async(dispatch_get_main_queue(), internalClosure)
            }
        }
        closure = nil
        result = nil
    }
    result = delayClosure
    dispatch_later { () -> () in
        if let delayClosure = result{
            delayClosure(cancel: false)
        }
    }
    return result
}

func cancel(task:Task?){
    task?(cancel:true)
}


func Log<T>(message:T,file:String = __FILE__, method:String = __FUNCTION__,line:Int = __LINE__){
    #if DEBUG
        if   let path = NSURL(string: file)
        {
            print("\(path.lastPathComponent!)[\(line)],\(method) \(message)")
        }
        else
        {
            print("[\(line)],\(method) \(message)")
        }
    #endif
}


func +(lhs: Int,rhs:Double)->Double{
    return Double(lhs) + rhs
}

func +(lhs: Double,rhs:Int)->Double{
    return lhs + Double(rhs)
}

func +(lhs: Int,rhs:Float)->Float{
    return Float(lhs) + rhs
}

func +(lhs: Float,rhs:Int)->Float{
    return lhs + Float(rhs)
}

func +(lhs: Float,rhs:Double)->Double{
    return Double(lhs) + rhs
}

func +(lhs: Double,rhs:Float)->Double{
    return lhs + Double(rhs)
}


func +(lhs: UInt,rhs:Double)->Double{
    return Double(lhs) + rhs
}

func +(lhs: Double,rhs:UInt)->Double{
    return lhs + Double(rhs)
}

func +(lhs: UInt,rhs:Float)->Float{
    return Float(lhs) + rhs
}

func +(lhs: Float,rhs:UInt)->Float{
    return lhs + Float(rhs)
}




func -(lhs: Int,rhs:Double)->Double{
    return Double(lhs) - rhs
}

func -(lhs: Double,rhs:Int)->Double{
    return lhs - Double(rhs)
}

func -(lhs: Int,rhs:Float)->Float{
    return Float(lhs) - rhs
}

func -(lhs: Float,rhs:Int)->Float{
    return lhs - Float(rhs)
}

func -(lhs: Float,rhs:Double)->Double{
    return Double(lhs) - rhs
}

func -(lhs: Double,rhs:Float)->Double{
    return lhs - Double(rhs)
}


func -(lhs: UInt,rhs:Double)->Double{
    return Double(lhs) - rhs
}

func -(lhs: Double,rhs:UInt)->Double{
    return lhs - Double(rhs)
}

func -(lhs: UInt,rhs:Float)->Float{
    return Float(lhs) - rhs
}

func -(lhs: Float,rhs:UInt)->Float{
    return lhs - Float(rhs)
}



func *(lhs: Int,rhs:Double)->Double{
    return Double(lhs) * rhs
}

func *(lhs: Double,rhs:Int)->Double{
    return lhs * Double(rhs)
}

func *(lhs: Int,rhs:Float)->Float{
    return Float(lhs) * rhs
}

func *(lhs: Float,rhs:Int)->Float{
    return lhs * Float(rhs)
}

func *(lhs: Float,rhs:Double)->Double{
    return Double(lhs) * rhs
}

func *(lhs: Double,rhs:Float)->Double{
    return lhs * Double(rhs)
}


func *(lhs: UInt,rhs:Double)->Double{
    return Double(lhs) * rhs
}

func *(lhs: Double,rhs:UInt)->Double{
    return lhs * Double(rhs)
}

func *(lhs: UInt,rhs:Float)->Float{
    return Float(lhs) * rhs
}

func *(lhs: Float,rhs:UInt)->Float{
    return lhs * Float(rhs)
}


func /(lhs: Int,rhs:Double)->Double{
    return Double(lhs) / rhs
}

func /(lhs: Double,rhs:Int)->Double{
    return lhs / Double(rhs)
}

func /(lhs: Int,rhs:Float)->Float{
    return Float(lhs) / rhs
}

func /(lhs: Float,rhs:Int)->Float{
    return lhs / Float(rhs)
}

func /(lhs: Float,rhs:Double)->Double{
    return Double(lhs) / rhs
}

func /(lhs: Double,rhs:Float)->Double{
    return lhs / Double(rhs)
}


func /(lhs: UInt,rhs:Double)->Double{
    return Double(lhs) / rhs
}

func /(lhs: Double,rhs:UInt)->Double{
    return lhs / Double(rhs)
}

func /(lhs: UInt,rhs:Float)->Float{
    return Float(lhs) / rhs
}

func /(lhs: Float,rhs:UInt)->Float{
    return lhs / Float(rhs)
}
func hookMethod(cls:AnyClass,originalSelector:Selector,swizzleSelector:Selector){  //交换方法
    let originalMethod = class_getInstanceMethod(cls, originalSelector)
    let swizzledMethod = class_getInstanceMethod(cls, swizzleSelector)
    let didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
    if didAddMethod{
        class_replaceMethod(cls, swizzleSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    }
    else{
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
private var NSObject_Name = 0
extension NSObject{
    @objc  var name:String?{
        get{
            return objc_getAssociatedObject(self, &NSObject_Name) as? String
        }
        set{
            objc_setAssociatedObject(self, &NSObject_Name, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

extension Float{
    func format(f:String)->String{
        return String(format:"%\(f)",self)
    }
}
extension Double{
    func format(f:String)->String{
        return String(format:"%\(f)",self)
    }
}
extension CGFloat{
    func format(f:String)->String{
        return String(format:"%\(f)",self)
    }
}

func currentDate(f:String?)->String{
    let  dateFormatter = NSDateFormatter()
    if f == nil{
        dateFormatter.dateFormat = "HH:mm:ss:SSS"
    }
    else{
        dateFormatter.dateFormat = f!
    }
    let str = dateFormatter.stringFromDate(NSDate())
    return str
}
