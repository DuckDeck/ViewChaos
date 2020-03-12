ViewChaos

> ViewChaos是一个动态的iOS UI调试工具，是为了解决纯代码编写的iOS UI而调试困难而写的

## ViewChaos 的特性

+ 集成方便，不用写一行代码，把文件拖进你的项目就行了，而且只有在`Debug`模式有效，`Release`模式将自动禁用。
+ 给`View`添加了`Name`属性，这样就能知道哪个`View`是由哪些代码生成的，可以更好地定位到代码。
+ 添加了摇一摇功能，里面集成了放大镜，UI边框显示，UI透明度，标记界面模式和显示log的功能，可以查看整个界面布局的一些基本信息。
+ 可以获取`View`的基本信息，以及它的所有的`父View`和`子View`的基本信息，同时还可以标记该`View`的坐标位置信息。
+ 可视化显示`Autolayout`。
+ 可以实时追踪`View`的状态。
+ 监测内存泄露。
+ 可以实时修改`View`的`Frame, Font,border,tintColor,background`,等属性，这样就不用一次又一次地调试代码后编译启动APP查看，可 以一次性设置后再在代码里修改。
+ ~~可以生成代码，这个用处不大，但是也是可以参考的~~。
+ 注意，如果禁用了摇一摇出菜单功能，如果自己手动调出菜单，那么还是需要用摇一摇来关了菜单，这实际是要将摇一摇功能开启了，这时需要再一次将摇一摇关了。

## ViewChaos的安装和使用
`ViewChaos`的安装极为方便，有两种安装方式，如果你不想用`Cocoapods`，只想拖文件，按照以下步骤就行：
+ 第一步：将这10个文件`(ViewChaos.swift,ViewChaosInfo.swift,ViewNeat.swift，ZoomView.swift,DrawView.swift,MarkInfo.swift,MarkView.swift，ShakeEnableCell.swift,tool.swift,LogView.swift)`复制到你的项目里，或者直接复制`ViewChaos`这个文件夹到你的项目。
+ 第二步：选择 `target-> 你的项目 -> Build Setting-> 搜索 'swift compile'-> 选择 'Other Swift Flags' -> 选择 DeBug option -> 添加 -DDEBUG command (这个能让此工具仅工Debug模式有效)`
+ 第三步:如果你找不到`Other Swift Flags`选项，说明你的项目是纯`Objective-c`，那么你需要手动添加一个`swift`文件到你的项目，这时`XCode`会让你添加一个`header bridge`文件，这时侯选择是，再做第二步操作.】
+ 第四步：开始使用。

如果你想用`Cocoapods`，就更简单了：
+ 第一步：`pod 'ViewChaos'`，再安装就行。
+ 第二步：`选择Pods项目->选择 target-> ViewChaos -> Build Setting-> 搜索 'swift compile'-> 选择 'Other Swift Flags' -> 选择 DeBug option -> 添加 -DDEBUG command (这个能让此工具仅工Debug模式有效).`
+ 第三步：开始使用。

