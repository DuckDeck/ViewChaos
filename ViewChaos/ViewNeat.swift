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
    
    enum preciseMode:Int{
        case normal=0,precise
    }
    
    var segMenu:UISegmentedControl
    var segItemMenu:UISegmentedControl
    weak var viewControl:UIView?{
        didSet{
            if viewControl != nil{
                originFrame = viewControl!.frame
                
                lblViewInfo.text = "The view type is: \(type(of: viewControl!))"
                if viewControl! is UIButton{
                    originFont = (viewControl! as! UIButton).titleLabel?.font
                    originForegroundColor = (viewControl! as! UIButton).titleColor(for: UIControlState())
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
                if let tColor = viewControl!.tintColor{
                    originTintColor = tColor
                }
            }
        }
    }
    var lblViewInfo:UILabel
    var isTouch = false
    var neatType:neat = .location
    var neatSizeType:neatSize = .topLeft
    var neatBorderType:neatBorder = .borderColor
    var neatColorType:neatColor = .foreGround
    var neatPreciseMode = preciseMode.normal
    var operatonScale:CGFloat = 0.0
    var originFrame:CGRect
    var originFont:UIFont?;
    var originBorderWidth:CGFloat = 0
    var originCornerRadius:CGFloat = 0
    var originBorderColor:CGColor?
    var originBackgroundColor:UIColor?
    var originForegroundColor:UIColor?
    var originTintColor = UIColor.blue
    var currentColor:UIColor
    var vRockerArea:UIView
    var vRocker: UIView
    var left,top:Float  //右 上
    var scaleX = 1
    var scaleY = 1
    var scale:Int = 1
    var timer:Timer?
    var stepScale:UIStepper
    var lblScale:UILabel
    var btnColorChooseCompleted:UIButton?
    var vColorPicker:ChaosColorPicker?
    var btnClose:UIButton
    var btnReset:UIButton
    var btnPrecise:UIButton
    var btnUp:UIButton
    var btnDown:UIButton
    var btnLeft:UIButton
    var btnRight:UIButton
    init(){
        //有一些View切换的细节后面边测试边处理
        segMenu = UISegmentedControl(items: ["Location","Size","Font","Border","Color","Code"])
        segItemMenu = UISegmentedControl(items: ["LeftTop","RightBottom"])
        vRockerArea = UIView()
        vRocker = UIView()
        left = 0
        top = 0
        lblViewInfo = UILabel()
        originFrame = CGRect.zero
        currentColor = UIColor.clear
        stepScale = UIStepper() //需要设置比例,来更精细的调节 
        lblScale = UILabel()
        btnClose = UIButton()
        btnReset = UIButton(type: UIButtonType.roundedRect)
        btnPrecise = UIButton()
        btnUp = UIButton()
        btnDown = UIButton()
        btnLeft = UIButton()
        btnRight = UIButton()
        super.init(frame:CGRect(x: 0, y: UIScreen.main.bounds.height - 180, width: UIScreen.main.bounds.width, height: 180))
        self.backgroundColor = UIColor(red: 0.0, green: 0.898, blue: 0.836, alpha: 0.3)
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(ViewNeat.timerFire(_:)), userInfo: nil, repeats: true)
        segMenu.frame = CGRect(x: 10, y:self.frame.size.height - 35 , width: self.frame.size.width - 20, height: 30)
        segMenu.tintColor = UIColor.black
        segMenu.addTarget(self, action: #selector(ViewNeat.segClick(_:)), for: UIControlEvents.valueChanged)
        if segMenu.selectedSegmentIndex == -1
        {
            segMenu.selectedSegmentIndex = 0
        }
        addSubview(segMenu)
        
        segItemMenu.frame = CGRect(x: 10, y: 2, width: 150, height: 20)
        segItemMenu.isHidden = true
        segItemMenu.tintColor = UIColor.black
        segItemMenu.selectedSegmentIndex = 0
        segItemMenu.addTarget(self, action: #selector(ViewNeat.segItemClick(_:)), for: UIControlEvents.valueChanged)
        addSubview(segItemMenu)
        
        vRockerArea.frame = CGRect(x: 10, y: 30, width: 100, height: 100)
        vRockerArea.layer.borderWidth = 0.5
        vRockerArea.layer.borderColor = UIColor.black.cgColor
        addSubview(vRockerArea)
        
        vRocker.frame  =  CGRect(x: vRockerArea.frame.size.width / 2 - 20, y: vRockerArea.frame.size.height / 2 - 20, width: 40, height: 40)
        vRocker.layer.borderColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5).cgColor
        vRocker.layer.borderWidth = 0.5
        vRocker.layer.cornerRadius = 20
        vRocker.clipsToBounds = true
        vRocker.backgroundColor = UIColor.red
        vRockerArea.addSubview(vRocker)
        
        
        btnUp.frame = CGRect(x: vRockerArea.frame.size.width / 2 - 15, y: 0, width: 30, height: 30)
        btnUp.setTitle("⬆︎", for: UIControlState())
        btnUp.setTitleColor(UIColor.red, for: UIControlState())
        btnUp.tag = 100
        btnUp.layer.borderColor = UIColor.red.cgColor
        btnUp.layer.borderWidth = 1
        btnUp.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        vRockerArea.addSubview(btnUp)
        btnDown.frame = CGRect(x: vRockerArea.frame.size.width / 2 - 15, y: vRockerArea.frame.size.height - 30, width: 30, height: 30)
        btnDown.setTitle("⬇︎", for: UIControlState())
        btnDown.setTitleColor(UIColor.red, for: UIControlState())
        btnDown.tag = 101
        btnDown.layer.borderColor = UIColor.red.cgColor
        btnDown.layer.borderWidth = 1
        btnDown.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        vRockerArea.addSubview(btnDown)
        btnLeft.frame = CGRect(x: 0, y: vRockerArea.frame.size.height / 2 - 15, width: 30, height: 30)
        btnLeft.setTitle("⬅︎", for: UIControlState())
        btnLeft.setTitleColor(UIColor.red, for: UIControlState())
        btnLeft.tag = 102
        btnLeft.layer.borderColor = UIColor.red.cgColor
        btnLeft.layer.borderWidth = 1
        btnLeft.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        vRockerArea.addSubview(btnLeft)
        btnRight.frame = CGRect(x: vRockerArea.frame.size.width - 30, y:  vRockerArea.frame.size.height / 2 - 15, width: 30, height: 30)
        btnRight.setTitle("➡︎", for: UIControlState())
        btnRight.setTitleColor(UIColor.red, for: UIControlState())
        btnRight.tag = 103
        btnRight.layer.borderColor = UIColor.red.cgColor
        btnRight.layer.borderWidth = 1
        btnRight.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        vRockerArea.addSubview(btnRight)
        btnUp.addTarget(self, action: #selector(ViewNeat.oper(_:)), for: UIControlEvents.touchUpInside)
        btnDown.addTarget(self, action: #selector(ViewNeat.oper(_:)), for: UIControlEvents.touchUpInside)
        btnLeft.addTarget(self, action: #selector(ViewNeat.oper(_:)), for: UIControlEvents.touchUpInside)
        btnRight.addTarget(self, action: #selector(ViewNeat.oper(_:)), for: UIControlEvents.touchUpInside)
        setOperButtonsVisible(false)
        
        
        lblViewInfo.frame = CGRect(x: vRockerArea.frame.maxX + 10 , y: 70, width: self.frame.size.width - vRockerArea.frame.maxX - 20, height: 60)
        lblViewInfo.font = UIFont.systemFont(ofSize: 13)
        lblViewInfo.numberOfLines = 0
        addSubview(lblViewInfo)
        
        btnColorChooseCompleted = UIButton(frame: CGRect(x: frame.size.width - 70, y: 5, width: 70, height: 27))
        btnColorChooseCompleted?.setTitle("ColorPick", for: UIControlState())
        btnColorChooseCompleted?.addTarget(self, action: #selector(ViewNeat.chooseColor(_:)), for: UIControlEvents.touchUpInside)
        btnColorChooseCompleted?.isHidden = true
        btnColorChooseCompleted?.layer.borderWidth = 0.5
        btnColorChooseCompleted?.layer.borderColor = UIColor.black.cgColor
        btnColorChooseCompleted?.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        addSubview(btnColorChooseCompleted!)
        
        btnClose.frame = CGRect(x: self.frame.size.width - 50, y: 40, width: 45, height: 27)
        btnClose.setTitle("Close", for: UIControlState())
        btnClose.layer.borderWidth  = 0.5
        btnClose.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btnClose.setTitleColor(UIColor.black, for: UIControlState())
        btnClose.addTarget(self, action: #selector(ViewNeat.close(_:)), for: UIControlEvents.touchUpInside)
        addSubview(btnClose)
        
        btnReset.frame = CGRect(x: self.frame.size.width - 100, y: 40, width: 40, height: 27)
        btnReset.setTitle("Reset", for: UIControlState())
        btnReset.layer.borderWidth  = 0.5
        btnReset.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btnReset.setTitleColor(UIColor.black, for: UIControlState())
        btnReset.addTarget(self, action: #selector(ViewNeat.reset(_:)), for: UIControlEvents.touchUpInside)
        addSubview(btnReset)
        
        stepScale.frame = CGRect(x: vRockerArea.frame.maxX + 8, y: 40, width: 94, height: 20)
        stepScale.maximumValue = 5
        stepScale.minimumValue = 1
        stepScale.value = 5
        stepScale.tintColor = UIColor.black
        stepScale.addTarget(self, action: #selector(ViewNeat.scaleChange(_:)), for: UIControlEvents.valueChanged)
        stepScale.stepValue = 1
        scale = Int(stepScale.value)
        addSubview(stepScale)
        
        lblScale.frame = CGRect(x: vRockerArea.frame.maxX + 8, y: 20, width: 60, height: 20)
        lblScale.text = "Scale:\(scale)"
        lblScale.font = UIFont.systemFont(ofSize: 12)
        lblScale.textColor = UIColor.black
        addSubview(lblScale)
        btnPrecise.frame = CGRect(x: btnColorChooseCompleted!.frame.origin.x-65, y: 5, width: 62, height: 27)
        btnPrecise.setTitle("Precise", for: UIControlState())
        btnPrecise.layer.borderWidth  = 0.5
        btnPrecise.setTitleColor(UIColor.black, for: UIControlState())
        btnPrecise.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btnPrecise.addTarget(self, action: #selector(ViewNeat.precise(_:)), for: UIControlEvents.touchUpInside)
        addSubview(btnPrecise)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        if let point =  touch?.location(in: vRocker)
        {
            if point.x > 0 && point.x < vRocker.frame.size.width && point.y > 0 && point.y < vRocker.frame.size.height{
                isTouch = true
                left = Float(point.x)
                top = Float(point.y)
                if timer!.isValid{
                    timer?.fire()
                    timer?.resumeChaosTimer()
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isTouch
        {
            return
        }
        let touch = touches.first
        if let point = touch?.location(in: vRockerArea){
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
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        isTouch = false
        timer?.pauseChaosTimer()
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.vRocker.frame = CGRect(x: self.vRockerArea.frame.size.width / 2 - 20, y: self.vRockerArea.frame.size.height / 2 - 20, width: 40, height: 40)
            }, completion: { (finished) -> Void in
                
        }) 
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
          isTouch = false
        timer?.pauseChaosTimer()
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
             self.vRocker.frame = CGRect(x: self.vRockerArea.frame.size.width / 2 - 20, y: self.vRockerArea.frame.size.height / 2 - 20, width: 40, height: 40)
            }, completion: { (finished) -> Void in
                
        }) 
        
    }
    
    func setOperButtonsVisible(_ visible:Bool){
        if(visible){
            btnUp.isHidden = false
            btnDown.isHidden = false
            btnLeft.isHidden = false
            btnRight.isHidden = false
            vRocker.isHidden = true
        }
        else{
            btnUp.isHidden = true
            btnDown.isHidden = true
            btnLeft.isHidden = true
            btnRight.isHidden = true
            vRocker.isHidden = false
        }
    }
    @objc func oper(_ sender:UIButton){
        switch sender.tag{
        case 100:
            scaleY = -1
            scaleX = 0
        case 101:
            scaleY = 1
            scaleX = 0
        case 102:
            scaleX = -1
            scaleY = 0
        case 103:
            scaleX = 1
            scaleY = 0
        default:break
        }
        operationView()
    }
    
    @objc func timerFire(_ sender:Timer){
        if !isTouch{
            return
        }
        if viewControl != nil{
            operationView()
            }
            else{
                Chaos.toast("VIew have released")
            }
        }
    
    
    func operationView(){
        operatonScale = neatPreciseMode == .normal ? 0.5 : (CGFloat(scale) / 10.0)
        switch(neatType){
        case .location:
            viewControl!.frame = CGRect(x: viewControl!.frame.origin.x + CGFloat(scaleX) * operatonScale, y: viewControl!.frame.origin.y + CGFloat(scaleY) * operatonScale, width: viewControl!.frame.size.width, height: viewControl!.frame.size.height)
            lblViewInfo.text = "\(type(of: viewControl!)) l:\(viewControl!.frame.origin.x) t:\(viewControl!.frame.origin.y) w:\(viewControl!.frame.size.width) h:\(viewControl!.frame.size.height)"
        case .size:
            switch neatSizeType{
            case.topLeft:
                let newFrame = CGRect(x: viewControl!.frame.origin.x + CGFloat(scaleX) * operatonScale, y: viewControl!.frame.origin.y + CGFloat(scaleY) * operatonScale, width: viewControl!.frame.size.width, height: viewControl!.frame.size.height)
                let newWidth = viewControl!.frame.maxX - newFrame.origin.x
                let newHeight = viewControl!.frame.maxY - newFrame.origin.y
                if newWidth <= CGFloat(0.0) || newHeight <= CGFloat(0.0)
                {
                    return
                }
                viewControl!.frame = CGRect(x: newFrame.origin.x, y: newFrame.origin.y, width: newWidth, height: newHeight)
                lblViewInfo.text = "\(type(of: viewControl!)) l:\(viewControl!.frame.origin.x) t:\(viewControl!.frame.origin.y) w:\(viewControl!.frame.size.width) h:\(viewControl!.frame.size.height)"
            case .rightBottom:
                let newWidth = viewControl!.frame.size.width + CGFloat(scaleX) * operatonScale
                let newHeight = viewControl!.frame.size.height + CGFloat(scaleY) * operatonScale
                if newWidth <= CGFloat(0.0) || newHeight <= CGFloat(0.0)
                {
                    return
                }
                viewControl!.frame = CGRect(x: viewControl!.frame.origin.x, y: viewControl!.frame.origin.y, width: newWidth, height: newHeight)
                lblViewInfo.text = "\(type(of: viewControl!)) l:\(viewControl!.frame.origin.x) t:\(viewControl!.frame.origin.y) w:\(viewControl!.frame.size.width) h:\(viewControl!.frame.size.height)"
            }
        case .font:
            if viewControl! is UILabel{
                let lbl = viewControl! as! UILabel
                let newSize = lbl.font.pointSize - CGFloat(scaleY) * operatonScale
                if newSize <= 0
                {
                    return
                }
                lbl.font = UIFont.systemFont(ofSize: newSize)
                lblViewInfo.text = "\(type(of: viewControl!)) FontSize: \(newSize)"
            }
            if viewControl! is UIButton{
                let btn = viewControl! as! UIButton
                if let fontSize = btn.titleLabel?.font.pointSize {
                    let newSize = fontSize - CGFloat(scaleY) * operatonScale
                    if newSize <= 0
                    {
                        return
                    }
                    btn.titleLabel?.font = UIFont.systemFont(ofSize: newSize)
                    lblViewInfo.text = "\(type(of: viewControl!)) FontSize: \(newSize)"
                }
            }
            if viewControl! is UITextField{
                let txt = viewControl! as! UITextField
                if let fontSize = txt.font?.pointSize {
                    let newSize = fontSize - CGFloat(scaleY) * operatonScale
                    if newSize <= 0
                    {
                        return
                    }
                    txt.font = UIFont.systemFont(ofSize: newSize)
                    lblViewInfo.text = "\(type(of: viewControl!)) FontSize: \(newSize)"
                }
            }
            if viewControl! is UITextView{
                let txt = viewControl! as! UITextView
                if let fontSize = txt.font?.pointSize {
                    let newSize = fontSize - CGFloat(scaleY) * operatonScale
                    if newSize < 0
                    {
                        return
                    }
                    txt.font = UIFont.systemFont(ofSize: newSize)
                    lblViewInfo.text = "\(type(of: viewControl!)) FontSize: \(newSize)"
                }
            }
        case .border:
            switch neatBorderType{
            case .borderWidth:
                let newWidth = viewControl!.layer.borderWidth  - CGFloat(scaleY) * operatonScale
                if newWidth < 0{
                    return
                }
                viewControl!.layer.borderWidth = newWidth
                lblViewInfo.text = "\(type(of: viewControl!)) BorderWidth: \(newWidth)"
            case.borderColor: break
            case.cornerRadius:
                let newCornerRadius = viewControl!.layer.cornerRadius  - CGFloat(scaleY) * operatonScale
                if newCornerRadius < 0{
                    return
                }
                viewControl!.layer.cornerRadius = newCornerRadius
                lblViewInfo.text = "\(type(of: viewControl!)) CornerRadius: \(newCornerRadius)"
            }
        default: break
        }

    }
    
    override convenience init(frame: CGRect) {
        self.init()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func segClick(_ sender:UISegmentedControl){
        if viewControl == nil{
            Chaos.toast("VIew have released")
            return
        }
        btnColorChooseCompleted?.isHidden = true
        btnColorChooseCompleted?.setTitle("ColorPick", for: UIControlState())
        vColorPicker?.delegate = nil
        vColorPicker?.removeFromSuperview()
        switch sender.selectedSegmentIndex{
            case 0: neatType = .location
            segItemMenu.isHidden = true
            case 1:neatType = .size
            lblViewInfo.text = "\(type(of: viewControl!)) l:\(viewControl!.frame.origin.x) t:\(viewControl!.frame.origin.y) w:\(viewControl!.frame.size.width) h:\(viewControl!.frame.size.height)"
            segItemMenu.isHidden = false
            if segItemMenu.numberOfSegments == 3{
                segItemMenu.removeSegment(at: 2, animated: false)
            }
            segItemMenu.setTitle("LeftTop", forSegmentAt: 0)
            segItemMenu.setTitle("RightBottom", forSegmentAt: 1)
            neatSizeType = .topLeft
            segItemMenu.selectedSegmentIndex = 0
            lblViewInfo.text = "\(type(of: viewControl!)) l:\(viewControl!.frame.origin.x) t:\(viewControl!.frame.origin.y) w:\(viewControl!.frame.size.width) h:\(viewControl!.frame.size.height)"
            case 2:neatType = .font
            segItemMenu.isHidden = true
            if let fontSize = getFont(){
                lblViewInfo.text = "\(type(of: viewControl!)) font:\(fontSize)"
            }
            case 3:neatType = .border
            segItemMenu.isHidden = false
            if segItemMenu.numberOfSegments == 2{
                segItemMenu.insertSegment(withTitle: "Radius", at: 2, animated: false)
            }
            else if segItemMenu.numberOfSegments == 3{
                segItemMenu.setTitle("Radius", forSegmentAt: 2)
            }
            segItemMenu.setTitle("Color", forSegmentAt: 0)
            segItemMenu.setTitle("Border", forSegmentAt: 1)
            segItemMenu.selectedSegmentIndex = 1
            neatBorderType = .borderWidth
            lblViewInfo.text = "\(type(of: viewControl!)) BorderWidth: \(viewControl!.layer.borderWidth)"
            case 4:neatType = .color
            segItemMenu.isHidden = false
            if segItemMenu.numberOfSegments == 3{
                 segItemMenu.setTitle("Tint", forSegmentAt: 2)
            }
            else if (segItemMenu.numberOfSegments == 2)
            {
                segItemMenu.insertSegment(withTitle: "Tint", at: 2, animated: false)
            }
            segItemMenu.setTitle("Fore", forSegmentAt: 0)
            segItemMenu.setTitle("Back", forSegmentAt: 1)
            segItemMenu.selectedSegmentIndex = 1
            neatColorType = .backGround
            btnColorChooseCompleted?.isHidden = false
            if let color = viewControl!.backgroundColor{
                btnColorChooseCompleted?.setTitleColor(color, for: UIControlState())
                currentColor = color
                lblViewInfo.text = "\(type(of: viewControl!)) BackGroundColor: \(color.format("swift"))"
            }
            case 5:neatType = .code
            segItemMenu.isHidden = true
            generateCode()
            default: break
        }

    }
    
    @objc func segItemClick(_ sender:UISegmentedControl){
        if viewControl == nil{
            Chaos.toast("VIew have released")
            return
        }
        btnColorChooseCompleted?.isHidden = true
        btnColorChooseCompleted?.setTitle("ColorPick", for: UIControlState())
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
                btnColorChooseCompleted?.isHidden = false
                if let color = viewControl!.layer.borderColor{
                    btnColorChooseCompleted?.setTitleColor(UIColor(cgColor: color), for: UIControlState())
                    currentColor = UIColor(cgColor: color)
                
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
                    btnColorChooseCompleted?.isHidden = false
                    let btn = viewControl! as! UIButton
                    if let color = btn.titleColor(for: UIControlState()){
                        btnColorChooseCompleted?.setTitleColor(color, for: UIControlState())
                        currentColor = color
                    }
                }
                else if viewControl! is UILabel{
                    btnColorChooseCompleted?.isHidden = false
                    let lbl = viewControl! as! UILabel
                    let color = lbl.textColor
                    btnColorChooseCompleted?.setTitleColor(color, for: UIControlState())
                    currentColor = color!
                }
                else if viewControl! is UITextField{
                    btnColorChooseCompleted?.isHidden = false
                    let txt = viewControl! as! UITextField
                    if   let color = txt.textColor{
                        btnColorChooseCompleted?.setTitleColor(color, for: UIControlState())
                        currentColor = color
                    }
              }
                else if viewControl! is UITextView{
                    btnColorChooseCompleted?.isHidden = false
                    let txt = viewControl! as! UITextView
                    if   let color = txt.textColor{
                        btnColorChooseCompleted?.setTitleColor(color, for: UIControlState())
                        currentColor = color
                    }
                }
                else{
                     Chaos.toast("Only contain text UIView can change foreground color")
                }
            case 1: neatColorType = .backGround
                btnColorChooseCompleted?.isHidden = false
                if let color = viewControl!.backgroundColor{
                    btnColorChooseCompleted?.setTitleColor(color, for: UIControlState())
                    currentColor = color
                    }
            case 2: neatColorType = .tintColor
                    btnColorChooseCompleted?.isHidden = false
                    if let color = viewControl!.tintColor{
                        btnColorChooseCompleted?.setTitleColor(color, for: UIControlState())
                        currentColor = color
                    }
                break
            default:break
                
            }
        default: break
        }
        
    }
    
    func colorSelectedChanged(_ color: UIColor) {
        if viewControl == nil{
            Chaos.toast("VIew have released")
            return
        }
        btnColorChooseCompleted?.setTitleColor(color, for: UIControlState())
        switch neatType{
        case .border:
            switch neatBorderType{
            case.borderColor: viewControl!.layer.borderColor = color.cgColor
            btnColorChooseCompleted?.setTitleColor(color, for: UIControlState())
                lblViewInfo.text = "\(type(of: viewControl!)) CornerRadius: \(color.format("swift"))"
            default : break
            }
        case .color:
            switch neatColorType{
            case .foreGround:
                if viewControl! is UIButton{
                    let btn = viewControl! as! UIButton
                    btn.setTitleColor(color, for: UIControlState())
                    lblViewInfo.text = "\(type(of: viewControl!)) TitleColor: \(color.format("swift"))"
                }
                else if viewControl! is UILabel{
                    let lbl = viewControl! as! UILabel
                   lbl.textColor = color
                    lblViewInfo.text = "\(type(of: viewControl!)) TextColor: \(color.format("swift"))"
                }
                else if viewControl! is UITextField{
                    let txt = viewControl! as! UITextField
                    txt.textColor = color
                    lblViewInfo.text = "\(type(of: viewControl!)) TextColor: \(color.format("swift")))"
                }
                else if viewControl! is UITextView{
                    let txt = viewControl! as! UITextView
                    txt.textColor = color
                    lblViewInfo.text = "\(type(of: viewControl!)) TextColor: \(color.format("swift"))"
                }
            case.backGround:
                viewControl!.backgroundColor = color
                lblViewInfo.text = "\(type(of: viewControl!)) BackGroundColor: \(color.format("swift"))"
            case .tintColor:
                viewControl!.tintColor = color
                lblViewInfo.text = "\(type(of: viewControl!)) TintColor: \(color.format("swift"))"
            }
            break
        default: break
        }
    }
    
    @objc func chooseColor(_ sender:UIButton){
        let title = sender.title(for: UIControlState())
        if title == "ColorPick"{
            vColorPicker = ChaosColorPicker(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 250), color: currentColor)
            vColorPicker?.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.frame.size.height - vColorPicker!.frame.size.height , width: UIScreen.main.bounds.width, height: vColorPicker!.frame.size.height)
            vColorPicker?.delegate = self
            vColorPicker?.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
            self.window?.addSubview(vColorPicker!)
            sender.setTitle("Completed", for: UIControlState())
        }
        else{
             sender.setTitle("ColorPick", for: UIControlState())
            vColorPicker?.delegate = nil
            vColorPicker?.removeFromSuperview()
        }
    }
    
    @objc func precise(_ sender:UIButton){
         let title = sender.title(for: UIControlState())!
        if title == "Precise"{
            sender.setTitle("Imprecise", for: UIControlState())
            timer?.pauseChaosTimer()
            setOperButtonsVisible(true)
            neatPreciseMode = .precise
            scaleX = 0
            scaleY = 0
          //  timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "timerFire:", userInfo: nil, repeats: true)
          //  scale = 1
          //  stepScale.enabled = false
            lblScale.text = "Scale:\(CGFloat(scale) / 10.0)"
            
        }
        else{
            sender.setTitle("Precise", for: UIControlState())
            timer?.resumeChaosTimer()
            setOperButtonsVisible(false)
            neatPreciseMode = .normal
           // timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "timerFire:", userInfo: nil, repeats: true)
           // scale = Int(stepScale.value)
         //   stepScale.enabled = true
            lblScale.text = "Scale:\(scale)"
        }
    }
    
    @objc func scaleChange(_ sender:UIStepper){
        scale = Int(sender.value)
        let showScaleValue = neatPreciseMode == .normal ? CGFloat(scale) : (CGFloat(scale) / 10.0)
      //  lblScale.text = "Scale:\(showScaleValue.format("00.00"))"
          lblScale.text = "Scale:\(showScaleValue)"
    }
    
    @objc func reset(_ sender:UIButton){
        if viewControl != nil{
            viewControl?.frame = originFrame
            if viewControl! is UIButton{
               (viewControl! as! UIButton).titleLabel?.font = originFont
                (viewControl! as! UIButton).setTitleColor(originForegroundColor, for: UIControlState())
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
    
    @objc func close(_ sender:UIButton){
       NotificationCenter.default.post(name: Notification.Name(rawValue: "handleTraceViewClose"), object: nil)
    }
    
    func generateCode(){
        if viewControl == nil{
            Chaos.toast("VIew have released")
            return
        }
        print("\n")
        print("Begin generate Swift code-------------------------------------:")
        var viewName = "view"
        if viewControl!.chaosName != nil{
            viewName = viewControl!.chaosName!
        }
        print("let \(viewName) = \(type(of: viewControl!))()")
        print("\(viewName).frame = CGRect(x: \(viewControl!.frame.origin.x), y: \(viewControl!.frame.origin.y), width: \(viewControl!.frame.size.width), height:\(viewControl!.frame.size.width))")
        if viewControl! is UIButton{
            let btn = viewControl! as! UIButton
            if let fontSize = btn.titleLabel?.font.pointSize.format(".1f")
            {
                print("\(viewName).titleLabel?.font = UIFont.systemFontOfSize(\(fontSize))")
            }
            if let color = btn.titleColor(for: UIControlState())
            {
                print("\(viewName).setTitleColor(\(color.format("swift")), forState: UIControlState.Normal)") //颜色需要format
            }
        }
        else if viewControl! is UILabel{
            let lbl = viewControl! as! UILabel
            print("\(viewName).font = UIFont.systemFontOfSize(\(lbl.font.pointSize.format(".1f")))")
            let color = lbl.textColor
            print("\(viewName).textColor = \(String(describing: color?.format("swift")))") //颜色需要format
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
            print("\(viewName).layer.borderColor = \(UIColor(cgColor: borderColor).format("swift")).CGColor")
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
        print("\(type(of: viewControl!))*  \(viewName) = [\(type(of: viewControl!)) new];")
        print("\(viewName).frame =  CGRectMake(\(viewControl!.frame.origin.x), \(viewControl!.frame.origin.y), \(viewControl!.frame.size.width), \(viewControl!.frame.size.width));")
        if viewControl! is UIButton{
            let btn = viewControl! as! UIButton
            if let fontSize = btn.titleLabel?.font.pointSize.format(".1f")
            {
                print("\(viewName).titleLabel.font = [UIFont systemFontOfSize:\(fontSize)];")
            }
            if let color = btn.titleColor(for: UIControlState())
            {
                print("[\(viewName) setTitleColor:\(color.format("objc")) forState:UIControlStateNormal];") //颜色需要format
            }
        }
        else if viewControl! is UILabel{
            let lbl = viewControl! as! UILabel
            print("\(viewName).font = [UIFont systemFontOfSize:\(lbl.font.pointSize.format(".1f"))];")
            let color = lbl.textColor
            print("\(viewName).textColor = \(String(describing: color?.format("objc")));") //颜色需要format
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
            print("\(viewName).layer.borderColor = \(UIColor(cgColor: borderColor).format("objc")).CGColor;")
        }
        print("\(viewName).layer.borderWidth = \(viewControl!.layer.borderWidth.format("0.1f"));")
        print("\(viewName).layer.cornerRadius = \(viewControl!.layer.cornerRadius.format("0.1f"));")
        if let backColor = viewControl!.backgroundColor{
            print("\(viewName).backgroundColor = \(backColor.format("objc"));")
        }
        print("\(viewName).tintColor = \(viewControl!.tintColor.format("objc"));")
    }
    
    func getFont()->CGFloat?{
        if viewControl! is UIButton{
            let btn = viewControl! as! UIButton
            return btn.titleLabel?.font.pointSize
        }
        else if viewControl! is UILabel{
            let lbl = viewControl! as! UILabel
            return lbl.font.pointSize
        }
        else if viewControl! is UITextField{
            let txt = viewControl! as! UITextField
            return txt.font?.pointSize
        }
        else if viewControl! is UITextView{
            let txt = viewControl! as! UITextView
            return txt.font?.pointSize
        }
        return nil
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        vColorPicker?.delegate = nil
        vColorPicker?.removeFromSuperview()
    }
}

extension Timer{
    func pauseChaosTimer(){ //这样可以尽量不导致冲突
        if !self.isValid
        {
            return
        }
        self.fireDate = Date.distantFuture
    }
    
    func resumeChaosTimer(){
        if !self.isValid
        {
            return
        }
        self.fireDate = Date()
    }
}
extension UIColor{
    func format(_ type:String)->String{
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
        else if type == "str"{
            let r = Int(red * 255)
            let g = Int(green * 255)
            let b = Int(blue * 255)
            let a = Int(alpha * 255)
            var ax = String(format: "%0X", a) as NSString
            if ax.length == 1
            {
                ax = "0\(ax)" as NSString
            }
            var rx = String(format: "%0X", r) as NSString
            if rx.length == 1
            {
                rx = "0\(rx)" as NSString
            }
            var gx = String(format: "%0X", g) as NSString
            if gx.length == 1
            {
                gx = "0\(gx)" as NSString
            }
            var bx = String(format: "%0X", b) as NSString
            if bx.length == 1
            {   
                bx = "0\(bx)" as NSString
            }
            return "#\(rx)\(gx)\(bx)--R\(r) G\(g) B\(b)"
           // return String(format: "%0X", num)
         }
         else{
            return self.description
        }
    }
    
    var alpha:Int{
        var red:CGFloat = 0.0
        var green:CGFloat = 0.0
        var blue:CGFloat = 0.0
        var a:CGFloat = 0.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &a)
        return Int(a * 255)
    }
    
}



