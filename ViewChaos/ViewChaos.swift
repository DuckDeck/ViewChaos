//
//  ViewChaos.swift
//  ViewChaosDemo
//
//  Created by Tyrant on 11/5/15.
//  Copyright © 2015 Qfq. All rights reserved.
//

import UIKit
extension UIWindow {
    #if DEBUG
    public override  class func initialize(){
    struct UIWindow_SwizzleToken {
    static var onceToken:dispatch_once_t = 0
        }
            dispatch_once(&UIWindow_SwizzleToken.onceToken) { () -> Void in
            Chaos.hookMethod(UIWindow.self, originalSelector: Selector("makeKeyAndVisible"), swizzleSelector: Selector("vcMakeKeyAndVisible"))
            Chaos.hookMethod(UIView.self, originalSelector: Selector("willMoveToSuperview:"), swizzleSelector: Selector("vcWillMoveToSuperview:"))
            Chaos.hookMethod(UIView.self, originalSelector: Selector("willRemoveSubview:"), swizzleSelector: Selector("vcWillRemoveSubview:"))
            Chaos.hookMethod(UIView.self, originalSelector: Selector("didAddSubview:"), swizzleSelector: Selector("vcDidAddSubview:"))
        }
    }
    #endif
    public  func vcMakeKeyAndVisible(){
        self.vcMakeKeyAndVisible()//看起来是死循环,其实不是,因为已经交换过了
        if self.frame.size.height > 20  //为什么是20
        {
            let viewChaos = ViewChaos()
            self.addSubview(viewChaos)
        }
    }
}
extension UIView{
    public func vcWillMoveToSuperview(subview:UIView?){
        self.vcWillMoveToSuperview(subview)
        if let v = subview{
            NSNotificationCenter.defaultCenter().postNotificationName(VcWillMoveToSuperview, object: self, userInfo: ["subview":v])
        }
    }
    public func vcWillRemoveSubview(subview:UIView?){
        self.vcWillRemoveSubview(subview)
        if let v = subview{
            NSNotificationCenter.defaultCenter().postNotificationName(VcWillRemoveSubview, object: self, userInfo: ["subview":v])
        }
    }
    public func vcDidAddSubview(subview:UIView?){
        self.vcDidAddSubview(subview)
        if let _ = subview{
            NSNotificationCenter.defaultCenter().postNotificationName(VcDidAddSubview, object: self)
        }
    }
}
class ViewChaos: UIView {
    var isTouch:Bool //是否下在触摸中
    var left,top:Float  //右 上
    weak var viewTouch:UIView?
    var viewBound:UIView  //显示抓去View的边界
    var windowInfo:UIWindow
    var lblInfo:UILabel
    var viewChaosInfo:ViewChaosInfo?
    var viewNeat:ViewNeat?
    var arrViewHit:[UIView]
    init() {
        isTouch = false
        arrViewHit = [UIView]()
        viewBound = UIView()
        viewBound.layer.masksToBounds = true
        viewBound.layer.borderWidth = 3
        viewBound.layer.borderColor = UIColor.blackColor().CGColor //View的边界黑色,这个应该可以切换
        viewBound.layer.zPosition = CGFloat(FLT_MAX)
        windowInfo = UIWindow(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 50))
        windowInfo.backgroundColor = UIColor(red: 0.0, green: 0.898, blue: 0.836, alpha: 0.7)
        windowInfo.hidden = true
        windowInfo.name = "windowInfo"
        windowInfo.windowLevel = UIWindowLevelAlert
        lblInfo = UILabel(frame: windowInfo.bounds)
        lblInfo.numberOfLines = 2
        lblInfo.backgroundColor = UIColor.clearColor()
        lblInfo.lineBreakMode = NSLineBreakMode.ByCharWrapping
        lblInfo.autoresizingMask = [UIViewAutoresizing.FlexibleHeight,UIViewAutoresizing.FlexibleWidth]
        //self.checkUpdate
        left = 0
        top = 0
        
        
        super.init(frame: CGRectZero)
        self.frame = CGRect(x: UIScreen.mainScreen().bounds.width-35, y: 100, width: 30, height: 30)
        self.layer.zPosition = CGFloat(FLT_MAX)
        let lbl = UILabel(frame: self.bounds)
        lbl.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        lbl.textAlignment = NSTextAlignment.Center
        lbl.text = "V"
        lbl.backgroundColor = UIColor(red: 0.253, green: 0.917, blue: 0.476, alpha: 1.0)
        self.addSubview(lbl)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 15
        
        
        let tap = UITapGestureRecognizer(target: self, action: "tapInfo:")
        lblInfo.userInteractionEnabled = true
        lblInfo.addGestureRecognizer(tap)
        windowInfo.addSubview(lblInfo)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTraceView:", name: "handleTraceView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTraceContraints:", name: "handleTraceContraints", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTraceAddSubView:", name: "handleTraceAddSubView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTraceShow:", name: "handleTraceShow", object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleTraceShow(notif:NSNotification){ //如果关了ViewChaosInfo,就会显示出来
        self.hidden = false
    }
    func handleTraceView(notif:NSNotification){// 显示选中的View
        let view = notif.object as! UIView
        self.window?.addSubview(viewBound)
        let p = self.window?.convertRect(view.bounds, fromView: view)
        viewBound.frame = p!
        UIView.animateWithDuration(0.3, delay: 0, options: [.AllowUserInteraction,.Repeat,.Autoreverse], animations: { () -> Void in
            UIView.setAnimationRepeatCount(2)
            self.viewBound.alpha = 0
            }) { (finished) -> Void in
                self.viewBound.removeFromSuperview()
                self.viewBound.alpha = 1
                self.viewNeat = ViewNeat()
                self.viewNeat?.viewControl = view;
                self.viewNeat?.layer.zPosition = CGFloat(FLT_MAX)
                self.window?.addSubview(self.viewNeat!);
        }
        
    }
    
    
    func handleTraceAddSubView(notif:NSNotification){
        if let viewSuper = notif.object
        {
            if let view = notif.userInfo!["subview" as NSObject] as? UIView{
                if viewSuper.isKindOfClass(UIWindow.self) && view != self{
                    viewSuper.bringSubviewToFront(self)
                    if viewChaosInfo != nil{
                        viewSuper.bringSubviewToFront(viewChaosInfo!)
                    }
                }
            }
        }
    }
    
