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
    var pointToZoom:CGPoint?
        {
        didSet{
            if let point = pointToZoom{
                self.center = CGPoint(x: point.x, y: point.y)
                self.contentLayer?.setNeedsDisplay()
            }
        }
    }
    var needWork = false
    var contentLayer:CALayer?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setWork", name: setZoomViewWork, object: nil)
        self.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.layer.cornerRadius = 60
        self.layer.masksToBounds = true
        self.windowLevel = UIWindowLevelAlert
        
        self.contentLayer = CALayer()
        self.contentLayer?.frame = self.bounds
        self.contentLayer?.delegate = self
        self.contentLayer?.contentsScale = UIScreen.mainScreen().scale
        self.layer.addSublayer(self.contentLayer!)
    }
    
    override func drawLayer(layer: CALayer, inContext ctx: CGContext) {
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
