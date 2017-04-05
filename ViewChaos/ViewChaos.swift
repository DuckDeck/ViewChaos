//
//  ViewChaos.swift
//  ViewChaosDemo
//
//  Created by Tyrant on 11/5/15.
//  Copyright © 2015 Qfq. All rights reserved.
//

import UIKit
enum ChaosFeature:Int{
    case none=0,zoom,border,alpha
}

public protocol SelfAware:class {
    static func awake()
}

class NothingToSeeHere{
    static func harmlessFunction(){
        let typeCount = Int(objc_getClassList(nil, 0))
        let  types = UnsafeMutablePointer<AnyClass?>.allocate(capacity: typeCount)
        let autoreleaseintTypes = AutoreleasingUnsafeMutablePointer<AnyClass?>(types)
        objc_getClassList(autoreleaseintTypes, Int32(typeCount))
        for index in 0 ..< typeCount{
            (types[index] as? SelfAware.Type)?.awake()
        }
        types.deallocate(capacity: typeCount)
    }
}

extension UIApplication{
    private static let runOnce:Void = {
        NothingToSeeHere.harmlessFunction()
    }()
    
    open override var next: UIResponder?{
        UIApplication.runOnce
        return super.next
    }
}

class ViewChaosStart: SelfAware {
    static func awake() {
          #if DEBUG
            Chaos.hookMethod(UIWindow.self, originalSelector: #selector(UIWindow.makeKeyAndVisible), swizzleSelector: #selector(UIWindow.vcMakeKeyAndVisible))
            Chaos.hookMethod(UIView.self, originalSelector: #selector(UIView.willMove(toSuperview:)), swizzleSelector: #selector(UIView.vcWillMoveToSuperview(_:)))
            
            Chaos.hookMethod(UIView.self, originalSelector: #selector(UIView.willRemoveSubview(_:)), swizzleSelector: #selector(UIView.vcWillRemoveSubview(_:)))
            Chaos.hookMethod(UIView.self, originalSelector: #selector(UIView.didAddSubview(_:)), swizzleSelector: #selector(UIView.vcDidAddSubview(_:)))
         #endif
    }
}

extension UIWindow:UIActionSheetDelegate {
    #if DEBUG
//    open override  class func initialize(){
//        struct UIWindow_SwizzleToken {
//            init() {
//                Chaos.hookMethod(UIWindow.self, originalSelector: #selector(UIWindow.makeKeyAndVisible), swizzleSelector: #selector(UIWindow.vcMakeKeyAndVisible))
//                Chaos.hookMethod(UIView.self, originalSelector: #selector(UIView.willMove(toSuperview:)), swizzleSelector: #selector(UIView.vcWillMoveToSuperview(_:)))
//
//                Chaos.hookMethod(UIView.self, originalSelector: #selector(UIView.willRemoveSubview(_:)), swizzleSelector: #selector(UIView.vcWillRemoveSubview(_:)))
//                Chaos.hookMethod(UIView.self, originalSelector: #selector(UIView.didAddSubview(_:)), swizzleSelector: #selector(UIView.vcDidAddSubview(_:)))
//            }
//            static  let sharedInstance = UIWindow_SwizzleToken()
//            static var shareWindow: UIWindow_SwizzleToken {
//                return sharedInstance
//            }
//        }
//        _ = UIWindow_SwizzleToken.shareWindow
//    
//    }
    
//    static var onceToken:dispatch_once_t = 0
//    }
//    dispatch_once(&UIWindow_SwizzleToken.onceToken) { () -> Void in
//    Chaos.hookMethod(UIWindow.self, originalSelector: #selector(UIWindow.makeKeyAndVisible), swizzleSelector: #selector(UIWindow.vcMakeKeyAndVisible))
//    Chaos.hookMethod(UIView.self, originalSelector: #selector(UIView.willMoveToSuperview(_:)), swizzleSelector: #selector(UIView.vcWillMoveToSuperview(_:)))
//    Chaos.hookMethod(UIView.self, originalSelector: #selector(UIView.willRemoveSubview(_:)), swizzleSelector: #selector(UIView.vcWillRemoveSubview(_:)))
//    Chaos.hookMethod(UIView.self, originalSelector: #selector(UIView.didAddSubview(_:)), swizzleSelector: #selector(UIView.vcDidAddSubview(_:)))

    
    
    public  func vcMakeKeyAndVisible(){
        self.vcMakeKeyAndVisible()//看起来是死循环,其实不是,因为已经交换过了
        if self.frame.size.height > 20  //为什么是20,当时写这个的时侯不明白为什么是20
        {//现在我在做放大镜时终于明白知道为什么是20,因为如果是20 的话就是最上面的信号条,而不是下面的UIWindow,信号条其实也是个UIWindow对象
            let viewChaos = ViewChaos()
            self.addSubview(viewChaos)
            UIApplication.shared.applicationSupportsShakeToEdit = true //启用摇一摇功能
            self.chaosFeature = 0
            self.viewLevel = 0
        }
    }
    
     open override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        switch self.chaosFeature
        {
            case ChaosFeature.none.rawValue:
            //这里放一个菜单
            let alert = UIAlertController(title: "使用功能", message: nil, preferredStyle: .actionSheet)
            let action1 = UIAlertAction(title: "启用放大镜", style: .default, handler: { (action) in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: setZoomViewWork), object: nil)
                Chaos.toast("放大镜已经启用")
                let view = ZoomViewBrace(frame: CGRect())
                view.tag = -1000
                self.insertSubview(view, at: 100)
                self.chaosFeature = ChaosFeature.zoom.rawValue
            })
            let action2 = UIAlertAction(title: "显示边框", style: .default, handler: { (action) in
                Chaos.toast("边框显示功能已经启用")
                self.chaosFeature = ChaosFeature.border.rawValue
                self.showBorderView(view: self)
                let view = DrawView(frame: CGRect())
                view.tag = -7000
                self.insertSubview(view, at: 600)

            })
            let action3 = UIAlertAction(title: "显示透明度", style: .default, handler: { (action) in
                Chaos.toast("透明显示功能已经启用")
                self.chaosFeature = ChaosFeature.alpha.rawValue
                self.showAlphaView(view: self)

            })
            let action4 = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(action1)
            alert.addAction(action2)
            alert.addAction(action3)
            alert.addAction(action4)
            self.rootViewController?.present(alert, animated: true, completion: nil)
        case ChaosFeature.zoom.rawValue:
            UIAlertView.setMessage("关闭放大镜").addFirstButton("取消").addSecondButton("确定").alertWithButtonClick({ (buttonIndex, alert) -> Void in
                if buttonIndex == 1{
                    Chaos.toast("放大镜已经关闭")
                    self.chaosFeature = ChaosFeature.none.rawValue
                    for view in self.subviews{
                        if view.tag == -1000{
                            view.removeFromSuperview()
                        }
                    }
                }
            })
        case ChaosFeature.border.rawValue:
            UIAlertView.setMessage("关闭边框显示功能").addFirstButton("取消").addSecondButton("确定").alertWithButtonClick({ (buttonIndex, alert) -> Void in
                if buttonIndex == 1{
                    Chaos.toast("边框显示功能已关闭")
                    self.chaosFeature = ChaosFeature.none.rawValue
                   self.removeBorderView(view: self)
                }
            })
            
        case ChaosFeature.alpha.rawValue:
            UIAlertView.setMessage("关闭透明显示功能").addFirstButton("取消").addSecondButton("确定").alertWithButtonClick({ (buttonIndex, alert) -> Void in
                if buttonIndex == 1{
                    Chaos.toast("透明显示功能已关闭")
                    self.chaosFeature = ChaosFeature.none.rawValue
                    self.removeAlphaView(view: self)
                }
            })
            
         default:break
        }
        
    }
    
    
    public func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex == 1{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: setZoomViewWork), object: nil)
            Chaos.toast("放大镜已经启用")
            let view = ZoomViewBrace(frame: CGRect())
            view.tag = -1000
            self.insertSubview(view, at: 100)
            self.chaosFeature = ChaosFeature.zoom.rawValue
        }
        if buttonIndex == 2{
            //显示甩有视图的边框
            Chaos.toast("边框显示功能已经启用")
            self.chaosFeature = ChaosFeature.border.rawValue
           showBorderView(view: self)
            let view = DrawView(frame: CGRect())
            view.tag = -7000
            self.insertSubview(view, at: 600)

        }
        if buttonIndex == 3{
            Chaos.toast("透明显示功能已经启用")
            self.chaosFeature = ChaosFeature.alpha.rawValue
            showAlphaView(view: self)
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
            let fm = v.convert(v.bounds, to: self)
//            print(fm)
            let vBorder = UIView(frame: fm)
            vBorder.layer.borderWidth = 0.5
            vBorder.tag = -5000
            vBorder.layer.borderColor = UIColor.red.cgColor
            self.insertSubview(vBorder, at: 500)
            showBorderView(view: v)
        }
    }
    
    private func removeBorderView(view:UIView){
        for v in view.subviews{
            removeBorderView(view: v)
            if v.tag == -5000{
               v.removeFromSuperview()
            }
            if view.tag == -7000{
                view.removeFromSuperview()
            }
        }//第二个功能完成
    }
    
    
   private func showAlphaView(view:UIView){
        for v in view.subviews{
            v.viewLevel = view.viewLevel + 1
            print("view:\(type(of: v)) level:\(v.viewLevel) alpha:\(v.alpha)")
            //Issue11 这个功能目前只能适用于Alpha属性
            //对于那个对于背景颜色的透明属性是无法完成的,所以用处不算大
            //实际上光用alpha是不够的,这样对于background无法获取
            //所以在这里在判断
            if v.viewLevel > 3{
                let fm = v.convert(v.bounds, to: self)
                let vBorder = UIView(frame: fm)
                vBorder.tag = -6000
                var alp = 1 - v.alpha
                if alp == 0{
                    //这个时侯获取background的透明度
                    if let co = v.backgroundColor{
                        alp = 1 - CGFloat(co.alpha) / 255.0
                    }
                }
                vBorder.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: alp / 2)//除以2更好辨认一点
                self.insertSubview(vBorder, at: 600)
            }
            showAlphaView(view: v)
        }
    }
    
    private func removeAlphaView(view:UIView){
        for v in view.subviews{
            removeAlphaView(view: v)
            if v.tag == -6000{
                v.removeFromSuperview()
            }
        }//第三个功能完成
    }

      #endif
}
extension UIView{
    public func vcWillMoveToSuperview(_ subview:UIView?){
        self.vcWillMoveToSuperview(subview)
        if let v = subview{
            NotificationCenter.default.post(name: Notification.Name(rawValue: VcWillMoveToSuperview), object: self, userInfo: ["subview":v])
        }
    }
    public func vcWillRemoveSubview(_ subview:UIView?){
        self.vcWillRemoveSubview(subview)
        if let v = subview{
            NotificationCenter.default.post(name: Notification.Name(rawValue: VcWillRemoveSubview), object: self, userInfo: ["subview":v])
        }
    }
    public func vcDidAddSubview(_ subview:UIView?){
        self.vcDidAddSubview(subview)
        if let _ = subview{
            NotificationCenter.default.post(name: Notification.Name(rawValue: VcDidAddSubview), object: self)
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
        viewBound.layer.borderColor = UIColor.black.cgColor //View的边界黑色,这个应该可以切换
        viewBound.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        windowInfo = UIWindow(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        windowInfo.backgroundColor = UIColor(red: 0.0, green: 0.898, blue: 0.836, alpha: 0.7)
        windowInfo.isHidden = true
        windowInfo.chaosName = "windowInfo"
        windowInfo.windowLevel = UIWindowLevelAlert
        lblInfo = UILabel(frame: windowInfo.bounds)
        lblInfo.numberOfLines = 2
        lblInfo.backgroundColor = UIColor.clear
        lblInfo.lineBreakMode = NSLineBreakMode.byCharWrapping
        lblInfo.autoresizingMask = [UIViewAutoresizing.flexibleHeight,UIViewAutoresizing.flexibleWidth]
        //self.checkUpdate
        left = 0
        top = 0
        
        super.init(frame: CGRect.zero)
        self.frame = CGRect(x: UIScreen.main.bounds.width-35, y: 100, width: 30, height: 30)
        self.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        
        let lbl = UILabel(frame: self.bounds)
        lbl.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        lbl.textAlignment = NSTextAlignment.center
        lbl.text = "V"
        lbl.backgroundColor = UIColor(red: 0.253, green: 0.917, blue: 0.476, alpha: 1.0)
        self.addSubview(lbl)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 15
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewChaos.tapInfo(_:)))
        lblInfo.isUserInteractionEnabled = true
        lblInfo.addGestureRecognizer(tap)
        windowInfo.addSubview(lblInfo)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewChaos.handleTraceView(_:)), name: NSNotification.Name(rawValue: "handleTraceView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewChaos.handleTraceViewClose(_:)), name: NSNotification.Name(rawValue: "handleTraceViewClose"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewChaos.handleTraceContraints(_:)), name: NSNotification.Name(rawValue: "handleTraceContraints"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewChaos.handleTraceAddSubView(_:)), name: NSNotification.Name(rawValue: "handleTraceAddSubView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewChaos.handleTraceShow(_:)), name: NSNotification.Name(rawValue: "handleTraceShow"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewChaos.controlTraceShow(_:)), name: NSNotification.Name(rawValue: controlTraceView), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    
    func handleTraceShow(_ notif:Notification){ //如果关了ViewChaosInfo,就会显示出来
        self.isHidden = false
    }
    func handleTraceView(_ notif:Notification){// 显示选中的View
        let view = notif.object as! UIView
        self.window?.addSubview(viewBound)
        let p = self.window?.convert(view.bounds, from: view)
        if p == nil {
            Chaos.toast("获取View失败")
            return
        }
        viewBound.frame = p!
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction,.repeat,.autoreverse], animations: { () -> Void in
            UIView.setAnimationRepeatCount(2)
            self.viewBound.alpha = 0
            }) { (finished) -> Void in
                self.viewBound.removeFromSuperview()
                self.viewBound.alpha = 1
            }
    }
    
    func handleTraceViewClose(_ notif:Notification){
        if viewNeat == nil{
            return
        }
        viewNeat?.removeFromSuperview()
        viewNeat = nil
    }
    
    func controlTraceShow(_ notif:Notification){
        
        let view = notif.object as! UIView
        self.window?.addSubview(viewBound)
        let p = self.window?.convert(view.bounds, from: view)
        Chaos.toast("开始控制:\(type(of: view))")
        viewBound.frame = p!
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction,.repeat,.autoreverse], animations: { () -> Void in
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
                    self.viewNeat?.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
                    self.window?.addSubview(self.viewNeat!);
                }
        }

    }
    
    func handleTraceAddSubView(_ notif:Notification){
        if let viewSuper = notif.object
        {
            if let view = (notif as NSNotification).userInfo!["subview" as NSObject] as? UIView{
                if (viewSuper as AnyObject).isKind(of: UIWindow.self) && view != self{
                    (viewSuper as AnyObject).bringSubview(toFront: self)
                    if viewChaosInfo != nil{
                        (viewSuper as AnyObject).bringSubview(toFront: viewChaosInfo!)
                    }
                }
            }
        }
    }
    
    func handleTraceContraints(_ notif:Notification){
        if let dict = notif.object as? [String:AnyObject]{
            let view = (dict["View"] as! ViewChaosObject).obj! as! UIView
            self.window?.addSubview(viewBound)
            let p = self.window?.convert(view.bounds, from: view)
            viewBound.frame = p!
            UIView.animate(withDuration: 0.3, delay: 0, options: [UIViewAnimationOptions.allowUserInteraction,UIViewAnimationOptions.repeat,UIViewAnimationOptions.autoreverse], animations: { () -> Void in
                UIView.setAnimationRepeatCount(2)
                self.viewBound.alpha = 0
                }, completion: { (finished) -> Void in
                    self.viewBound.removeFromSuperview()
                    self.viewBound.alpha = 1
            })
            let lbl = UILabel(frame: CGRect.zero)
            lbl.backgroundColor = UIColor.blue
            let strType = dict["Type"] as! String
            let constant = dict["Constant"]!.floatValue
            let viewTo = (dict["ToView"] as! ViewChaosObject).obj! as? UIView
            if constant != 0{
                if strType == "Left"{
                    lbl.frame = CGRect(x: view.frame.origin.x - CGFloat(constant!), y: view.frame.origin.y + view.frame.size.height / 2 - 2, width: CGFloat(constant!), height: 4)
                }
                else if strType == "Right"{
                    lbl.frame = CGRect(x: view.frame.origin.x + view.frame.size.width, y: view.frame.origin.y + view.frame.size.height / 2 - 2, width: CGFloat(constant!), height: 4)
                }
                else  if strType == "Top"{
                    lbl.frame = CGRect(x: view.frame.origin.x  +  view.frame.size.width/2 - 2, y: view.frame.origin.y - CGFloat(constant!), width: 4, height: CGFloat(constant!))
                }
                else  if strType == "Bottom"{
                    lbl.frame = CGRect(x: view.frame.origin.x +  view.frame.size.width/2 - 2, y: view.frame.origin.y + view.frame.size.height, width: 4, height: CGFloat(constant!))
                }
                else     if strType == "Width"{
                    lbl.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y + view.frame.size.height / 2 - 2, width: view.frame.width, height: 4)
                }
                else   if strType == "Height"{
                    lbl.frame = CGRect(x: view.frame.origin.x + view.frame.size.width / 2 - 2 , y: view.frame.origin.y, width: 4, height: view.frame.size.height)
                }
                else   if strType == "CenterX"{
                    lbl.frame = CGRect(x: view.frame.origin.x + view.frame.size.width / 2 - CGFloat(constant!) , y: view.frame.origin.y + view.frame.size.height / 2 - 2, width: CGFloat(constant!), height: 4)
                }
                else    if strType == "CenterY"{
                    lbl.frame = CGRect(x: view.frame.origin.x + view.frame.size.width / 2 - 2, y: view.frame.origin.y + view.frame.size.height / 2 - CGFloat(constant!), width: 4, height: CGFloat(constant!))
                }
                self.window?.addSubview(lbl)
                let p1 = self.window?.convert(lbl.frame, from: view.superview)
                lbl.frame = p1!
                UIView.animate(withDuration: 0.3, delay: 0, options:  [.allowUserInteraction,.repeat,.autoreverse], animations: { () -> Void in
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
                viewToBound.layer.borderColor = UIColor.red.cgColor
                viewToBound.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
                self.window?.addSubview(viewToBound)
                let p = self.window?.convert((viewTo?.bounds)!, from: viewTo)
                viewToBound.frame = p!
                UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction,.repeat,.autoreverse], animations: { () -> Void in
                    UIView.setAnimationRepeatCount(2)
                    viewToBound.alpha = 0
                    }, completion: { (finished) -> Void in
                        viewToBound.removeFromSuperview()
                })
            }
        }
    }
    
    
    
    func  tapInfo(_ tapGesture:UITapGestureRecognizer){
        if viewChaosInfo?.superview != nil{  //如果没有移除就不继续
            return
        }
        viewChaosInfo = ViewChaosInfo()
        viewChaosInfo?.bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20, height: viewChaosInfo!.bounds.size.height)
        viewChaosInfo?.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        viewChaosInfo?.viewHit = viewTouch
        self.window?.addSubview(viewChaosInfo!)
        viewChaosInfo?.center = self.window!.center
        self.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouch = true
        windowInfo.alpha = 1
        windowInfo.isHidden = false
        viewChaosInfo?.removeFromSuperview()
        viewBound.removeFromSuperview()
        
        let touch = touches.first
        let point = touch?.location(in: self)
        left = Float(point!.x)
        top = Float(point!.y)
        let topPoint = touch?.location(in: self.window)
        
        if  let view = topView(self.window!, point: topPoint!)
        {
            let fm = self.window?.convert(view.bounds, from: view)
            viewTouch = view
            viewBound.frame = fm!
            self.window?.addSubview(viewBound)
            lblInfo.text = "\(type(of: view)) l:\(view.frame.origin.x.format(".1f"))t:\(view.frame.origin.y.format(".1f"))w:\(view.frame.size.width.format(".1f"))h:\(view.frame.size.height.format(".1f"))"
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isTouch
        {
            return
        }
        
        let touch = touches.first
        let point = touch?.location(in: self.window)
        self.frame = CGRect(x: point!.x - CGFloat(left), y: point!.y - CGFloat(top), width: self.frame.size.width, height: self.frame.size.height)//这是为了精准定位.,要处理当前点到top和left的位移
        if  let view = topView(self.window!, point: point!)
        {
            let fm = self.window?.convert(view.bounds, from: view)
            viewTouch = view
            viewBound.frame = fm!
            lblInfo.text = "\(type(of: view)) l:\(view.frame.origin.x.format(".1f"))t:\(view.frame.origin.y.format(".1f"))w:\(view.frame.size.width.format(".1f"))h:\(view.frame.size.height.format(".1f"))"
            windowInfo.alpha = 1
            windowInfo.isHidden = false
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        isTouch = false
        viewBound.removeFromSuperview()
        let _ = Chaos.delay(1.5) { () -> () in
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.windowInfo.alpha = 0
                }, completion: { (finished) -> Void in
                    self.windowInfo.isHidden = true
            })
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouch = false
        viewBound.removeFromSuperview()
       let _ = Chaos.delay(1.5) { () -> () in
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.windowInfo.alpha = 0
                }, completion: { (finished) -> Void in
                    self.windowInfo.isHidden = true
            })
        }
    }
    
    func topViewController()->UIViewController{
        var vc:UIViewController?
        if let v1 = UIApplication.shared.keyWindow?.rootViewController{
            vc = v1
        }
        else if let v2 = UIApplication.shared.delegate?.window!!.rootViewController{
            vc = v2
        }
        return topViewControllerWithRootViewController(vc!)
    }
    
    
    func topViewControllerWithRootViewController(_ rootViewController:UIViewController)->UIViewController{
        if rootViewController.isKind(of: UITabBarController.self){
            let tabBarController = rootViewController as! UITabBarController
            return self.topViewControllerWithRootViewController(tabBarController.selectedViewController!)
        }
        else if rootViewController .isKind(of: UINavigationController.self){
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
    
    func hitTest(_ view:UIView, point:CGPoint){
        var pt = point
        if view is UIScrollView{
            pt.x += (view as! UIScrollView).contentOffset.x
            pt.y += (view as! UIScrollView).contentOffset.y
        }
        if view.point(inside: point, with: nil) && !view.isHidden && view.alpha > 0.01 && view != viewBound && !view.isDescendant(of: self){//这里的判断很重要.
            arrViewHit.append(view)
            for subView in view.subviews{
                let subPoint = CGPoint(x: point.x - subView.frame.origin.x , y: point.y - subView.frame.origin.y)
                hitTest(subView, point: subPoint)
            }
        }//四个条件,当前触摸的点一定要在要抓的View里面,View不能是隐藏的或者透明的,View不是我们用于定位的边界View,同时也不是我们用于定位的View.也就是说isDescendantOfView
    }
    
    func topView(_ view:UIView,point:CGPoint)->UIView?{
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
        NotificationCenter.default.removeObserver(self)
    }
}


class ViewChaosObject: NSObject {
    weak var obj:AnyObject?
    static func objectWithWeak(_ o:AnyObject)->AnyObject{
        let viewObject = ViewChaosObject()
        viewObject.obj = o
        return viewObject
    }
}


class Chaos {
    fileprivate static let sharedInstance = Chaos()
    class var staredChaos:Chaos {
        return sharedInstance
    }
    typealias Task = (_ cancel:Bool)->()
    static func delay(_ time:TimeInterval,task:@escaping ()->())->Task?{
        let delayTime = DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        func dispatch_later(_ block:@escaping ()->()){
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: block)
        }
        var closure:(()->())? = task
        var result:Task?
        let delayClosure:Task = {
            cancel in
            if let internalClosure = closure{
                if cancel == false{
                    DispatchQueue.main.async(execute: internalClosure)
                }
            }
            closure = nil
            result = nil
        }
        result = delayClosure
        dispatch_later { () -> () in
            if let delayClosure = result{
                delayClosure(false)
            }
        }
        return result
    }
    
   static func cancel(_ task:Task?){
        task?(true)
    }
    
    
  static  func Log<T>(_ message:T,file:String = #file, method:String = #function,line:Int = #line){
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

   static func hookMethod(_ cls:AnyClass,originalSelector:Selector,swizzleSelector:Selector){  //交换方法
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
    
   static func currentDate(_ f:String?)->String{
        let  dateFormatter = DateFormatter()
        if f == nil{
            dateFormatter.dateFormat = "HH:mm:ss:SSS"
        }
        else{
            dateFormatter.dateFormat = f!
        }
        let str = dateFormatter.string(from: Date())
        return str
    }
    

    class var sharedToast:Chaos {
        return sharedInstance
    }
    var lbl:ToastLable?
    var window:UIWindow?
    static func toast(_ msg:String){
        Chaos.sharedToast.showToast(msg)
    }
    
    static func toast(_ msg:String,verticalScale:Float){
        Chaos.sharedToast.showToast(msg,verticalScale:verticalScale)
    }
    
    fileprivate func showToast(_ msg:String){
        self.showToast(msg,verticalScale:0.85)
    }
    
    
    fileprivate func showToast(_ msg:String,verticalScale:Float = 0.8){
        if lbl == nil{
            lbl = ToastLable(text: msg)
        }
        else{
            lbl?.text = msg
            lbl?.sizeToFit()
            lbl?.layer.removeAnimation(forKey: "animation")
        }
        window = UIApplication.shared.keyWindow
        //Issue4 window对象可能是会改变的,前面的UIWindow是KeyWindow,后来可能就不是了,所以Toast也就显示不出来了,这个是我的猜测.
        //因为使用放大镜功能后Toast就再也显示不出来了.后面让window在每次都指向keyWindow对象就行了,但还是不完美
        if !(window!.subviews.contains(lbl!)){
            window?.addSubview(lbl!)
            lbl?.center = window!.center
            lbl?.frame.origin.y = UIScreen.main.bounds.height * CGFloat(verticalScale)
        }
        lbl?.addAnimationGroup()
    }
    
}

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
    func colorSelectedChanged(_ color: UIColor);
}

class ChaosColorPicker: UIView
{
    fileprivate var viewPickerHeight = 0;
    fileprivate let brightnessPickerHeight = 30;
    
    fileprivate var hueColorsImageView: UIImageView!, brightnessColorsImageView: UIImageView!, fullColorImageView: UIImageView!;
    
    var delegate: ColorPickerDelegate?;
    
    func colorFor( _ x: CGFloat, y: CGFloat) -> UIColor
    {
        let screenSize: CGRect = UIScreen.main.bounds
        
        return UIColor(hue: (x/screenSize.width), saturation: y/CGFloat(viewPickerHeight), brightness:1, alpha: 1);
    }
    
    func colorWithColor(_ baseColor: UIColor, brightness: CGFloat) -> UIColor
    {
        var hue: CGFloat = 0.0;
        var saturation: CGFloat = 0.0;
        
        baseColor.getHue(&hue, saturation: &saturation, brightness: nil, alpha:nil);
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1);
    }
    
    func createHueColorImage() -> UIImage
    {
        let screenSize: CGRect = UIScreen.main.bounds
        
        let imageHeight = CGFloat(viewPickerHeight - brightnessPickerHeight);
        let imageWidth: CGFloat  = screenSize.width;
        let size: CGSize = CGSize(width: imageWidth, height: CGFloat(imageHeight));
        
        UIGraphicsBeginImageContext(size);
        let context: CGContext = UIGraphicsGetCurrentContext()!;
        let recSize = CGSize(width:ceil(imageWidth/256),
            height:ceil(imageWidth/256));

        var y:CGFloat = 0
        while  y < imageHeight{
            var x:CGFloat = 0
            while x < imageWidth {
                let rec = CGRect(x: x, y: y, width: recSize.width , height: recSize.height);
                let color = self.colorFor(x, y: y);

                context.setFillColor(color.cgColor);
                context.fill(rec);
                x += imageWidth / 256
            }
            y += imageHeight / 256
        }

        
        let hueImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return hueImage!;
    }
    
    func createBrightnessImage(_ baseColor:UIColor) -> UIImage
    {
        let imageHeight = CGFloat(brightnessPickerHeight);
        let screenSize: CGRect = UIScreen.main.bounds
        
        let imageWidth: CGFloat  = screenSize.width;
        let size: CGSize = CGSize(width: imageWidth, height: CGFloat(imageHeight));
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        let context: CGContext = UIGraphicsGetCurrentContext()!;
        let recSize = CGSize(width:ceil(imageWidth/256),
            height:imageHeight);
        
        var hue:CGFloat = 0.0;
        var saturation:CGFloat = 0.0;
        baseColor.getHue(&hue, saturation:&saturation, brightness:nil, alpha:nil);
        
        var z:CGFloat = 0
        while z < imageWidth {
            let rec = CGRect(x: z, y: 0, width: recSize.width , height: recSize.height);
            let color = UIColor(hue: hue, saturation: saturation, brightness: (imageWidth-z)/imageWidth, alpha: 1);
            
            context.setFillColor(color.cgColor);
            context.fill(rec);
            z += imageWidth/256
        }
        
        let hueImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return hueImage!;
    }
    
    func createFullColorImage(_ color :UIColor, size: CGSize, radius: CGFloat) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        let context: CGContext = UIGraphicsGetCurrentContext()!;
        let rec = CGRect(x: 0, y: 0, width: size.width , height: size.height);
        
        context.setFillColor(color.cgColor);
        let roundedRect = UIBezierPath(roundedRect: rec, cornerRadius: radius);
        roundedRect.fill(with: CGBlendMode.normal, alpha: 1);
        
        let fullColorImage =  UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return fullColorImage!;
    }
    
    func loadView()
    {
        let screenSize: CGRect = UIScreen.main.bounds
        viewPickerHeight = Int(ceil( screenSize.width / 1.10344));
        
        self.frame = CGRect(x:0,y:0,width:Int(screenSize.width),height:viewPickerHeight);
        
        
        let hueColorImage = self.createHueColorImage();
        self.hueColorsImageView = UIImageView(image: hueColorImage);
        self.addSubview(self.hueColorsImageView);
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action:#selector(ChaosColorPicker.baseColorPicking(_:)));
        self.hueColorsImageView.addGestureRecognizer(panRecognizer);
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChaosColorPicker.baseColorPicking(_:)));
        self.hueColorsImageView.addGestureRecognizer(tapRecognizer);
        self.hueColorsImageView.isUserInteractionEnabled = true;
        
        
        //------
        let brightnessColorImage = self.createBrightnessImage(self.selectedBaseColor);
        self.brightnessColorsImageView = UIImageView(image: brightnessColorImage);
        self.addSubview(self.brightnessColorsImageView);
        
        var brImgRect = self.brightnessColorsImageView.frame;
        brImgRect.origin.y = self.hueColorsImageView.frame.origin.y + self.hueColorsImageView.frame.size.height;
        self.brightnessColorsImageView.frame = brImgRect;
        self.brightnessColorsImageView.isUserInteractionEnabled = true;
        
        let brightSlideGesture = UIPanGestureRecognizer(target: self, action:#selector(ChaosColorPicker.colorPicking(_:)));
        self.brightnessColorsImageView.addGestureRecognizer(brightSlideGesture);
        
        let brightTapGesture = UITapGestureRecognizer(target: self, action: #selector(ChaosColorPicker.colorPicking(_:)));
        self.brightnessColorsImageView.addGestureRecognizer(brightTapGesture);
        self.brightnessColorsImageView.isUserInteractionEnabled = true;
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
    
    func setSelectedBrightness(_ brightness: CGFloat)
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
    
    func setColor(_ color: UIColor)
    {
        selectedBaseColor = color;
        selectedColor = color;
    }
    
    func baseColorPicking(_ sender: UIGestureRecognizer)
    {
        if(sender.numberOfTouches==1)
        {
            let picked = sender.location(ofTouch: 0, in: sender.view);
            
            self.selectedBaseColor = self.colorFor(picked.x, y:picked.y);
            self.selectedColor = self.colorWithColor(self.selectedBaseColor, brightness:self.selectedBrightness);
        }
    }
    
    func colorPicking(_ sender: UIGestureRecognizer)
    {
        if(sender.numberOfTouches==1)
        {
            let picked = sender.location(ofTouch: 0, in:sender.view);
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
        selectedColor = UIColor.white;
        selectedBaseColor = UIColor.white;
        
        super.init(coder: aDecoder);
        self.loadView();
    }
}






class ToastLable:UILabel {
    enum ToastShowType{
        case top,center,bottom
    }
    var forwardAnimationDuration:CFTimeInterval = 0.3
    var backwardAnimationDuration:CFTimeInterval = 0.2
    var waitAnimationDuration:CFTimeInterval = 1.5
    var textInsets:UIEdgeInsets?
    var maxWidth:Float?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        maxWidth = Float(UIScreen.main.bounds.width) - 20.0
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.numberOfLines = 0
        self.textAlignment = NSTextAlignment.left
        self.textColor = UIColor.white
        self.font = UIFont.systemFont(ofSize: 14)
    }
    convenience init(text:String) {
        self.init(frame:CGRect.zero)
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
        animationGroup.isRemovedOnCompletion = false
        //animationGroup.delegate = self
        animationGroup.fillMode = kCAFillModeForwards
        self.layer.add(animationGroup, forKey: "animation")
    }
    override func sizeToFit() {
        super.sizeToFit()
        var fm = self.frame
        let width = self.bounds.width + self.textInsets!.left + self.textInsets!.right
        fm.size.width = width > CGFloat(self.maxWidth!) ? CGFloat(self.maxWidth!) : width
        fm.size.height = self.bounds.height + self.textInsets!.top + self.textInsets!.bottom
        fm.origin.x = UIScreen.main.bounds.width / 2 - fm.size.width / 2
        self.frame = fm
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag{
            self.removeFromSuperview()
        }
    }
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, self.textInsets!))
    }
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = bounds
        if let txt = self.text{
            rect.size =  (txt as NSString).boundingRect(with: CGSize(width: CGFloat(self.maxWidth!) - self.textInsets!.left - self.textInsets!.right, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:self.font], context: nil).size
        }
        return rect
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
class BlockAlert:UIAlertView,UIAlertViewDelegate {
    var completion:((_ buttonIndex:Int,_ alert:UIAlertView)->Void)?
    var willDismissBlock:((_ buttonIndex:Int,_ alert:UIAlertView)->Void)?
    var didDismissBlock:((_ buttonIndex:Int,_ alert:UIAlertView)->Void)?
    var didPresentBlock:((_ alert:UIAlertView)->Void)?
    var willPresentBlock:((_ alert:UIAlertView)->Void)?
    var alertWithCalcelBlock:((_ alert:UIAlertView)->Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }
    
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if let block = completion{
            block(buttonIndex, alertView)
        }
    }
    
    
    func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if let block = didDismissBlock{
            block(buttonIndex, alertView)
        }
    }
    
    func alertView(_ alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        if let block = willDismissBlock{
            block(buttonIndex, alertView)
        }
        
    }
    
    
    func didPresent(_ alertView: UIAlertView) {
        if let block = didPresentBlock{
            block(alertView)
        }
    }
    
    func willPresent(_ alertView: UIAlertView) {
        if let block = willPresentBlock{
            block(alertView)
        }
    }
    
    func alertViewCancel(_ alertView: UIAlertView) {
        if let block = alertWithCalcelBlock{
            block(alertView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
