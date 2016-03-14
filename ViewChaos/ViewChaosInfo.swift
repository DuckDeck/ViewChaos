//
//  ViewChaosInfo.swift
//  ViewChaosDemo
//
//  Created by Tyrant on 11/5/15.
//  Copyright © 2015 Qfq. All rights reserved.
//

import UIKit

class ViewChaosInfo: UIView,UITableViewDataSource,UITableViewDelegate {
    enum tbType:Int{
        case general = 0
        case superview = 1
        case subview = 2
        case constrain = 3
        case trace = 4
        case about = 5
    }
    weak var viewHit:UIView?
    var lblCurrentView:UILabel
    var btnHit:UIButton
    var btnClose:UIButton
    var btnControl:UIButton
    var tbLeft:UITableView
    var tbRight:UITableView
    var btnBack:UIButton
    var btnMinimize:UIButton
    var type:tbType = .general
    var arrSuperView:[ViewChaosObject]?
    var arrSubview:[ViewChaosObject]?
    var isTouch:Bool = false
    var top:CGFloat = 0
    var left:CGFloat = 0
    var originFrame:CGRect?
    var arrTrace:[[String:AnyObject]]?
    var viewTrackBorderWith:CGFloat?
    var viewTrackBorderColor:UIColor?
    var arrConstrains:[[String:AnyObject]]?
    var arrStackView:[ViewChaosObject]?
    var arrGeneral:[String]?
    var arrAbout:[String]?
    var arrLeft:[String]?
    var isTrace:Bool?
    