    func handleTraceContraints(notif:NSNotification){
        if let dict = notif.object{
            let view = (dict["View"] as! ViewChaosObject).obj! as! UIView
            self.window?.addSubview(viewBound)
            let p = self.window?.convertRect(view.bounds, fromView: view)
            viewBound.frame = p!
            UIView.animateWithDuration(0.3, delay: 0, options: [UIViewAnimationOptions.AllowUserInteraction,UIViewAnimationOptions.Repeat,UIViewAnimationOptions.Autoreverse], animations: { () -> Void in
                UIView.setAnimationRepeatCount(2)
                self.viewBound.alpha = 0
                }, completion: { (finished) -> Void in
                    self.viewBound.removeFromSuperview()
                    self.viewBound.alpha = 1
            })
            let lbl = UILabel(frame: CGRectZero)
            lbl.backgroundColor = UIColor.blueColor()
            let strType = dict["Type"] as! String
            let constant = dict["Constant"]!!.floatValue
            let viewTo = (dict["ToView"] as! ViewChaosObject).obj! as? UIView
            if constant != 0{
                if strType == "Left"{
                    lbl.frame = CGRect(x: view.frame.origin.x - CGFloat(constant), y: view.frame.origin.y + view.frame.size.height / 2 - 2, width: CGFloat(constant), height: 4)
                }
                else if strType == "Right"{
                    lbl.frame = CGRect(x: view.frame.origin.x + view.frame.size.width, y: view.frame.origin.y + view.frame.size.height / 2 - 2, width: CGFloat(constant), height: 4)
                }
                else  if strType == "Top"{
                    lbl.frame = CGRect(x: view.frame.origin.x  +  view.frame.size.width/2 - 2, y: view.frame.origin.y - CGFloat(constant), width: 4, height: CGFloat(constant))
                }
                else  if strType == "Bottom"{
                    lbl.frame = CGRect(x: view.frame.origin.x +  view.frame.size.width/2 - 2, y: view.frame.origin.y + view.frame.size.height, width: 4, height: CGFloat(constant))
                }
                else     if strType == "Width"{
                    lbl.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y + view.frame.size.height / 2 - 2, width: view.frame.width, height: 4)
                }
                else   if strType == "Height"{
                    lbl.frame = CGRect(x: view.frame.origin.x + view.frame.size.width / 2 - 2 , y: view.frame.origin.y, width: 4, height: view.frame.size.height)
                }
                else   if strType == "CenterX"{
                    lbl.frame = CGRect(x: view.frame.origin.x + view.frame.size.width / 2 - CGFloat(constant) , y: view.frame.origin.y + view.frame.size.height / 2 - 2, width: CGFloat(constant), height: 4)
                }
                else    if strType == "CenterY"{
                    lbl.frame = CGRect(x: view.frame.origin.x + view.frame.size.width / 2 - 2, y: view.frame.origin.y + view.frame.size.height / 2 - CGFloat(constant), width: 4, height: CGFloat(constant))
                }
                self.window?.addSubview(lbl)
                let p1 = self.window?.convertRect(lbl.frame, fromView: view.superview)
                lbl.frame = p1!
                UIView.animateWithDuration(0.3, delay: 0, options:  [.AllowUserInteraction,.Repeat,.Autoreverse], animations: { () -> Void in
                    UIView.setAnimationRepeatCount(2)
                    lbl.alpha = 0
                    }, completion: { (finished) -> Void in
                        lbl.removeFromSuperview()
                })
                
            }
            if viewTo != nil{
                let viewToBound = UIView()
                viewToBound.layer.masksToBounds = true
                viewToBound.layer.borderWidth = 3
                viewToBound.layer.borderColor = UIColor.redColor().CGColor
                viewToBound.layer.zPosition = CGFloat(FLT_MAX)
                self.window?.addSubview(viewToBound)
                let p = self.window?.convertRect((viewTo?.bounds)!, fromView: viewTo)
                viewToBound.frame = p!
                UIView.animateWithDuration(0.3, delay: 0, options: [.AllowUserInteraction,.Repeat,.Autoreverse], animations: { () -> Void in
                    UIView.setAnimationRepeatCount(2)
                    viewToBound.alpha = 0
                    }, completion: { (finished) -> Void in
                        viewToBound.removeFromSuperview()
                })
            }
        }
    }
    
    
    
    func  tapInfo(tapGesture:UITapGestureRecognizer){
        if viewChaosInfo?.superview != nil{  //如果没有移除就不继续
            return
        }
        viewChaosInfo = ViewChaosInfo()
        viewChaosInfo?.bounds = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width - 20, height: viewChaosInfo!.bounds.size.height)
        viewChaosInfo?.layer.zPosition = CGFloat(FLT_MAX)
        viewChaosInfo?.viewHit = viewTouch
        self.window?.addSubview(viewChaosInfo!)
        viewChaosInfo?.center = self.window!.center
        self.hidden = true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isTouch = true
        windowInfo.alpha = 1
        windowInfo.hidden = false
        viewChaosInfo?.removeFromSuperview()
        viewBound.removeFromSuperview()
        let touch = touches.first
        let point = touch?.locationInView(self)
        left = Float(point!.x)
        top = Float(point!.y)
        let topPoint = touch?.locationInView(self.window)
        if  let view = topView(self.window!, point: topPoint!)
        {
            let fm = self.window?.convertRect(view.bounds, fromView: view)
            viewTouch = view
            viewBound.frame = fm!
            self.window?.addSubview(viewBound)
            lblInfo.text = "\(view.dynamicType) l:\(view.frame.origin.x.format(".1f"))t:\(view.frame.origin.y.format(".1f"))w:\(view.frame.size.width.format(".1f"))h:\(view.frame.size.height.format(".1f"))"
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !isTouch
        {
            return
        }
        
        let touch = touches.first
        let point = touch?.locationInView(self.window)
        self.frame = CGRect(x: point!.x - CGFloat(left), y: point!.y - CGFloat(top), width: self.frame.size.width, height: self.frame.size.height)//这是为了精准定位.,要处理当前点到top和left的位移
        if  let view = topView(self.window!, point: point!)
        {
            let fm = self.window?.convertRect(view.bounds, fromView: view)
            viewTouch = view
            viewBound.frame = fm!
            lblInfo.text = "\(view.dynamicType) l:\(view.frame.origin.x.format(".1f"))t:\(view.frame.origin.y.format(".1f"))w:\(view.frame.size.width.format(".1f"))h:\(view.frame.size.height.format(".1f"))"
            windowInfo.alpha = 1
            windowInfo.hidden = false
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        isTouch = false
        viewBound.removeFromSuperview()
        Chaos.delay(1.5) { () -> () in
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.windowInfo.alpha = 0
                }, completion: { (finished) -> Void in
                    self.windowInfo.hidden = true
            })
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isTouch = false
        viewBound.removeFromSuperview()
        Chaos.delay(1.5) { () -> () in
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.windowInfo.alpha = 0
                }, completion: { (finished) -> Void in
                    self.windowInfo.hidden = true
            })
        }
    }
    
    func topViewController()->UIViewController{
        var vc:UIViewController?
        if let v1 = UIApplication.sharedApplication().keyWindow?.rootViewController{
            vc = v1
        }
        else if let v2 = UIApplication.sharedApplication().delegate?.window!!.rootViewController{
            vc = v2
        }
        return topViewControllerWithRootViewController(vc!)
    }
    
    
    func topViewControllerWithRootViewController(rootViewController:UIViewController)->UIViewController{
        if rootViewController.isKindOfClass(UITabBarController.self){
            let tabBarController = rootViewController as! UITabBarController
            return self.topViewControllerWithRootViewController(tabBarController.selectedViewController!)
        }
        else if rootViewController .isKindOfClass(UINavigationController.self){
            let navigationController = rootViewController as! UINavigationController
            return topViewControllerWithRootViewController(navigationController.visibleViewController!)
        }
        else if let presentViewController = rootViewController.presentedViewController{
            return topViewControllerWithRootViewController(presentViewController)
        }
        else{
            return rootViewController
        }
    }
    
    func hitTest(view:UIView,var point:CGPoint){
        if view is UIScrollView{
            point.x += (view as! UIScrollView).contentOffset.x
            point.y += (view as! UIScrollView).contentOffset.y
        }
        if view.pointInside(point, withEvent: nil) && !view.hidden && view.alpha > 0.01 && view != viewBound && !view.isDescendantOfView(self){//这里的判断很重要.
            arrViewHit.append(view)
            for subView in view.subviews{
                let subPoint = CGPoint(x: point.x - subView.frame.origin.x , y: point.y - subView.frame.origin.y)
                hitTest(subView, point: subPoint)
            }
        }//四个条件,当前触摸的点一定要在要抓的View里面,View不能是隐藏的或者透明的,View不是我们用于定位的边界View,同时也不是我们用于定位的View.也就是说isDescendantOfView
    }
    
    func topView(view:UIView,point:CGPoint)->UIView?{
        arrViewHit .removeAll()
        hitTest(view, point: point)
        let viewTop = arrViewHit.last
//        for v in arrViewHit{
//            Chaos.Log("\(v.dynamicType)")
//        }
        arrViewHit.removeAll()
        return viewTop
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}


