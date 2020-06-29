//
//  MarkInfo.swift
//  ViewChaosDemo
//
//  Created by Stan Hu on 5/7/2017.
//  Copyright © 2017 Qfq. All rights reserved.
//

import UIKit
struct Line:Equatable{
    var belongToFrame:CGRect?
    var point1:ShortPoint
    var point2:ShortPoint
    init(point1:ShortPoint,point2:ShortPoint) {
        self.point1 = point1
        self.point2 = point2
    }
    var centerPoint:CGPoint{
        get{
            return CGPoint(x: (point1.point.x + point2.point.x)/2, y: (point1.point.y + point2.point.y)/2)
        }
    }
    
    var lineWidth:CGFloat{
        get{
            return sqrt(pow(abs(point1.point.x-point2.point.x), 2)+pow(abs(point1.point.y-point2.point.y), 2))
        }
    }
    
    public static func ==(lhs: Line, rhs: Line) -> Bool{
        if lhs.point1 == rhs.point1 && lhs.point2 == rhs.point2 {
            return true
        }
        return false
    }
}
struct ShortPoint :Equatable{
    var point:CGPoint
    var handle:CGFloat
    init(x:CGFloat,y:CGFloat,handle:CGFloat) {
        self.point = CGPoint(x: x, y: y)
        self.handle = handle
    }

    public static func ==(lhs: ShortPoint, rhs: ShortPoint) -> Bool{
        if lhs.point == rhs.point && lhs.handle == rhs.handle {
            return true
        }
        return false
    }
}

struct Interval {
    var start:CGFloat
    var length:CGFloat
    init(start:CGFloat,length:CGFloat) {
        self.start = start
        self.length = length
    }
}

class FrameObject {
    var frame:CGRect
    var attachedView:UIView
    var topInjectedObjs:[Line]
    var leftInjectedObjs:[Line]
    init(frame:CGRect,attachedView:UIView) {
        self.frame = frame
        self.attachedView = attachedView
        topInjectedObjs = [Line]()
        leftInjectedObjs = [Line]()
    }
}

protocol AbstractView {

}

class BorderAttachView:UIView,AbstractView{
    
}

class TaggingView: UIView,AbstractView {
    weak var attachedView:UIView?
    var lines:[Line]?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     convenience init(frame: CGRect,lines:[Line]) {
        self.init(frame: frame)
        backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.05)
        self.lines = lines
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else{
            return
        }
        guard let mLimes = lines else {
            return
        }
        
        for line in mLimes {
            context.setLineWidth(2.0 / UIScreen.main.scale)
            context.setAllowsAntialiasing(true)
            context.setStrokeColor(red: 1, green: 0, blue: 70.0/255.0, alpha: 1)
            context.beginPath()
            context.move(to: line.point1.point)
            context.addLine(to: line.point2.point)
            context.strokePath()
            let str = String.init(format: "%.0f px", line.lineWidth)
            let position = CGRect(x: line.centerPoint.x - 15 < 0 ? 3 :  line.centerPoint.x - 15 , y: line.centerPoint.y - 6 < 3 ? 0 : line.centerPoint.y - 6 , width: 30, height: 16)
            (str as NSString).draw(in: position, withAttributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 7),NSAttributedString.Key.foregroundColor:UIColor.red,NSAttributedString.Key.backgroundColor:UIColor(red: 1, green: 1, blue: 0, alpha: 0.5)])
        }
    }
    
    func addLines(_ lines:[Line])  {
        for l in lines{
            self.lines?.append(l)
        }
        setNeedsDisplay()
    }
}

extension Array{
    mutating func removeWith(condition:((_ obj:Element)->Bool)) {
        var index = [Int]()
        var i = 0
        for item in self{
            if condition(item){
                index.append(i)
            }
            i = i + 1
        }
        for i in index.enumerated().reversed(){
            self.remove(at: i.element)
        }
    }
}

extension CGRect{
    var center:CGPoint {
        return CGPoint(x: self.origin.x + self.size.width / 2, y: self.origin.y + self.size.height / 2)
    }
    
    var leftCenter:CGPoint{
        return CGPoint(x: self.origin.x, y: self.origin.y + self.size.height / 2)
    }
    
    var rightCenter:CGPoint{
        return CGPoint(x: self.origin.x + self.size.width, y: self.origin.y + self.size.height / 2)
    }
    
    var topCenter:CGPoint{
        return CGPoint(x: self.origin.x + self.size.width / 2, y: self.origin.y )
    }
    
    var bottomCenter:CGPoint{
        return CGPoint(x: self.origin.x + self.size.width / 2, y: self.origin.y + self.size.height)
    }
}

class HolderMarkView: UIView,AbstractView {
    var arrViewHit:[UIView] = [UIView]()
    override init(frame: CGRect) {
        super.init(frame: frame)
        //最后再加上双击删除功能
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(HolderMarkView.doubleTap(gesture:)))
        tap.numberOfTapsRequired = 2
        addGestureRecognizer(tap)
    }
    
    
    @objc func doubleTap(gesture:UITapGestureRecognizer)  {
       let location =  gesture.location(in: self)
        if let t = topView(self.window!, point: location)
        {
            MarkView.removeSingleTaggingView(view: t)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        //获取相应的view
        //Issue 15 因为要最外面 加了view,所以不能获取下面是哪个view，那么要用viewshaos里面的办法才行
//        let touch = touches.first
//        if let v = touch?.view{
//            print(v.frame)
//        }
     
        let touch = touches.first
        let point = touch?.location(in: self.window)
        if let t = topView(self.window!, point: point!)
        {
            MarkView.showSingleTaggingView(view: t)
        }
    }
    
    func topView(_ view:UIView,point:CGPoint)->UIView?{
        arrViewHit .removeAll()
        hitTest(view, point: point)
        let viewTop = arrViewHit.last
//        for v in arrViewHit{
//            Chaos.Log("\(type(of: v))")
//        }
        arrViewHit.removeAll()
        return viewTop
    }
    
    func hitTest(_ view:UIView, point:CGPoint){
        var pt = point
        if view is UIScrollView{
            pt.x += (view as! UIScrollView).contentOffset.x
            pt.y += (view as! UIScrollView).contentOffset.y
        }
        if view.point(inside: point, with: nil) && !view.isHidden && view.alpha > 0.01  && !view.isDescendant(of: self) && !(view is ViewChaos){//这里的判断很重要.
            if !(view is AbstractView) {//issue12 在这里过滤掉AbstractView就行，就可以是获取最上面的AbstractView了
                arrViewHit.append(view)
                for subView in view.subviews{
                    let subPoint = CGPoint(x: point.x - subView.frame.origin.x , y: point.y - subView.frame.origin.y)
                    hitTest(subView, point: subPoint)
                }
            }
        }
    }
    
}
