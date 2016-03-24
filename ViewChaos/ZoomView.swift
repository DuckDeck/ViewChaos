//
//  ZoomView.swift
//  Demo
//
//  Created by HuStan on 3/17/16.
//
//

import UIKit

class ZoomView: UIWindow {
    
    var imgCapture:UIImage?
    var currentColor:UIColor?
    weak  var viewToZoom:UIView?
    {
        didSet{
            if let v = viewToZoom{
            UIGraphicsBeginImageContextWithOptions(UIScreen.mainScreen().bounds.size, true, 0)//这个应该是设定一个区域
                v.layer.renderInContext(UIGraphicsGetCurrentContext()!)//将整个View渲染到Context里
                imgCapture = UIGraphicsGetImageFromCurrentImageContext()
            }
        }
    }
    var imgForPoint:UIImage?
    var pointToZoom:CGPoint?
        {
        didSet{
            if let point = pointToZoom{
                self.center = CGPoint(x: point.x, y: point.y)
                self.contentLayer?.setNeedsDisplay()
                currentColor = imgCapture?.getPixelColor(self.center)
                //Issue6 这样写内存很容易就爆炸了,只有先将其转化成一堆指针,每次关了放大镜,就清空这个指针
                //getPixelColor这是我有史以来写得占用内存最快的方法,不停地调用这个方法,不到5秒APP就被系统干掉了
                //而且从打印出来的数据来看,好象颜色还是有问题的
                print(currentColor?.format("swift"))
            }
        }
    }

    var contentLayer:CALayer?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}


class ZoomViewBrace: UIView {
    var viewZoom = ZoomView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = UIScreen.mainScreen().bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
     override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //Issue 5如果是的ViewController里的View,是可以触发这个事件的,现在问题是APP里面外面的View是作为容器,里面是有很多View的,这些View不会触发
        //事件,所以放大镜就失效了
        //这个问题需要解决,如果是放大镜,那么就不能让里面的所有View响应事件,
        //所以在这种模式下,需要在最外面铺一层View,专门用来响应触摸事件
        //所以我现在用这个就解决问题了
        //但是界面上所有东西都失灵了,为了用放大镜,这也是没办法的事件
        if let touch = touches.first{
            let point = touch.locationInView(self)
            viewZoom.pointToZoom = point
            viewZoom.hidden = false
            
            if viewZoom.viewToZoom == nil{
                viewZoom.viewToZoom = UIApplication.sharedApplication().keyWindow
            }
            viewZoom.makeKeyAndVisible()//这个严重要说明,这个方法应该会将这个Window设成Keywindow,然后原来的那个就不是KeyWindow了,所以调用Xcode主视图查看器就看不到东西了,
            //Issue2 ,使用些功能后会让XCode 的 view hierarchy 功能失效,会变成一片空白,看有没有什么解决的办法
        }
    }
    
     override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {

        if let touch = touches.first{
            let point = touch.locationInView(self)
            viewZoom.pointToZoom = point
            //viewZoom?.makeKeyAndVisible() 这个只要调用一次就行.不然后会有内存问题,所以要注视掉
            //Issue3 用放大镜吃内存问题,已经解决,在这里不再调用makeKeyAndVisible()就行
        }
    }
      override  func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        viewZoom.hidden = true
        self.viewZoom.resignKeyWindow()
        
    }
     override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        viewZoom.hidden = true
        self.viewZoom.resignKeyWindow()
        
    }

    
}


extension UIImage{
    func getPixelColor(point:CGPoint)->UIColor?{
        var color:UIColor?
        if point.x > self.size.width || point.y > self.size.height{
            return color
        }
        let imgRef = self.CGImage
        if imgRef == nil{
            return color
        }
        
        var context: CGContextRef?
        let colorSpace:CGColorSpace?
        let pixelWidth = CGImageGetWidth(imgRef!)
        let pixelHight = CGImageGetHeight(imgRef!)
        let bitmapBytesPerRow = pixelWidth * 4
        let bitmapByteCount = bitmapBytesPerRow * pixelHight
        colorSpace = CGColorSpaceCreateDeviceRGB()
        if colorSpace == nil{
            print("error init CGColorSpace")
            return color
        }
        let bitmapData = malloc(bitmapByteCount)
        if bitmapData == nil{
            print("Memory not allocated!")
            return color
        }
        context = CGBitmapContextCreate(bitmapData, pixelWidth, pixelHight, 8, bitmapBytesPerRow, colorSpace, 2)
        if context == nil{
            //freelocale(bitmapData)
            print("Context not created!")
            return color
        }
        let w:CGFloat = CGFloat(CGImageGetWidth(imgRef!))
        let h = CGFloat(CGImageGetHeight(imgRef!))
        let imgRect = CGRect(x: 0, y: 0, width: w, height: h)
        CGContextDrawImage(context!, imgRect, imgRef)
        let data = CGBitmapContextGetData(context!)
        let info = UnsafeMutablePointer<CUnsignedChar>(data)
        let offset:Int = Int(4 * ((w * round(point.x)) + round(point.x)))
        let a =  info[offset]
        let r = info[offset + 1]
        let g = info[offset + 2]
        let b = info[offset + 3]
        color = UIColor(red: CGFloat(r.toIntMax()) / 255.0, green: CGFloat(g.toIntMax()) / 255.0, blue: CGFloat(b.toIntMax()) / 255.0, alpha: CGFloat(a.toIntMax()) / 255.0)
        
        //Issue0: 怎么样才能从UnsafemutablePoint<Void>里面获取一位一位的数据出来,我用index的方法打印出来全是空的括号
        //通过stackoverflow,知道怎么办了
        //UnsafeMutablePointer<Void>调用memery是没有任何东西的,实际上这代表一种通用的"泛型",你需要UnsafeMutablePointer<T>(data)
        //这个构造函数将其转化正确的类型,这个正确的类型就是T,T是个什么样的东西呢,一般是以C开头的比如CUnsignedChar等东西,
        //具体是什么东西需要去看ObjectiveC的类型是什么,再对C指针类型-Swift指针类型转换就行了
        //这个指针类型里面一共有多少数据呢,目前还需要研究,所以这里就是Issue2了
        //Issue2:对于UnsafeMutablePointer<T>类型,从Memery里面取值比较麻烦.那么怎么知道一共有多少值,怎么用index取值呢?
        //对于这个问题,我发现了,其实是也可以像Objc那样取值的.直接用[index]来取就行,一个像素点一共有四个可以取,分别是alpha,red,green,blue
        //依次加1,加2,加3就行了,再就可以婚礼转化成颜色
        //真TMD不容易啊
        
        return color
    }
    
}

