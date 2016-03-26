//
//  ViewChaos.swift
//  ViewChaosDemo
//
//  Created by Tyrant on 11/5/15.
//  Copyright © 2015 Qfq. All rights reserved.
//

import UIKit
enum ChaosFeature:Int{
    case None=0,Zoom,Border,Alpha,Draw
}
extension UIWindow:UIActionSheetDelegate {
    #if DEBUG
    public override  class func initialize(){
    struct UIWindow_SwizzleToken {
    static var onceToken:dispatch_once_t = 0
        }
            dispatch_once(&UIWindow_SwizzleToken.onceToken) { () -> Void in
            Chaos.hookMethod(UIWindow.self, originalSelector: #selector(UIWindow.makeKeyAndVisible), swizzleSelector: #selector(UIWindow.vcMakeKeyAndVisible))
            Chaos.hookMethod(UIView.self, originalSelector: #selector(UIView.willMoveToSuperview(_:)), swizzleSelector: #selector(UIView.vcWillMoveToSuperview(_:)))
            Chaos.hookMethod(UIView.self, originalSelector: #selector(UIView.willRemoveSubview(_:)), swizzleSelector: #selector(UIView.vcWillRemoveSubview(_:)))
            Chaos.hookMethod(UIView.self, originalSelector: #selector(UIView.didAddSubview(_:)), swizzleSelector: #selector(UIView.vcDidAddSubview(_:)))
        }
    }
    
    public  func vcMakeKeyAndVisible(){
        self.vcMakeKeyAndVisible()//看起来是死循环,其实不是,因为已经交换过了
        if self.frame.size.height > 20  //为什么是20,当时写这个的时侯不明白为什么是20
        {//现在我在做放大镜时终于明白知道为什么是20,因为如果是20 的话就是最上面的信号条,而不是下面的UIWindow,信号条其实也是个UIWindow对象
            let viewChaos = ViewChaos()
            self.addSubview(viewChaos)
            UIApplication.sharedApplication().applicationSupportsShakeToEdit = true //启用摇一摇功能
            self.chaosFeature = 0
            self.viewLevel = 0
        }
    }
    
    public override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        
        switch self.chaosFeature
        {
            case ChaosFeature.None.rawValue:
            //这里放一个菜单
            let menu = UIActionSheet(title: "使用功能", delegate: self, cancelButtonTitle:"取消", destructiveButtonTitle: nil)
            menu.addButtonWithTitle("启用放大镜")
            menu.addButtonWithTitle("显示边框")
            menu.addButtonWithTitle("显示透明度")
            menu.addButtonWithTitle("画画截图")
            menu.showInView(self)
        case ChaosFeature.Zoom.rawValue:
            UIAlertView.setMessage("关闭放大镜").addFirstButton("取消").addSecondButton("确定").alertWithButtonClick({ (buttonIndex, alert) -> Void in
                if buttonIndex == 1{
                    Chaos.toast("放大镜已经关闭")
                    self.chaosFeature = ChaosFeature.None.rawValue
                    for view in self.subviews{
                        if view.tag == -1000{
                            view.removeFromSuperview()
                        }
                    }
                }
            })
        case ChaosFeature.Border.rawValue:
            UIAlertView.setMessage("关闭边框显示功能").addFirstButton("取消").addSecondButton("确定").alertWithButtonClick({ (buttonIndex, alert) -> Void in
                if buttonIndex == 1{
                    Chaos.toast("边框显示功能已关闭")
                    self.chaosFeature = ChaosFeature.None.rawValue
                   self.removeBorderView(self)
                }
            })
            
        case ChaosFeature.Alpha.rawValue:
            UIAlertView.setMessage("关闭透明显示功能").addFirstButton("取消").addSecondButton("确定").alertWithButtonClick({ (buttonIndex, alert) -> Void in
                if buttonIndex == 1{
                    Chaos.toast("透明显示功能已关闭")
                    self.chaosFeature = ChaosFeature.None.rawValue
                    self.removeAlphaView(self)
                }
            })
        default:break
        }
        
    }
    
    
    public func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1{
            NSNotificationCenter.defaultCenter().postNotificationName(setZoomViewWork, object: nil)
            Chaos.toast("放大镜已经启用")
            let view = ZoomViewBrace(frame: CGRectZero)
            view.tag = -1000
            self.insertSubview(view, atIndex: 100)
            self.chaosFeature = ChaosFeature.Zoom.rawValue
        }
        if buttonIndex == 2{
            //显示甩有视图的边框
            Chaos.toast("边框显示功能已经启用")
            self.chaosFeature = ChaosFeature.Border.rawValue
           showBorderView(self)
        }
        if buttonIndex == 3{
            Chaos.toast("边框显示功能已经启用")
            self.chaosFeature = ChaosFeature.Alpha.rawValue
            showAlphaView(self)
        }
        if buttonIndex == 3{
            Chaos.toast("画画截图功能已经启用")
            self.chaosFeature = ChaosFeature.Draw.rawValue
            //等会再做
        }
    }
    
       private  func showBorderView(view:UIView){
        for v in view.subviews{
//            print("\(v.dynamicType)")
//            print(v.frame)
            //从打印出来数据看好像没有什么问题
            //这个功能比想像的要简单
            //Issue10 用Frame是肯定不对的,因为这个只是相对于爹的位置,我们需要一个绝对布局,所以很多的地方可能是错误的
            //所以要想办法获取到一个绝对位置
            //使用convertRect:toView方法,有一些是错的,不知道为什么下去了
            //我知道怎么回事了,因为我在这里是用frame来转换坐标,convertRect方法是两个坐标的相加,用bounds应该就行了
            let fm = v.convertRect(v.bounds, toView: self)
//            print(fm)
            let vBorder = UIView(frame: fm)
            vBorder.layer.borderWidth = 0.5
            vBorder.tag = -5000
            vBorder.layer.borderColor = UIColor.redColor().CGColor
            self.insertSubview(vBorder, atIndex: 500)
            showBorderView(v)
        }
    }
    
    private func removeBorderView(view:UIView){
        for v in view.subviews{
            removeBorderView(v)
            if v.tag == -5000{
               v.removeFromSuperview()
            }
        }//第二个功能完成
    }
    
    
   private func showAlphaView(view:UIView){
        for v in view.subviews{
            v.viewLevel = view.viewLevel + 1
            print("view:\(v.dynamicType) level:\(v.viewLevel) alpha:\(v.alpha)")
            //Issue11 这个功能目前只能适用于Alpha属性
            //对于那个对于背景颜色的透明属性是无法完成的,所以用处不算大
            if v.viewLevel > 4{
                let fm = v.convertRect(v.bounds, toView: self)
                let vBorder = UIView(frame: fm)
                vBorder.tag = -6000
                vBorder.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1 - v.alpha)
                self.insertSubview(vBorder, atIndex: 600)
            }
            showAlphaView(v)
        }
    }
    
    private func removeAlphaView(view:UIView){
        for v in view.subviews{
            removeAlphaView(v)
            if v.tag == -6000{
                v.removeFromSuperview()
            }
        }
    }

      #endif
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
        windowInfo.chaosName = "windowInfo"
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewChaos.tapInfo(_:)))
        lblInfo.userInteractionEnabled = true
        lblInfo.addGestureRecognizer(tap)
        windowInfo.addSubview(lblInfo)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewChaos.handleTraceView(_:)), name: "handleTraceView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewChaos.handleTraceViewClose(_:)), name: "handleTraceViewClose", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewChaos.handleTraceContraints(_:)), name: "handleTraceContraints", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewChaos.handleTraceAddSubView(_:)), name: "handleTraceAddSubView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewChaos.handleTraceShow(_:)), name: "handleTraceShow", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewChaos.controlTraceShow(_:)), name: controlTraceView, object: nil)
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
            }
    }
    
    func handleTraceViewClose(notif:NSNotification){
        if viewNeat == nil{
            return
        }
        viewNeat?.removeFromSuperview()
        viewNeat = nil
    }
    
    func controlTraceShow(notif:NSNotification){
        
        let view = notif.object as! UIView
        self.window?.addSubview(viewBound)
        let p = self.window?.convertRect(view.bounds, fromView: view)
        Chaos.toast("开始控制:\(view.dynamicType)")
        viewBound.frame = p!
        UIView.animateWithDuration(0.3, delay: 0, options: [.AllowUserInteraction,.Repeat,.Autoreverse], animations: { () -> Void in
            UIView.setAnimationRepeatCount(1)
            self.viewBound.alpha = 0
            }) { (finished) -> Void in
                self.viewBound.removeFromSuperview()
                self.viewBound.alpha = 1
                if(self.viewNeat != nil){
                    self.viewNeat?.viewControl = view
                }
                else{
                    self.viewNeat = ViewNeat()
                    self.viewNeat?.viewControl = view;
                    self.viewNeat?.layer.zPosition = CGFloat(FLT_MAX)
                    self.window?.addSubview(self.viewNeat!);
                }
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
    
    func hitTest(view:UIView, point:CGPoint){
        var pt = point
        if view is UIScrollView{
            pt.x += (view as! UIScrollView).contentOffset.x
            pt.y += (view as! UIScrollView).contentOffset.y
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
    private static let sharedInstance = Chaos()
    class var staredChaos:Chaos {
        return sharedInstance
    }
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
    
    
  static  func Log<T>(message:T,file:String = #file, method:String = #function,line:Int = #line){
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
    

    class var sharedToast:Chaos {
        return sharedInstance
    }
    var lbl:ToastLable?
    var window:UIWindow?
    static func toast(msg:String){
        Chaos.sharedToast.showToast(msg)
    }
    
    static func toast(msg:String,verticalScale:Float){
        Chaos.sharedToast.showToast(msg,verticalScale:verticalScale)
    }
    
    private func showToast(msg:String){
        self.showToast(msg,verticalScale:0.85)
    }
    
    
    private func showToast(msg:String,verticalScale:Float = 0.8){
        if lbl == nil{
            lbl = ToastLable(text: msg)
        }
        else{
            lbl?.text = msg
            lbl?.sizeToFit()
            lbl?.layer.removeAnimationForKey("animation")
        }
        window = UIApplication.sharedApplication().keyWindow
        //Issue4 window对象可能是会改变的,前面的UIWindow是KeyWindow,后来可能就不是了,所以Toast也就显示不出来了,这个是我的猜测.
        //因为使用放大镜功能后Toast就再也显示不出来了.后面让window在每次都指向keyWindow对象就行了,但还是不完美
        if !(window!.subviews.contains(lbl!)){
            window?.addSubview(lbl!)
            lbl?.center = window!.center
            lbl?.frame.origin.y = UIScreen.mainScreen().bounds.height * CGFloat(verticalScale)
        }
        lbl?.addAnimationGroup()
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
    @objc  var chaosName:String?{
        get{
            return objc_getAssociatedObject(self, &NSObject_Name) as? String
        }
        set{
            objc_setAssociatedObject(self, &NSObject_Name, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

private var UIWindow_Feature = 0

extension UIWindow{
    @objc var chaosFeature:Int{
            get{
                return objc_getAssociatedObject(self, &UIWindow_Feature) as! Int
            }
            set{
                objc_setAssociatedObject(self, &UIWindow_Feature, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
                //Issue1, 要添加不同的类型的属性,就要设置正确的objc_AssociationPolicy,如果是Class,就要用OBJC_ASSOCIATION_RETAIN_NONATOMIC,Int要用OBJC_ASSOCIATION_ASSIGN,String要用OBJC_ASSOCIATION_COPY_NONATOMIC
                //不然后可能会造成数据丢失或者其他异常
                //注意objc_AssociationPolicy类型一定要正确,不然可能会从内存里丢失
            }
    }
}


private var UIView_Level = 1
extension UIView{
    @objc var viewLevel:Int{
        get{
            return objc_getAssociatedObject(self, &UIView_Level) as! Int
        }
        set{
            objc_setAssociatedObject(self, &UIView_Level, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

let VcWillMoveToSuperview = "vcWillMoveToSuperview"
let VcWillRemoveSubview = "vcWillRemoveSubview"
let VcDidAddSubview = "vcDidAddSubview"
let handleTraceView = "handleTraceView"
let controlTraceView = "controlTraceView"
let handleTraceContraints = "handleTraceContraints"
let handleTraceAddSubView = "handleTraceAddSubView"
let handleTraceShow = "handleTraceShow"
let handleTraceRemoveView = "handleTraceRemoveView"
let handleTraceRemoveSubView = "handleTraceRemoveSubView"
let setZoomViewWork = "setZoomViewWork"




protocol ColorPickerDelegate {
    func colorSelectedChanged(color: UIColor);
}

class ChaosColorPicker: UIView
{
    private var viewPickerHeight = 0;
    private let brightnessPickerHeight = 30;
    
    private var hueColorsImageView: UIImageView!, brightnessColorsImageView: UIImageView!, fullColorImageView: UIImageView!;
    
    var delegate: ColorPickerDelegate?;
    
    func colorFor( x: CGFloat, y: CGFloat) -> UIColor
    {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        return UIColor(hue: (x/screenSize.width), saturation: y/CGFloat(viewPickerHeight), brightness:1, alpha: 1);
    }
    
    func colorWithColor(baseColor: UIColor, brightness: CGFloat) -> UIColor
    {
        var hue: CGFloat = 0.0;
        var saturation: CGFloat = 0.0;
        
        baseColor.getHue(&hue, saturation: &saturation, brightness: nil, alpha:nil);
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1);
    }
    
    func createHueColorImage() -> UIImage
    {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        let imageHeight = CGFloat(viewPickerHeight - brightnessPickerHeight);
        let imageWidth: CGFloat  = screenSize.width;
        let size: CGSize = CGSize(width: imageWidth, height: CGFloat(imageHeight));
        
        UIGraphicsBeginImageContext(size);
        let context: CGContextRef = UIGraphicsGetCurrentContext()!;
        let recSize = CGSize(width:ceil(imageWidth/256),
            height:ceil(imageWidth/256));

        var y:CGFloat = 0
        while  y < imageHeight{
            var x:CGFloat = 0
            while x < imageWidth {
                let rec = CGRect(x: x, y: y, width: recSize.width , height: recSize.height);
                let color = self.colorFor(x, y: y);

                CGContextSetFillColorWithColor(context, color.CGColor);
                CGContextFillRect(context,rec);
                x += imageWidth / 256
            }
            y += imageHeight / 256
        }

        
        let hueImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return hueImage;
    }
    
    func createBrightnessImage(baseColor:UIColor) -> UIImage
    {
        let imageHeight = CGFloat(brightnessPickerHeight);
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        let imageWidth: CGFloat  = screenSize.width;
        let size: CGSize = CGSize(width: imageWidth, height: CGFloat(imageHeight));
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        let context: CGContextRef = UIGraphicsGetCurrentContext()!;
        let recSize = CGSize(width:ceil(imageWidth/256),
            height:imageHeight);
        
        var hue:CGFloat = 0.0;
        var saturation:CGFloat = 0.0;
        baseColor.getHue(&hue, saturation:&saturation, brightness:nil, alpha:nil);
        
        var z:CGFloat = 0
        while z < imageWidth {
            let rec = CGRect(x: z, y: 0, width: recSize.width , height: recSize.height);
            let color = UIColor(hue: hue, saturation: saturation, brightness: (imageWidth-z)/imageWidth, alpha: 1);
            
            CGContextSetFillColorWithColor(context, color.CGColor);
            CGContextFillRect(context,rec);
            z += imageWidth/256
        }
        
        let hueImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return hueImage;
    }
    
    func createFullColorImage(color :UIColor, size: CGSize, radius: CGFloat) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        let context: CGContextRef = UIGraphicsGetCurrentContext()!;
        let rec = CGRect(x: 0, y: 0, width: size.width , height: size.height);
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        let roundedRect = UIBezierPath(roundedRect: rec, cornerRadius: radius);
        roundedRect.fillWithBlendMode(CGBlendMode.Normal, alpha: 1);
        
        let fullColorImage =  UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return fullColorImage;
    }
    
    func loadView()
    {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        viewPickerHeight = Int(ceil( screenSize.width / 1.10344));
        
        self.frame = CGRect(x:0,y:0,width:Int(screenSize.width),height:viewPickerHeight);
        
        
        let hueColorImage = self.createHueColorImage();
        self.hueColorsImageView = UIImageView(image: hueColorImage);
        self.addSubview(self.hueColorsImageView);
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action:#selector(ChaosColorPicker.baseColorPicking(_:)));
        self.hueColorsImageView.addGestureRecognizer(panRecognizer);
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChaosColorPicker.baseColorPicking(_:)));
        self.hueColorsImageView.addGestureRecognizer(tapRecognizer);
        self.hueColorsImageView.userInteractionEnabled = true;
        
        
        //------
        let brightnessColorImage = self.createBrightnessImage(self.selectedBaseColor);
        self.brightnessColorsImageView = UIImageView(image: brightnessColorImage);
        self.addSubview(self.brightnessColorsImageView);
        
        var brImgRect = self.brightnessColorsImageView.frame;
        brImgRect.origin.y = self.hueColorsImageView.frame.origin.y + self.hueColorsImageView.frame.size.height;
        self.brightnessColorsImageView.frame = brImgRect;
        self.brightnessColorsImageView.userInteractionEnabled = true;
        
        let brightSlideGesture = UIPanGestureRecognizer(target: self, action:#selector(ChaosColorPicker.colorPicking(_:)));
        self.brightnessColorsImageView.addGestureRecognizer(brightSlideGesture);
        
        let brightTapGesture = UITapGestureRecognizer(target: self, action: #selector(ChaosColorPicker.colorPicking(_:)));
        self.brightnessColorsImageView.addGestureRecognizer(brightTapGesture);
        self.brightnessColorsImageView.userInteractionEnabled = true;
    }
    
    internal var selectedColor: UIColor
        {
        didSet{
            if((self.fullColorImageView) != nil)
            {
                let fullColorImage = self.createFullColorImage(selectedColor, size: CGSize(width: 40, height: 40),radius: CGFloat(6));
                fullColorImageView.image = fullColorImage;
            }
            
            self.delegate?.colorSelectedChanged(self.selectedColor);
        }
    }
    
    var selectedBrightness: CGFloat
        {
        get
        {
            var brightness: CGFloat=0;
            self.selectedColor.getHue(nil, saturation: nil, brightness:&brightness, alpha:nil);
            
            return brightness;
        }
        
    }
    
    func setSelectedBrightness(brightness: CGFloat)
    {
        self.selectedColor = self.colorWithColor(self.selectedBaseColor, brightness:brightness);
        
    }
    
    var selectedBaseColor: UIColor
        {
        didSet{
            let brightnessColorImage = self.createBrightnessImage(self.selectedBaseColor);
            self.brightnessColorsImageView.image = brightnessColorImage;
        }
    }
    
    func setColor(color: UIColor)
    {
        selectedBaseColor = color;
        selectedColor = color;
    }
    
    func baseColorPicking(sender: UIGestureRecognizer)
    {
        if(sender.numberOfTouches()==1)
        {
            let picked = sender.locationOfTouch(0, inView: sender.view);
            
            self.selectedBaseColor = self.colorFor(picked.x, y:picked.y);
            self.selectedColor = self.colorWithColor(self.selectedBaseColor, brightness:self.selectedBrightness);
        }
    }
    
    func colorPicking(sender: UIGestureRecognizer)
    {
        if(sender.numberOfTouches()==1)
        {
            let picked = sender.locationOfTouch(0, inView:sender.view);
            self.setSelectedBrightness((sender.view!.frame.width-picked.x)/sender.view!.frame.width);
        }
    }
    
    init(frame:CGRect, color: UIColor)
    {
        selectedColor = color;
        selectedBaseColor = color;
        
        super.init(frame: frame);
        self.loadView();
    }
    
    required init?(coder aDecoder: NSCoder) {
        selectedColor = UIColor.whiteColor();
        selectedBaseColor = UIColor.whiteColor();
        
        super.init(coder: aDecoder);
        self.loadView();
    }
}






class ToastLable:UILabel {
    enum ToastShowType{
        case Top,Center,Bottom
    }
    var forwardAnimationDuration:CFTimeInterval = 0.3
    var backwardAnimationDuration:CFTimeInterval = 0.2
    var waitAnimationDuration:CFTimeInterval = 1.5
    var textInsets:UIEdgeInsets?
    var maxWidth:Float?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        maxWidth = Float(UIScreen.mainScreen().bounds.width) - 20.0
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.numberOfLines = 0
        self.textAlignment = NSTextAlignment.Left
        self.textColor = UIColor.whiteColor()
        self.font = UIFont.systemFontOfSize(14)
    }
    convenience init(text:String) {
        self.init(frame:CGRectZero)
        self.text = text
        self.sizeToFit()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func addAnimationGroup(){
        let forwardAnimation = CABasicAnimation(keyPath: "transform.scale")
        forwardAnimation.duration = self.forwardAnimationDuration
        forwardAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, 1.7, 0.6, 0.85)
        forwardAnimation.fromValue = 0
        forwardAnimation.toValue = 1
        
        let backWardAnimation = CABasicAnimation(keyPath: "transform.scale")
        backWardAnimation.duration = self.backwardAnimationDuration
        backWardAnimation.beginTime = forwardAnimation.duration + waitAnimationDuration
        backWardAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.15, 0.5, -0.7)
        backWardAnimation.fromValue = 1
        backWardAnimation.toValue = 0
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [forwardAnimation,backWardAnimation]
        animationGroup.duration = forwardAnimation.duration + backWardAnimation.duration + waitAnimationDuration
        animationGroup.removedOnCompletion = false
        animationGroup.delegate = self
        animationGroup.fillMode = kCAFillModeForwards
        self.layer.addAnimation(animationGroup, forKey: "animation")
    }
    override func sizeToFit() {
        super.sizeToFit()
        var fm = self.frame
        let width = CGRectGetWidth(self.bounds) + self.textInsets!.left + self.textInsets!.right
        fm.size.width = width > CGFloat(self.maxWidth!) ? CGFloat(self.maxWidth!) : width
        fm.size.height = CGRectGetHeight(self.bounds) + self.textInsets!.top + self.textInsets!.bottom
        fm.origin.x = UIScreen.mainScreen().bounds.width / 2 - fm.size.width / 2
        self.frame = fm
    }
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if flag{
            self.removeFromSuperview()
        }
    }
    override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, self.textInsets!))
    }
    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = bounds
        if let txt = self.text{
            rect.size =  (txt as NSString).boundingRectWithSize(CGSize(width: CGFloat(self.maxWidth!) - self.textInsets!.left - self.textInsets!.right, height: CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:self.font], context: nil).size
        }
        return rect
    }
}









extension UIAlertView {
    static func setMessage(msg:String)->UIAlertView{
        let alert = BlockAlert()
        alert.message = msg
        return alert
    }
    
    func addAlertStyle(style:UIAlertViewStyle)->UIAlertView{
        self.alertViewStyle = style
        return self
    }
    
    func addTitle(title:String)->UIAlertView{
        self.title = title
        return self
    }
    
    func addFirstButton(btnTitle:String)->UIAlertView{
        self.addButtonWithTitle(btnTitle)
        return self
    }
    
    func addSecondButton(btnTitle:String)->UIAlertView{
        self.addButtonWithTitle(btnTitle)
        return self
    }
    
    func addButtons(btnTitles:[String])->UIAlertView{
        for title in btnTitles{
            self.addButtonWithTitle(title)
        }
        return self
    }
    
    func addButtonClickEvent(clickButton:((buttonIndex:Int,alert:UIAlertView)->Void)?)->UIAlertView{
        if let alert = self as? BlockAlert{
            alert.completion = clickButton
        }
        return self
    }
    
    func addDidDismissEvent(event:((buttonIndex:Int,alert:UIAlertView)->Void)?)->UIAlertView{
        if let alert = self as? BlockAlert{
            alert.didDismissBlock = event
        }
        return self
    }
    
    func addWillDismissEvent(event:((buttonIndex:Int,alert:UIAlertView)->Void)?)->UIAlertView{
        if let alert = self as? BlockAlert{
            alert.willDismissBlock = event
        }
        return self
    }
    
    
    func addDidPresentEvent(event:((alert:UIAlertView)->Void)?)->UIAlertView{
        if let alert = self as? BlockAlert{
            alert.didPresentBlock = event
        }
        return self
    }
    
    func addWillPresentEvent(event:((alert:UIAlertView)->Void)?)->UIAlertView{
        if let alert = self as? BlockAlert{
            alert.willPresentBlock = event
        }
        return self
    }
    
    func addAlertCancelEvent(event:((alert:UIAlertView)->Void)?)->UIAlertView{
        if let alert = self as? BlockAlert{
            alert.alertWithCalcelBlock = event
        }
        return self
    }
    
    
    func alertWithButtonClick(clickButton:((buttonIndex:Int,alert:UIAlertView)->Void)?){
        if let alert = self as? BlockAlert{
            alert.completion = clickButton
            alert.show()
        }
    }
}
class BlockAlert:UIAlertView,UIAlertViewDelegate {
    var completion:((buttonIndex:Int,alert:UIAlertView)->Void)?
    var willDismissBlock:((buttonIndex:Int,alert:UIAlertView)->Void)?
    var didDismissBlock:((buttonIndex:Int,alert:UIAlertView)->Void)?
    var didPresentBlock:((alert:UIAlertView)->Void)?
    var willPresentBlock:((alert:UIAlertView)->Void)?
    var alertWithCalcelBlock:((alert:UIAlertView)->Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if let block = completion{
            block(buttonIndex: buttonIndex, alert: alertView)
        }
    }
    
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if let block = didDismissBlock{
            block(buttonIndex: buttonIndex, alert: alertView)
        }
    }
    
    func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        if let block = willDismissBlock{
            block(buttonIndex: buttonIndex, alert: alertView)
        }
        
    }
    
    
    func didPresentAlertView(alertView: UIAlertView) {
        if let block = didPresentBlock{
            block(alert: alertView)
        }
    }
    
    func willPresentAlertView(alertView: UIAlertView) {
        if let block = willPresentBlock{
            block(alert: alertView)
        }
    }
    
    func alertViewCancel(alertView: UIAlertView) {
        if let block = alertWithCalcelBlock{
            block(alert: alertView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