class ViewChaosObject: NSObject {
    weak var obj:AnyObject?
    static func objectWithWeak(o:AnyObject)->AnyObject{
        let viewObject = ViewChaosObject()
        viewObject.obj = o
        return viewObject
    }
}


class Chaos {
    typealias Task = (cancel:Bool)->()
    static func delay(time:NSTimeInterval,task:()->())->Task?{
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
    
   static func cancel(task:Task?){
        task?(cancel:true)
    }
    
    
  static  func Log<T>(message:T,file:String = __FILE__, method:String = __FUNCTION__,line:Int = __LINE__){
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

   static func hookMethod(cls:AnyClass,originalSelector:Selector,swizzleSelector:Selector){  //交换方法
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
    
   static func currentDate(f:String?)->String{
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

let VcWillMoveToSuperview = "vcWillMoveToSuperview"
let VcWillRemoveSubview = "vcWillRemoveSubview"
let VcDidAddSubview = "vcDidAddSubview"
let handleTraceView = "handleTraceView"
let handleTraceContraints = "handleTraceContraints"
let handleTraceAddSubView = "handleTraceAddSubView"
let handleTraceShow = "handleTraceShow"
let handleTraceRemoveView = "handleTraceRemoveView"
let handleTraceRemoveSubView = "handleTraceRemoveSubView"

