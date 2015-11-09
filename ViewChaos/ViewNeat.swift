//
//  ViewNeat.swift
//  ViewChaosDemo
//
//  Created by Tyrant on 11/9/15.
//  Copyright © 2015 Qfq. All rights reserved.
//

import UIKit
enum Neat:Int{
    case location = 0,size
}
class ViewNeat: UIView {
    var btnLocation:UIButton
    var btnSize:UIButton
    var viewControl:UIView?
    var vFont:UIView
    var vBorder:UIView
    var vColor:UIView
    var isTouch = false
    var neatType:Neat = .location
    var vRockerArea:UIView
    var vRocker: UIView
    var left,top:Float  //右 上
    var scaleX = 1
    var scaleY = 1
    var lblTopLeft:UILabel
    var lblRightBotoom:UILabel
    var timer:NSTimer?
    init(){
        btnLocation = UIButton()
        btnSize = UIButton()
        vFont = UIView()
        vBorder = UIView()
        vColor = UIView()
        vRockerArea = UIView()
        vRocker = UIView()
        lblTopLeft  = UILabel()
        lblRightBotoom = UILabel()
        left = 0
        top = 0
        super.init(frame:CGRect(x: 10, y: UIScreen.mainScreen().bounds.height - 150, width: UIScreen.mainScreen().bounds.width-20, height: 150))
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "timerFire:", userInfo: nil, repeats: true)
        btnLocation.frame = CGRect(x: 10, y: 100, width: 40, height: 40)
        btnLocation.layer.cornerRadius = 20
        btnLocation.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5)
        btnLocation.setTitle("位置", forState: UIControlState.Normal)
        btnLocation.addTarget(self, action: "showLocation:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(btnLocation)
        
        
        vRockerArea.frame = CGRect(x: self.frame.size.width / 2 - 50, y: 0, width: 100, height: 100)
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
        
        btnSize.frame = CGRect(x: 70, y: 100, width: 40, height: 40)
        btnSize.layer.cornerRadius = 20
        btnSize.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5)
        btnSize.setTitle("大小", forState: UIControlState.Normal)
        btnSize.addTarget(self, action: "showSize:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(btnSize)
        

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
                                Chaos.Log("scaleX:\(scaleX)  scaleY:\(scaleY)")
                        viewControl!.frame = CGRect(x: viewControl!.frame.origin.x + CGFloat(scaleX) * 0.5, y: viewControl!.frame.origin.y + CGFloat(scaleY) * 0.5, width: viewControl!.frame.size.width, height: viewControl!.frame.size.height)
                case .size: break
                }
            }
        }
    
    override convenience init(frame: CGRect) {
        self.init()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showLocation(sender:UIButton){
        neatType = .location
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
