//
//  MarkView.swift
//  ViewChaosDemo
//
//  Created by Stan Hu on 5/7/2017.
//  Copyright © 2017 Qfq. All rights reserved.
//

import UIKit
class MarkView {
    static func showingTaggingView(view:UIView){
        registerBorderTestView(view: view)
        var arrViewFrameObjs = [FrameObject]()
        let subViews = view.subviews
        for sub in subViews{
            if !(sub is AbstractView ){
                if sub.alpha < 0.01 {
                    continue
                }
                if sub.frame.size.width < 2 {
                    continue
                }
            }
            let frameObject = FrameObject(frame: sub.frame, attachedView: sub)
            arrViewFrameObjs.append(frameObject)
        }
        var arrLines = [Line]()
        for sourceFrameObj in arrViewFrameObjs{
            for var targetFrameObj in arrViewFrameObjs{
                if sourceFrameObj.attachedView is AbstractView && targetFrameObj.attachedView is AbstractView {
                    continue
                }
                let hLine = horizontalLine(frameObj1: sourceFrameObj, frameObj2: targetFrameObj)
                if hLine != nil {
                    arrLines.append(hLine!)
                    targetFrameObj.leftInjectedObjs.append(hLine!)
                }
                let vLine = verticalLine(frameObj1: sourceFrameObj, frameObj2: targetFrameObj)
                if vLine != nil{
                    arrLines.append(vLine!)
                    targetFrameObj.topInjectedObjs.append(vLine!)
                }
            }
        }
        
        // 查找重复的射入line
        // hLine:Y的差值小于某个值，leftInjectedObjs->取最小一条
        // vLine:X的差值小于某个值，topInjectedObjs->取最小一条
        let minValue:CGFloat = 5
        for var obj in arrViewFrameObjs{
                // 排序：Y值：从大到小
                obj.leftInjectedObjs =  obj.leftInjectedObjs.sorted{$0.point1.point.y > $1.point1.point.y}
                var i = 0
                var baseLine:Line?
                var compareLine:Line?
                if obj.leftInjectedObjs.count > 0{
                    baseLine = obj.leftInjectedObjs[i]
                }
                while i < obj.leftInjectedObjs.count{
                    if i + 1 < obj.leftInjectedObjs.count{
                        compareLine = obj.leftInjectedObjs[i+1]
                        if abs(baseLine!.point1.point.y - compareLine!.point1.point.y) < minValue{
                            if baseLine!.lineWidth > compareLine!.lineWidth{
                                arrLines.removeWith(condition: { (l) -> Bool in
                                    l == baseLine!
                                })
                                baseLine = compareLine
                            }
                            else{
                                arrLines.removeWith(condition: { (l) -> Bool in
                                    l == compareLine!
                                })
                            }
                           
                        }
                        else{
                            baseLine = compareLine
                        }
                    }
                    i = i + 1
                }
   
            
             obj.topInjectedObjs =  obj.topInjectedObjs.sorted{$0.point1.point.y > $1.point1.point.y}
            
            var j = 0
            var baseLine2:Line?
            var compareLine2:Line?
            if obj.topInjectedObjs.count > 0 {
                baseLine2 = obj.topInjectedObjs[0]
            }
            while j < obj.topInjectedObjs.count {
                if j+1 < obj.topInjectedObjs.count{
                    compareLine2 = obj.topInjectedObjs[j+1]
                    if abs(baseLine2!.point1.point.x - compareLine2!.point1.point.x) < minValue{
                        if baseLine2!.lineWidth > compareLine2!.lineWidth {
                            arrLines.removeWith(condition: { (l) -> Bool in
                                l == baseLine2!
                            })
                            baseLine2 = compareLine2
                        }
                        else{
                            arrLines.removeWith(condition: { (l) -> Bool in
                                l == compareLine2!
                            })
                        }
                    }
                    else{
                        baseLine2 = compareLine2
                    }
                }
                j = j + 1
            }
            
        }
        let taggintView = TaggingView(frame: view.bounds, lines: arrLines)
        view.addSubview(taggintView)
    }
    
    
    static func verticalLine(frameObj1:FrameObject,frameObj2:FrameObject)->Line?{
        if frameObj1.frame.origin.y + frameObj1.frame.size.height >= frameObj2.frame.origin.y{
            return nil
        }
        if abs(frameObj1.frame.origin.y + frameObj1.frame.size.height - frameObj2.frame.origin.y) < 5{
            return nil
        }
        let obj1BottomY = frameObj1.frame.origin.y + frameObj1.frame.size.height
        let obj1Width = frameObj1.frame.size.width
        let obj2TopY = frameObj2.frame.origin.y
        let obj2Width = frameObj2.frame.size.width
        var handle:CGFloat = 0
        let pointX = approperiatePoint(interval1: Interval(start:frameObj1.frame.origin.x,length:obj1Width), interval2: Interval(start:frameObj2.frame.origin.x,length:obj2Width), handle: &handle)
        let line = Line(point1: ShortPoint(x:pointX,y:obj1BottomY,handle:handle), point2: ShortPoint(x:pointX,y:obj2TopY,handle:handle))
        return line
    }
    
