//
//  DrawView.swift
//  ViewChaosDemo
//
//  Created by HuStan on 3/26/16.
//  Copyright © 2016 Qfq. All rights reserved.
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

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

enum DrawMode {
    case draw,capture
}
class DrawView: UIView {

    var btnCaptureScreen = UIButton()
    var btnCleanTrace = UIButton()
    var drawMode = DrawMode.draw
    var pointOrigin = CGPoint.zero
    var pointLast = CGPoint.zero
    fileprivate var arrTraces:Array<Trace>?
    override init(frame: CGRect) {
        super.init(frame: frame)
        arrTraces = [Trace]()
        self.frame = UIScreen.main.bounds
        self.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.2)
        btnCaptureScreen.frame = CGRect(x: UIScreen.main.bounds.size.width - 90, y: UIScreen.main.bounds.size.height - 25, width: 90, height: 25)
        btnCaptureScreen.backgroundColor =  UIColor(red: 0.0, green: 0.898, blue: 0.836, alpha: 0.5)
        btnCaptureScreen.setTitle("启用截屏", for: UIControlState())
        btnCaptureScreen.addTarget(self, action: #selector(DrawView.captureScreenClick(_:)), for: UIControlEvents.touchUpInside)
        addSubview(btnCaptureScreen)
        
        btnCleanTrace.frame = CGRect(x: UIScreen.main.bounds.size.width - 150, y: UIScreen.main.bounds.size.height - 25, width: 50, height: 25)
        btnCleanTrace.backgroundColor =  UIColor(red: 0.0, green: 0.898, blue: 0.836, alpha: 0.5)
        btnCleanTrace.setTitle("清理", for: UIControlState())
        btnCleanTrace.addTarget(self, action: #selector(DrawView.clearTraceClick(_:)), for: UIControlEvents.touchUpInside)
        addSubview(btnCleanTrace)
        btnCleanTrace.isHidden = true
    }
    
    
    
    func captureScreenClick(_ sender:UIButton)  {
        //这里用截图功能
        if let title = sender.title(for: UIControlState())
        {
            if title == "启用截屏"{
            Chaos.toast("现在开始截图")
            drawMode = .capture
                self.backgroundColor = UIColor.clear
                btnCaptureScreen.setTitle("保存", for: UIControlState())
            }
            else{
                UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, true, 0)//这个应该是设定一个区域
                UIApplication.shared.keyWindow!.layer.render(in: UIGraphicsGetCurrentContext()!)//将整个View渲染到Context里
                let  imgCapture = UIGraphicsGetImageFromCurrentImageContext()
                UIImageWriteToSavedPhotosAlbum(imgCapture!, self, nil, nil)
                self.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.2)
                Chaos.toast("保存截图成功")
                btnCaptureScreen.setTitle("启用截屏", for: UIControlState())
                clearTrace()
                drawMode = .draw
            }
         }
    }
    
  
    
    func clearTraceClick(_ sender:UIButton){
        clearTrace()
        btnCaptureScreen.setTitle("启用截屏", for: UIControlState())
        drawMode = .draw
    }
    
    func clearTrace() {
        arrTraces?.removeAll()
        btnCleanTrace.isHidden = true
        pointOrigin = CGPoint.zero
        pointLast = CGPoint.zero
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
       
        super.draw(rect)
        let ctg = UIGraphicsGetCurrentContext()
        ctg?.clear(rect)
        ctg?.setLineWidth(1)
        ctg?.setLineJoin(CGLineJoin.round)
        ctg?.setLineCap(CGLineCap.round)
        //画当前的线
        if arrTraces?.count > 0
        {
            ctg?.beginPath()
            var i = 0
            while i < arrTraces?.count {
                var tempTrace = arrTraces![i]
                if tempTrace.arrPoints.count > 0
                {
                    ctg?.beginPath()
                    var point = tempTrace.arrPoints[0]
                    ctg?.move(to: CGPoint(x: point.x, y: point.y))
                    let count:Int! = tempTrace.arrPoints.count
                    for j in 0 ..< count-1
                    {
                        point = tempTrace.arrPoints[j+1]
                        ctg?.addLine(to: CGPoint(x: point.x, y: point.y))
                    }
                    ctg?.setStrokeColor(tempTrace.color.cgColor)
                    let width:CGFloat!  = tempTrace.thickness
                    ctg?.setLineWidth(width)
                    ctg?.strokePath()
                }
                i += 1
            }
        }
        
        if drawMode == .capture{
            ctg?.setFillColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.3).cgColor)
            ctg?.setStrokeColor(UIColor.red.cgColor)
//            let dash:UnsafeMutablePointer<CGFloat> = UnsafeMutablePointer<CGFloat>.alloc(2)
//            dash.initialize(1)
//            dash.successor().initialize(1)
//            
//            CGContextSetLineDash(ctg, 0, dash, 2)
            ctg?.stroke(CGRect(x: pointOrigin.x, y: pointOrigin.y, width: pointLast.x - pointOrigin.x, height: pointLast.y - pointOrigin.y))
            ctg?.fill(CGRect(x: pointOrigin.x, y: pointOrigin.y, width: pointLast.x - pointOrigin.x, height: pointLast.y - pointOrigin.y))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if drawMode == .draw{
            for touch in touches
            {
                 let  touchPoint:UITouch = touch
                let point = touchPoint.location(in: self)
                var trace = Trace()
                trace.arrPoints = Array<CGPoint>()
                trace.arrPoints.append(point)
                trace.color = UIColor.red
                trace.thickness = 1
                arrTraces?.append(trace)
                self.setNeedsDisplay()
            }
         
        }
        else{
            if  let touch = touches.first{
                pointOrigin = touch.location(in: self)
            }
        }
        btnCleanTrace.isHidden = false
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if drawMode == .draw{
            for touch in touches
            {
                let  touchPoint:UITouch = touch
                let point = touchPoint.location(in: self)
                //怎么找到上一个Point
                let previousPoint = touchPoint.previousLocation(in: self)
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
        else{
            if let touch = touches.first{
                pointLast = touch.location(in: self)
                setNeedsDisplay()
            }
        }
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
struct Trace {
    fileprivate var  _arrPoints:Array<CGPoint>?
    fileprivate var _color:UIColor = UIColor.white
    fileprivate var _thickness:CGFloat = 1
    
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
