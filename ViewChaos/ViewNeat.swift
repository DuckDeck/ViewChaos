//
//  ViewNeat.swift
//  ViewChaosDemo
//
//  Created by Tyrant on 11/9/15.
//  Copyright © 2015 Qfq. All rights reserved.
//

import UIKit

class ViewNeat: UIView {
    enum neat:Int{
        case location = 0,size,font,border,color,code
    }
    
    enum neatSize:Int{
        case topLeft = 0, rightBottom
    }
    
    enum neatBorder:Int{
        case borderColor = 0,borderWidth,cornerRadius
    }
    
    enum neatColor:Int{
        case foreGround = 0,backGround
    }
    
    var segMenu:UISegmentedControl
    var segItemMenu:UISegmentedControl
    var viewControl:UIView?{
        didSet{
            if viewControl != nil{
                originFrame = viewControl!.frame
                lblViewInfo.text = "The view type is: \(viewControl!.dynamicType))"
            }
        }
    }
    var lblViewInfo:UILabel
    var isTouch = false
    var neatType:neat = .location
    var neatSizeType:neatSize = .topLeft
    var neatBorderType:neatBorder = .borderColor
    var neatColorType:neatColor = .foreGround
    var originFrame:CGRect
    
    var vRockerArea:UIView
    var vRocker: UIView
    var left,top:Float  //右 上
    var scaleX = 1
    var scaleY = 1
    var timer:NSTimer?
    init(){
        //有一些View切换的细节后面边测试边处理
        segMenu = UISegmentedControl(items: ["Location","Size","Font","Border","Color","Code"])
        segItemMenu = UISegmentedControl(items: ["LeftTop","RightBottom"])
        vRockerArea = UIView()
        vRocker = UIView()
        left = 0
        top = 0
        lblViewInfo = UILabel()
        originFrame = CGRectZero
        super.init(frame:CGRect(x: 0, y: UIScreen.mainScreen().bounds.height - 180, width: UIScreen.mainScreen().bounds.width, height: 180))
        self.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.3)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "timerFire:", userInfo: nil, repeats: true)
        segMenu.frame = CGRect(x: 10, y:self.frame.size.height - 35 , width: self.frame.size.width - 20, height: 30)
        segMenu.tintColor = UIColor.blackColor()
        segMenu.addTarget(self, action: "segClick:", forControlEvents: UIControlEvents.ValueChanged)
        if segMenu.selectedSegmentIndex == -1
        {
            segMenu.selectedSegmentIndex = 0
        }
        addSubview(segMenu)
        
        segItemMenu.frame = CGRect(x: 10, y: 5, width: 150, height: 20)
        segItemMenu.hidden = true
        segItemMenu.tintColor = UIColor.blackColor()
        segItemMenu.selectedSegmentIndex = 0
        segItemMenu.addTarget(self, action: "segItemClick:", forControlEvents: UIControlEvents.ValueChanged)
        addSubview(segItemMenu)
        
        vRockerArea.frame = CGRect(x: 10, y: 30, width: 100, height: 100)
        vRockerArea.layer.borderWidth = 0.5
        vRockerArea.layer.borderColor = UIColor.orangeColor().CGColor
        addSubview(vRockerArea)
        
        vRocker.frame  =  CGRect(x: vRockerArea.frame.size.width / 2 - 20, y: vRockerArea.frame.size.height / 2 - 20, width: 40, height: 40)
        vRocker.layer.borderColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5).CGColor
        vRocker.layer.borderWidth = 0.5
        vRocker.layer.cornerRadius = 20
        vRocker.clipsToBounds = true
        vRocker.backgroundColor = UIColor.redColor()
        vRockerArea.addSubview(vRocker)
        
        lblViewInfo.frame = CGRect(x: CGRectGetMaxX(vRockerArea.frame) + 20 , y: 70, width: self.frame.size.width - CGRectGetMaxX(vRockerArea.frame) - 30, height: 60)
        lblViewInfo.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.3)
        lblViewInfo.font = UIFont.systemFontOfSize(13)
        lblViewInfo.numberOfLines = 0
        addSubview(lblViewInfo)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first
        if let point =  touch?.locationInView(vRocker)
        {
            if point.x > 0 && point.x < vRocker.frame.size.width && point.y > 0 && point.y < vRocker.frame.size.height{
                isTouch = true
                left = Float(point.x)
                top = Float(point.y)
                if timer!.valid{
                    timer?.fire()
                    timer?.resumeChaosTimer()
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !isTouch
        {
            return
        }
        let touch = touches.first
        if let point = touch?.locationInView(vRockerArea){
        //    Chaos.Log("X:\(point.x) Y:\(point.y)")
            //Chaos.Log("CehterX:\(vRockerArea.center.x) CenterY:\(vRockerArea.center.y)")
        //限定在一个圆形范围内
//            let x = point.x - 50
//            let y = point.y - 50
//            if x * x + y*y >= 250{
//                return
//            }
            let newFrame = CGRect(x: point.x - CGFloat(left), y: point.y - CGFloat(top), width: vRocker.frame.size.width, height: vRocker.frame.size.height)
            if newFrame.origin.x <= 0 || newFrame.origin.x >= 60 || newFrame.origin.y <= 0 ||  newFrame.origin.y >= 60{
                return
            }
            //self.vRocker.frame = CGRect(x: point.x - CGFloat(left), y: point.y - CGFloat(top), width: vRocker.frame.size.width, height: vRocker.frame.size.height)
            //用这种方法创建摇杆全部失败,
           self.vRocker.frame = newFrame
            //换算到中间
            let newPoint = CGPoint(x: point.x - 50, y: point.y - 50)
            scaleX = Int(newPoint.x) / 5
            scaleY = Int(newPoint.y) / 5
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        isTouch = false
        timer?.pauseChaosTimer()
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.vRocker.frame = CGRect(x: self.vRockerArea.frame.size.width / 2 - 20, y: self.vRockerArea.frame.size.height / 2 - 20, width: 40, height: 40)
            }) { (finished) -> Void in
                
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
          isTouch = false
        timer?.pauseChaosTimer()
        UIView.animateWithDuration(0.2, animations: { () -> Void in
             self.vRocker.frame = CGRect(x: self.vRockerArea.frame.size.width / 2 - 20, y: self.vRockerArea.frame.size.height / 2 - 20, width: 40, height: 40)
            }) { (finished) -> Void in
                
        }
        
    }
    
    func timerFire(sender:NSTimer){
        if !isTouch{
            return
        }
        if viewControl != nil{
            switch(neatType){
                case .location:
                        viewControl!.frame = CGRect(x: viewControl!.frame.origin.x + CGFloat(scaleX) * 0.5, y: viewControl!.frame.origin.y + CGFloat(scaleY) * 0.5, width: viewControl!.frame.size.width, height: viewControl!.frame.size.height)
                    lblViewInfo.text = "\(viewControl!.dynamicType) l:\(viewControl!.frame.origin.x) t:\(viewControl!.frame.origin.y) w:\(viewControl!.frame.size.width) h:\(viewControl!.frame.size.height)"
                case .size:
                    switch neatSizeType{
                    case.topLeft:
                        let newFrame = CGRect(x: viewControl!.frame.origin.x + CGFloat(scaleX) * 0.5, y: viewControl!.frame.origin.y + CGFloat(scaleY) * 0.5, width: viewControl!.frame.size.width, height: viewControl!.frame.size.height)
                        let newWidth = CGRectGetMaxX(originFrame) - newFrame.origin.x
                        let newHeight = CGRectGetMaxY(originFrame) - newFrame.origin.y
                        if newWidth <= CGFloat(0.0) || newHeight <= CGFloat(0.0)
                        {
                            return
                        }
                        viewControl!.frame = CGRect(x: newFrame.origin.x, y: newFrame.origin.y, width: newWidth, height: newHeight)
                        lblViewInfo.text = "\(viewControl!.dynamicType) l:\(viewControl!.frame.origin.x) t:\(viewControl!.frame.origin.y) w:\(viewControl!.frame.size.width) h:\(viewControl!.frame.size.height)"
                    case .rightBottom:
                        let newWidth = viewControl!.frame.size.width + CGFloat(scaleX) * 0.5
                        let newHeight = viewControl!.frame.size.height + CGFloat(scaleY) * 0.5
                        if newWidth <= CGFloat(0.0) || newHeight <= CGFloat(0.0)
                        {
                            return
                        }
                        viewControl!.frame = CGRect(x: viewControl!.frame.origin.x, y: viewControl!.frame.origin.y, width: newWidth, height: newHeight)
                        lblViewInfo.text = "\(viewControl!.dynamicType) l:\(viewControl!.frame.origin.x) t:\(viewControl!.frame.origin.y) w:\(viewControl!.frame.size.width) h:\(viewControl!.frame.size.height)"
                }
            case .font:
                    if viewControl! is UILabel{
                        let lbl = viewControl! as! UILabel
                        let newSize = lbl.font.pointSize - CGFloat(scaleY) * 0.5
                        if newSize <= 0
                        {
                            return
                        }
                        lbl.font = UIFont.systemFontOfSize(newSize)
                        lblViewInfo.text = "\(viewControl!.dynamicType) FontSize: \(newSize))"
                    }
                    if viewControl! is UIButton{
                        let btn = viewControl! as! UIButton
                        if let fontSize = btn.titleLabel?.font.pointSize {
                            let newSize = fontSize - CGFloat(scaleY) * 0.5
                            if newSize <= 0
                            {
                                return
                            }
                            btn.titleLabel?.font = UIFont.systemFontOfSize(newSize)
                            lblViewInfo.text = "\(viewControl!.dynamicType) FontSize: \(newSize))"
                        }
                    }
                    if viewControl! is UITextField{
                        let txt = viewControl! as! UITextField
                        if let fontSize = txt.font?.pointSize {
                            let newSize = fontSize - CGFloat(scaleY) * 0.5
                            if newSize <= 0
                            {
                                return
                            }
                            txt.font = UIFont.systemFontOfSize(newSize)
                            lblViewInfo.text = "\(viewControl!.dynamicType) FontSize: \(newSize))"
                        }
                    }
                    if viewControl! is UITextView{
                        let txt = viewControl! as! UITextView
                        if let fontSize = txt.font?.pointSize {
                            let newSize = fontSize - CGFloat(scaleY) * 0.5
                            if newSize <= 0
                            {
                                return
                            }
                            txt.font = UIFont.systemFontOfSize(newSize)
                            lblViewInfo.text = "\(viewControl!.dynamicType) FontSize: \(newSize))"
                        }
                }
                
                default: break
                }
            }
        }
    
    override convenience init(frame: CGRect) {
        self.init()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func segClick(sender:UISegmentedControl){
        switch sender.selectedSegmentIndex{
            case 0: neatType = .location
            segItemMenu.hidden = true
            case 1:neatType = .size
            segItemMenu.hidden = false
            if segItemMenu.numberOfSegments == 3{
                segItemMenu.removeSegmentAtIndex(2, animated: false)
            }
            segItemMenu.setTitle("LeftTop", forSegmentAtIndex: 0)
            segItemMenu.setTitle("RightBottom", forSegmentAtIndex: 1)
            case 2:neatType = .font
            segItemMenu.hidden = true
            case 3:neatType = .border
            segItemMenu.hidden = false
            if segItemMenu.numberOfSegments == 2{
                segItemMenu.setTitle("Color", forSegmentAtIndex: 0)
                segItemMenu.setTitle("Border", forSegmentAtIndex: 1)
                segItemMenu.insertSegmentWithTitle("Radius", atIndex: 2, animated: false)
            }
            case 4:neatType = .color
            segItemMenu.hidden = false
            if segItemMenu.numberOfSegments == 3{
                segItemMenu.removeSegmentAtIndex(2, animated: false)
            }
            segItemMenu.setTitle("Fore", forSegmentAtIndex: 0)
            segItemMenu.setTitle("Back", forSegmentAtIndex: 1)
            case 5:neatType = .code
            segItemMenu.hidden = true
            default: break
        }
        lblViewInfo.text = ""
    }
    
    func segItemClick(sender:UISegmentedControl){
        switch neatType{
        case .size:
            switch sender.selectedSegmentIndex{
            case 0: neatSizeType = .topLeft
            case 1:neatSizeType = .rightBottom
            default:break
            }
        case .border:
            switch sender.selectedSegmentIndex{
            case 0: neatBorderType = .borderColor
            case 1: neatBorderType = .borderWidth
            case 2: neatBorderType = .cornerRadius
            default:break
            
            }
        case .color:
            switch sender.selectedSegmentIndex{
            case 0: neatColorType = .foreGround
            case 1: neatColorType = .backGround
            default:break
                
            }
        default: break
        }
        
    }
}

extension NSTimer{
    func pauseChaosTimer(){ //这样可以尽量不导致冲突
        if !self.valid
        {
            return
        }
        self.fireDate = NSDate.distantFuture()
    }
    
    func resumeChaosTimer(){
        if !self.valid
        {
            return
        }
        self.fireDate = NSDate()
    }
}