    static func horizontalLine(frameObj1:FrameObject,frameObj2:FrameObject)->Line?{
        if abs(frameObj1.frame.origin.x  - frameObj2.frame.origin.x) < 3 {
            return nil
        }
        // frameObj2整体在frameObj1右边
        if frameObj1.frame.origin.x + frameObj1.frame.size.width > frameObj2.frame.origin.x {
            return nil
        }
        let obj1RightX = frameObj1.frame.origin.x + frameObj1.frame.size.width
        let obj1Height = frameObj1.frame.size.height
        let obj2LeftX = frameObj2.frame.origin.x
        let obj2Height = frameObj2.frame.size.height
        var handle:CGFloat = 0
        let pointY = approperiatePoint(interval1: Interval(start:frameObj1.frame.origin.y,length:obj1Height), interval2: Interval(start:frameObj2.frame.origin.y,length:obj2Height), handle: &handle)
        let line = Line(point1: ShortPoint(x:obj1RightX,y:pointY,handle:handle), point2: ShortPoint(x:obj2LeftX,y:pointY,handle:handle))
        return line
    }
    
    
    static func approperiatePoint(interval1:Interval,interval2:Interval, handle:inout CGFloat)->CGFloat{
        let MINHandleValue:CGFloat = 20
        var pointValue:CGFloat = 0
        var handleValue:CGFloat = 0
        var bigInterval = interval1
        var smallInterval = interval2
        if interval1.length < interval2.length {
            bigInterval = interval2
            smallInterval = interval1
        }
        if smallInterval.start < bigInterval.start && smallInterval.start + smallInterval.length < bigInterval.start {
            let tmpHandleValue = bigInterval.start - smallInterval.start + smallInterval.length
            pointValue = bigInterval.start - tmpHandleValue / 2
            handleValue = max(tmpHandleValue, MINHandleValue)
        }
        
        if (smallInterval.start < bigInterval.start && smallInterval.start+smallInterval.length >= bigInterval.start) {
            let tmpHandleValue = smallInterval.start+smallInterval.length - bigInterval.start;
            pointValue = bigInterval.start + tmpHandleValue/2;
            handleValue = max(tmpHandleValue, MINHandleValue);
        }
        
        if (smallInterval.start >= bigInterval.start && smallInterval.start+smallInterval.length <= bigInterval.start+bigInterval.length) {
            let tmpHandleValue = smallInterval.length;
            pointValue = smallInterval.start + tmpHandleValue/2;
            handleValue = max(tmpHandleValue, MINHandleValue);
        }
        
        if (smallInterval.start >= bigInterval.start && smallInterval.start+smallInterval.length > bigInterval.start+bigInterval.length) {
            let tmpHandleValue = bigInterval.start+bigInterval.length - smallInterval.start;
            pointValue = bigInterval.start + tmpHandleValue/2;
            handleValue = max(tmpHandleValue, MINHandleValue);
        }
        
        if (smallInterval.start >= bigInterval.start+bigInterval.length && smallInterval.start+smallInterval.length > bigInterval.start+bigInterval.length) {
            let tmpHandleValue = smallInterval.start - (bigInterval.start+bigInterval.length);
            pointValue = smallInterval.start - tmpHandleValue/2;
            handleValue = max(tmpHandleValue, MINHandleValue);
        }
        handle = handleValue
        return pointValue
    }
    
    static func registerBorderTestView(view:UIView){
        let minWh = 1.0 / UIScreen.main.scale
        let leftBorderView  = BorderAttachView(frame: CGRect(x: 0, y: 0, width: minWh, height: view.bounds.size.height))
        let rightBoaderView = BorderAttachView(frame: CGRect(x: view.bounds.size.width - minWh, y: 0, width: minWh, height: view.bounds.size.height))
        let topBorderView = BorderAttachView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: minWh))
        let bottomBorderView = BorderAttachView(frame: CGRect(x: 0, y: view.bounds.size.height - minWh, width: view.bounds.size.height, height: minWh))
        view.addSubview(leftBorderView)
        view.addSubview(rightBoaderView)
        view.addSubview(topBorderView)
        view.addSubview(bottomBorderView)
    }
}