    init(){
        
        tbLeft = UITableView()
        tbRight = UITableView()
        btnClose = UIButton()
        btnBack = UIButton()
        lblCurrentView = UILabel()
        btnHit = UIButton()
        btnControl = UIButton()
        btnMinimize = UIButton()
        
        super.init(frame: CGRect(x: 10, y: 80, width: UIScreen.mainScreen().bounds.width-20, height: UIScreen.mainScreen().bounds.height-160))
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        tbLeft.frame = CGRect(x: 0, y: 50, width: self.frame.size.width / 3, height: self.frame.size.height - 50)
        tbLeft.backgroundView?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        tbLeft.backgroundColor  = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        tbLeft.tableFooterView = UIView()
        tbRight.frame = CGRect(x: tbLeft.frame.size.width, y: 50, width: self.frame.size.width - tbLeft.frame.size.width, height: self.frame.size.height - 50)
        tbRight.backgroundView?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        tbRight.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        addSubview(tbLeft)
        addSubview(tbRight)
        btnClose.frame = CGRect(x: self.frame.size.width - 45, y: 5, width: 45, height: 22)
        btnClose.setTitle("Close", forState: UIControlState.Normal)
        btnClose.titleLabel?.font = UIFont.systemFontOfSize(13)
        btnClose.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        btnClose.addTarget(self, action: "close:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(btnClose)
        btnBack.frame = CGRect(x: self.frame.size.width - btnClose.frame.size.width - 45, y: 5, width: 45, height: 22)
        btnBack.setTitle("Back", forState: UIControlState.Normal)
        btnBack.titleLabel?.font = UIFont.systemFontOfSize(12)
        btnBack.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        btnBack.addTarget(self, action: "back:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(btnBack)
        btnHit.frame = CGRect(x: btnBack.frame.origin.x - 45, y: 5, width: 45, height: 22)
        btnHit.setTitle("Hit", forState: UIControlState.Normal)
        btnHit.titleLabel?.font = UIFont.systemFontOfSize(13)
        btnHit.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        btnHit.addTarget(self, action: "hit:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(btnHit)
        btnControl.frame = CGRect(x: btnHit.frame.origin.x - 45, y: 5, width: 45, height: 22)
        btnControl.setTitle("Control", forState: UIControlState.Normal)
        btnControl.titleLabel?.font = UIFont.systemFontOfSize(13)
        btnControl.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        btnControl.addTarget(self, action: "control:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(btnControl)
        
        let lblCurrent = UILabel(frame: CGRect(x: 2, y: 5, width: 100, height: 22))
        lblCurrent.text = "Current View:"
        lblCurrent.textColor = UIColor.whiteColor()
        lblCurrent.font = UIFont.systemFontOfSize(13)
        addSubview(lblCurrent)
        lblCurrentView.frame = CGRect(x: 2, y: CGRectGetMaxY(lblCurrent.frame) + 3, width: self.frame.size.width - 3, height: 20)
        lblCurrentView.textColor = UIColor.whiteColor()
        lblCurrentView.font = UIFont.systemFontOfSize(13)
        addSubview(lblCurrentView)
        btnMinimize.frame = CGRect(x: self.frame.size.width-20, y: self.frame.size.height / 2 - 20, width: 20, height: 40)
        btnMinimize.backgroundColor = UIColor.blackColor()
        btnMinimize.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnMinimize.setTitle(">", forState: UIControlState.Normal)
        btnMinimize.addTarget(self, action: "minimize:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(btnMinimize)
    }
    
    override convenience init(frame: CGRect) {
        self.init()
    }
    
    
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        if let _ = newWindow{
            isTouch = false
            isTrace = false
            self.clipsToBounds = true
            self.translatesAutoresizingMaskIntoConstraints = true
            self.layer.borderWidth = 2
            self.layer.borderColor = UIColor.blackColor().CGColor
            tbLeft.delegate = self
            tbLeft.dataSource = self
            tbRight.delegate = self
            tbRight.dataSource = self
            btnBack.hidden = true
            arrLeft = ["General","SuperView","SubView","Constrains","Trace","About"]
            arrStackView = [ViewChaosObject]()
            arrGeneral = [String]()
            arrAbout = ["这是一个测试UI的工具",",这个工具是RunTrace的Swift版本.希望大家用得开心"]
            initView(viewHit!, back: false)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleRemoveView:", name: handleTraceRemoveView, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleRemoveSubView:", name: handleTraceRemoveSubView, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleAddSubView:", name: handleTraceAddSubView, object: nil)
        }
        else{
            NSNotificationCenter.defaultCenter().removeObserver(self)
            if isTrace! && viewHit != nil{
                stopTrace()
            }
            NSNotificationCenter.defaultCenter().postNotificationName(handleTraceShow, object: nil)
        }
    }
    
    
    func handleRemoveSubView(notif:NSNotification){
        var view = notif.object as! UIView
        if viewHit! == view{
            view = notif.userInfo!["subview" as NSObject] as! UIView
            var dict:[String:AnyObject] = [String:AnyObject]()
            dict["key"] = "Add Subview"
            dict["Time"] = Chaos.currentDate(nil)
            dict["OldValue"] = "\(view.dynamicType)l:\(view.frame.origin.x.format(".1f"))t:\(view.frame.origin.y.format(".1f"))w:\(view.frame.size.width.format(".1f"))h:\(view.frame.size.height.format(".1f"))"
            dict["NewValue"] = "nil"
            arrTrace?.append(dict)
            if type == .trace{
                tbRight.reloadData()
                tbRight.tableFooterView = UIView()
            }
        }
    }
    
    
    func handleAddSubView(notif:NSNotification)
    {
        var view = notif.object as! UIView
        if viewHit! == view{
            view = notif.userInfo!["subview" as NSObject] as! UIView
            var dict:[String:AnyObject] = [String:AnyObject]()
            dict["key"] = "Add Subview"
            dict["Time"] = Chaos.currentDate(nil)
            dict["OldValue"] = "nil"
            dict["NewValue"] = "\(view.dynamicType)l:\(view.frame.origin.x.format(".1f"))t:\(view.frame.origin.y.format(".1f"))w:\(view.frame.size.width.format(".1f"))h:\(view.frame.size.height.format(".1f"))"
            arrTrace?.append(dict)
            if type == .trace{
                tbRight.reloadData()
                tbRight.tableFooterView = UIView()
            }
        }
        
    }
    
    
    func handleRemoveView(notif:NSNotification){
        let view = notif.object as! UIView
        if viewHit! == view{
            stopTrace()
            viewHit?.layer.borderColor = viewTrackBorderColor?.CGColor
            viewHit?.layer.borderWidth = viewTrackBorderWith!
            var dict:[String:AnyObject] = [String:AnyObject]()
            dict["key"] = "RemoveFromSuperview"
            dict["Time"] = Chaos.currentDate(nil)
            dict["OldValue"] = "\(view.dynamicType)l:\(view.frame.origin.x.format(".1f"))t:\(view.frame.origin.y.format(".1f"))w:\(view.frame.size.width.format(".1f"))h:\(view.frame.size.height.format(".1f"))"
            dict["NewValue"] = "nil"
            arrTrace?.append(dict)
            if type == .trace{
                tbRight.reloadData()
                tbRight.tableFooterView = UIView()
                if let btn = tbRight.tableHeaderView as? UIButton{
                    btn.setTitle("Start", forState: UIControlState.Normal)
                }
            }
            arrSubview?.removeAll()
            arrSuperView?.removeAll()
            arrConstrains?.removeAll()
            let alert = UIAlertView(title: "ViewChecl", message: "\(view.dynamicType)RemoveFromSuperview", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            lblCurrentView.text = lblCurrentView.text! + "has removed"
        }
    }
    
    
    
    func initView(view:UIView,back:Bool){
        stopTrace()
        viewHit = view
        if let name = viewHit?.chaosName{
            lblCurrentView.text = "\(viewHit!.dynamicType) name:\(name) (\(viewHit!.description))"
        }
        else{
            lblCurrentView.text = "\(viewHit!.dynamicType)(\(viewHit!.description))"
        }
        
        if !back {
            arrStackView?.append(ViewChaosObject.objectWithWeak(view) as! ViewChaosObject)
            if arrStackView?.count >= 2{
                btnBack.hidden = false
            }
        }
        arrSuperView = [ViewChaosObject]()
        var viewSuper = viewHit
        while viewSuper?.superview != nil{
            viewSuper = viewSuper?.superview
            arrSuperView?.append(ViewChaosObject.objectWithWeak(viewSuper!) as! ViewChaosObject)
        }
        arrSubview = [ViewChaosObject]()
        for sub in viewHit!.subviews{
            arrSubview?.append(ViewChaosObject.objectWithWeak(sub) as! ViewChaosObject)
        }
        arrTrace = [[String:AnyObject]]()
        arrConstrains = [[String:AnyObject]]()
        arrGeneral = [String]()
        arrGeneral?.append( "Class Name:\(viewHit!.dynamicType)")
        arrGeneral?.append("AutoLayout:\(viewHit!.translatesAutoresizingMaskIntoConstraints ? "NO" : "YES")")
        arrGeneral?.append("Left:\(viewHit!.frame.origin.x.format(".2f"))")
        arrGeneral?.append("Top:\(viewHit!.frame.origin.y.format(".2f"))")
        arrGeneral?.append("Width:\(viewHit!.frame.size.width.format(".2f"))")
        arrGeneral?.append("Height:\(viewHit!.frame.size.height.format(".2f"))")
        analysisAutolayout()
        tbRight.reloadData()
        tbRight.tableFooterView = UIView()
    }
    
    func onTrace(sender:UIButton)
    {
        if sender.titleForState(UIControlState.Normal) == "Start"{
            startTrace()
        }
        else{
            stopTrace()
        }
    }
    
    func startTrace(){
        let btn = tbRight.tableHeaderView! as! UIButton
        if viewHit == nil{
            let alert = UIAlertView(title: "ViewCheck", message: "View has removed and can't trace!", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        isTrace =  true
        btn.setTitle("Stop", forState: UIControlState.Normal)
        arrTrace?.removeAll()
        tbRight.reloadData()
        tbRight.tableFooterView = UIView()
        viewHit?.addObserver(self, forKeyPath: "frame", options: [NSKeyValueObservingOptions.Old,NSKeyValueObservingOptions.New], context: nil)
        viewHit?.addObserver(self, forKeyPath: "center", options: [NSKeyValueObservingOptions.Old,NSKeyValueObservingOptions.New], context: nil)
        viewHit?.addObserver(self, forKeyPath: "superview.frame", options: [NSKeyValueObservingOptions.Old,NSKeyValueObservingOptions.New], context: nil)
        viewHit?.addObserver(self, forKeyPath: "tag", options: [NSKeyValueObservingOptions.Old,NSKeyValueObservingOptions.New], context: nil)
        viewHit?.addObserver(self, forKeyPath: "userInteractionEnabled", options: [NSKeyValueObservingOptions.Old,NSKeyValueObservingOptions.New], context: nil)
        viewHit?.addObserver(self, forKeyPath: "hidden", options: [NSKeyValueObservingOptions.Old,NSKeyValueObservingOptions.New], context: nil)
        viewHit?.addObserver(self, forKeyPath: "bounds", options: [NSKeyValueObservingOptions.Old,NSKeyValueObservingOptions.New], context: nil)
        if viewHit! is UIScrollView{
            viewHit?.addObserver(self, forKeyPath: "contentSize", options: [NSKeyValueObservingOptions.Old,NSKeyValueObservingOptions.New], context: nil)
            viewHit?.addObserver(self, forKeyPath: "contentOffset", options: [NSKeyValueObservingOptions.Old,NSKeyValueObservingOptions.New], context: nil)
            viewHit?.addObserver(self, forKeyPath: "contentInset", options: [NSKeyValueObservingOptions.Old,NSKeyValueObservingOptions.New], context: nil)
        }
        traceSuperAndSubView()
        Chaos.toast("Start Trace")
    }
    
    func stopTrace(){
        if !isTrace!{
            return
        }
        isTrace = false
        let btn = tbRight.tableHeaderView! as! UIButton
        btn.setTitle("Start", forState: UIControlState.Normal)
        viewHit?.removeObserver(self, forKeyPath: "frame")
        viewHit?.removeObserver(self, forKeyPath: "center")
        viewHit?.removeObserver(self, forKeyPath: "superview.frame")
        viewHit?.removeObserver(self, forKeyPath: "tag")
        viewHit?.removeObserver(self, forKeyPath: "userInteractionEnabled")
        viewHit?.removeObserver(self, forKeyPath: "hidden")
        viewHit?.removeObserver(self, forKeyPath: "bounds")
        if viewHit is UIScrollView{
            viewHit?.removeObserver(self, forKeyPath: "contentSize")
            viewHit?.removeObserver(self, forKeyPath: "contentOffset")
            viewHit?.removeObserver(self, forKeyPath: "contentInset")
        }
        viewHit?.layer.borderColor = viewTrackBorderColor?.CGColor
        viewHit?.layer.borderWidth = viewTrackBorderWith!
    }
    
    func close(sender:UIButton){
        if btnClose.titleForState(UIControlState.Normal) == "Close"{
            self.removeFromSuperview()
            NSNotificationCenter.defaultCenter().postNotificationName("handleTraceViewClose", object: nil)
        }
        else if btnClose.titleForState(UIControlState.Normal) == "Stop"{
            stopTrace()
            if isTrace! &&  viewHit != nil{
                viewHit?.layer.borderColor = viewTrackBorderColor?.CGColor
                viewHit?.layer.borderWidth = viewTrackBorderWith!
                isTrace = false
            }
        }
    }
    
    func back(sender:UIButton){
        arrStackView?.removeLast()
        let view = arrStackView!.last!.obj as! UIView
        if arrStackView?.count == 1{
            btnBack.hidden = true
        }
        initView(view, back: true)
    }
    
    func hit(sender:UIButton){
        if viewHit == nil{
            let alert = UIAlertView(title: "ViewChaos", message: "View has removed and can't hit!", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        NSNotificationCenter.defaultCenter().postNotificationName("handleTraceView", object: viewHit!)
        minimize()
    }
    
    func control(sender:UIButton){
        if viewHit == nil{
            let alert = UIAlertView(title: "ViewChaos", message: "View has removed and can't control!", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        NSNotificationCenter.defaultCenter().postNotificationName(controlTraceView, object: viewHit!)
        minimize()
    }
    
    func analysisAutolayout(){
        if viewHit == nil
        {
            return
        }
        if viewHit!.translatesAutoresizingMaskIntoConstraints{
            return
        }
        var viewConstraint = viewHit
        while viewConstraint != nil && !(viewConstraint!.isKindOfClass(NSClassFromString("UIViewControllerWrapperView")!))
        {
            for con in viewConstraint!.constraints{
                var constant = con.constant
                let viewFirst = con.firstItem as! UIView
                let viewSecond = con.secondItem as? UIView
                if con.secondItem != nil{
                    if con.firstItem as! UIView == viewHit! && con.firstAttribute == con.secondAttribute{
                        if viewFirst.isDescendantOfView(viewSecond!){
                            constant = con.constant
                        }
                        else if viewSecond!.isDescendantOfView(viewFirst){
                            constant = -con.constant
                        }
                        else{
                            constant = con.constant
                        }
                    }
                    else if con.firstItem as! UIView == viewHit! && con.firstAttribute != con.secondAttribute{
                        constant = con.constant
                    }
                    else if(con.secondItem as! UIView == viewHit! && con.firstAttribute == con.secondAttribute){
                        if viewFirst.isDescendantOfView(viewSecond!){
                            constant = -con.constant
                        }
                        else if viewSecond!.isDescendantOfView(viewFirst)
                        {
                            constant = con.constant
                        }
                        else{
                            constant = con.constant
                        }
                    }
                    else if con.secondItem as! UIView == viewHit! && con.firstAttribute != con.secondAttribute{
                        constant = con.constant
                    }
                }
                if con.firstItem as! UIView == viewHit! && (con.firstAttribute == NSLayoutAttribute.Leading || con.firstAttribute == NSLayoutAttribute.Left || con.firstAttribute == NSLayoutAttribute.LeadingMargin || con.firstAttribute == NSLayoutAttribute.LeftMargin){
                    var dict = [String:AnyObject]()
                    dict["Type"] = "Left"
                    dict["Value"] = con.description
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.secondItem!)
                    dict["Constant"] = con.constant
                    dict["Multiplier"] = con.multiplier
                    dict["Priority"] = con.priority
                    arrConstrains?.append(dict)
                }
                else if  con.secondItem as? UIView == viewHit! && (con.secondAttribute == NSLayoutAttribute.Leading || con.secondAttribute == NSLayoutAttribute.Left || con.secondAttribute == NSLayoutAttribute.LeadingMargin || con.secondAttribute == NSLayoutAttribute.LeftMargin){
                    var dict = [String:AnyObject]()
                    dict["Type"] = "Left"
                    dict["Value"] = con.description
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.firstItem)
                    dict["Constant"] = constant
                    dict["Multiplier"] = con.multiplier
                    dict["Priority"] = con.priority
                    arrConstrains?.append(dict)
                }
                else if con.firstItem as! UIView == viewHit! && (con.firstAttribute == NSLayoutAttribute.Top || con.firstAttribute == NSLayoutAttribute.TopMargin) {
                    var dict = [String:AnyObject]()
                    dict["Type"] = "Top"
                    dict["Value"] = con.description
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.secondItem!)
                    dict["Constant"] = constant
                    dict["Multiplier"] = con.multiplier
                    dict["Priority"] = con.priority
                    arrConstrains?.append(dict)
                }
                else if con.secondItem as? UIView == viewHit! && (con.secondAttribute == NSLayoutAttribute.Top || con.secondAttribute == NSLayoutAttribute.TopMargin) {
                    var dict = [String:AnyObject]()
                    dict["Type"] = "Top"
                    dict["Value"] = con.description
                    Chaos.Log(con.description)
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.firstItem)
                    dict["Constant"] = constant
                    dict["Multiplier"] = con.multiplier
                    dict["Priority"] = con.priority
                    arrConstrains?.append(dict)
                }
                else if con.firstItem as! UIView == viewHit! && (con.firstAttribute == NSLayoutAttribute.Trailing || con.firstAttribute == NSLayoutAttribute.TrailingMargin || con.firstAttribute == NSLayoutAttribute.Right || con.firstAttribute == NSLayoutAttribute.RightMargin){
                    var dict = [String:AnyObject]()
                    dict["Type"] = "Right"
                    dict["Value"] = con.description
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.secondItem!)
                    dict["Constant"] = constant
                    dict["Multiplier"] = con.multiplier
                    dict["Priority"] = con.priority
                    arrConstrains?.append(dict)
                }
                else if con.secondItem as? UIView == viewHit! && (con.secondAttribute == NSLayoutAttribute.Trailing || con.secondAttribute == NSLayoutAttribute.TrailingMargin || con.secondAttribute == NSLayoutAttribute.Right || con.secondAttribute == NSLayoutAttribute.RightMargin){
                    var dict = [String:AnyObject]()
                    dict["Type"] = "Right"
                    dict["Value"] = con.description
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.firstItem)
                    dict["Constant"] = constant
                    dict["Multiplier"] = con.multiplier
                    dict["Priority"] = con.priority
                    arrConstrains?.append(dict)
                }
                else if con.firstItem as! UIView == viewHit! && (con.firstAttribute == NSLayoutAttribute.Bottom || con.firstAttribute == NSLayoutAttribute.BottomMargin) {
                    var dict = [String:AnyObject]()
                    dict["Type"] = "Bottom"
                    dict["Value"] = con.description
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.secondItem!)
                    dict["Constant"] = constant
                    dict["Multiplier"] = con.multiplier
                    dict["Priority"] = con.priority
                    arrConstrains?.append(dict)
                }
                else if con.secondItem as? UIView == viewHit! && (con.secondAttribute == NSLayoutAttribute.Bottom || con.secondAttribute == NSLayoutAttribute.BottomMargin) {
                    var dict = [String:AnyObject]()
                    dict["Type"] = "Bottom"
                    dict["Value"] = con.description
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.firstItem)
                    dict["Constant"] = constant
                    dict["Multiplier"] = con.multiplier
                    dict["Priority"] = con.priority
                    arrConstrains?.append(dict)
                }
                else if (con.firstItem as! UIView == viewHit! && con.firstAttribute == NSLayoutAttribute.Width) || (con.secondItem as? UIView == viewHit && con.secondAttribute == NSLayoutAttribute.Width){
                    if con.isKindOfClass(NSClassFromString("NSContentSizeLayoutConstraint")!){
                        var dict = [String:AnyObject]()
                        dict["Type"] = "IntrinsicContent Width"
                        dict["Value"] = con.description
                        dict["Constant"] = constant
                        arrConstrains?.append(dict)
                    }
                    else{
                        var dict = [String:AnyObject]()
                        dict["Type"] = "Width"
                        dict["Value"] = con.description
                        dict["ToView"] = ViewChaosObject.objectWithWeak(con.firstItem)
                        dict["Constant"] = constant
                        dict["Multiplier"] = con.multiplier
                        dict["Priority"] = con.priority
                        arrConstrains?.append(dict)
                    }
                }
                else if (con.firstItem as! UIView == viewHit! && con.firstAttribute == NSLayoutAttribute.Height) || (con.secondItem as? UIView == viewHit && con.secondAttribute == NSLayoutAttribute.Height){
                    if con.isKindOfClass(NSClassFromString("NSContentSizeLayoutConstraint")!){
                        var dict = [String:AnyObject]()
                        dict["Type"] = "IntrinsicContent Height"
                        dict["Value"] = con.description
                        dict["Constant"] = con.constant
                        arrConstrains?.append(dict)
                    }
                    else{
                        var dict = [String:AnyObject]()
                        dict["Type"] = "Height"
                        dict["Value"] = con.description
                        dict["ToView"] = ViewChaosObject.objectWithWeak(con.firstItem)
                        dict["Constant"] = constant
                        dict["Multiplier"] = con.multiplier
                        dict["Priority"] = con.priority
                        arrConstrains?.append(dict)
                    }
                }
                else if con.firstItem as! UIView == viewHit! && con.firstAttribute == NSLayoutAttribute.CenterX{
                    var dict = [String:AnyObject]()
                    dict["Type"] = "CenterX"
                    dict["Value"] = con.description
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.secondItem!)
                    dict["Constant"] = constant
                    dict["Multiplier"] = con.multiplier
                    dict["Priority"] = con.priority
                    arrConstrains?.append(dict)
                }
                else if con.secondItem as? UIView == viewHit! && con.firstAttribute == NSLayoutAttribute.CenterX{
                    var dict = [String:AnyObject]()
                    dict["Type"] = "CenterX"
                    dict["Value"] = con.description
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.firstItem)
                    dict["Constant"] = constant
                    dict["Multiplier"] = con.multiplier
                    dict["Priority"] = con.priority
                    arrConstrains?.append(dict)
                }
                else if con.firstItem as! UIView == viewHit! && con.firstAttribute == NSLayoutAttribute.CenterY{
                    var dict = [String:AnyObject]()
                    dict["Type"] = "CenterY"
                    dict["Value"] = con.description
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.secondItem!)
                    dict["Constant"] = constant
                    dict["Multiplier"] = con.multiplier
                    dict["Priority"] = con.priority
                    arrConstrains?.append(dict)
                }
                else if con.secondItem as? UIView == viewHit! && con.firstAttribute == NSLayoutAttribute.CenterY{
                    var dict = [String:AnyObject]()
                    dict["Type"] = "CenterY"
                    dict["Value"] = con.description
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.firstItem)
                    dict["Constant"] = constant
                    dict["Multiplier"] = con.multiplier
                    dict["Priority"] = con.priority
                    arrConstrains?.append(dict)
                }
                else if con.firstItem as! UIView == viewHit! && con.firstAttribute == NSLayoutAttribute.Baseline{
                    var dict = [String:AnyObject]()
                    dict["Type"] = "BaseLine"
                    dict["Value"] = con.description
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.secondItem!)
                    dict["Constant"] = constant
                    dict["Multiplier"] = con.multiplier
                    dict["Priority"] = con.priority
                    arrConstrains?.append(dict)
                }
                else if con.secondItem as? UIView == viewHit! && con.firstAttribute == NSLayoutAttribute.Baseline{
                    var dict = [String:AnyObject]()
                    dict["Type"] = "BaseLine"
                    dict["Value"] = con.description
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.firstItem)
                    dict["Constant"] = constant
                    dict["Multiplier"] = con.multiplier
                    dict["Priority"] = con.priority
                    arrConstrains?.append(dict)
                }
                    
                    
            }
            viewConstraint = viewConstraint?.superview
        }
    }
    
    
    func minimize(){
        originFrame = self.frame
        let fm = CGRect(x: UIScreen.mainScreen().bounds.width - 20, y: UIScreen.mainScreen().bounds.height / 2 - 20, width: 20, height: 40)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.frame = fm
            }) { (finished) -> Void in
                let btn = UIButton(frame: self.bounds)
                btn.setTitle("<", forState: UIControlState.Normal)
                btn.backgroundColor = UIColor.blackColor()
                btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                btn.addTarget(self, action: "expand:", forControlEvents: UIControlEvents.TouchUpInside)
                self.addSubview(btn)
        }
    }
    
    func expand(sender:UIButton){
        sender.removeFromSuperview()
        NSNotificationCenter.defaultCenter().postNotificationName("handleTraceViewClose", object: nil)
        UIView.animateWithDuration(0.2) { () -> Void in
            self.frame = self.originFrame!
        }
    }
    
    func minimize(sender:UIButton){
        minimize()
    }
    
    
    func traceSuperAndSubView(){
        if viewHit == nil{
            let alert = UIAlertView(title: "ViewChecK", message: "View has removed and can't trace!", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        viewTrackBorderWith = viewHit!.layer.borderWidth
        viewTrackBorderColor = UIColor(CGColor: viewHit!.layer.borderColor!)
        viewHit?.layer.borderWidth = 3
        viewHit?.layer.borderColor = UIColor.blackColor().CGColor
        minimize()
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "frame"{
            let oldFrame = change![NSKeyValueChangeOldKey]!.CGRectValue
            let newFrame = change![NSKeyValueChangeNewKey]!.CGRectValue
            if CGRectEqualToRect(oldFrame, newFrame)
            {
                return
            }
            var dict = [String:AnyObject]()
            dict["Key"] = "Frame Change"
            dict["Time"] = Chaos.currentDate(nil)
            dict["OldValue"] = "l:\(oldFrame.origin.x.format(".1f")) t:\(oldFrame.origin.y.format(".1f")) w:\(oldFrame.origin.x.format(".1f")) :h\(oldFrame.origin.x.format(".1f"))"
            dict["NewValue"] = "l:\(newFrame.origin.x.format(".1f")) t:\(newFrame.origin.y.format(".1f")) w:\(newFrame.origin.x.format(".1f")) h:\(newFrame.origin.x.format(".1f"))"
            arrTrace?.append(dict)
        }
        else if keyPath == " center"{
            let oldCenter = change![NSKeyValueChangeOldKey]!.CGPointValue
            let newCenter = change![NSKeyValueChangeNewKey]!.CGPointValue
            if CGPointEqualToPoint(oldCenter, newCenter)
            {
                return
            }
            var dict = [String:AnyObject]()
            dict["Key"] = "Center Change"
            dict["Time"] = Chaos.currentDate(nil)
            dict["OldValue"] = "l:\(oldCenter.x.format(".1f")) t:\(oldCenter.y.format(".1f"))"
            dict["NewValue"] = "l:\(newCenter.x.format(".1f")) t:\(newCenter.y.format(".1f"))"
            arrTrace?.append(dict)
        }
        else if keyPath == "superview.frame"{
            let oldFrame = change![NSKeyValueChangeOldKey]!.CGRectValue
            let newFrame = change![NSKeyValueChangeNewKey]!.CGRectValue
            if CGRectEqualToRect(oldFrame, newFrame)
            {
                return
            }
            var dict = [String:AnyObject]()
            dict["Key"] = "Superview Frame Change"
            dict["Time"] = Chaos.currentDate(nil)
            dict["OldValue"] = "l:\(oldFrame.origin.x.format(".1f")) t:\(oldFrame.origin.y.format(".1f")) w:\(oldFrame.origin.x.format(".1f")) :h\(oldFrame.origin.x.format(".1f"))"
            dict["NewValue"] = "l:\(newFrame.origin.x.format(".1f")) t:\(newFrame.origin.y.format(".1f")) w:\(newFrame.origin.x.format(".1f")) h:\(newFrame.origin.x.format(".1f"))"
            dict["SuperView"] = "\((object! as! UIView).superview.dynamicType)"
            arrTrace?.append(dict)
        }
        else if keyPath == "tag"{
            let oldValue = change![NSKeyValueChangeOldKey]!.integerValue
            let newValue = change![NSKeyValueChangeNewKey]!.integerValue
            var dict = [String:AnyObject]()
            dict["Key"] = "Tag Change"
            dict["Time"] = Chaos.currentDate(nil)
            dict["OldValue"] = "\(oldValue)"
            dict["NewValue"] = "\(newValue)"
            arrTrace?.append(dict)
        }
        else if keyPath == "userInteractionEnabled"{
            let oldValue = change![NSKeyValueChangeOldKey]!.boolValue
            let newValue = change![NSKeyValueChangeNewKey]!.boolValue
            var dict = [String:AnyObject]()
            dict["Key"] = "UserInteractionEnabled Change"
            dict["Time"] = Chaos.currentDate(nil)
            dict["OldValue"] = "\(oldValue! ? "Yes" : "No")"
            dict["NewValue"] = "\(newValue! ? "Yes" : "No")"
            arrTrace?.append(dict)
        }
        else if keyPath == "hidden"{
            let oldValue = change![NSKeyValueChangeOldKey]!.boolValue
            let newValue = change![NSKeyValueChangeNewKey]!.boolValue
            var dict = [String:AnyObject]()
            dict["Key"] = "Hidden Change"
            dict["Time"] = Chaos.currentDate(nil)
            dict["OldValue"] = "\(oldValue! ? "Yes" : "No")"
            dict["NewValue"] = "\(newValue! ? "Yes" : "No")"
            arrTrace?.append(dict)
        }
        else if keyPath == "bounds"{
            let oldFrame = change![NSKeyValueChangeOldKey]!.CGRectValue
            let newFrame = change![NSKeyValueChangeNewKey]!.CGRectValue
            if CGRectEqualToRect(oldFrame, newFrame)
            {
                return
            }
            var dict = [String:AnyObject]()
            dict["Key"] = "Bounds Change"
            dict["Time"] = Chaos.currentDate(nil)
            dict["OldValue"] = "l:\(oldFrame.origin.x.format(".1f")) t:\(oldFrame.origin.y.format(".1f")) w:\(oldFrame.origin.x.format(".1f")) :h\(oldFrame.origin.x.format(".1f"))"
            dict["NewValue"] = "l:\(newFrame.origin.x.format(".1f")) t:\(newFrame.origin.y.format(".1f")) w:\(newFrame.origin.x.format(".1f")) h:\(newFrame.origin.x.format(".1f"))"
            arrTrace?.append(dict)
        }
        else if keyPath == "contentSize"{
            let oldSize = change![NSKeyValueChangeOldKey]!.CGSizeValue()
            let newSize = change![NSKeyValueChangeNewKey]!.CGSizeValue()
            if CGSizeEqualToSize(oldSize, newSize)
            {
                return
            }
            var dict = [String:AnyObject]()
            dict["Key"] = "ContentSize Change"
            dict["Time"] = Chaos.currentDate(nil)
            dict["OldValue"] = "w:\(oldSize.width.format(".1f")) h:\(oldSize.height.format(".1f"))"
            dict["NewValue"] = "w:\(newSize.width.format(".1f")) h:\(newSize.height.format(".1f"))"
            arrTrace?.append(dict)
        }
        else if keyPath == "contentOffset"{
            let oldOffset = change![NSKeyValueChangeOldKey]!.CGPointValue
            let newOffset = change![NSKeyValueChangeNewKey]!.CGPointValue
            if CGPointEqualToPoint(oldOffset, newOffset)
            {
                return
            }
            var dict = [String:AnyObject]()
            dict["Key"] = "ContentOffset Change"
            dict["Time"] = Chaos.currentDate(nil)
            dict["OldValue"] = "l:\(oldOffset.x.format(".1f")) t:\(oldOffset.y.format(".1f"))"
            dict["NewValue"] = "l:\(newOffset.x.format(".1f")) t:\(newOffset.y.format(".1f"))"
            arrTrace?.append(dict)
        }
        else if keyPath == "contentInset"{
            let oldEdge = change![NSKeyValueChangeOldKey]!.UIEdgeInsetsValue()
            let newEdge = change![NSKeyValueChangeNewKey]!.UIEdgeInsetsValue()
            if UIEdgeInsetsEqualToEdgeInsets(oldEdge, newEdge){
                return
            }
            var dict = [String:AnyObject]()
            dict["Key"] = "ContentInset Change"
            dict["Time"] = Chaos.currentDate(nil)
            dict["OldValue"] = "l:\(oldEdge.left.format(".1f")) t:\(oldEdge.top.format(".1f")) r:\(oldEdge.right.format(".1f")) b:\(oldEdge.bottom.format(".1f"))"
            dict["NewValue"] = "l:\(newEdge.left.format(".1f")) t:\(newEdge.top.format(".1f")) r:\(newEdge.right.format(".1f")) :b\(newEdge.bottom.format(".1f"))"
            arrTrace?.append(dict)
        }
        tbRight .reloadData()
        tbRight.tableFooterView = UIView()
    }
    
    
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isTouch = true
        if  let touch = touches.first{
            let p = touch.locationInView(self)
            left = p.x
            top = p.y
        }
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !isTouch{
            return
        }
        if let touch = touches.first
        {
            let p = touch.locationInView(self.window)
            self.frame = CGRect(x: p.x - left, y: p.y - top, width: self.frame.size.width, height: self.frame.size.height)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isTouch = false
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        isTouch = false
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tbLeft{
            return tbType.about.rawValue  + 1
        }
        else if tableView == tbRight{
            if type == .general{
                return (arrGeneral!.count)
            }
            else if type == .superview{
                return arrSuperView!.count
            }
            else if type == .subview{
                return arrSubview!.count
            }
            else if type == .constrain{
                return arrConstrains!.count
            }
            else if type  == .trace{
                return arrTrace!.count
            }
            else if type == .about{
                return arrAbout!.count
            }
            else
            {
                return 0
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        if tableView == tbLeft{
            cell = tableView.dequeueReusableCellWithIdentifier("cellLeft")
            if cell == nil{
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cellLeft")
                cell?.backgroundColor = UIColor.clearColor()
            }
            cell?.textLabel?.font = UIFont.systemFontOfSize(14)
            cell?.textLabel?.text = arrLeft![indexPath.row]
            return cell!
        }
        else{
            switch type{
            case .general:cell = handleGeneralCell(indexPath)
            case .superview:cell = handleSuperViewCell(indexPath)
            case .subview:cell = handleSubViewCell(indexPath)
            case .constrain:cell = handleConstrainCell(indexPath)
            case .trace:cell = handleTraceCell(indexPath)
            case .about:cell = handleAboutCell(indexPath)
            }
            return cell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == tbLeft{
            type = tbType.init(rawValue: indexPath.row)!
            tbRight.reloadData()
            if type == .trace{
                let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
                btn.setTitle(isTrace! ? "Stop" : "Start", forState: UIControlState.Normal)
                btn.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
                btn.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.74, alpha: 1.0)
                btn.addTarget(self, action: "onTrace:", forControlEvents: UIControlEvents.TouchUpInside)
                tbRight.tableHeaderView = btn
            }
            else
            {
                tbRight.tableHeaderView = nil
            }
        }
        else{
            switch type{
            case .superview: let view = arrSuperView![indexPath.row].obj as? UIView
                if view != nil{
                    NSNotificationCenter.defaultCenter().postNotificationName(handleTraceView, object: view!) //不需要点一下就跳进去看那个View, 所以这里不要缩小
                    initView(view!, back: false)
                }
            case .subview: let view = arrSubview![indexPath.row].obj as? UIView
                if view != nil{
                    NSNotificationCenter.defaultCenter().postNotificationName(handleTraceView, object: view!) //不需要点一下就跳进去看那个View, 所以这里不要缩小
                    initView(view!, back: false)
                }
            case .constrain: let strType = arrConstrains![indexPath.row]["Type"] as! String
                if strType == "IntrinsicContent Width" || strType == "IntrinsicContent Height" || strType == "BaseLine" {
                    return
                }
                if viewHit == nil{
                    return;
                }
                var dict = arrConstrains![indexPath.row]
                dict["View"] = ViewChaosObject.objectWithWeak(viewHit!)
                NSNotificationCenter.defaultCenter().postNotificationName(handleTraceContraints, object: dict)
                 minimize()  //只有这里可以缩小一下
            default: return
            }
           
        }
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == tbLeft{
            return 44
        }
        else
        {
            switch type{
            case .general: return heightForGeneralCell(indexPath, width: tableView.bounds.size.width - 2 * tableView.separatorInset.left)
            case .superview: return heightForSuperViewCell(indexPath, width: tableView.bounds.size.width - 2 * tableView.separatorInset.left)
            case .subview: return heightForSubViewCell(indexPath, width: tableView.bounds.size.width - 2 * tableView.separatorInset.left)
            case .constrain: return heightForConstrainCell(indexPath, width: tableView.bounds.size.width - 2 * tableView.separatorInset.left)
            case .trace: return heightForTraceCell(indexPath, width: tableView.bounds.size.width - 2 * tableView.separatorInset.left)
            case .about: return heightForAboutCell(indexPath, width: tableView.bounds.size.width - 2 * tableView.separatorInset.left)
            }
        }
    }
    
    func handleGeneralCell(index:NSIndexPath)->UITableViewCell{
        var cell = tbRight.dequeueReusableCellWithIdentifier("tbrightGeneral")
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "tbrightGeneral")
            cell?.backgroundColor = UIColor.clearColor()
        }
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
        cell?.textLabel?.frame = CGRect(x: 0, y: 0, width: cell!.textLabel!.frame.size.width, height: 40)
        cell?.textLabel?.text = arrGeneral![index.row]
        cell?.textLabel?.sizeToFit()
        return cell!
    }
    
    func handleSuperViewCell(index:NSIndexPath)->UITableViewCell{
        var cell = tbRight.dequeueReusableCellWithIdentifier("tbrightSuperView")
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "tbrightSuperView")
            cell?.backgroundColor = UIColor.clearColor()
        }
        let view = (arrSuperView![index.row]).obj as? UIView
        if view == nil{
            cell?.textLabel?.text = "view has released"
            cell?.detailTextLabel?.text = ""
        }
        else{
            cell?.textLabel?.numberOfLines = 0
            cell?.textLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
            cell?.textLabel?.frame = CGRect(x: 0, y: 0, width: cell!.textLabel!.frame.size.width, height: 40)
            cell?.textLabel?.font = UIFont.systemFontOfSize(15)
            cell?.textLabel?.text = "\(view!.dynamicType)"
            cell?.textLabel?.sizeToFit()
            cell?.detailTextLabel?.numberOfLines = 0
            cell?.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
            cell?.detailTextLabel?.frame = CGRect(x: 0, y: 0, width: cell!.detailTextLabel!.frame.size.width, height: 40)
            cell?.detailTextLabel?.text = "l:\(view!.frame.origin.x.format(".1f")) t:\(view!.frame.origin.y.format(".1f")) w:\(view!.frame.size.width.format(".1f")) h:\(view!.frame.size.height.format(".1f"))"
            if view is UILabel || view is UITextField || view is UITextView{
                if let text = view?.valueForKey("text") as? String{
                    cell?.detailTextLabel?.text = cell!.detailTextLabel!.text! + " text(\((text as NSString).length): \(text))"
                }
            }
            else if view is UIButton{
                let btn = view as! UIButton
                let title = btn.titleForState(UIControlState.Normal) == nil ? "": btn.titleForState(UIControlState.Normal)!
                cell?.detailTextLabel?.text = cell!.detailTextLabel!.text! + " text(\((title as NSString).length): \(title))"
            }
            cell?.detailTextLabel?.sizeToFit()
        }
        return cell!
        
    }
    
    func handleSubViewCell(index:NSIndexPath)->UITableViewCell{
        var cell = tbRight.dequeueReusableCellWithIdentifier("tbrightSubView")
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "tbrightSubView")
            cell?.backgroundColor = UIColor.clearColor()
        }
        let view = (arrSubview![index.row]).obj as? UIView
        if view == nil{
            cell?.textLabel?.text = "view has released"
            cell?.detailTextLabel?.text = ""
        }
        else{
            cell?.textLabel?.numberOfLines = 0
            cell?.textLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
            cell?.textLabel?.frame = CGRect(x: 0, y: 0, width: cell!.textLabel!.frame.size.width, height: 40)
            cell?.textLabel?.text = "\(view!.dynamicType)"
            cell?.textLabel?.sizeToFit()
            cell?.detailTextLabel?.numberOfLines = 0
            cell?.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
            cell?.detailTextLabel?.frame = CGRect(x: 0, y: 0, width: cell!.detailTextLabel!.frame.size.width, height: 40)
            cell?.detailTextLabel?.text = "l:\(view!.frame.origin.x.format(".1f")) t:\(view!.frame.origin.y.format(".1f")) w:\(view!.frame.size.width.format(".1f")) h:\(view!.frame.size.height.format(".1f"))"
            if view is UILabel || view is UITextField || view is UITextView{
                if let text = view?.valueForKey("text") as? String{
                    cell?.detailTextLabel?.text = cell!.detailTextLabel!.text! + " text(\((text as NSString).length): \(text))"
                }
            }
            else if view is UIButton{
                let btn = view as! UIButton
                let title = btn.titleForState(UIControlState.Normal) == nil ? "": btn.titleForState(UIControlState.Normal)!
                cell?.detailTextLabel?.text = cell!.detailTextLabel!.text! + " text(\((title as NSString).length): \(title))"
            }
            cell?.detailTextLabel?.sizeToFit()
        }
        return cell!
    }
    
    func handleConstrainCell(index:NSIndexPath)->UITableViewCell{
        var cell = tbRight.dequeueReusableCellWithIdentifier("tbrightConstrain")
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "tbrightConstrain")
            cell?.backgroundColor = UIColor.clearColor()
        }
        let dict = arrConstrains![index.row]
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
        cell?.textLabel?.frame = CGRect(x: 0, y: 0, width: cell!.textLabel!.frame.size.width, height: 40)
        cell?.textLabel?.text = "\(dict["Type"]!)(Priority:\(dict["Priority"] == nil ? "" : dict["Priority"]!))"
        cell?.textLabel?.sizeToFit()
        cell?.detailTextLabel?.numberOfLines = 0
        cell?.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
        cell?.detailTextLabel?.frame = CGRect(x: 0, y: 0, width: cell!.detailTextLabel!.frame.size.width, height: 30)
        let arrTemp = (dict["Value"] as! NSString).componentsSeparatedByString(" ")
        var arr = [String]()
        for t in arrTemp{
            arr.append(t)
        }
        let text = (arr as NSArray).componentsJoinedByString(" ").stringByReplacingOccurrencesOfString(">", withString: "")
        cell?.detailTextLabel?.text = text
        cell?.detailTextLabel?.sizeToFit()
        return cell!
    }
    
    func handleTraceCell(index:NSIndexPath)->UITableViewCell{
        var cell = tbRight.dequeueReusableCellWithIdentifier("tbrightTrace")
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "tbrightTrace")
            cell?.backgroundColor = UIColor.clearColor()
        }
        let dict = arrTrace![index.row]
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
        cell?.textLabel?.frame = CGRect(x: 0, y: 0, width: cell!.textLabel!.frame.size.width, height: 40)
        cell?.textLabel?.text = "\(dict["Key"]!)(\(dict["Time"]!))"
        cell?.textLabel?.sizeToFit()
        cell?.detailTextLabel?.numberOfLines = 0
        cell?.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
        cell?.detailTextLabel?.frame = CGRect(x: 0, y: 0, width: cell!.detailTextLabel!.frame.size.width, height: 40)
        cell?.detailTextLabel?.text = "from \(dict["OldValue"]!) to \(dict["NewValue"]!)"
        if dict["Key"] as! String == "superview.frame"{
            cell?.detailTextLabel?.text = "\(dict["Superview"]!)" + cell!.detailTextLabel!.text!
        }
        cell?.detailTextLabel?.sizeToFit()
        return cell!
    }
    
    func  handleAboutCell(index:NSIndexPath)->UITableViewCell{
        var cell = tbRight.dequeueReusableCellWithIdentifier("tbrightAbout")
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "tbrightAbout")
            cell?.backgroundColor = UIColor.clearColor()
        }
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
        cell?.textLabel?.frame = CGRect(x: 0, y: 0, width: cell!.textLabel!.frame.size.width, height: 40)
        cell?.textLabel?.text = arrAbout![index.row]
        cell?.textLabel?.sizeToFit()
        return cell!
    }
    
    
    func heightForGeneralCell(index:NSIndexPath,width:CGFloat) -> CGFloat{
        if index.row == 0{
            let str = arrGeneral![0] as NSString
            let rect = str.boundingRectWithSize(CGSize(width: width, height: 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(17)], context: nil)
            return rect.size.height + 5
        }
        else{
            return 44
        }
    }
    
    func heightForSuperViewCell(index:NSIndexPath,width:CGFloat) -> CGFloat{
        let view = arrSuperView![index.row].obj as? UIView
        var str,strDetail:String
        if view == nil
        {
            str = "view has released"
            strDetail = ""
        }
        else{
            str = "\(view!.dynamicType)"
            strDetail = "l:\(view!.frame.origin.x.format(".1f"))t:\(view!.frame.origin.y.format(".1f"))w:\(view!.frame.size.width.format(".1f"))h:\(view!.frame.size.height.format(".1f"))"
            if view! is UILabel || view! is UITextField || view! is UITextView{
                let text = view!.valueForKey("text") as! String
                strDetail = "\(strDetail) text(\((text as NSString).length)):\(text)"
            }else if view! is UIButton{
                let btn = view as! UIButton
                if let title = btn.titleForState(UIControlState.Normal){
                    strDetail = "\(strDetail) text(\((title as NSString).length)):\(title)"
                }
                else{
                    strDetail = "\(strDetail) text(0):\" \""
                }
            }
        }
        let rect = (str as NSString).boundingRectWithSize(CGSize(width: width, height: 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(17)], context: nil)
        let rectDetail = (strDetail as NSString).boundingRectWithSize(CGSize(width: width, height: 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12)], context: nil)
        let height = rect.size.height + rectDetail.size.height + 10
        return height
    }
    
    func heightForSubViewCell(index:NSIndexPath,width:CGFloat) -> CGFloat{
        let view = arrSubview![index.row].obj as? UIView
        var str,strDetail:String
        if view == nil
        {
            str = "view has released"
            strDetail = ""
        }
        else{
            str = "\(view!.dynamicType)"
            strDetail = "l:\(view!.frame.origin.x.format(".1f"))t:\(view!.frame.origin.y.format(".1f"))w:\(view!.frame.size.width.format(".1f"))h:\(view!.frame.size.height.format(".1f"))"
            if view! is UILabel || view! is UITextField || view! is UITextView{
                let text = view!.valueForKey("text") as! String
                strDetail = "\(strDetail) text(\((text as NSString).length)):\(text)"
            }else if view! is UIButton{
                let btn = view as! UIButton
                if let title = btn.titleForState(UIControlState.Normal){
                    strDetail = "\(strDetail) text(\((title as NSString).length)):\(title)"
                }
                else{
                    strDetail = "\(strDetail) text(0):\" \""
                }
            }
        }
        let rect = (str as NSString).boundingRectWithSize(CGSize(width: width, height: 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(17)], context: nil)
        let rectDetail = (strDetail as NSString).boundingRectWithSize(CGSize(width: width, height: 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12)], context: nil)
        return rect.size.height + rectDetail.size.height + 10
    }
    
    
    func heightForConstrainCell(index:NSIndexPath,width:CGFloat) -> CGFloat{
        var str,strDetail:String
        let dic = arrConstrains![index.row]
        str  = "\(dic["Type"]!)(Priority:\(dic["Priority"] == nil ? "" : dic["Priority"]!))"
        let arrTemp = (dic["Value"] as! NSString).componentsSeparatedByString(" ")
        var arr = [String]()
        for t in arrTemp{
            arr.append(t)
        }
        strDetail = (arr as NSArray).componentsJoinedByString(" ").stringByReplacingOccurrencesOfString(">", withString: "")
        let rect = (str as NSString).boundingRectWithSize(CGSize(width: width, height: 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(17)], context: nil)
        let rectDetail = (strDetail as NSString).boundingRectWithSize(CGSize(width: width, height: 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12)], context: nil)
        return rect.size.height + rectDetail.size.height + 10
    }
    
    func heightForTraceCell(index:NSIndexPath,width:CGFloat)->CGFloat{
        var str,strDetail:String
        let dic = arrTrace![index.row]
        str  = "\(dic["Key"]!)(\(dic["Time"])!)"
        strDetail = "from \(dic["OldValue"]!) to \(dic["NewValue"]!)"
        if (dic["Key"] as! String) == "superview.frame"{
            strDetail = (dic["Superview"]! as! String) + strDetail
        }
        let rect = (str as NSString).boundingRectWithSize(CGSize(width: width, height: 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(17)], context: nil)
        let rectDetail = (strDetail as NSString).boundingRectWithSize(CGSize(width: width, height: 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12)], context: nil)
        return rect.size.height + rectDetail.size.height + 10
    }
    
    func heightForAboutCell(index:NSIndexPath,width:CGFloat)->CGFloat{
        let str = arrAbout![index.row]
        let rect = (str as NSString).boundingRectWithSize(CGSize(width: width, height: 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(17)], context: nil)
        return rect.size.height + 5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
