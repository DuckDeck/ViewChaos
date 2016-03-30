//
//  DrawView.swift
//  ViewChaosDemo
//
//  Created by HuStan on 3/26/16.
//  Copyright © 2016 Qfq. All rights reserved.
//

import UIKit
enum DrawMode {
    case Draw,Capture
}
class DrawView: UIView {

    var btnCaptureScreen = UIButton()
    var btnCleanTrace = UIButton()
    var drawMode = DrawMode.Draw
    var pointOrigin = CGPointZero
    var pointLast = CGPointZero
    private var arrTraces:Array<Trace>?
    override init(frame: CGRect) {
        super.init(frame: frame)
        arrTraces = [Trace]()
        self.frame = UIScreen.mainScreen().bounds
        self.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.2)
        btnCaptureScreen.frame = CGRect(x: UIScreen.mainScreen().bounds.size.width - 90, y: UIScreen.mainScreen().bounds.size.height - 25, width: 90, height: 25)
        btnCaptureScreen.backgroundColor =  UIColor(red: 0.0, green: 0.898, blue: 0.836, alpha: 0.5)
        btnCaptureScreen.setTitle("启用截屏", forState: UIControlState.Normal)
        btnCaptureScreen.addTarget(self, action: #selector(DrawView.captureScreenClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(btnCaptureScreen)
        
        btnCleanTrace.frame = CGRect(x: UIScreen.mainScreen().bounds.size.width - 150, y: UIScreen.mainScreen().bounds.size.height - 25, width: 50, height: 25)
        btnCleanTrace.backgroundColor =  UIColor(red: 0.0, green: 0.898, blue: 0.836, alpha: 0.5)
        btnCleanTrace.setTitle("清理", forState: UIControlState.Normal)
        btnCleanTrace.addTarget(self, action: #selector(DrawView.clearTraceClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(btnCleanTrace)
        btnCleanTrace.hidden = true
    }
    
    
    
    func captureScreenClick(sender:UIButton)  {
        //这里用截图功能
        if let title = sender.titleForState(UIControlState.Normal)
        {
            if title == "启用截屏"{
            Chaos.toast("现在开始截图")
            drawMode = .Capture
                self.backgroundColor = UIColor.clearColor()
                btnCaptureScreen.setTitle("保存", forState: UIControlState.Normal)
            }
            else{
                UIGraphicsBeginImageContextWithOptions(UIScreen.mainScreen().bounds.size, true, 0)//这个应该是设定一个区域
                UIApplication.sharedApplication().keyWindow!.layer.renderInContext(UIGraphicsGetCurrentContext()!)//将整个View渲染到Context里
                let  imgCapture = UIGraphicsGetImageFromCurrentImageContext()
                UIImageWriteToSavedPhotosAlbum(imgCapture, self, nil, nil)
                self.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.2)
                Chaos.toast("保存截图成功")
                btnCaptureScreen.setTitle("启用截屏", forState: UIControlState.Normal)
                clearTrace()
                drawMode = .Draw
            }
         }
    }
    
  
    
    func clearTraceClick(sender:UIButton){
        clearTrace()
        btnCaptureScreen.setTitle("启用截屏", forState: UIControlState.Normal)
        drawMode = .Draw
    }
    
    func clearTrace() {
        arrTraces?.removeAll()
        btnCleanTrace.hidden = true
        pointOrigin = CGPointZero
        pointLast = CGPointZero
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
       
        super.drawRect(rect)
        let ctg = UIGraphicsGetCurrentContext()
        CGContextClearRect(ctg, rect)
        CGContextSetLineWidth(ctg, 1)
        CGContextSetLineJoin(ctg, CGLineJoin.Round)
        CGContextSetLineCap(ctg, CGLineCap.Round)
        //画当前的线
        if arrTraces?.count > 0
        {
            CGContextBeginPath(ctg)
            var i = 0
            while i < arrTraces?.count {
                var tempTrace = arrTraces![i]
                if tempTrace.arrPoints.count > 0
                {
                    CGContextBeginPath(ctg)
                    var point = tempTrace.arrPoints[0]
                    CGContextMoveToPoint(ctg, point.x, point.y)
                    let count:Int! = tempTrace.arrPoints.count
                    for j in 0 ..< count-1
                    {
                        point = tempTrace.arrPoints[j+1]
                        CGContextAddLineToPoint(ctg, point.x, point.y)
                    }
                    CGContextSetStrokeColorWithColor(ctg, tempTrace.color.CGColor)
                    let width:CGFloat!  = tempTrace.thickness
                    CGContextSetLineWidth(ctg, width)
                    CGContextStrokePath(ctg)
                }
                i += 1
            }
        }
        
        if drawMode == .Capture{
            CGContextSetFillColorWithColor(ctg, UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.3).CGColor)
            CGContextSetStrokeColorWithColor(ctg, UIColor.redColor().CGColor)
//            let dash:UnsafeMutablePointer<CGFloat> = UnsafeMutablePointer<CGFloat>.alloc(2)
//            dash.initialize(1)
//            dash.successor().initialize(1)
//            
//            CGContextSetLineDash(ctg, 0, dash, 2)
            CGContextStrokeRect(ctg, CGRect(x: pointOrigin.x, y: pointOrigin.y, width: pointLast.x - pointOrigin.x, height: pointLast.y - pointOrigin.y))
            CGContextFillRect(ctg, CGRect(x: pointOrigin.x, y: pointOrigin.y, width: pointLast.x - pointOrigin.x, height: pointLast.y - pointOrigin.y))
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if drawMode == .Draw{
            for touch in touches
            {
                if let  touchPoint:UITouch = touch
                {
                    let point = touchPoint.locationInView(self)
                    var trace = Trace()
                    trace.arrPoints = Array<CGPoint>()
                    trace.arrPoints.append(point)
                    trace.color = UIColor.redColor()
                    trace.thickness = 1
                    arrTraces?.append(trace)
                }
                self.setNeedsDisplay()
            }
         
        }
        else{
            if  let touch = touches.first{
                pointOrigin = touch.locationInView(self)
            }
        }
        btnCleanTrace.hidden = false
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        if drawMode == .Draw{
            for touch in touches
            {
                if let  touchPoint:UITouch = touch
                {
                    let point = touchPoint.locationInView(self)
                    //怎么找到上一个Point
                    let previousPoint = touchPoint.previousLocationInView(self)
                    var i = 0
                    while i < arrTraces?.count {
                        var tempTraces = arrTraces![i]
                        let lastPoint = tempTraces.arrPoints.last
                        if lastPoint == previousPoint
                        {
                            arrTraces![i].arrPoints.append(point)
                            break
                        }
                        i += 1
                    }
                    self .setNeedsDisplay()
                }
            }
        }
        else{
            if let touch = touches.first{
                pointLast = touch.locationInView(self)
                setNeedsDisplay()
            }
        }
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
struct Trace {
    private var  _arrPoints:Array<CGPoint>?
    private var _color:UIColor = UIColor.whiteColor()
    private var _thickness:CGFloat = 1
    
    var arrPoints:Array<CGPoint>{
        mutating get{
            if _arrPoints == nil
            {
                _arrPoints = Array<CGPoint>()
            }
            return _arrPoints!
        }
        set{
            _arrPoints = newValue
        }
    }
    
    var color:UIColor{
        get{
            return _color
        }
        set{
            _color = newValue
        }
    }
    
    var thickness:CGFloat{
        get{
            return _thickness
        }
        set{
            _thickness = newValue
        }
    }
}