![加上-DDEBUG](http://upload-images.jianshu.io/upload_images/1281203-5760044ba4ebc6d7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

注意一定要添加`-DDEBUG`，加上这个功能是为了让`ViewChaos`可以在`Debug`模式下启动，而`Release`模式会不会启动。然后启动你的项目，你就可以看到你的APP里面多了一个V的绿色小圆，同时你的APP也有了摇一摇功能。下面我用图片和文字来给读者展示`ViewChaos`的各种功能，建议读者下载`Demo`用真机或者模拟器亲自试试，下面的详细讲解这些功能。

## 摇一摇功能

![摇一摇呼唤出菜单](http://upload-images.jianshu.io/upload_images/1281203-85bec787e39209e8.gif?imageMogr2/auto-orient/strip)

如果`ViewChaos`正确地集成到了你的APP里，那么就可以使用摇一摇调试功能。摇一摇功能里面一共有四个小功能，分别是放大镜，显示边框，显示透明度和标记界面。下面一个一个讲解


![放大镜模式](http://upload-images.jianshu.io/upload_images/1281203-f15934bf8eb7fe11.gif?imageMogr2/auto-orient/strip)
放大镜模式比较简单，当启用后，用手指触摸屏幕，它会将你手指下的点放大显示（只支持单点），上面绿色区域可以显示该点的坐标和颜色值。

![边框模式](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_border_1.gif)
![边框模式](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_border_2.gif)

边框模式也比较简单，进入该模式后，所有UI控件的边框都会用红色的线显示出来，你可以在上面做一些标记，当启用截图时，你可以画个框然后再把该页面保存到相框里，

![透明模式](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_alpha.gif)

透明模式更简单了，可以直接现实页面里的UI控件的透明情况，透明度越高的`View`红色会越深。如果没有红色表示此`View`是不透明的。

最后一个功能新加的，也比较新颖，就是标记界面功能，启动该模式后。点击你想要标记的`View`，`ViewChaos`会将此`View`的左右上下标记并显示出来。双击该`View`会取消标记。

![标记界面模式](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/shake.gif)


上面就是摇一摇的全部功能了，注意这个可能和你的项目的摇一摇功能相冲突，目前还没有提供关闭功能，以后版本会提供的

## 最核心的抓取`View`和用表格表示显示`View`相关信息功能
下面要讲的就是`ViewChaos`的最核心的功能了， 这一切都要靠这这个绿色的V字小球来实现。

![移动小球](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_ball_move.gif)

用手指触摸小球后，小球会跟随手指在屏幕上移动，同时小球会抓去位于小球下的`View`的信息，并的屏幕顶部显示出来

![View信息](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_view_level1.gif)
![View信息](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_view_level2.gif)

点击顶部的绿色区域后，会出现一个表格，里面从下到下的菜单分别是基本信息，`SuperView,SubView,约束和View追踪功能`。`SuperView`可以展示该`View`层级上所有的`View`，而`SubView`可以展示该`View`下的一层的所有的子`View`，也可以点开它。

![这样也行？？？](http://upload-images.jianshu.io/upload_images/1281203-5c0709232cac1dbf.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

在这里其实针对单个`View`，我也做了标记功能(上面的动图都比较老，没有显示标记功能) ，只要在这个表里就可以启动这个功能

![启用和关闭单个View标记功能](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/mark.gif)

对于单个`View`标记功能，可以显示该`View`本身和它最近的`View`的标记。

如果你使用了`Autolayout`,那么还会该`View`的信息表里还出显示该`View`的约束数据。

![View约束](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_constrain.gif)

该功能可以显示该`View`所有存在的约束(如果存在的话，也就是说，你是用`AutoLayout`来布局的，而不是`frame`布局)。点击该约束，可以用可视化的信息展示出来，相当实用。

![View追踪](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_trace_view.gif)

最后就是追踪`(Trace)`功能。该功能可以追踪`View`的状态，比如`frame，tag，center`，等，当你点开始，`ViewChaos`就会监视该View的各种属性，如果该`View`的属性发生的改变，`ViewChaos`会记录下来并保存,然后在下面显示出来。

## 实时调整UI功能
后面的功能就是属于改变`View`的各种属性，它可以让你调整`View`，直到符合你的要求为止，然后你可以生成代码，从里面选择出你需要的代码。
从表里面点`Control`，就会出来一个控制器，这个控制器可以改变`View`和一些属性，从左到右依次是**位置** **大小** **字体** **边框** **颜色** **代码**
下面一个一个讲解



![View位置](http://upload-images.jianshu.io/upload_images/1281203-36eddc5c6f5fb129.gif?imageMogr2/auto-orient/strip)
![View位置](http://upload-images.jianshu.io/upload_images/1281203-3e97f7a520051ae4.gif?imageMogr2/auto-orient/strip)

第一个功能就是改变`View`的位置，比较简单



![View大小](http://upload-images.jianshu.io/upload_images/1281203-cdc22f4a8bbe3cc0.gif?imageMogr2/auto-orient/strip)

第二功能就是改变`View`的大小，上面有两个按钮，一个是控制左上边的大小，一个是控制右下边的大小。


![View字体](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_size.gif)

第三个功能就是改变`View`里面字体的大小，目前只对`Button,Lable,TextFiled和TextView`有用。其他的无效

![View边框](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_border.gif)
![View边框](http://upload-images.jianshu.io/upload_images/1281203-26a2c69a5a0ecbe6.gif?imageMogr2/auto-orient/strip)

第四个功能就是改变`View`的边框，摇杆上面有三个子菜单，分别是颜色，边框和弧度，选择哪种就能控制哪种。

![View颜色](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_color1.gif)
![View颜色](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_color2.gif)

第五个功能就是改变View的颜色属性，如果存在的话。分别是前景色，背影色和主题色。

![View颜色](http://upload-images.jianshu.io/upload_images/1281203-732a8731b4c0a236.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

最后一个功能就是生成代码啦，将所有的属性调整好之后，点一下code就能生成下面的代码。你可以从里面选择出有用的部分。

+ 里面部分功能说明，在调整`VIew`位置和大小时，如果想让View的变化更慢一些，那么可以修改`scale`的值，5是最快的，1是最慢的。
+ 如果你想做特别微小的调整，那么可以点Precise按钮启动精确模式，想退出再点一下就行.
+ `Reset(重设)`按钮会将View回复成原来的状态.
+ `Close(关闭)`按钮会关闭控制面板.

以上差不多就是`VIewChaos的`全部功能，要这里还是建议读者亲自去下载`Demo`试用一下。`ViewChaos`基本上能够满足大部分UI的调试，但是也有的属性还不能看到和修改，另外还希望读者给出建议，这些都是以后的改进方向。
