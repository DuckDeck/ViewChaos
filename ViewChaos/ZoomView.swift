//
//  ZoomView.swift
//  Demo
//
//  Created by HuStan on 3/17/16.
//
//

import UIKit

class ZoomView: UIWindow {
    
    weak  var viewToZoom:UIView?
    var imgForPoint:UIImage?
    var pointToZoom:CGPoint?
        {
        didSet{
            if let point = pointToZoom{
                self.center = CGPoint(x: point.x, y: point.y)
                self.contentLayer?.setNeedsDisplay()
//                UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
//                viewZoom?.layer.renderInContext(UIGraphicsGetCurrentContext()!)
//                let image = UIGraphicsGetImageFromCurrentImageContext()
            }
        }
    }
    var needWork = false
    var contentLayer:CALayer?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ZoomView.setWork), name: setZoomViewWork, object: nil)
        //因为不能直接访问,所以这里基本采用发通知的方式来设置一些东西
        self.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.layer.cornerRadius = 60
        self.layer.masksToBounds = true
        self.windowLevel = UIWindowLevelAlert
        
        //Issue0 如果我在这里把UIApplication.sharedApplication().keyWindow给vZoom.viewToZoom，也就是说在ViewDidLoad里面
        //那么如果我要pop这个ViewController,
        //那么UIApplication.sharedApplication().keyWindow就变成上面的信号条了，不知道为什么
        //也就是说，高度只有20了， 太奇怪了
        //这说明上面的信号条其实是一个UIWindow
        //而view.Window对象其实是在ViewDidAppare叶才有，这说明了ViewDidAppare后才把生成好的View加到UIWindow里面

        self.contentLayer = CALayer()
        self.contentLayer?.frame = self.bounds
        self.contentLayer?.delegate = self
        self.contentLayer?.contentsScale = UIScreen.mainScreen().scale
        self.layer.addSublayer(self.contentLayer!)
    }
    
    override func drawLayer(layer: CALayer, inContext ctx: CGContext) { //使用这个方法会导致占用内存,而且不能释放,以后再想办法 ,
        CGContextTranslateCTM(ctx, self.frame.size.width / 2, self.frame.size.height / 2)
        CGContextScaleCTM(ctx, 1.5, 1.5)
        CGContextTranslateCTM(ctx, -1 * self.pointToZoom!.x, -1 * self.pointToZoom!.y)
        self.viewToZoom?.layer.renderInContext(ctx)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setWork(){
        needWork = !needWork
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
