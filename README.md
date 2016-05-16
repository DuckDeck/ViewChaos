ViewChaos
===
####下面有中文说明
##ViewChaos is a iOS view diagnose tool【ViewChaos是一个iOS UI调试工具】
ViewChaos is a powerful iOS UI debug tool, It can help you locate the view, find the superView and subView. check the constrains, and trace the view which you want to observe. and the most magical thing is that it can change the view's frame. background&title color, resize the font. change the border color,width and corner radius. at last.it can generate the code,ViewChaos can generate the code which is you adjusted code. you can copy the code to XCode。  until now what make it more powerful is that ViewChaos add shake feature, you can zoom the view and capture the color on the screen, you can also check all the views's border and transparence。 
【ViewChaos是一个强大的IOS UI开发工具，它可以帮助你定位View，找出它的Superview和subview，检查约束，同时也可以追踪你想要观察的View。 其中最神奇的是它可以改变VIew的边框，背景&标题色，改变字体大小，改变边框颜色，厚度和弧度。最后，它还可以生成代码，你可以直接拷贝调整好的代码粘贴到XCode里使用。它太好用了，每个iOS开发者都应该使用这个工具！】



##Key Features【关键特点】
* No code, you do not need write any code!【不要写代码，你不需要写任何代码】
* Debug mode. it will automatically disable when you set in release mode.【调试模式，当设为发布模式会自动禁用此功能】
* Check view's frame, subViews, superViews.【检查VIew的frame, subViews, superViews.】
* Can see the view's constrains.【可视化View的约束】
* Trace the view‘s properties, and check memory leak.【追踪VIew，还可以检查内存泄漏】
* Change the view's property,include frame,size,font,border and background.【改变VIew的属性，包括frame,size,font,border and background】
* Magnifier mode can zoom the screen and capture the view's color on the screen【放大镜模式可以放大屏幕的实图，还可以获取视图上点的颜色值】
* Boder mode can show all the views border. and you can capture and save it【边框模式获取所有View的边框并显示出来，还可以截图并保存】
* Transparence mode can show all the views transparence. you can use it to check thich view is transparence【透明模式可以获取所有View的透明度，你可以用来检查有哪些View是透明的】


##Requirements 【系统要求】

Xcode 7.3 and iOS 8.0 the last Swift grammer【Xcode 7.3 and iOS 8.0 最新的Swift语法】

##Installation(this is very important)【安装，这很重要】
`if you like to copy the five files(ViewChaos.swift,ViewChaosInfo.swift,ViewNeat.swift，ZoomView.swift,DrawView.swift) to your project to install ViewChaos, please follow these setps bellow:`【如果你想直接Copy这五个文件(ViewChaos.swift,ViewChaosInfo.swift,ViewNeat.swift，ZoomView.swift,DrawView.swift)到你的项目里来安装ViewChaos，请照以下步骤】
* step1:copy the five files(ViewChaos.swift,ViewChaosInfo.swift,ViewNeat.swift，ZoomView.swift,DrawView.swift) to your project.【第一步：将这五个文件(ViewChaos.swift,ViewChaosInfo.swift,ViewNeat.swift，ZoomView.swift,DrawView.swift)拷贝到你的项目里】
* step2:set Target(select your project)->build setting-> search 'swift compile' ->select 'Other Swift Flags' -> select DeBug option -> add -DDEBUG command (this make it only work in debug mode).【第二步：选择 target-> 你的项目 -> Build Setting-> 搜索 'swift compile'-> 选择 'Other Swift Flags' -> 选择 DeBug option -> 添加 -DDEBUG command (这个能让此工具仅工Debug模式有效)】
* step3: if you can not find the 'Other Swift Flags' option, it turn out that your project is a pure objective-c project. you need add a swift file to your project, then the xcode want you to build a header bridge file. you need add it. then you can process step2 correctly.【第三步:如果你找不到Other Swift Flags选项，说明你的项目是纯objective-c，那么你需要手动添加一个swift文件到你的项目，这时XCode会让你添加一个header bridge文件，这时侯选择是，再做第二步操作.】
* step4 just use it! 【第四步：开始使用】

