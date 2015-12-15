ViewChaos
===
####下面有中文说明
##ViewChaos is a iOS view diagnose tool
ViewChaos is a powerful iOS UI development tool, It can help you locate the view, find the superView and subView. check the constrains, and trace the view which you want to observe. and the most magical thing is that it can change the view's frame. background&title color, resize the font. change the border color,width and corner radius. at last.it can generate the code,  you can just copy the ajusted view's code parse to the Xcode.  it is very powerful. and every iOS developer should use this tool!

##Key Features
* No code, you do not need write any code!
* Debug mode. it will automatically disable when you set in release mode.
* Check view's frame, subViews, superViews.
* Can see the view's constrains.
* Trace the view.
* Change the view's property,include frame,size,font,border and background.

##Requirements 

Xcode 7.1 and iOS 8.0

##Installation(this is very important)
`if you like to copy the three files(ViewChaos.swift,ViewChaosInfo.swift,ViewNeat.swift) to your project to install ViewChaos, please follow these setps bellow:`
* step1:copy the three files(ViewChaos.swift,ViewChaosInfo.swift,ViewNeat.swift) to your project.
* step2:set Target(select your project)->build setting-> search 'swift compile' ->select 'Other Swift Flags' -> select DeBug option -> add -DDEBUG command (this make it only work in debug mode).
* step3: if you can not find the 'Other Swift Flags' option, it turn out that your project is a pure objective-c project. you need add a swift file to your project, then the xcode want you to build a header bridge file. you need add it. then you can process step2 correctly.
* step4 just use it! 

`if you want to use cocopods, just pod 'ViewChaos'.`
* step1:pod 'ViewChaos', and install it.
* step2:select the Pods project, then choose target-> your project -> Build Setting-> serach 'swift compile'-> select 'Other Swift Flags' -> select DeBug option -> add -DDEBUG command (this make it only work in debug mode).
* step3: just use it!
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/0.png)  

##How To Use It 
* If you install ViewChaos successfully, then run your project, you will see a green ball, and you can move it, the green ball will capture the toppest view and show on the screen's top.
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/1.gif)
<br>
* Click the green area, you will get a table, which is show this view's information, include it's superView,subView, and constrains(if it exist)
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/2.gif)
<br>
* The contrain can show the view's constrain. just click it
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/3.gif)
<br>
* it can trace view's frame,center, tag, and bounds..and the change value can show in the table
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/4.gif)
<br>
* Controller view's location
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/5.gif)
<br>
* Change View's size and font size
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/6.gif)
<br>
* Change's view's border and forground, background and tint color
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/7.gif)
<br>
* Once the set the view to the property, you can click "Code" and it will generate code for you, include Objective-c and swift
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/00.png)
<br>
* if you can control the view precise, jusr click Precise, and the view will move 0.5px every 0.3 second.If you want cancel, just click Imprecise
* The view move speed can changed by set property Scale value. 5 is the fastest, and 1 is very slow.
* Reset will set the view to the origin status
* Close will close the control panel
* Some color porperty, the panel will show a ColorPick button, click this button a ColorPick will show, the can usr it to choose color.

##Contact 
Any issue or problem please contact me:3421902@qq.com, I will be happy fix it




ViewChaos
===
##中文说明
##ViewChaos是一个IOS UI调试工具
ViewChaos是一个强大的IOS UI开发工具，它可以帮助你定位View，找出它的Superview和subview，检查约束，同时也可以追踪你想要观察的View。 其中最神奇的是它可以改变VIew的边框，背景&标题色，改变字体大小，改变边框颜色，厚度和弧度。最后，它还可以生成代码，你可以直接拷贝调整好的代码粘贴到XCode里使用。它太好用了，每个iOS开发者都应该使用这个工具！

##关键特点
* 不需要代码，你不需要写任何代码!
* 调试模式，当设为发布模式会自动禁用此功能.
* 检查VIew的frame, subViews, superViews.
* 可视化View的约束.
* 追踪VIew，还可以检查内存泄漏.
* 改变VIew的属性，包括frame,size,font,border and background.

##系统要求 

Xcode 7.1 and iOS 8.0

##安装(非常重要，请细读)
`如果你想使用文件，那么拷贝这三个文件ViewChaos.swift,ViewChaosInfo.swift,ViewNeat.swift到你项目即可，再按照以下步骤:`
* 第一步：拷贝这三个文件ViewChaos.swift,ViewChaosInfo.swift,ViewNeat.swift到你项目.
* 第二步：选择 target-> 你的项目 -> Build Setting-> 搜索 'swift compile'-> 选择 'Other Swift Flags' -> 选择 DeBug option -> 添加 -DDEBUG command (这个能让此工具仅工Debug模式有效).
* 第三步:如果你找不到Other Swift Flags选项，说明你的项目是纯objective-c，那么你需要手动添加一个swift文件到你的项目，这时XCode会让你添加一个header bridge文件，这时侯选择是，再做第二步操作.
* 第四步:开始使用! 

`如果你使用cocopods, 则pod 'StarReview'.`
* 第一步：pod 'StarReview'，再安装.
* 第二步：选择Pods项目->选择 target-> 你的项目 -> Build Setting-> 搜索 'swift compile'-> 选择 'Other Swift Flags' -> 选择 DeBug option -> 添加 -DDEBUG command (这个能让此工具仅工Debug模式有效).
* 第三步:开始使用!
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/0.png)  

##怎么使用
* 如果你正确得安装了ViewChaos ，那么当你启动项目，你会看见一个绿色的小球，你可以移动它，这个小球会自动抓取位于这个小球最上层上VIew，上面会显示这个VIew的简单信息.
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/1.gif)
<br>
* 点击绿色区域，会出一个表格，里面详细得显示了这个VIew的信息，包括它的superView，subViews还有约束（如果存在的话）
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/2.gif)
<br>
* 可以点击约束，可视化查看
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/3.gif)
<br>
* 可以追踪一个View的frame，center, tag和bounds，改变的记录显示要表格里
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/4.gif)
<br>
* 控制View的位置
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/5.gif)
<br>
* 改变VIew的大小和字体大小
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/6.gif)
<br>
* 改变VIew的边框大小，背景色和弧度。还可以改主题色
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/7.gif)
<br>
* 一但你正确地设置了VIew的各项属性，那么可以点Code按钮来生成代码，同时包含Swift和Objective-c代码
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/00.png)
<br>
* 使用摇杆来制作View如果你觉得移动幅度达大，那么可以减少Scale，或者点Precise按钮，这个是指精确化控制，它可以让view第0.3秒移动0.5个像素。如果你想点取消，就点Imprecise.
* Scale是指操作VIew移动幅度的比例，5是最快的，1 是最慢的.
* Reset 将会将View重设为初始状态.
* Close将会关闭操作面板.
* 一些可以改变颜色的属性被选中时，面板上将会显示一个选择颜色的按钮，可以用它来设置各种颜色.

##与我联系 
任何问题或者BUG请直接和我联系3421902@qq.com, 我会乐于帮你解决

