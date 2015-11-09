//
//  ViewNeat.swift
//  ViewChaosDemo
//
//  Created by Tyrant on 11/9/15.
//  Copyright © 2015 Qfq. All rights reserved.
//

import UIKit

class ViewNeat: UIView {
    var btnLocation:UIButton
    var btnSize:UIButton
    var viewControl:UIView?
    var vLocaton:UIView
    var vSize:UIView
    var vFont:UIView
    var vBorder:UIView
    var vColor:UIView
    var isTouch = false
    var vRocker: UIView
    var left,top:Float  //右 上
    init(){
        btnLocation = UIButton()
        btnSize = UIButton()
        vLocaton = UIView()
        vSize = UIView()
        vFont = UIView()
        vBorder = UIView()
        vColor = UIView()
        vRocker = UIView()
        left = 0
        top = 0
        super.init(frame:CGRect(x: 10, y: UIScreen.mainScreen().bounds.height - 150, width: UIScreen.mainScreen().bounds.width-20, height: 150))
        btnLocation.frame = CGRect(x: 10, y: 100, width: 40, height: 40)
        btnLocation.layer.cornerRadius = 20
        btnLocation.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5)
        btnLocation.setTitle("位置", forState: UIControlState.Normal)
        btnLocation.addTarget(self, action: "showLocation:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(btnLocation)
        
        vLocaton.frame = CGRectMake(10, 0, UIScreen.mainScreen().bounds.width-20, 100)
        addSubview(vLocaton)

        vRocker.frame  =  CGRect(x: UIScreen.mainScreen().bounds.width / 2 - 20, y: 40, width: 40, height: 40)
        vRocker.layer.borderColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5).CGColor
        vRocker.layer.borderWidth = 0.5
        vRocker.layer.cornerRadius = 20
        vRocker.backgroundColor = UIColor.redColor()
        addSubview(vRocker)
        
        
        
        
        
        

        
        
        
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first
//        let point = touch?.locationInView(self)
//        left = Float(point!.x)
//        top = Float(point!.y)
        if let point =  touch?.locationInView(vRocker)
        {
            if point.x > 0 && point.x < vRocker.frame.size.width && point.y > 0 && point.y < vRocker.frame.size.height{
                isTouch = true
                left = Float(point.x)
                top = Float(point.y)
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !isTouch
        {
            return
        }
        let touch = touches.first
        if let point = touch?.locationInView(self){
        //限定在一个圆形范围内
            let x = point.x - self.center.x
            let y = point.y - self.center.y
            if x * x + y*y >= 100{
                return
            }
            self.frame = CGRect(x: point.x - CGFloat(left), y: point.y - CGFloat(top), width: self.frame.size.width, height: self.frame.size.height)
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        isTouch = false
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isTouch = false
    }
    

    override convenience init(frame: CGRect) {
        self.init()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showLocation(sender:UIButton){
        
    }


}
