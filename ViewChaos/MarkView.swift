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
            let frameObject = FrameObject(frame: sub.frame, attachedView: sub, topInjectedObjs: nil, leftInjectedObjs: nil)
            arrViewFrameObjs.append(frameObject)
        }
        var arrLines = [Line]()
        for sourceFrameObj in arrViewFrameObjs{
            for targetFrameObj in arrViewFrameObjs{
                if sourceFrameObj.attachedView is AbstractView && targetFrameObj.attachedView is AbstractView {
                    continue
                }
                
            }
        }
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
        let handle = 0
        
        
        
        return nil
    }
    
    
    static func approperiatePoint(interval1:Interval,interval2:Interval, handle:inout CGFloat)->CGFloat{
        var MINHandleValue:CGFloat = 20
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
        
        return 0
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
