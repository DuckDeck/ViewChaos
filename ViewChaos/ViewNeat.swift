//
//  ViewNeat.swift
//  ViewChaosDemo
//
//  Created by Tyrant on 11/9/15.
//  Copyright © 2015 Qfq. All rights reserved.
//

import UIKit

class ViewNeat: UIView,ColorPickerDelegate {
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
        case foreGround = 0,backGround,tintColor
    }
    
    var segMenu:UISegmentedControl
    var segItemMenu:UISegmentedControl
    var viewControl:UIView?{
        didSet{
            if viewControl != nil{
                originFrame = viewControl!.frame
                
                lblViewInfo.text = "The view type is: \(viewControl!.dynamicType)"
                if viewControl! is UIButton{
                    originFont = (viewControl! as! UIButton).titleLabel?.font
                    originForegroundColor = (viewControl! as! UIButton).titleColorForState(UIControlState.Normal)
                }
                if viewControl! is UILabel{
                    originFont = (viewControl! as! UILabel).font
                    originForegroundColor = (viewControl! as! UILabel).textColor
                }
                if viewControl! is UITextField{
                    originFont = (viewControl! as! UITextField).font
                    originForegroundColor = (viewControl! as! UITextField).textColor
                }
                if viewControl! is UITextView{
                    originFont = (viewControl! as! UITextView).font
                    originForegroundColor = (viewControl! as! UITextView).textColor
                }
               originBorderColor =  viewControl!.layer.borderColor
               originBorderWidth = viewControl!.layer.borderWidth
               originCornerRadius = viewControl!.layer.cornerRadius
                originBackgroundColor = viewControl!.backgroundColor
                originTintColor = viewControl!.tintColor
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
    var originFont:UIFont?;
    var originBorderWidth:CGFloat = 0
    var originCornerRadius:CGFloat = 0
    var originBorderColor:CGColorRef?
    var originBackgroundColor:UIColor?
    var originForegroundColor:UIColor?
    var originTintColor = UIColor.blueColor()
    var currentColor:UIColor
    var vRockerArea:UIView
    var vRocker: UIView
    var left,top:Float  //右 上
    var scaleX = 1
    var scaleY = 1
    var scale:Int = 1
    var timer:NSTimer?
    var stepScale:UIStepper
    var lblScale:UILabel
    var btnColorChooseCompleted:UIButton?
    var vColorPicker:ChaosColorPicker?
    var btnClose:UIButton
    var btnReset:UIButton
    var btnPrecise:UIButton
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
        currentColor = UIColor.clearColor()
        stepScale = UIStepper() //需要设置比例,来更精细的调节 
        lblScale = UILabel()
        btnClose = UIButton()
        btnReset = UIButton(type: UIButtonType.RoundedRect)
        btnPrecise = UIButton()
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
        
        segItemMenu.frame = CGRect(x: 10, y: 2, width: 150, height: 20)
        segItemMenu.hidden = true
        segItemMenu.tintColor = UIColor.blackColor()
        segItemMenu.selectedSegmentIndex = 0
        segItemMenu.addTarget(self, action: "segItemClick:", forControlEvents: UIControlEvents.ValueChanged)
        addSubview(segItemMenu)
        
        vRockerArea.frame = CGRect(x: 10, y: 30, width: 100, height: 100)
        vRockerArea.layer.borderWidth = 0.5
        vRockerArea.layer.borderColor = UIColor.blackColor().CGColor
        addSubview(vRockerArea)
        
        vRocker.frame  =  CGRect(x: vRockerArea.frame.size.width / 2 - 20, y: vRockerArea.frame.size.height / 2 - 20, width: 40, height: 40)
        vRocker.layer.borderColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5).CGColor
        vRocker.layer.borderWidth = 0.5
        vRocker.layer.cornerRadius = 20
        vRocker.clipsToBounds = true
        vRocker.backgroundColor = UIColor.redColor()
        vRockerArea.addSubview(vRocker)
        
        lblViewInfo.frame = CGRect(x: CGRectGetMaxX(vRockerArea.frame) + 10 , y: 70, width: self.frame.size.width - CGRectGetMaxX(vRockerArea.frame) - 20, height: 60)
        lblViewInfo.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.3)
        lblViewInfo.font = UIFont.systemFontOfSize(13)
        lblViewInfo.numberOfLines = 0
        addSubview(lblViewInfo)
        
        btnColorChooseCompleted = UIButton(frame: CGRect(x: frame.size.width - 70, y: 5, width: 70, height: 27))
        btnColorChooseCompleted?.setTitle("ColorPick", forState: UIControlState.Normal)
        btnColorChooseCompleted?.addTarget(self, action: "chooseColor:", forControlEvents: UIControlEvents.TouchUpInside)
        btnColorChooseCompleted?.hidden = true
        btnColorChooseCompleted?.layer.borderWidth = 0.5
        btnColorChooseCompleted?.layer.borderColor = UIColor.blackColor().CGColor
        btnColorChooseCompleted?.titleLabel?.font = UIFont.systemFontOfSize(13)
        addSubview(btnColorChooseCompleted!)
        
        btnClose.frame = CGRect(x: self.frame.size.width - 50, y: 40, width: 45, height: 27)
        btnClose.setTitle("Close", forState: UIControlState.Normal)
        btnClose.layer.borderWidth  = 0.5
        btnClose.titleLabel?.font = UIFont.systemFontOfSize(13)
        btnClose.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btnClose.addTarget(self, action: "close:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(btnClose)
        
        btnReset.frame = CGRect(x: self.frame.size.width - 100, y: 40, width: 40, height: 27)
        btnReset.setTitle("Reset", forState: UIControlState.Normal)
        btnReset.layer.borderWidth  = 0.5
        btnReset.titleLabel?.font = UIFont.systemFontOfSize(13)
        btnReset.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btnReset.addTarget(self, action: "reset:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(btnReset)
        
        stepScale.frame = CGRect(x: CGRectGetMaxX(vRockerArea.frame) + 8, y: 40, width: 94, height: 20)
        stepScale.maximumValue = 5
        stepScale.minimumValue = 1
        stepScale.value = 5
        stepScale.tintColor = UIColor.blackColor()
        stepScale.addTarget(self, action: "scaleChange:", forControlEvents: UIControlEvents.ValueChanged)
        stepScale.stepValue = 1
        scale = Int(stepScale.value)
        addSubview(stepScale)
        
        lblScale.frame = CGRect(x: CGRectGetMaxX(vRockerArea.frame) + 8, y: 20, width: 45, height: 20)
        lblScale.text = "Scale:\(scale)"
        lblScale.font = UIFont.systemFontOfSize(13)
        lblScale.textColor = UIColor.blackColor()
        addSubview(lblScale)
        btnPrecise.frame = CGRect(x: btnColorChooseCompleted!.frame.origin.x-72, y: 5, width: 62, height: 27)
        btnPrecise.setTitle("Precise", forState: UIControlState.Normal)
        btnPrecise.layer.borderWidth  = 0.5
        btnPrecise.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btnPrecise.titleLabel?.font = UIFont.systemFontOfSize(13)
        btnPrecise.addTarget(self, action: "precise:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(btnPrecise)
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
            var newFrame = CGRect(x: point.x - CGFloat(left), y: point.y - CGFloat(top), width: vRocker.frame.size.width, height: vRocker.frame.size.height)
            if newFrame.origin.x <= 0{
                newFrame.origin.x = 0
            }
            if newFrame.origin.x >= 60{
                newFrame.origin.x = 60
            }
            if newFrame.origin.y <= 0{
                newFrame.origin.y = 0
            }
            if newFrame.origin.y >= 60{
                newFrame.origin.y = 60
            }
            //self.vRocker.frame = CGRect(x: point.x - CGFloat(left), y: point.y - CGFloat(top), width: vRocker.frame.size.width, height: vRocker.frame.size.height)
            //用这种方法创建摇杆全部失败,
           self.vRocker.frame = newFrame
            //换算到中间
            let newPoint = CGPoint(x: point.x - 50, y: point.y - 50)
            scaleX = Int(newPoint.x) / ((-5) * scale + 30)
            scaleY = Int(newPoint.y) / ((-5) * scale + 30)
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
                        let newWidth = CGRectGetMaxX(viewControl!.frame) - newFrame.origin.x
                        let newHeight = CGRectGetMaxY(viewControl!.frame) - newFrame.origin.y
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
                            if newSize < 0
                            {
                                return
                            }
                            txt.font = UIFont.systemFontOfSize(newSize)
                            lblViewInfo.text = "\(viewControl!.dynamicType) FontSize: \(newSize))"
                        }
                }
            case .border:
                switch neatBorderType{
                    case .borderWidth:
                    let newWidth = viewControl!.layer.borderWidth  - CGFloat(scaleY) * 0.5
                    if newWidth < 0{
                        return
                    }
                    viewControl!.layer.borderWidth = newWidth
                    lblViewInfo.text = "\(viewControl!.dynamicType) BorderWidth: \(newWidth))"
                case.borderColor: break
                case.cornerRadius:
                    let newCornerRadius = viewControl!.layer.cornerRadius  - CGFloat(scaleY) * 0.5
                    if newCornerRadius < 0{
                        return
                    }
                    viewControl!.layer.cornerRadius = newCornerRadius
                    lblViewInfo.text = "\(viewControl!.dynamicType) CornerRadius: \(newCornerRadius))"
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
        btnColorChooseCompleted?.hidden = true
        btnColorChooseCompleted?.setTitle("ColorPick", forState: UIControlState.Normal)
        vColorPicker?.delegate = nil
        vColorPicker?.removeFromSuperview()
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
                segItemMenu.insertSegmentWithTitle("Radius", atIndex: 2, animated: false)
            }
            else if segItemMenu.numberOfSegments == 3{
                segItemMenu.setTitle("Radius", forSegmentAtIndex: 2)
            }
            segItemMenu.setTitle("Color", forSegmentAtIndex: 0)
            segItemMenu.setTitle("Border", forSegmentAtIndex: 1)
            segItemMenu.selectedSegmentIndex = 1
            neatBorderType = .borderWidth
            case 4:neatType = .color
            segItemMenu.hidden = false
            if segItemMenu.numberOfSegments == 3{
                 segItemMenu.setTitle("Tint", forSegmentAtIndex: 2)
            }
            else if (segItemMenu.numberOfSegments == 2)
            {
                segItemMenu.insertSegmentWithTitle("Tint", atIndex: 2, animated: false)
            }
            segItemMenu.setTitle("Fore", forSegmentAtIndex: 0)
            segItemMenu.setTitle("Back", forSegmentAtIndex: 1)
            segItemMenu.selectedSegmentIndex = 1
            neatColorType = .backGround
            btnColorChooseCompleted?.hidden = false
            if let color = viewControl!.backgroundColor{
                btnColorChooseCompleted?.setTitleColor(color, forState: UIControlState.Normal)
                currentColor = color
            }
            case 5:neatType = .code
            segItemMenu.hidden = true
            generateCode()
            default: break
        }
        lblViewInfo.text = ""
    }
    
    func segItemClick(sender:UISegmentedControl){
        btnColorChooseCompleted?.hidden = true
        btnColorChooseCompleted?.setTitle("ColorPick", forState: UIControlState.Normal)
        vColorPicker?.delegate = nil
        vColorPicker?.removeFromSuperview()
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
                btnColorChooseCompleted?.hidden = false
                if let color = viewControl!.layer.borderColor{
                    btnColorChooseCompleted?.setTitleColor(UIColor(CGColor: color), forState: UIControlState.Normal)
                    currentColor = UIColor(CGColor: color)
                
                }
            case 1: neatBorderType = .borderWidth  //第一次调度BorderWidth不管用
            case 2: neatBorderType = .cornerRadius
            default:break
            
            }
        case .color:
            switch sender.selectedSegmentIndex{
            case 0: neatColorType = .foreGround
                //只有有字体的才是
                if viewControl! is UIButton{
                    btnColorChooseCompleted?.hidden = false
                    let btn = viewControl! as! UIButton
                    if let color = btn.titleColorForState(UIControlState.Normal){
                        btnColorChooseCompleted?.setTitleColor(color, forState: UIControlState.Normal)
                        currentColor = color
                    }
                }
                else if viewControl! is UILabel{
                    btnColorChooseCompleted?.hidden = false
                    let lbl = viewControl! as! UILabel
                    let color = lbl.textColor
                    btnColorChooseCompleted?.setTitleColor(color, forState: UIControlState.Normal)
                    currentColor = color
                }
                else if viewControl! is UITextField{
                    btnColorChooseCompleted?.hidden = false
                    let txt = viewControl! as! UITextField
                    if   let color = txt.textColor{
                        btnColorChooseCompleted?.setTitleColor(color, forState: UIControlState.Normal)
                        currentColor = color
                    }
              }
                else if viewControl! is UITextView{
                    btnColorChooseCompleted?.hidden = false
                    let txt = viewControl! as! UITextView
                    if   let color = txt.textColor{
                        btnColorChooseCompleted?.setTitleColor(color, forState: UIControlState.Normal)
                        currentColor = color
                    }
                }
                else{
                     Chaos.toast("Only contain text UIView can change foreground color")
                }
            case 1: neatColorType = .backGround
                btnColorChooseCompleted?.hidden = false
                if let color = viewControl!.backgroundColor{
                    btnColorChooseCompleted?.setTitleColor(color, forState: UIControlState.Normal)
                    currentColor = color
                    }
            case 2: neatColorType = .tintColor
                    btnColorChooseCompleted?.hidden = false
                    if let color = viewControl!.tintColor{
                        btnColorChooseCompleted?.setTitleColor(color, forState: UIControlState.Normal)
                        currentColor = color
                    }
                break
            default:break
                
            }
        default: break
        }
        
    }
    
    func colorSelectedChanged(color: UIColor) {
        btnColorChooseCompleted?.setTitleColor(color, forState: UIControlState.Normal)
        switch neatType{
        case .border:
            switch neatBorderType{
            case.borderColor: viewControl!.layer.borderColor = color.CGColor
            btnColorChooseCompleted?.setTitleColor(color, forState: UIControlState.Normal)
                lblViewInfo.text = "\(viewControl!.dynamicType) CornerRadius: \(color.format("swift"))"
            default : break
            }
        case .color:
            switch neatColorType{
            case .foreGround:
                if viewControl! is UIButton{
                    let btn = viewControl! as! UIButton
                    btn.setTitleColor(color, forState: UIControlState.Normal)
                    lblViewInfo.text = "\(viewControl!.dynamicType) TitleColor: \(color.format("swift"))"
                }
                else if viewControl! is UILabel{
                    let lbl = viewControl! as! UILabel
                   lbl.textColor = color
                    lblViewInfo.text = "\(viewControl!.dynamicType) TextColor: \(color.format("swift"))"
                }
                else if viewControl! is UITextField{
                    let txt = viewControl! as! UITextField
                    txt.textColor = color
                    lblViewInfo.text = "\(viewControl!.dynamicType) TextColor: \(color.format("swift")))"
                }
                else if viewControl! is UITextView{
                    let txt = viewControl! as! UITextView
                    txt.textColor = color
                    lblViewInfo.text = "\(viewControl!.dynamicType) TextColor: \(color.format("swift"))"
                }
            case.backGround:
                viewControl!.backgroundColor = color
                lblViewInfo.text = "\(viewControl!.dynamicType) BackGroundColor: \(color.format("swift"))"
            case .tintColor:
                viewControl!.tintColor = color
                lblViewInfo.text = "\(viewControl!.dynamicType) TintColor: \(color.format("swift"))"
            }
            break
        default: break
        }
    }
    
    func chooseColor(sender:UIButton){
        let title = sender.titleForState(UIControlState.Normal)
        if title == "ColorPick"{
            vColorPicker = ChaosColorPicker(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 250), color: currentColor)
            vColorPicker?.frame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.height - self.frame.size.height - vColorPicker!.frame.size.height, width: UIScreen.mainScreen().bounds.width, height: 200)
            vColorPicker?.delegate = self
            self.window?.addSubview(vColorPicker!)
            sender.setTitle("Completed", forState: UIControlState.Normal)
        }
        else{
             sender.setTitle("ColorPick", forState: UIControlState.Normal)
            vColorPicker?.delegate = nil
            vColorPicker?.removeFromSuperview()
        }
    }
    
    func precise(sender:UIButton){
         let title = sender.titleForState(UIControlState.Normal)!
        if title == "Precise"{
            sender.setTitle("Imprecise", forState: UIControlState.Normal)
            timer?.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "timerFire:", userInfo: nil, repeats: true)
            scale = 1
            stepScale.enabled = false
            lblScale.text = "Scale:\(scale)"
        }
        else{
            sender.setTitle("Precise", forState: UIControlState.Normal)
            timer?.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "timerFire:", userInfo: nil, repeats: true)
            scale = Int(stepScale.value)
            stepScale.enabled = true
            lblScale.text = "Scale:\(scale)"
        }
    }
    
    func scaleChange(sender:UIStepper){
        scale = Int(sender.value)
        lblScale.text = "Scale:\(scale)"
    }
    
    func reset(sender:UIButton){
        if viewControl != nil{
            viewControl?.frame = originFrame
            if viewControl! is UIButton{
               (viewControl! as! UIButton).titleLabel?.font = originFont
                (viewControl! as! UIButton).setTitleColor(originForegroundColor, forState: UIControlState.Normal)
            }
            if viewControl! is UILabel{
                 (viewControl! as! UILabel).font = originFont
                 (viewControl! as! UILabel).textColor = originForegroundColor
            }
            if viewControl! is UITextField{
                 (viewControl! as! UITextField).font = originFont
                (viewControl! as! UITextField).textColor = originForegroundColor
            }
            if viewControl! is UITextView{
                 (viewControl! as! UITextView).font = originFont
                (viewControl! as! UITextView).textColor = originForegroundColor
            }
            viewControl!.layer.borderColor = originBorderColor
            viewControl!.layer.borderWidth = originBorderWidth
             viewControl!.layer.cornerRadius = originCornerRadius
             viewControl!.backgroundColor = originBackgroundColor
            viewControl!.tintColor  = originTintColor
        }
    }
    
    func close(sender:UIButton){
       NSNotificationCenter.defaultCenter().postNotificationName("handleTraceViewClose", object: nil)
    }
    
    func generateCode(){
        print("\n")
        print("Begin generate Swift code-------------------------------------:")
        var viewName = "view"
        if viewControl!.name != nil{
            viewName = viewControl!.name!
        }
        print("let \(viewName) = \(viewControl!.dynamicType)()")
        print("\(viewName).frame = CGRect(x: \(viewControl!.frame.origin.x), y: \(viewControl!.frame.origin.y), width: \(viewControl!.frame.size.width), height:\(viewControl!.frame.size.width))")
        if viewControl! is UIButton{
            let btn = viewControl! as! UIButton
            if let fontSize = btn.titleLabel?.font.pointSize.format(".1f")
            {
                print("\(viewName).titleLabel?.font = UIFont.systemFontOfSize(\(fontSize))")
            }
            if let color = btn.titleColorForState(UIControlState.Normal)
            {
                print("\(viewName).setTitleColor(\(color.format("swift")), forState: UIControlState.Normal)") //颜色需要format
            }
        }
        else if viewControl! is UILabel{
            let lbl = viewControl! as! UILabel
            print("\(viewName).font = UIFont.systemFontOfSize(\(lbl.font.pointSize.format(".1f")))")
            let color = lbl.textColor
            print("\(viewName).textColor = \(color.format("swift"))") //颜色需要format
        }
        else if viewControl! is UITextField{
            let txt = viewControl! as! UITextField
            if let font = txt.font{
                print("\(viewName).font = UIFont.systemFontOfSize(\(font.pointSize.format(".1f")))")
            }
            if let color = txt.textColor{
                print("\(viewName).textColor = \(color.format("swift"))") //颜色需要format
            }
        }
        else if viewControl! is UITextView{
            let txt = viewControl! as! UITextView
            if let font = txt.font{
                print("\(viewName).font = UIFont.systemFontOfSize(\(font.pointSize.format(".1f")))")
            }
            if let color = txt.textColor{
                print("\(viewName).textColor = \(color.format("swift"))") //颜色需要format
            }
        }
        viewControl!.tintColor = viewControl!.backgroundColor
        viewControl!.layer.borderWidth = viewControl!.layer.borderWidth
        if let borderColor = viewControl!.layer.borderColor{
            print("\(viewName).layer.borderColor = \(UIColor(CGColor: borderColor).format("swift")).CGColor")
        }
        print("\(viewName).layer.borderWidth = \(viewControl!.layer.borderWidth.format("0.1f"))")
        print("\(viewName).layer.cornerRadius = \(viewControl!.layer.cornerRadius.format("0.1f"))")
        if let backColor = viewControl!.backgroundColor{
            print("\(viewName).backgroundColor = \(backColor.format("swift"))")
        }
        print("\(viewName).tintColor = \(viewControl!.tintColor.format("swift"))")
        
        
        print("\n")
        print("\n")
        print("Begin generate Objective -C code-------------------------------------:")
        print("\(viewControl!.dynamicType)*  \(viewName) = [\(viewControl!.dynamicType) new];")
        print("\(viewName).frame =  CGRectMake(\(viewControl!.frame.origin.x), \(viewControl!.frame.origin.y), \(viewControl!.frame.size.width), \(viewControl!.frame.size.width));")
        if viewControl! is UIButton{
            let btn = viewControl! as! UIButton
            if let fontSize = btn.titleLabel?.font.pointSize.format(".1f")
            {
                print("\(viewName).titleLabel.font = [UIFont systemFontOfSize:\(fontSize)];")
            }
            if let color = btn.titleColorForState(UIControlState.Normal)
            {
                print("[\(viewName) setTitleColor:\(color.format("objc")) forState:UIControlStateNormal];") //颜色需要format
            }
        }
        else if viewControl! is UILabel{
            let lbl = viewControl! as! UILabel
            print("\(viewName).font = [UIFont systemFontOfSize:\(lbl.font.pointSize.format(".1f"))];")
            let color = lbl.textColor
            print("\(viewName).textColor = \(color.format("objc"));") //颜色需要format
        }
        else if viewControl! is UITextField{
            let txt = viewControl! as! UITextField
            if let font = txt.font{
                print("\(viewName).font = [UIFont systemFontOfSize:\(font.pointSize.format(".1f"))];")
            }
            if let color = txt.textColor{
                print("\(viewName).textColor = \(color.format("objc"));") //颜色需要format
            }
        }
        else if viewControl! is UITextView{
            let txt = viewControl! as! UITextView
            if let font = txt.font{
                print("\(viewName).font =  [UIFont systemFontOfSize:\(font.pointSize.format(".1f"))];")
            }
            if let color = txt.textColor{
                print("\(viewName).textColor = \(color.format("objc"));") //颜色需要format
            }
        }
  
        if let borderColor = viewControl!.layer.borderColor{
            print("\(viewName).layer.borderColor = \(UIColor(CGColor: borderColor).format("objc")).CGColor;")
        }
        print("\(viewName).layer.borderWidth = \(viewControl!.layer.borderWidth.format("0.1f"));")
        print("\(viewName).layer.cornerRadius = \(viewControl!.layer.cornerRadius.format("0.1f"));")
        if let backColor = viewControl!.backgroundColor{
            print("\(viewName).backgroundColor = \(backColor.format("objc"));")
        }
        print("\(viewName).tintColor = \(viewControl!.tintColor.format("objc"));")
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
extension UIColor{
    func format(type:String)->String{
        var red:CGFloat = 0.0
        var green:CGFloat = 0.0
        var blue:CGFloat = 0.0
        var alpha:CGFloat = 0.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
         if type == "swift"{
            return "UIColor(red: \(red.format(".2f")), green: \(green.format(".2f")), blue: \(blue.format(".2f")), alpha: \(alpha.format(".2f")))"
        }
         else if type == "objc"{
            return "[UIColor colorWithRed:\(red.format(".2f")) green:\(green.format(".2f")) blue: \(blue.format(".2f")) alpha:\(alpha.format(".2f"))]"
        }
         else{
            return self.description
        }
    }
}



