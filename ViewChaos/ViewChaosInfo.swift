//
//  ViewChaosInfo.swift
//  ViewChaosDemo
//
//  Created by Tyrant on 11/5/15.
//  Copyright © 2015 Qfq. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


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
        
        super.init(frame: CGRect(x: 10, y: 80, width: UIScreen.main.bounds.width-20, height: UIScreen.main.bounds.height-160))
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
        btnClose.setTitle("Close", for: UIControlState())
        btnClose.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btnClose.setTitleColor(UIColor.orange, for: UIControlState())
        btnClose.addTarget(self, action: #selector(ViewChaosInfo.close(_:)), for: UIControlEvents.touchUpInside)
        addSubview(btnClose)
        btnBack.frame = CGRect(x: self.frame.size.width - btnClose.frame.size.width - 45, y: 5, width: 45, height: 22)
        btnBack.setTitle("Back", for: UIControlState())
        btnBack.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btnBack.setTitleColor(UIColor.orange, for: UIControlState())
        btnBack.addTarget(self, action: #selector(ViewChaosInfo.back(_:)), for: UIControlEvents.touchUpInside)
        addSubview(btnBack)
        btnHit.frame = CGRect(x: btnBack.frame.origin.x - 45, y: 5, width: 45, height: 22)
        btnHit.setTitle("Hit", for: UIControlState())
        btnHit.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btnHit.setTitleColor(UIColor.orange, for: UIControlState())
        btnHit.addTarget(self, action: #selector(ViewChaosInfo.hit(_:)), for: UIControlEvents.touchUpInside)
        addSubview(btnHit)
        btnControl.frame = CGRect(x: btnHit.frame.origin.x - 45, y: 5, width: 45, height: 22)
        btnControl.setTitle("Control", for: UIControlState())
        btnControl.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btnControl.setTitleColor(UIColor.orange, for: UIControlState())
        btnControl.addTarget(self, action: #selector(ViewChaosInfo.control(_:)), for: UIControlEvents.touchUpInside)
        addSubview(btnControl)
        
        let lblCurrent = UILabel(frame: CGRect(x: 2, y: 5, width: 100, height: 22))
        lblCurrent.text = "Current View:"
        lblCurrent.textColor = UIColor.white
        lblCurrent.font = UIFont.systemFont(ofSize: 13)
        addSubview(lblCurrent)
        lblCurrentView.frame = CGRect(x: 2, y: lblCurrent.frame.maxY + 3, width: self.frame.size.width - 3, height: 20)
        lblCurrentView.textColor = UIColor.white
        lblCurrentView.font = UIFont.systemFont(ofSize: 13)
        addSubview(lblCurrentView)
        btnMinimize.frame = CGRect(x: self.frame.size.width-20, y: self.frame.size.height / 2 - 20, width: 20, height: 40)
        btnMinimize.backgroundColor = UIColor.black
        btnMinimize.setTitleColor(UIColor.white, for: UIControlState())
        btnMinimize.setTitle(">", for: UIControlState())
        btnMinimize.addTarget(self, action: #selector(ViewChaosInfo.minimize(_:)), for: UIControlEvents.touchUpInside)
        addSubview(btnMinimize)
    }
    
    override convenience init(frame: CGRect) {
        self.init()
    }
    
    
    
    override func willMove(toWindow newWindow: UIWindow?) {
        if let _ = newWindow{
            isTouch = false
            isTrace = false
            self.clipsToBounds = true
            self.translatesAutoresizingMaskIntoConstraints = true
            self.layer.borderWidth = 2
            self.layer.borderColor = UIColor.black.cgColor
            tbLeft.delegate = self
            tbLeft.dataSource = self
            tbRight.delegate = self
            tbRight.dataSource = self
            btnBack.isHidden = true
            arrLeft = ["General","SuperView","SubView","Constrains","Trace","About"]
            arrStackView = [ViewChaosObject]()
            arrGeneral = [String]()
            arrAbout = ["这是一个测试UI的工具",",这个工具是RunTrace的Swift版本.希望大家用得开心"]
            initView(viewHit!, back: false)
            NotificationCenter.default.addObserver(self, selector: #selector(ViewChaosInfo.handleRemoveView(_:)), name: NSNotification.Name(rawValue: handleTraceRemoveView), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(ViewChaosInfo.handleRemoveSubView(_:)), name: NSNotification.Name(rawValue: handleTraceRemoveSubView), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(ViewChaosInfo.handleAddSubView(_:)), name: NSNotification.Name(rawValue: handleTraceAddSubView), object: nil)
        }
        else{
            NotificationCenter.default.removeObserver(self)
            if isTrace! && viewHit != nil{
                stopTrace()
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: handleTraceShow), object: nil)
        }
    }
    
    
    func handleRemoveSubView(_ notif:Notification){
        var view = notif.object as! UIView
        if viewHit! == view{
            view = (notif as NSNotification).userInfo!["subview" as NSObject] as! UIView
            var dict:[String:AnyObject] = [String:AnyObject]()
            dict["key"] = "Add Subview" as AnyObject?
            dict["Time"] = Chaos.currentDate(nil) as AnyObject?
            dict["OldValue"] = "\(type(of: view))l:\(view.frame.origin.x.format(".1f"))t:\(view.frame.origin.y.format(".1f"))w:\(view.frame.size.width.format(".1f"))h:\(view.frame.size.height.format(".1f"))" as AnyObject?
            dict["NewValue"] = "nil" as AnyObject?
            arrTrace?.append(dict)
            if type == .trace{
                tbRight.reloadData()
                tbRight.tableFooterView = UIView()
            }
        }
    }
    
    
    func handleAddSubView(_ notif:Notification)
    {
        var view = notif.object as! UIView
        if viewHit! == view{
            view = (notif as NSNotification).userInfo!["subview" as NSObject] as! UIView
            var dict:[String:AnyObject] = [String:AnyObject]()
            dict["key"] = "Add Subview" as AnyObject?
            dict["Time"] = Chaos.currentDate(nil) as AnyObject?
            dict["OldValue"] = "nil" as AnyObject?
            dict["NewValue"] = "\(type(of: view))l:\(view.frame.origin.x.format(".1f"))t:\(view.frame.origin.y.format(".1f"))w:\(view.frame.size.width.format(".1f"))h:\(view.frame.size.height.format(".1f"))" as AnyObject?
            arrTrace?.append(dict)
            if type == .trace{
                tbRight.reloadData()
                tbRight.tableFooterView = UIView()
            }
        }
        
    }
    
    
    func handleRemoveView(_ notif:Notification){
        let view = notif.object as! UIView
        if viewHit! == view{
            stopTrace()
            viewHit?.layer.borderColor = viewTrackBorderColor?.cgColor
            viewHit?.layer.borderWidth = viewTrackBorderWith!
            var dict:[String:AnyObject] = [String:AnyObject]()
            dict["key"] = "RemoveFromSuperview" as AnyObject?
            dict["Time"] = Chaos.currentDate(nil) as AnyObject?
            dict["OldValue"] = "\(type(of: view))l:\(view.frame.origin.x.format(".1f"))t:\(view.frame.origin.y.format(".1f"))w:\(view.frame.size.width.format(".1f"))h:\(view.frame.size.height.format(".1f"))" as AnyObject?
            dict["NewValue"] = "nil" as AnyObject?
            arrTrace?.append(dict)
            if type == .trace{
                tbRight.reloadData()
                tbRight.tableFooterView = UIView()
                if let btn = tbRight.tableHeaderView as? UIButton{
                    btn.setTitle("Start", for: UIControlState())
                }
            }
            arrSubview?.removeAll()
            arrSuperView?.removeAll()
            arrConstrains?.removeAll()
            let alert = UIAlertView(title: "ViewChecl", message: "\(type(of: view))RemoveFromSuperview", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            lblCurrentView.text = lblCurrentView.text! + "has removed"
        }
    }
    
    
    
    func initView(_ view:UIView,back:Bool){
        stopTrace()
        viewHit = view
        if let name = viewHit?.chaosName{
            lblCurrentView.text = "\(type(of: viewHit!)) name:\(name) (\(viewHit!.description))"
        }
        else{
            lblCurrentView.text = "\(type(of: viewHit!))(\(viewHit!.description))"
        }
        
        if !back {
            arrStackView?.append(ViewChaosObject.objectWithWeak(view) as! ViewChaosObject)
            if arrStackView?.count >= 2{
                btnBack.isHidden = false
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
        arrGeneral?.append( "Class Name:\(type(of: viewHit!))")
        arrGeneral?.append("AutoLayout:\(viewHit!.translatesAutoresizingMaskIntoConstraints ? "NO" : "YES")")
        arrGeneral?.append("Left:\(viewHit!.frame.origin.x.format(".2f"))")
        arrGeneral?.append("Top:\(viewHit!.frame.origin.y.format(".2f"))")
        arrGeneral?.append("Width:\(viewHit!.frame.size.width.format(".2f"))")
        arrGeneral?.append("Height:\(viewHit!.frame.size.height.format(".2f"))")
        analysisAutolayout()
        tbRight.reloadData()
        tbRight.tableFooterView = UIView()
    }
    
    func onTrace(_ sender:UIButton)
    {
        if sender.title(for: UIControlState()) == "Start"{
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
        btn.setTitle("Stop", for: UIControlState())
        arrTrace?.removeAll()
        tbRight.reloadData()
        tbRight.tableFooterView = UIView()
        viewHit?.addObserver(self, forKeyPath: "frame", options: [NSKeyValueObservingOptions.old,NSKeyValueObservingOptions.new], context: nil)
        viewHit?.addObserver(self, forKeyPath: "center", options: [NSKeyValueObservingOptions.old,NSKeyValueObservingOptions.new], context: nil)
        viewHit?.addObserver(self, forKeyPath: "superview.frame", options: [NSKeyValueObservingOptions.old,NSKeyValueObservingOptions.new], context: nil)
        viewHit?.addObserver(self, forKeyPath: "tag", options: [NSKeyValueObservingOptions.old,NSKeyValueObservingOptions.new], context: nil)
        viewHit?.addObserver(self, forKeyPath: "userInteractionEnabled", options: [NSKeyValueObservingOptions.old,NSKeyValueObservingOptions.new], context: nil)
        viewHit?.addObserver(self, forKeyPath: "hidden", options: [NSKeyValueObservingOptions.old,NSKeyValueObservingOptions.new], context: nil)
        viewHit?.addObserver(self, forKeyPath: "bounds", options: [NSKeyValueObservingOptions.old,NSKeyValueObservingOptions.new], context: nil)
        if viewHit! is UIScrollView{
            viewHit?.addObserver(self, forKeyPath: "contentSize", options: [NSKeyValueObservingOptions.old,NSKeyValueObservingOptions.new], context: nil)
            viewHit?.addObserver(self, forKeyPath: "contentOffset", options: [NSKeyValueObservingOptions.old,NSKeyValueObservingOptions.new], context: nil)
            viewHit?.addObserver(self, forKeyPath: "contentInset", options: [NSKeyValueObservingOptions.old,NSKeyValueObservingOptions.new], context: nil)
        }
        traceSuperAndSubView()
        Chaos.toast("Start Trace")
    }
    
    func stopTrace(){
        if !isTrace!{
            return
        }
        isTrace = false
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
        viewHit?.layer.borderColor = viewTrackBorderColor?.cgColor
        viewHit?.layer.borderWidth = viewTrackBorderWith!
        if tbRight.tableHeaderView == nil {
            return;
        }
        let btn = tbRight.tableHeaderView! as! UIButton
        btn.setTitle("Start", for: UIControlState())
    }
    
    func close(_ sender:UIButton){
        if btnClose.title(for: UIControlState()) == "Close"{
            self.removeFromSuperview()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "handleTraceViewClose"), object: nil)
        }
        else if btnClose.title(for: UIControlState()) == "Stop"{
            stopTrace()
            if isTrace! &&  viewHit != nil{
                viewHit?.layer.borderColor = viewTrackBorderColor?.cgColor
                viewHit?.layer.borderWidth = viewTrackBorderWith!
                isTrace = false
            }
        }
    }
    
    func back(_ sender:UIButton){
        arrStackView?.removeLast()
        let view = arrStackView!.last!.obj as! UIView
        if arrStackView?.count == 1{
            btnBack.isHidden = true
        }
        initView(view, back: true)
    }
    
    func hit(_ sender:UIButton){
        if viewHit == nil{
            let alert = UIAlertView(title: "ViewChaos", message: "View has removed and can't hit!", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "handleTraceView"), object: viewHit!)
        minimize()
    }
    
    func control(_ sender:UIButton){
        if viewHit == nil{
            let alert = UIAlertView(title: "ViewChaos", message: "View has removed and can't control!", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: controlTraceView), object: viewHit!)
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
        while viewConstraint != nil && !(viewConstraint!.isKind(of: NSClassFromString("UIViewControllerWrapperView")!))
        {
            for con in viewConstraint!.constraints{
                var constant = con.constant
                let viewFirst = con.firstItem as! UIView
                let viewSecond = con.secondItem as? UIView
                if con.secondItem != nil{
                    if con.firstItem as! UIView == viewHit! && con.firstAttribute == con.secondAttribute{
                        if viewFirst.isDescendant(of: viewSecond!){
                            constant = con.constant
                        }
                        else if viewSecond!.isDescendant(of: viewFirst){
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
                        if viewFirst.isDescendant(of: viewSecond!){
                            constant = -con.constant
                        }
                        else if viewSecond!.isDescendant(of: viewFirst)
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
                if con.firstItem as! UIView == viewHit! && (con.firstAttribute == NSLayoutAttribute.leading || con.firstAttribute == NSLayoutAttribute.left || con.firstAttribute == NSLayoutAttribute.leadingMargin || con.firstAttribute == NSLayoutAttribute.leftMargin){
                    var dict = [String:AnyObject]()
                    dict["Type"] = "Left" as AnyObject?
                    dict["Value"] = con.description as AnyObject?
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.secondItem!)
                    dict["Constant"] = con.constant as AnyObject?
                    dict["Multiplier"] = con.multiplier as AnyObject?
                    dict["Priority"] = con.priority as AnyObject?
                    arrConstrains?.append(dict)
                }
                else if  con.secondItem as? UIView == viewHit! && (con.secondAttribute == NSLayoutAttribute.leading || con.secondAttribute == NSLayoutAttribute.left || con.secondAttribute == NSLayoutAttribute.leadingMargin || con.secondAttribute == NSLayoutAttribute.leftMargin){
                    var dict = [String:AnyObject]()
                    dict["Type"] = "Left" as AnyObject?
                    dict["Value"] = con.description as AnyObject?
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.firstItem)
                    dict["Constant"] = constant as AnyObject?
                    dict["Multiplier"] = con.multiplier as AnyObject?
                    dict["Priority"] = con.priority as AnyObject?
                    arrConstrains?.append(dict)
                }
                else if con.firstItem as! UIView == viewHit! && (con.firstAttribute == NSLayoutAttribute.top || con.firstAttribute == NSLayoutAttribute.topMargin) {
                    var dict = [String:AnyObject]()
                    dict["Type"] = "Top" as AnyObject?
                    dict["Value"] = con.description as AnyObject?
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.secondItem!)
                    dict["Constant"] = constant as AnyObject?
                    dict["Multiplier"] = con.multiplier as AnyObject?
                    dict["Priority"] = con.priority as AnyObject?
                    arrConstrains?.append(dict)
                }
                else if con.secondItem as? UIView == viewHit! && (con.secondAttribute == NSLayoutAttribute.top || con.secondAttribute == NSLayoutAttribute.topMargin) {
                    var dict = [String:AnyObject]()
                    dict["Type"] = "Top" as AnyObject?
                    dict["Value"] = con.description as AnyObject?
                    Chaos.Log(con.description)
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.firstItem)
                    dict["Constant"] = constant as AnyObject?
                    dict["Multiplier"] = con.multiplier as AnyObject?
                    dict["Priority"] = con.priority as AnyObject?
                    arrConstrains?.append(dict)
                }
                else if con.firstItem as! UIView == viewHit! && (con.firstAttribute == NSLayoutAttribute.trailing || con.firstAttribute == NSLayoutAttribute.trailingMargin || con.firstAttribute == NSLayoutAttribute.right || con.firstAttribute == NSLayoutAttribute.rightMargin){
                    var dict = [String:AnyObject]()
                    dict["Type"] = "Right" as AnyObject?
                    dict["Value"] = con.description as AnyObject?
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.secondItem!)
                    dict["Constant"] = constant as AnyObject?
                    dict["Multiplier"] = con.multiplier as AnyObject?
                    dict["Priority"] = con.priority as AnyObject?
                    arrConstrains?.append(dict)
                }
                else if con.secondItem as? UIView == viewHit! && (con.secondAttribute == NSLayoutAttribute.trailing || con.secondAttribute == NSLayoutAttribute.trailingMargin || con.secondAttribute == NSLayoutAttribute.right || con.secondAttribute == NSLayoutAttribute.rightMargin){
                    var dict = [String:AnyObject]()
                    dict["Type"] = "Right" as AnyObject?
                    dict["Value"] = con.description as AnyObject?
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.firstItem)
                    dict["Constant"] = constant as AnyObject?
                    dict["Multiplier"] = con.multiplier as AnyObject?
                    dict["Priority"] = con.priority as AnyObject?
                    arrConstrains?.append(dict)
                }
                else if con.firstItem as! UIView == viewHit! && (con.firstAttribute == NSLayoutAttribute.bottom || con.firstAttribute == NSLayoutAttribute.bottomMargin) {
                    var dict = [String:AnyObject]()
                    dict["Type"] = "Bottom" as AnyObject?
                    dict["Value"] = con.description as AnyObject?
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.secondItem!)
                    dict["Constant"] = constant as AnyObject?
                    dict["Multiplier"] = con.multiplier as AnyObject?
                    dict["Priority"] = con.priority as AnyObject?
                    arrConstrains?.append(dict)
                }
                else if con.secondItem as? UIView == viewHit! && (con.secondAttribute == NSLayoutAttribute.bottom || con.secondAttribute == NSLayoutAttribute.bottomMargin) {
                    var dict = [String:AnyObject]()
                    dict["Type"] = "Bottom" as AnyObject?
                    dict["Value"] = con.description as AnyObject?
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.firstItem)
                    dict["Constant"] = constant as AnyObject?
                    dict["Multiplier"] = con.multiplier as AnyObject?
                    dict["Priority"] = con.priority as AnyObject?
                    arrConstrains?.append(dict)
                }
                else if (con.firstItem as! UIView == viewHit! && con.firstAttribute == NSLayoutAttribute.width) || (con.secondItem as? UIView == viewHit && con.secondAttribute == NSLayoutAttribute.width){
                    if con.isKind(of: NSClassFromString("NSContentSizeLayoutConstraint")!){
                        var dict = [String:AnyObject]()
                        dict["Type"] = "IntrinsicContent Width" as AnyObject?
                        dict["Value"] = con.description as AnyObject?
                        dict["Constant"] = constant as AnyObject?
                        arrConstrains?.append(dict)
                    }
                    else{
                        var dict = [String:AnyObject]()
                        dict["Type"] = "Width" as AnyObject?
                        dict["Value"] = con.description as AnyObject?
                        dict["ToView"] = ViewChaosObject.objectWithWeak(con.firstItem)
                        dict["Constant"] = constant as AnyObject?
                        dict["Multiplier"] = con.multiplier as AnyObject?
                        dict["Priority"] = con.priority as AnyObject?
                        arrConstrains?.append(dict)
                    }
                }
                else if (con.firstItem as! UIView == viewHit! && con.firstAttribute == NSLayoutAttribute.height) || (con.secondItem as? UIView == viewHit && con.secondAttribute == NSLayoutAttribute.height){
                    if con.isKind(of: NSClassFromString("NSContentSizeLayoutConstraint")!){
                        var dict = [String:AnyObject]()
                        dict["Type"] = "IntrinsicContent Height" as AnyObject?
                        dict["Value"] = con.description as AnyObject?
                        dict["Constant"] = con.constant as AnyObject?
                        arrConstrains?.append(dict)
                    }
                    else{
                        var dict = [String:AnyObject]()
                        dict["Type"] = "Height" as AnyObject?
                        dict["Value"] = con.description as AnyObject?
                        dict["ToView"] = ViewChaosObject.objectWithWeak(con.firstItem)
                        dict["Constant"] = constant as AnyObject?
                        dict["Multiplier"] = con.multiplier as AnyObject?
                        dict["Priority"] = con.priority as AnyObject?
                        arrConstrains?.append(dict)
                    }
                }
                else if con.firstItem as! UIView == viewHit! && con.firstAttribute == NSLayoutAttribute.centerX{
                    var dict = [String:AnyObject]()
                    dict["Type"] = "CenterX" as AnyObject?
                    dict["Value"] = con.description as AnyObject?
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.secondItem!)
                    dict["Constant"] = constant as AnyObject?
                    dict["Multiplier"] = con.multiplier as AnyObject?
                    dict["Priority"] = con.priority as AnyObject?
                    arrConstrains?.append(dict)
                }
                else if con.secondItem as? UIView == viewHit! && con.firstAttribute == NSLayoutAttribute.centerX{
                    var dict = [String:AnyObject]()
                    dict["Type"] = "CenterX" as AnyObject?
                    dict["Value"] = con.description as AnyObject?
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.firstItem)
                    dict["Constant"] = constant as AnyObject?
                    dict["Multiplier"] = con.multiplier as AnyObject?
                    dict["Priority"] = con.priority as AnyObject?
                    arrConstrains?.append(dict)
                }
                else if con.firstItem as! UIView == viewHit! && con.firstAttribute == NSLayoutAttribute.centerY{
                    var dict = [String:AnyObject]()
                    dict["Type"] = "CenterY" as AnyObject?
                    dict["Value"] = con.description as AnyObject?
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.secondItem!)
                    dict["Constant"] = constant as AnyObject?
                    dict["Multiplier"] = con.multiplier as AnyObject?
                    dict["Priority"] = con.priority as AnyObject?
                    arrConstrains?.append(dict)
                }
                else if con.secondItem as? UIView == viewHit! && con.firstAttribute == NSLayoutAttribute.centerY{
                    var dict = [String:AnyObject]()
                    dict["Type"] = "CenterY" as AnyObject?
                    dict["Value"] = con.description as AnyObject?
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.firstItem)
                    dict["Constant"] = constant as AnyObject?
                    dict["Multiplier"] = con.multiplier as AnyObject?
                    dict["Priority"] = con.priority as AnyObject?
                    arrConstrains?.append(dict)
                }
                else if con.firstItem as! UIView == viewHit! && con.firstAttribute == NSLayoutAttribute.lastBaseline{
                    var dict = [String:AnyObject]()
                    dict["Type"] = "BaseLine" as AnyObject?
                    dict["Value"] = con.description as AnyObject?
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.secondItem!)
                    dict["Constant"] = constant as AnyObject?
                    dict["Multiplier"] = con.multiplier as AnyObject?
                    dict["Priority"] = con.priority as AnyObject?
                    arrConstrains?.append(dict)
                }
                else if con.secondItem as? UIView == viewHit! && con.firstAttribute == NSLayoutAttribute.lastBaseline{
                    var dict = [String:AnyObject]()
                    dict["Type"] = "BaseLine" as AnyObject?
                    dict["Value"] = con.description as AnyObject?
                    dict["ToView"] = ViewChaosObject.objectWithWeak(con.firstItem)
                    dict["Constant"] = constant as AnyObject?
                    dict["Multiplier"] = con.multiplier as AnyObject?
                    dict["Priority"] = con.priority as AnyObject?
                    arrConstrains?.append(dict)
                }
                    
                    
            }
            viewConstraint = viewConstraint?.superview
        }
    }
    
    
    func minimize(){
        originFrame = self.frame
        let fm = CGRect(x: UIScreen.main.bounds.width - 20, y: UIScreen.main.bounds.height / 2 - 20, width: 20, height: 40)
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.frame = fm
            }, completion: { (finished) -> Void in
                let btn = UIButton(frame: self.bounds)
                btn.setTitle("<", for: UIControlState())
                btn.backgroundColor = UIColor.black
                btn.setTitleColor(UIColor.white, for: UIControlState())
                btn.addTarget(self, action: #selector(ViewChaosInfo.expand(_:)), for: UIControlEvents.touchUpInside)
                self.addSubview(btn)
        }) 
    }
    
    func expand(_ sender:UIButton){
        sender.removeFromSuperview()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "handleTraceViewClose"), object: nil)
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.frame = self.originFrame!
        }) 
    }
    
    func minimize(_ sender:UIButton){
        minimize()
    }
    
    
    func traceSuperAndSubView(){
        if viewHit == nil{
            let alert = UIAlertView(title: "ViewChecK", message: "View has removed and can't trace!", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        viewTrackBorderWith = viewHit!.layer.borderWidth
        viewTrackBorderColor = UIColor(cgColor: viewHit!.layer.borderColor!)
        viewHit?.layer.borderWidth = 3
        viewHit?.layer.borderColor = UIColor.black.cgColor
        minimize()
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame"{
            let oldFrame = (change![NSKeyValueChangeKey.oldKey]! as AnyObject).cgRectValue
            let newFrame = (change![NSKeyValueChangeKey.newKey]! as AnyObject).cgRectValue
            if (oldFrame?.equalTo(newFrame!))!
            {
                return
            }
            var dict = [String:AnyObject]()
            dict["Key"] = "Frame Change" as AnyObject?
            dict["Time"] = Chaos.currentDate(nil) as AnyObject?
            dict["OldValue"] = "l:\(oldFrame?.origin.x.format(".1f")) t:\(oldFrame?.origin.y.format(".1f")) w:\(oldFrame?.origin.x.format(".1f")) :h\(oldFrame?.origin.x.format(".1f"))" as AnyObject?
            dict["NewValue"] = "l:\(newFrame?.origin.x.format(".1f")) t:\(newFrame?.origin.y.format(".1f")) w:\(newFrame?.origin.x.format(".1f")) h:\(newFrame?.origin.x.format(".1f"))" as AnyObject?
            arrTrace?.append(dict)
        }
        else if keyPath == " center"{
            let oldCenter = (change![NSKeyValueChangeKey.oldKey]! as AnyObject).cgPointValue
            let newCenter = (change![NSKeyValueChangeKey.newKey]! as AnyObject).cgPointValue
            if (oldCenter?.equalTo(newCenter!))!
            {
                return
            }
            var dict = [String:AnyObject]()
            dict["Key"] = "Center Change" as AnyObject?
            dict["Time"] = Chaos.currentDate(nil) as AnyObject?
            dict["OldValue"] = "l:\(oldCenter?.x.format(".1f")) t:\(oldCenter?.y.format(".1f"))" as AnyObject?
            dict["NewValue"] = "l:\(newCenter?.x.format(".1f")) t:\(newCenter?.y.format(".1f"))" as AnyObject?
            arrTrace?.append(dict)
        }
        else if keyPath == "superview.frame"{
            let oldFrame = (change![NSKeyValueChangeKey.oldKey]! as AnyObject).cgRectValue
            let newFrame = (change![NSKeyValueChangeKey.newKey]! as AnyObject).cgRectValue
            if (oldFrame?.equalTo(newFrame!))!
            {
                return
            }
            var dict = [String:AnyObject]()
            dict["Key"] = "Superview Frame Change" as AnyObject?
            dict["Time"] = Chaos.currentDate(nil) as AnyObject?
            dict["OldValue"] = "l:\(oldFrame?.origin.x.format(".1f")) t:\(oldFrame?.origin.y.format(".1f")) w:\(oldFrame?.origin.x.format(".1f")) :h\(oldFrame?.origin.x.format(".1f"))" as AnyObject?
            dict["NewValue"] = "l:\(newFrame?.origin.x.format(".1f")) t:\(newFrame?.origin.y.format(".1f")) w:\(newFrame?.origin.x.format(".1f")) h:\(newFrame?.origin.x.format(".1f"))" as AnyObject?
            dict["SuperView"] = "\(type(of: (object! as! UIView).superview))" as AnyObject?
            arrTrace?.append(dict)
        }
        else if keyPath == "tag"{
            let oldValue = (change![NSKeyValueChangeKey.oldKey]! as AnyObject)
            let newValue = (change![NSKeyValueChangeKey.newKey]! as AnyObject)
            var dict = [String:AnyObject]()
            dict["Key"] = "Tag Change" as AnyObject?
            dict["Time"] = Chaos.currentDate(nil) as AnyObject?
            dict["OldValue"] = oldValue
            dict["NewValue"] = newValue
            arrTrace?.append(dict)
        }
        else if keyPath == "userInteractionEnabled"{
            let oldValue = (change![NSKeyValueChangeKey.oldKey]! as AnyObject).boolValue
            let newValue = (change![NSKeyValueChangeKey.newKey]! as AnyObject).boolValue
            var dict = [String:AnyObject]()
            dict["Key"] = "UserInteractionEnabled Change" as AnyObject?
            dict["Time"] = Chaos.currentDate(nil) as AnyObject?
            dict["OldValue"] = (oldValue! ? "Yes" : "No") as AnyObject
            dict["NewValue"] = (newValue! ? "Yes" : "No") as AnyObject
            arrTrace?.append(dict)
        }
        else if keyPath == "hidden"{
            let oldValue = (change![NSKeyValueChangeKey.oldKey]! as AnyObject).boolValue
            let newValue = (change![NSKeyValueChangeKey.newKey]! as AnyObject).boolValue
            var dict = [String:AnyObject]()
            dict["Key"] = "Hidden Change" as AnyObject?
            dict["Time"] = Chaos.currentDate(nil) as AnyObject?
            dict["OldValue"] = (oldValue! ? "Yes" : "No") as AnyObject
            dict["NewValue"] = (newValue! ? "Yes" : "No") as AnyObject
            arrTrace?.append(dict)
        }
        else if keyPath == "bounds"{
            let oldFrame = (change![NSKeyValueChangeKey.oldKey]! as AnyObject).cgRectValue
            let newFrame = (change![NSKeyValueChangeKey.newKey]! as AnyObject).cgRectValue
            if (oldFrame?.equalTo(newFrame!))!
            {
                return
            }
            var dict = [String:AnyObject]()
            dict["Key"] = "Bounds Change" as AnyObject?
            dict["Time"] = Chaos.currentDate(nil) as AnyObject?
            dict["OldValue"] = "l:\(oldFrame?.origin.x.format(".1f")) t:\(oldFrame?.origin.y.format(".1f")) w:\(oldFrame?.origin.x.format(".1f")) :h\(oldFrame?.origin.x.format(".1f"))" as AnyObject?
            dict["NewValue"] = "l:\(newFrame?.origin.x.format(".1f")) t:\(newFrame?.origin.y.format(".1f")) w:\(newFrame?.origin.x.format(".1f")) h:\(newFrame?.origin.x.format(".1f"))" as AnyObject?
            arrTrace?.append(dict)
        }
        else if keyPath == "contentSize"{
            let oldSize = (change![NSKeyValueChangeKey.oldKey]! as AnyObject).cgSizeValue
            let newSize = (change![NSKeyValueChangeKey.newKey]! as AnyObject).cgSizeValue
            if (oldSize?.equalTo(newSize!))!
            {
                return
            }
            var dict = [String:AnyObject]()
            dict["Key"] = "ContentSize Change" as AnyObject?
            dict["Time"] = Chaos.currentDate(nil) as AnyObject?
            dict["OldValue"] = "w:\(oldSize?.width.format(".1f")) h:\(oldSize?.height.format(".1f"))" as AnyObject?
            dict["NewValue"] = "w:\(newSize?.width.format(".1f")) h:\(newSize?.height.format(".1f"))" as AnyObject?
            arrTrace?.append(dict)
        }
        else if keyPath == "contentOffset"{
            let oldOffset = (change![NSKeyValueChangeKey.oldKey]! as AnyObject).cgPointValue
            let newOffset = (change![NSKeyValueChangeKey.newKey]! as AnyObject).cgPointValue
            if (oldOffset?.equalTo(newOffset!))!
            {
                return
            }
            var dict = [String:AnyObject]()
            dict["Key"] = "ContentOffset Change" as AnyObject?
            dict["Time"] = Chaos.currentDate(nil) as AnyObject?
            dict["OldValue"] = "l:\(oldOffset?.x.format(".1f")) t:\(oldOffset?.y.format(".1f"))" as AnyObject?
            dict["NewValue"] = "l:\(newOffset?.x.format(".1f")) t:\(newOffset?.y.format(".1f"))" as AnyObject?
            arrTrace?.append(dict)
        }
        else if keyPath == "contentInset"{
            let oldEdge = (change![NSKeyValueChangeKey.oldKey]! as AnyObject).uiEdgeInsetsValue
            let newEdge = (change![NSKeyValueChangeKey.newKey]! as AnyObject).uiEdgeInsetsValue
            if UIEdgeInsetsEqualToEdgeInsets(oldEdge!, newEdge!){
                return
            }
            var dict = [String:AnyObject]()
            dict["Key"] = "ContentInset Change" as AnyObject?
            dict["Time"] = Chaos.currentDate(nil) as AnyObject?
            dict["OldValue"] = "l:\(oldEdge?.left.format(".1f")) t:\(oldEdge?.top.format(".1f")) r:\(oldEdge?.right.format(".1f")) b:\(oldEdge?.bottom.format(".1f"))" as AnyObject?
            dict["NewValue"] = "l:\(newEdge?.left.format(".1f")) t:\(newEdge?.top.format(".1f")) r:\(newEdge?.right.format(".1f")) :b\(newEdge?.bottom.format(".1f"))" as AnyObject?
            arrTrace?.append(dict)
        }
        tbRight .reloadData()
        tbRight.tableFooterView = UIView()
    }
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouch = true
        if  let touch = touches.first{
            let p = touch.location(in: self)
            left = p.x
            top = p.y
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isTouch{
            return
        }
        if let touch = touches.first
        {
            let p = touch.location(in: self.window)
            self.frame = CGRect(x: p.x - left, y: p.y - top, width: self.frame.size.width, height: self.frame.size.height)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouch = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        isTouch = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        if tableView == tbLeft{
            cell = tableView.dequeueReusableCell(withIdentifier: "cellLeft")
            if cell == nil{
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cellLeft")
                cell?.backgroundColor = UIColor.clear
            }
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell?.textLabel?.text = arrLeft![(indexPath as NSIndexPath).row]
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tbLeft{
            type = tbType.init(rawValue: (indexPath as NSIndexPath).row)!
            tbRight.reloadData()
            if type == .trace{
                let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
                btn.setTitle(isTrace! ? "Stop" : "Start", for: UIControlState())
                btn.setTitleColor(UIColor.orange, for: UIControlState())
                btn.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.74, alpha: 1.0)
                btn.addTarget(self, action: #selector(ViewChaosInfo.onTrace(_:)), for: UIControlEvents.touchUpInside)
                tbRight.tableHeaderView = btn
            }
            else
            {
                tbRight.tableHeaderView = nil
            }
        }
        else{
            switch type{
            case .superview: let view = arrSuperView![(indexPath as NSIndexPath).row].obj as? UIView
                if view != nil{
                    NotificationCenter.default.post(name: Notification.Name(rawValue: handleTraceView), object: view!) //不需要点一下就跳进去看那个View, 所以这里不要缩小
                    initView(view!, back: false)
                }
            case .subview: let view = arrSubview![(indexPath as NSIndexPath).row].obj as? UIView
                if view != nil{
                    NotificationCenter.default.post(name: Notification.Name(rawValue: handleTraceView), object: view!) //不需要点一下就跳进去看那个View, 所以这里不要缩小
                    initView(view!, back: false)
                }
            case .constrain: let strType = arrConstrains![(indexPath as NSIndexPath).row]["Type"] as! String
                if strType == "IntrinsicContent Width" || strType == "IntrinsicContent Height" || strType == "BaseLine" {
                    return
                }
                if viewHit == nil{
                    return;
                }
                var dict = arrConstrains![(indexPath as NSIndexPath).row]
                dict["View"] = ViewChaosObject.objectWithWeak(viewHit!)
                NotificationCenter.default.post(name: Notification.Name(rawValue: handleTraceContraints), object: dict)
                 minimize()  //只有这里可以缩小一下
            default: return
            }
           
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    func handleGeneralCell(_ index:IndexPath)->UITableViewCell{
        var cell = tbRight.dequeueReusableCell(withIdentifier: "tbrightGeneral")
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "tbrightGeneral")
            cell?.backgroundColor = UIColor.clear
        }
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.lineBreakMode = NSLineBreakMode.byCharWrapping
        cell?.textLabel?.frame = CGRect(x: 0, y: 0, width: cell!.textLabel!.frame.size.width, height: 40)
        cell?.textLabel?.text = arrGeneral![(index as NSIndexPath).row]
        cell?.textLabel?.sizeToFit()
        return cell!
    }
    
    func handleSuperViewCell(_ index:IndexPath)->UITableViewCell{
        var cell = tbRight.dequeueReusableCell(withIdentifier: "tbrightSuperView")
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "tbrightSuperView")
            cell?.backgroundColor = UIColor.clear
        }
        let view = (arrSuperView![(index as NSIndexPath).row]).obj as? UIView
        if view == nil{
            cell?.textLabel?.text = "view has released"
            cell?.detailTextLabel?.text = ""
        }
        else{
            cell?.textLabel?.numberOfLines = 0
            cell?.textLabel?.lineBreakMode = NSLineBreakMode.byCharWrapping
            cell?.textLabel?.frame = CGRect(x: 0, y: 0, width: cell!.textLabel!.frame.size.width, height: 40)
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell?.textLabel?.text = "\(type(of: view!))"
            cell?.textLabel?.sizeToFit()
            cell?.detailTextLabel?.numberOfLines = 0
            cell?.detailTextLabel?.lineBreakMode = NSLineBreakMode.byCharWrapping
            cell?.detailTextLabel?.frame = CGRect(x: 0, y: 0, width: cell!.detailTextLabel!.frame.size.width, height: 40)
            cell?.detailTextLabel?.text = "l:\(view!.frame.origin.x.format(".1f")) t:\(view!.frame.origin.y.format(".1f")) w:\(view!.frame.size.width.format(".1f")) h:\(view!.frame.size.height.format(".1f"))"
            if view is UILabel || view is UITextField || view is UITextView{
                if let text = view?.value(forKey: "text") as? String{
                    cell?.detailTextLabel?.text = cell!.detailTextLabel!.text! + " text(\((text as NSString).length): \(text))"
                }
            }
            else if view is UIButton{
                let btn = view as! UIButton
                let title = btn.title(for: UIControlState()) == nil ? "": btn.title(for: UIControlState())!
                cell?.detailTextLabel?.text = cell!.detailTextLabel!.text! + " text(\((title as NSString).length): \(title))"
            }
            cell?.detailTextLabel?.sizeToFit()
        }
        return cell!
        
    }
    
    func handleSubViewCell(_ index:IndexPath)->UITableViewCell{
        var cell = tbRight.dequeueReusableCell(withIdentifier: "tbrightSubView")
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "tbrightSubView")
            cell?.backgroundColor = UIColor.clear
        }
        let view = (arrSubview![(index as NSIndexPath).row]).obj as? UIView
        if view == nil{
            cell?.textLabel?.text = "view has released"
            cell?.detailTextLabel?.text = ""
        }
        else{
            cell?.textLabel?.numberOfLines = 0
            cell?.textLabel?.lineBreakMode = NSLineBreakMode.byCharWrapping
            cell?.textLabel?.frame = CGRect(x: 0, y: 0, width: cell!.textLabel!.frame.size.width, height: 40)
            cell?.textLabel?.text = "\(type(of: view!))"
            cell?.textLabel?.sizeToFit()
            cell?.detailTextLabel?.numberOfLines = 0
            cell?.detailTextLabel?.lineBreakMode = NSLineBreakMode.byCharWrapping
            cell?.detailTextLabel?.frame = CGRect(x: 0, y: 0, width: cell!.detailTextLabel!.frame.size.width, height: 40)
            cell?.detailTextLabel?.text = "l:\(view!.frame.origin.x.format(".1f")) t:\(view!.frame.origin.y.format(".1f")) w:\(view!.frame.size.width.format(".1f")) h:\(view!.frame.size.height.format(".1f"))"
            if view is UILabel || view is UITextField || view is UITextView{
                if let text = view?.value(forKey: "text") as? String{
                    cell?.detailTextLabel?.text = cell!.detailTextLabel!.text! + " text(\((text as NSString).length): \(text))"
                }
            }
            else if view is UIButton{
                let btn = view as! UIButton
                let title = btn.title(for: UIControlState()) == nil ? "": btn.title(for: UIControlState())!
                cell?.detailTextLabel?.text = cell!.detailTextLabel!.text! + " text(\((title as NSString).length): \(title))"
            }
            cell?.detailTextLabel?.sizeToFit()
        }
        return cell!
    }
    
    func handleConstrainCell(_ index:IndexPath)->UITableViewCell{
        var cell = tbRight.dequeueReusableCell(withIdentifier: "tbrightConstrain")
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "tbrightConstrain")
            cell?.backgroundColor = UIColor.clear
        }
        let dict = arrConstrains![(index as NSIndexPath).row]
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.lineBreakMode = NSLineBreakMode.byCharWrapping
        cell?.textLabel?.frame = CGRect(x: 0, y: 0, width: cell!.textLabel!.frame.size.width, height: 40)
        cell?.textLabel?.text = "\(dict["Type"]!)(Priority:\(dict["Priority"] == nil ? "" : dict["Priority"]! as! String))"
        cell?.textLabel?.sizeToFit()
        cell?.detailTextLabel?.numberOfLines = 0
        cell?.detailTextLabel?.lineBreakMode = NSLineBreakMode.byCharWrapping
        cell?.detailTextLabel?.frame = CGRect(x: 0, y: 0, width: cell!.detailTextLabel!.frame.size.width, height: 30)
        let arrTemp = (dict["Value"] as! NSString).components(separatedBy: " ")
        var arr = [String]()
        for t in arrTemp{
            arr.append(t)
        }
        let text = (arr as NSArray).componentsJoined(by: " ").replacingOccurrences(of: ">", with: "")
        cell?.detailTextLabel?.text = text
        cell?.detailTextLabel?.sizeToFit()
        return cell!
    }
    
    func handleTraceCell(_ index:IndexPath)->UITableViewCell{
        var cell = tbRight.dequeueReusableCell(withIdentifier: "tbrightTrace")
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "tbrightTrace")
            cell?.backgroundColor = UIColor.clear
        }
        let dict = arrTrace![(index as NSIndexPath).row]
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.lineBreakMode = NSLineBreakMode.byCharWrapping
        cell?.textLabel?.frame = CGRect(x: 0, y: 0, width: cell!.textLabel!.frame.size.width, height: 40)
        cell?.textLabel?.text = "\(dict["Key"]!)(\(dict["Time"]!))"
        cell?.textLabel?.sizeToFit()
        cell?.detailTextLabel?.numberOfLines = 0
        cell?.detailTextLabel?.lineBreakMode = NSLineBreakMode.byCharWrapping
        cell?.detailTextLabel?.frame = CGRect(x: 0, y: 0, width: cell!.detailTextLabel!.frame.size.width, height: 40)
        cell?.detailTextLabel?.text = "from \(dict["OldValue"]!) to \(dict["NewValue"]!)"
        if dict["Key"] as! String == "superview.frame"{
            cell?.detailTextLabel?.text = "\(dict["Superview"]!)" + cell!.detailTextLabel!.text!
        }
        cell?.detailTextLabel?.sizeToFit()
        return cell!
    }
    
    func  handleAboutCell(_ index:IndexPath)->UITableViewCell{
        var cell = tbRight.dequeueReusableCell(withIdentifier: "tbrightAbout")
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "tbrightAbout")
            cell?.backgroundColor = UIColor.clear
        }
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.lineBreakMode = NSLineBreakMode.byCharWrapping
        cell?.textLabel?.frame = CGRect(x: 0, y: 0, width: cell!.textLabel!.frame.size.width, height: 40)
        cell?.textLabel?.text = arrAbout![(index as NSIndexPath).row]
        cell?.textLabel?.sizeToFit()
        return cell!
    }
    
    
    func heightForGeneralCell(_ index:IndexPath,width:CGFloat) -> CGFloat{
        if (index as NSIndexPath).row == 0{
            let str = arrGeneral![0] as NSString
            let rect = str.boundingRect(with: CGSize(width: width, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 17)], context: nil)
            return rect.size.height + 5
        }
        else{
            return 44
        }
    }
    
    func heightForSuperViewCell(_ index:IndexPath,width:CGFloat) -> CGFloat{
        let view = arrSuperView![(index as NSIndexPath).row].obj as? UIView
        var str,strDetail:String
        if view == nil
        {
            str = "view has released"
            strDetail = ""
        }
        else{
            str = "\(type(of: view!))"
            strDetail = "l:\(view!.frame.origin.x.format(".1f"))t:\(view!.frame.origin.y.format(".1f"))w:\(view!.frame.size.width.format(".1f"))h:\(view!.frame.size.height.format(".1f"))"
            if view! is UILabel || view! is UITextField || view! is UITextView{
                let text = view!.value(forKey: "text") as! String
                strDetail = "\(strDetail) text(\((text as NSString).length)):\(text)"
            }else if view! is UIButton{
                let btn = view as! UIButton
                if let title = btn.title(for: UIControlState()){
                    strDetail = "\(strDetail) text(\((title as NSString).length)):\(title)"
                }
                else{
                    strDetail = "\(strDetail) text(0):\" \""
                }
            }
        }
        let rect = (str as NSString).boundingRect(with: CGSize(width: width, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 17)], context: nil)
        let rectDetail = (strDetail as NSString).boundingRect(with: CGSize(width: width, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 12)], context: nil)
        let height = rect.size.height + rectDetail.size.height + 10
        return height
    }
    
    func heightForSubViewCell(_ index:IndexPath,width:CGFloat) -> CGFloat{
        let view = arrSubview![(index as NSIndexPath).row].obj as? UIView
        var str,strDetail:String
        if view == nil
        {
            str = "view has released"
            strDetail = ""
        }
        else{
            str = "\(type(of: view!))"
            strDetail = "l:\(view!.frame.origin.x.format(".1f"))t:\(view!.frame.origin.y.format(".1f"))w:\(view!.frame.size.width.format(".1f"))h:\(view!.frame.size.height.format(".1f"))"
            if view! is UILabel || view! is UITextField || view! is UITextView{
                let text = view!.value(forKey: "text") as! String
                strDetail = "\(strDetail) text(\((text as NSString).length)):\(text)"
            }else if view! is UIButton{
                let btn = view as! UIButton
                if let title = btn.title(for: UIControlState()){
                    strDetail = "\(strDetail) text(\((title as NSString).length)):\(title)"
                }
                else{
                    strDetail = "\(strDetail) text(0):\" \""
                }
            }
        }
        let rect = (str as NSString).boundingRect(with: CGSize(width: width, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 17)], context: nil)
        let rectDetail = (strDetail as NSString).boundingRect(with: CGSize(width: width, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 12)], context: nil)
        return rect.size.height + rectDetail.size.height + 10
    }
    
    
    func heightForConstrainCell(_ index:IndexPath,width:CGFloat) -> CGFloat{
        var str,strDetail:String
        let dic = arrConstrains![(index as NSIndexPath).row]
        str  = "\(dic["Type"]!)(Priority:\(dic["Priority"] == nil ? "" : dic["Priority"]! as! String))"
        let arrTemp = (dic["Value"] as! NSString).components(separatedBy: " ")
        var arr = [String]()
        for t in arrTemp{
            arr.append(t)
        }
        strDetail = (arr as NSArray).componentsJoined(by: " ").replacingOccurrences(of: ">", with: "")
        let rect = (str as NSString).boundingRect(with: CGSize(width: width, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 17)], context: nil)
        let rectDetail = (strDetail as NSString).boundingRect(with: CGSize(width: width, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 12)], context: nil)
        return rect.size.height + rectDetail.size.height + 10
    }
    
    func heightForTraceCell(_ index:IndexPath,width:CGFloat)->CGFloat{
        var str,strDetail:String
        let dic = arrTrace![(index as NSIndexPath).row]
        str  = "\(dic["Key"]!)(\(dic["Time"])!)"
        strDetail = "from \(dic["OldValue"]!) to \(dic["NewValue"]!)"
        if (dic["Key"] as! String) == "superview.frame"{
            strDetail = (dic["Superview"]! as! String) + strDetail
        }
        let rect = (str as NSString).boundingRect(with: CGSize(width: width, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 17)], context: nil)
        let rectDetail = (strDetail as NSString).boundingRect(with: CGSize(width: width, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 12)], context: nil)
        return rect.size.height + rectDetail.size.height + 10
    }
    
    func heightForAboutCell(_ index:IndexPath,width:CGFloat)->CGFloat{
        let str = arrAbout![(index as NSIndexPath).row]
        let rect = (str as NSString).boundingRect(with: CGSize(width: width, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 17)], context: nil)
        return rect.size.height + 5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }

}
