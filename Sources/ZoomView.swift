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
    var imgCaptureData:UnsafeMutablePointer<CUnsignedChar>? = nil
    var imgSize = CGSize.zero
    var currentColor:UIColor?
    
    weak  var viewToZoom:UIView?
    {
        didSet{
            if let v = viewToZoom{
            UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, true, 0)//这个应该是设定一个区域
                v.layer.render(in: UIGraphicsGetCurrentContext()!)//将整个View渲染到Context里
                imgCapture = UIGraphicsGetImageFromCurrentImageContext()
                let imgRef = imgCapture?.cgImage
                var context: CGContext?
                let colorSpace:CGColorSpace?
                let pixelWidth = imgRef!.width
                let pixelHight = imgRef!.height
                let bitmapBytesPerRow = pixelWidth * 4
                let bitmapByteCount = bitmapBytesPerRow * pixelHight
                colorSpace = CGColorSpaceCreateDeviceRGB()
                if colorSpace == nil{
                    print("error init CGColorSpace")
                    
                }
                let bitmapData = malloc(bitmapByteCount)
                if bitmapData == nil{
                    print("Memory not allocated!")
                    
                }
                context = CGContext(data: bitmapData, width: pixelWidth, height: pixelHight, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace!, bitmapInfo: 2)
                if context == nil{
                    //freelocale(bitmapData)
                    print("Context not created!")
                    
                }
                let w:CGFloat = CGFloat(imgRef!.width)
                let h = CGFloat(imgRef!.height)
                imgSize.width = w
                imgSize.height = h
                let imgRect = CGRect(x: 0, y: 0, width: w, height: h)
                context!.draw(imgRef!, in: imgRect)
                let data = context!.data
                 imgCaptureData = data!.assumingMemoryBound(to: CUnsignedChar.self)
                //imgCaptureData = UnsafeMutablePointer<CUnsignedChar>(data)
            }
        }
    }
    var imgForPoint:UIImage?
    var pointToZoom:CGPoint?
        {
        didSet{
            if let point = pointToZoom{
                self.center = CGPoint(x: point.x, y: point.y)
                let offset = 4 * ((imgSize.width * round(point.y*2)) + round(point.x*2))
                let a =  UInt64(imgCaptureData![Int(offset)])
                let r = UInt64(imgCaptureData![Int(offset) + 1])
                let g = UInt64(imgCaptureData![Int(offset) + 2])
                let b = UInt64(imgCaptureData![Int(offset) + 3])
                currentColor = UIColor(red:CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
                print("point:\(point) the color is :\(String(describing: currentColor?.format("swift")))")
                //大功基本告成,我再加个Lable来显示就行
                
                
                self.contentLayer?.setNeedsDisplay()
                //currentColor = imgCapture?.getPixelColor(self.center) 不能写这个方法
                //Issue6 这样写内存很容易就爆炸了,只有先将其转化成一堆指针,每次关了放大镜,就清空这个指针
                //getPixelColor这是我有史以来写得占用内存最快的方法,不停地调用这个方法,不到5秒APP就被系统干掉了
                //而且从打印出来的数据来看,好象颜色还是有问题的

                //Issue7 目前内存问题已经修改OK,不会战用太高的内存.只是颜色还是有问题的.
                //所以后面是解决颜色问题
                //我终于知道为什么颜色死活都不对的原因了,因为Int(4 * ((imgSize.width * round(point.y*2)) + round(point.x*2)))这里是关键
                //((imgSize.width * round(point.y))我写成((imgSize.width * round(point.x))了,
                //2是因为point其实是屏幕分辨率的一半,所以颜色死话都不对, 对这个Point的x和y* 2 就OK了,基本完美
                
            }
        }
    }

    var contentLayer:CALayer?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        //因为不能直接访问,所以这里基本采用发通知的方式来设置一些东西
        self.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 60
        self.layer.masksToBounds = true
        self.windowLevel = UIWindow.Level.alert
        
        //Issue0 如果我在这里把UIApplication.sharedApplication().keyWindow给vZoom.viewToZoom，也就是说在ViewDidLoad里面
        //那么如果我要pop这个ViewController,
        //那么UIApplication.sharedApplication().keyWindow就变成上面的信号条了，不知道为什么
        //也就是说，高度只有20了， 太奇怪了
        //这说明上面的信号条其实是一个UIWindow
        //而view.Window对象其实是在ViewDidAppare叶才有，这说明了ViewDidAppare后才把生成好的View加到UIWindow里面

        self.contentLayer = CALayer()
        self.contentLayer?.frame = self.bounds
        self.contentLayer?.delegate = self
        self.contentLayer?.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(self.contentLayer!)
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) { //使用这个方法会导致占用内存,而且不能释放,以后再想办法 ,
        ctx.translateBy(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        ctx.scaleBy(x: 1.5, y: 1.5)
        ctx.translateBy(x: -1 * self.pointToZoom!.x, y: -1 * self.pointToZoom!.y)
        self.viewToZoom?.layer.render(in: ctx)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    deinit{
        free(imgCaptureData)
    }
    
}


class ZoomViewBrace: UIView {
    var viewZoom = ZoomView(frame: CGRect.zero)
    var lblPixelColor = UILabel()
//    var img:UIImageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = UIScreen.main.bounds
        let infoTop:CGFloat = UIDevice.isNotchScreen ? 50 : 0
        lblPixelColor.frame = CGRect(x: 0, y: infoTop, width: UIScreen.main.bounds.size.width, height: 22)
        lblPixelColor.backgroundColor = UIColor(red: 0.0, green: 0.898, blue: 0.836, alpha: 0.7)
        lblPixelColor.textColor = UIColor.black
        lblPixelColor.numberOfLines = 2
        lblPixelColor.font = UIFont.systemFont(ofSize: 10)
        addSubview(lblPixelColor)
        
//        img.frame = CGRect(x: UIScreen.mainScreen().bounds.size.width / 2, y: UIScreen.mainScreen().bounds.size.height / 2, width: UIScreen.mainScreen().bounds.size.width / 2, height: UIScreen.mainScreen().bounds.size.height / 2)
//        img.layer.borderColor = UIColor.greenColor().CGColor
//        img.layer.borderWidth = 1
//        addSubview(img)
        //加这个UIImageView是为了看从UIWindow的Layer渲染的图片是不是正确的,被逼是确实是正确的
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Issue 5如果是的ViewController里的View,是可以触发这个事件的,现在问题是APP里面外面的View是作为容器,里面是有很多View的,这些View不会触发
        //事件,所以放大镜就失效了
        //这个问题需要解决,如果是放大镜,那么就不能让里面的所有View响应事件,
        //所以在这种模式下,需要在最外面铺一层View,专门用来响应触摸事件
        //所以我现在用这个就解决问题了
        //但是界面上所有东西都失灵了,为了用放大镜,这也是没办法的事件
        if let touch = touches.first{
            let point = touch.location(in: self)
            if viewZoom.viewToZoom == nil{
                viewZoom.viewToZoom = UIApplication.shared.keyWindow
//                img.image = viewZoom.imgCapture
            }
            viewZoom.pointToZoom = point
            viewZoom.isHidden = false
            viewZoom.makeKeyAndVisible()
             lblPixelColor.text = "color :\(viewZoom.currentColor!.format("str")) point:\(point) "
            //这个严重要说明,这个方法应该会将这个Window设成Keywindow,然后原来的那个就不是KeyWindow了,所以调用Xcode主视图查看器就看不到东西了,
            //Issue2 ,使用些功能后会让XCode 的 view hierarchy 功能失效,会变成一片空白,看有没有什么解决的办法
        }
    }
    
     override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        if let touch = touches.first{
            let point = touch.location(in: self)
           viewZoom.pointToZoom = point
            
             lblPixelColor.text = "color :\(viewZoom.currentColor!.format("str")) point:\(point) "
            //viewZoom?.makeKeyAndVisible() 这个只要调用一次就行.不然后会有内存问题,所以要注视掉
            //Issue3 用放大镜吃内存问题,已经解决,在这里不再调用makeKeyAndVisible()就行
        }
    }
      override  func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        viewZoom.isHidden = true
        self.viewZoom.resignKey()
        
    }
     override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        viewZoom.isHidden = true
        self.viewZoom.resignKey()
        
    }

    
}


