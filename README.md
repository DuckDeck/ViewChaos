ViewChaos
===
ViewChaos是一个iOS UI调试工具，可以直接在APP里面看到UI的各种状态，对用代码开以UI十分友好
##ViewChaos的安装和使用
ViewChaos的安装极为方便，有两种安装方式，如果你不想用Cocoapods，只想拖文件，按照以下步骤就行：
+ 第一步：将这五个文件(ViewChaos.swift,ViewChaosInfo.swift,ViewNeat.swift，ZoomView.swift,DrawView.swift)拷贝到你的项目里。
+ 第二步：选择 target-> 你的项目 -> Build Setting-> 搜索 'swift compile'-> 选择 'Other Swift Flags' -> 选择 DeBug option -> 添加 -DDEBUG command (这个能让此工具仅工Debug模式有效)
+ 第三步:如果你找不到Other Swift Flags选项，说明你的项目是纯objective-c，那么你需要手动添加一个swift文件到你的项目，这时XCode会让你添加一个header bridge文件，这时侯选择是，再做第二步操作.】
+ 第四步：开始使用。

如果你想用Cocoapods，就更简单了：
+ 第一步：pod 'ViewChaos'，再安装就行。
+ 第二步：选择Pods项目->选择 target-> ViewChaos -> Build Setting-> 搜索 'swift compile'-> 选择 'Other Swift Flags' -> 选择 DeBug option -> 添加 -DDEBUG command (这个能让此工具仅工Debug模式有效).
+ 第三步：开始使用。

![加上-DDEBUG](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/0.png)

添加-DDEBUG就OK了，启动你的项目，你就可以看到你的APP里面多了一个V的绿色小圆，同时你的APP也有了摇一摇功能。下面我用图片和文字来给读者展示ViewChaos的各种功能，建议读者下载Demo用真机或者模拟器亲自试试。

![摇一摇呼唤出菜单](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/shake_pop_menu.gif)

摇一摇功能里面一共有三个小功能，分别是放大镜，显示边框和显示透明度。下面一个一个讲解

![放大镜模式](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_zoom.gif)

放大镜模式比较简单，当启用后，用手指触摸屏幕，它会放大你手指下的点（只支持单点），上面绿色区域可以显示该点的坐标和颜色值。

![边框模式](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_border_1.gif)
![边框模式](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_border_2.gif)

边框模式也比较简单，进入该模式后，所有UI控件的边框都会用红色的线显示出来，你可以在上面画画，当启用截图时，你可以画个框然后再把该页面保存到相框里(目前用处不大)，

![透明模式](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_alpha.gif)

透明模式更简单了，可以直接现实页面里的UI控件的透明情况，越透明越红。

上面就是摇一摇的全部功能了，注意这个可能和你的项目的摇一摇功能相冲突，目前还没有提供关闭功能，以后版本会提供的

下面就是ViewChaos的打功能了，帮你定位View并获取View的信息

![移动小球](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_ball_move.gif)

用手指触摸小球后，小球会跟随手指在屏幕上移动，同时小球会抓去位于小球下的View的信息，并的屏幕顶部显示出来

![View信息](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_view_level1.gif)
![View信息](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_view_level2.gif)

点击顶部的绿色区域后，会出现一个表格，里面从下到下的菜单分别是基本信息，SuperView,SubView,约束和View追踪功能。SuperView可以展示该View层级上所有的View，而SubView可以展示该View下的一层的所有的子View，也可以点开它。

![View约束](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_constrain.gif)

该功能可以显示View的约束(如果存在的话，也就是说，你是用AutoLayout来布局的)。

![View约束](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_trace_view.gif)

该功能可以追踪View的状态，比如frame，tag，center，等，当你点开始，ViewChaos就会监视该View的各种属性，如果该View的属性发生的改变，ViewChaos会记录下来并保存,然后在下面显示出来。

后面的功能就是属于改变View的各种属性，它可以让你调整View，直到符合你的要求为止，然后你可以生成代码，从里面选择出你需要的代码。
从表里面点Control，就会出来一个控制器，这个控制器可以改变View和一些属性，从左到右依次是**位置** **大小** **字体** **边框** **颜色** **代码**
下面一个一个讲解



![View位置](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_move.gif)
![View位置](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_move2.gif)

第一个功能就是改变View的位置，比较简单



![View大小](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_size1.gif)

第二功能就是改变View的大小，上面有两个按钮，一个是控制左上，一个是控制右下。


![View字体](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_size.gif)

第三个功能就是改变View里面字体的大小，目前只对Button,Lable,TextFiled和TextView有用。其他的无效

![View边框](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_border.gif)
![View边框](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_border2.gif)

第四个功能就是改变View的边框，摇杆上面有三个子菜单，分别是颜色，边框和弧度，选择哪种就能控制哪种。

![View颜色](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_color1.gif)
![View颜色](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/chaos_control_color2.gif)

第五个功能就是改变View的颜色属性，如果存在的话。分别是前景色，背影色和主题色。

![View颜色](https://raw.githubusercontent.com/DuckDeck/ViewChaos/master/ViewChaosDemo/Resource/00.png)

最后一个功能就是生成代码啦，将所有的属性调整好之后，点一下code就能生成下面的代码。你可以从里面选择出有用的部分。

+ 里面部分功能说明，在调整VIew位置和大小时，如果想让View的变化更慢一些，那么可以修改scale的值，5是最快的，1是最慢的。
+ 如果你想做特别微笑的调整，那么可以点Precise按钮启动精确模式，想退出再点一下就行.
+ Reset(重设)按钮会将View回复成原来的状态.
+ Close(关闭)按钮会关闭控制面板.

以上差不多就是VIewChaos的全部功能，要这里还是建议读者亲自去下载Demo试用一下。ViewChaos基本上能够满足大部分UI的调试，但是也有的属性还不能看到和修改，另外还希望读者给出建议，这些都是以后的改进方向。

其实最理想的UI开发方式就是把大部分UI交给美工来设计，程序员只要写逻辑就行了。很遗憾的是，目前我还没有发现有任何一项技术可以过到这个要求，但最为接近的应该是基于WPF的MVVM开发框架，MVVM可以最大限度的实现UI和逻辑的分离，美工用Expression Blend来设计UI，程序员则同时开发逻辑，再后合并即可。有兴趣的读者可以去找找基于WPF的MVVM资料看看。

###另外，希望大家赏脸给个Star, 谢谢。
