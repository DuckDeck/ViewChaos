//
//  MarkView.swift
//  ViewChaosDemo
//
//  Created by Stan Hu on 5/7/2017.
//  Copyright © 2017 Qfq. All rights reserved.
//



import UIKit


private var UIView_IsMarked = 0
extension UIView{
      var isMarked:Bool?{
        get{
            return objc_getAssociatedObject(self, &UIView_IsMarked) as? Bool
        }
        set{
            objc_setAssociatedObject(self, &UIView_IsMarked, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

class MarkView {
    static func removeTaggView(view:UIView){
        for v in view.subviews{
            if v is AbstractView{
                v.removeFromSuperview()
            }
        }
    }
    
    static func isMarked(view:UIView)->Bool{
        for v in view.subviews{
            if v is AbstractView {
                return true
            }
        }
        return false
    }
    
    static func recursiveRemoveTagView(view:UIView){
        removeTaggView(view: view)
        view.isMarked = false
        for v in view.subviews{
            recursiveRemoveTagView(view: v)
        }
    }
    
    static func recursiveShowTagView(view:UIView){
        if !(view is AbstractView) && !(view is UIWindow) {
            showTaggingView(view: view)
        }
        for v in view.subviews{
            recursiveShowTagView(view: v)
        }
    }
    
    static func isAreadyShowTag(view:UIView)->Bool{
        for sub in view.subviews{
            if sub is AbstractView{
                return true
            }
        }
        return false
    }
    
    static func showSuperTaggingView(view:UIView){
        guard let superView = view.superview else {
            return
        }
        //issue13 这里不能就这样直接调用这个方法，因为会获取下面在其他view.需要写特定的方法
        if isAreadyShowTag(view: superView){
            return
        }
      //  showTaggingView(view: superView)
        showTaggingView(view: superView, withView: view)
    }
    
    static func removeSuperTaggingView(view:UIView){
        guard let superView = view.superview else {
            return
        }
        superView.isMarked = false
       recursiveRemoveTagView(view: superView)
    }

    static func removeSingleTaggingView(view:UIView){
        guard let supView = view.superview else {
            return
        }
        //这个地方会有一占麻烦
        var taggintView:TaggingView?
        for s in supView.subviews{
            if s is TaggingView{
                taggintView  = s as? TaggingView
                break
            }
        }
        if taggintView == nil {
            return
        }
        if taggintView!.lines == nil{
            return
        }
        taggintView!.lines!.removeWith { (l) -> Bool in
            if let fm = l.belongToFrame{
               return  fm.equalTo(view.frame)
            }
            return false
        }
        if taggintView!.lines!.count <= 0{
            removeTaggView(view: supView)
        }
        else{
            taggintView?.setNeedsDisplay()
        }
        
        view.isMarked = false
    }
    
    static func showSingleTaggingView(view:UIView)  {
        if let m = view.isMarked{
            if m{
                return  //这样内存占用少了很多
            }
        }
        guard let supView = view.superview else {
            return
        }
        //这样会添加很多view
        
        var isHaveRegistered = false
        for s in supView.subviews{
            if s is AbstractView{
                isHaveRegistered = true
                break
            }
        }
        if !isHaveRegistered{
            registerBorderTestView(view: supView)
        }
        
        //要断送这个view有没有票标记过
        var arrViewFrameObjs = [FrameObject]()
        for sub in supView.subviews{
            if !(sub is AbstractView ){
                if sub.alpha < 0.01 {
                    continue
                }
                if sub.frame.size.width < 2 {
                    continue
                }
                if sub != view {
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
                var hLine = horizontalLine(frameObj1: sourceFrameObj, frameObj2: targetFrameObj)
                //判断两个view之间有没有中间view, 可以从这根水平线入手
                if hLine != nil {
                    hLine?.belongToFrame = sourceFrameObj.frame.size.width < 1 ? targetFrameObj.frame : sourceFrameObj.frame
                    arrLines.append(hLine!)
                    targetFrameObj.leftInjectedObjs.append(hLine!)
                }
                var vLine = verticalLine(frameObj1: sourceFrameObj, frameObj2: targetFrameObj)
                if vLine != nil{
                     vLine?.belongToFrame = sourceFrameObj.frame.size.height < 1 ? targetFrameObj.frame : sourceFrameObj.frame
                    arrLines.append(vLine!)
                   
                    targetFrameObj.topInjectedObjs.append(vLine!)
                }
            }
        }
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
        //Issue 15 每占一次全添加一个view ,点太多了会让TaggingView太多占太多的内存
        //所以先要找出这个view再重新绘制
        var taggintView:TaggingView?
        for s in supView.subviews{
            if s is TaggingView{
                taggintView  = s as? TaggingView
                break
            }
        }
        if taggintView == nil {
             taggintView = TaggingView(frame: supView.bounds, lines: arrLines)
            taggintView?.attachedView = taggintView
        }
        else{
            taggintView?.addLines(arrLines)
        }
        
        supView.addSubview(taggintView!)
        view.isMarked = true
    }

    
   static func showTaggingView(view:UIView,withView:UIView)  {
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
                //如果没有相邻，就不要加入
                if isNotAdjoin(view1: withView, view2: sub) {
                    continue
                }
            }
            //获取到附近关系是个很关键的点
            
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
                //判断两个view之间有没有中间view, 可以从这根水平线入手
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
        taggintView.attachedView = view
//        taggintView.isUserInteractionEnabled = true
//        let tap = UITapGestureRecognizer(target: self, action: #selector(MarkView.doubleTap(gesture:)))
//        tap.numberOfTapsRequired = 2
//        taggintView.addGestureRecognizer(tap)
    //暂时不要这个功能
        view.addSubview(taggintView)
    }
    
    //并不是看最近，而是看中间有没有view档住，这个会比较 麻烦
    //返回一个值，看两个view之间有没有其他的view,有表示true 没有表示false
    static func isNotAdjoin(view1:UIView,view2:UIView) ->Bool{
        if view1.superview != view2.superview{
            return true
        }
        if view1 is AbstractView || view2 is AbstractView{
            return false
        }
        let fm1 = view1.frame
        let fm2 = view2.frame
        let rectCenter = CGRect(x: fm1.center.x < fm2.center.x ? fm1.center.x : fm2.center.x, y: fm1.center.y < fm2.center.y ? fm1.center.y : fm2.center.y,
                                width: abs(fm2.center.x - fm1.center.x), height: abs(fm2.center.y - fm1.center.y))
        for sub in view1.superview!.subviews{
            if sub == view1 || sub == view2{
                continue
            }
            if sub is AbstractView {
                continue
            }
            let midFrame = sub.frame
            //看fm1和fm2中间有没有midFrame
            //这里的算法不太好搞
            if (rectCenter.contains(midFrame.leftCenter)||rectCenter.contains(midFrame.rightCenter)||rectCenter.contains(midFrame.topCenter)||rectCenter.contains(midFrame.bottomCenter)) {
                return true
            }
            else{
                return false
            }
        }
        return false
    }
    
    static func showTaggingView(view:UIView){
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
                 //判断两个view之间有没有中间view, 可以从这根水平线入手
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
        taggintView.attachedView = view
//        taggintView.isUserInteractionEnabled = true
//        let tap = UITapGestureRecognizer(target: self, action: #selector(MarkView.doubleTap(gesture:)))
//        tap.numberOfTapsRequired = 2
//        taggintView.addGestureRecognizer(tap)
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
    
    @objc static func doubleTap(gesture:UITapGestureRecognizer)  {
        guard let v = gesture.view as? TaggingView else {
           return
        }
        if let att = v.attachedView{
            MarkView.recursiveRemoveTagView(view: att)
            att.window?.chaosFeature = ChaosFeature.none.rawValue
        }
        v.removeFromSuperview()
    }
    
}