`if you want to use cocopods, just pod 'ViewChaos'`【如果你使用cocopods, 则pod 'ViewChaos'】
* step1:pod 'ViewChaos', and install it.【第一步：pod 'ViewChaos'，再安装就行】
* step2:select the Pods project, then choose target-> your project -> Build Setting-> serach 'swift compile'-> select 'Other Swift Flags' -> select DeBug option -> add -DDEBUG command (this make it only work in debug mode).【选择Pods项目->选择 target-> ViewChaos -> Build Setting-> 搜索 'swift compile'-> 选择 'Other Swift Flags' -> 选择 DeBug option -> 添加 -DDEBUG command (这个能让此工具仅工Debug模式有效).】
* step3: just use it!【第三步：开始使用】
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/0.png)  

##How To Use It 【如何使用】
* If you install ViewChaos successfully, then run your project, you will see a green ball, and you can move it, the green ball will capture the toppest view and show on the screen's top.【如果你正确得安装了ViewChaos ，那么当你启动项目，你会看见一个绿色的小球，你可以移动它，这个小球会自动抓取位于这个小球最上层上VIew，上面会显示这个VIew的简单信息】
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/shake_pop_menu.gif)
<br>
* this is how to shake to wake ViewChaos feature work. you shake your device, then action sheep come up, the can choose one feature, if you want to quit, just shake again.【这是ViewChaos的摇一摇功能，安装成功后摇动手机就能呼唤出菜单，你可以选择一项功能，如果你想退出，那么再摇就行了】


![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_zoom.gif)
<br>
* this is magnifier mode.when you choose this mode, then touch the screen, a magnifer will show the view's detail. and it will capture the point's color, show on the top,.【这是放大镜模式，当你选择选择这项功能，触摸到屏幕后它会放大你点到的位置，是面还会显示该点的颜色】

![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_border_1.gif)
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_border_2.gif)
* this is border mode.this mode will show all the views's border. and you can capture the screen as well.【这是边框模式，这种种模式可以显示所有View的边框，同时还可以截图】

![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_alpha.gif)
* this is transparence mode.this mode will show all the views's transparence. 【这是透明模式，这种种模式可以显示所有View的透明度，】




![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_ball_move.gif)
* move the V ball, the ball will capture the view below it , and show with boder, 【移动V这个球，它会抓取球下面的View，并且加上边框】

![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_view_level1.gif)
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_view_level2.gif)
* tap the green area,A table will araise, the table will show all the info about the view. can you can click this view's superview and subview.【点上面的绿色区域，会出现一个表格，这个表格可以显示这个View的所有信息。还可以点subView 和 superView 】


<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_constrain.gif)
<br>
* The constrain will show the view's constrain(if it exist),约束可以显示这个view的相关约束，如果存在的话
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_trace_view.gif)
<br>
* You can monitor the view's property(frame,center,tag..etc), when you click start, ViewChaos will monitor the view, all the operate will log, and you can check the log in the table. 【你可以监视视图的各种属性，当你点了开始，ViewChaos会监视这个View，所有的操作将被记录下来，并且可以显示在table里】
<br>

![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_move.gif)
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_move2.gif)

<br>
* Control view's location, precise mode let you control the view precisely【控制View的位置，精确】
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_size1.gif)
<br>
* Change View's size and font size【控制View的大小】
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_size.gif)
<br>
* Change View's font size【控制View里的字体大小（如果有的话）】
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_border.gif)
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_border2.gif)
<br>
* Change's view's border 【控制View里的边框】
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_color1.gif)
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_color2.gif)
* Change's view's background,foreground and tintColor 【控制View里的背景色，前景色和主题色】
<br>
* Once the set the view to the property, you can click "Code" and it will generate code for you, include Objective-c and swift【一但你设置好了view的各个属性，你可以点code然后它就会为你生成代码，同时包括objective-c代码和swift代码】
<br>
![add -DDEBUG location](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/00.png)
<br>
* if you want to control the view precisely, jusr click Precise, If you want cancel, just click Imprecise【如果你想精确地控制View，就点精确按钮，如果你想取消，就Imprecise就行】
* The view move speed can changed by set property Scale value. 5 is the fastest, and 1 is very slow.【view的移动速度可以由Scale来决定，5是最快的，1 是最慢的】
* Reset will set the view to the origin status【重设按钮会将View回复成原来的状态】
* Close will close the control panel【Close按钮会关闭控制面板】
* Some color porperty, the panel will show a ColorPick button, click this button a ColorPick will show, the can usr it to choose color.【如果选择民可以改颜色的面板，ColorPick按钮会显示出来。你可以用来修改颜色】


##Contact 【联系】
Any issue or problem please contact me:3421902@qq.com, I will be happy fix it【任何问题或者BUG请直接和我联系3421902@qq.com, 我会乐于帮你解决】