extension UIImage{
    func getPixelColor(_ point:CGPoint)->UIColor?{
        var color:UIColor?
        if point.x > self.size.width || point.y > self.size.height{
            return color
        }
        let imgRef = self.cgImage
        if imgRef == nil{
            return color
        }
        
        var context: CGContext?
        let colorSpace:CGColorSpace?
        let pixelWidth = imgRef!.width
        let pixelHight = imgRef!.height
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
        context = CGContext(data: bitmapData, width: pixelWidth, height: pixelHight, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace!, bitmapInfo: 2)
        if context == nil{
            //freelocale(bitmapData)
            print("Context not created!")
            return color
        }
        let w:CGFloat = CGFloat(imgRef!.width)
        let h = CGFloat(imgRef!.height)
        let imgRect = CGRect(x: 0, y: 0, width: w, height: h)
        context!.draw(imgRef!, in: imgRect)
        let data = context!.data
       // let info = UnsafeMutablePointer<CUnsignedChar>(data)
        
        let info = data!.assumingMemoryBound(to: CUnsignedChar.self)
        let offset:Int = Int(4 * ((w * round(point.x)) + round(point.x)))
        let a =  info[offset]
        let r = info[offset + 1]
        let g = info[offset + 2]
        let b = info[offset + 3]
        color = UIColor(red: CGFloat(UInt64(r)) / 255.0, green: CGFloat(UInt64(g)) / 255.0, blue: CGFloat(UInt64(b)) / 255.0, alpha: CGFloat(UInt64(a)) / 255.0)
        
        //Issue8: 怎么样才能从UnsafemutablePoint<Void>里面获取一位一位的数据出来,我用index的方法打印出来全是空的括号
        //通过stackoverflow,知道怎么办了
        //UnsafeMutablePointer<Void>调用memery是没有任何东西的,实际上这代表一种通用的"泛型",你需要UnsafeMutablePointer<T>(data)
        //这个构造函数将其转化正确的类型,这个正确的类型就是T,T是个什么样的东西呢,一般是以C开头的比如CUnsignedChar等东西,
        //具体是什么东西需要去看ObjectiveC的类型是什么,再对C指针类型-Swift指针类型转换就行了
        //这个指针类型里面一共有多少数据呢,目前还需要研究,所以这里就是Issue2了
        //Issue9:对于UnsafeMutablePointer<T>类型,从Memery里面取值比较麻烦.那么怎么知道一共有多少值,怎么用index取值呢?
        //对于这个问题,我发现了,其实是也可以像Objc那样取值的.直接用[index]来取就行,一个像素点一共有四个可以取,分别是alpha,red,green,blue
        //依次加1,加2,加3就行了,再就可以婚礼转化成颜色
        
        return color
    }
    
}

