#iOS开发技巧系列---ViewChaos我的UI调试之道（效果篇）
![](http://7xr2ax.com1.z0.glb.clouddn.com/chaos_fitst_Image.jpg)
>首先因为工作较忙，我有快一个月没有更新文章了，现在事情不多了，就给大家献上最重量级的文章。
本来我是打算写详解KVO这篇文章的，但是我突然看到网络上出现了很多关于KVO的文章，心想于是就算了，就先写这个吧。
UI调试是每一个APP开发者或者前端开发者必备的技术。相对来说，iOS开发者调试UI是最苦逼的。
无论是用Storyboard&XIB或者是纯手写代码实现UI，都要经过修改代码->编译生成->启动APP，进入指定页面后才能看到效果。整个过程需要等待一定的时间。而且反复修改编译后才能达到自己想要的效果，浪费时间。同时如果你是用代码生成UI的话，想要在复杂的页面里找到每个视图控件对应的代码也比较麻烦(目前我的所有项目都是用纯代码写的)。有一天无意中发现了一个叫RunTrace的开源项目[RunTrace](https://github.com/sx1989827/RunTrace)，它是一个IOS动态调试UI的开源项目，做得非常的有新意。并且也能够解决一些用纯代码写UI的疼点。我对这个项目非常有兴趣，我就用Swift重写一次，并且加入了自己的一些功能，使用iOS的UI调试更加方便了。正如标题，它叫[ViewChaos](https://github.com/DuckDeck/ViewChaos)，请大家赏脸给个Star,我将继续写更好的文章和开源项目。

##各平台的UI开发概况
在这里我简单给大家分析一下各平台的UI开发技术，目前最主要有：HTML&CSS，Winform&WPF,Universal Windows APP, Android,iOS这几个平台和开发技术，
####Web界面的开发HTML&CSS
+ Web界面是以HTML标签的形式构建UI，它是HTML语言的最基本的单位。
+ 用尖括号包围的关键词如<div>来表示UI元素，通常是成对出现。
+ 如果需要在容器标签里放其他HTML单位，需要放在标签对里面。
+ 一些HTML元素属性，放在第一个HTML标签里。以键值对的形式存在，比如type = 'text'。
+ 使用Form来提交表单，Http(HTTPS)协议和服务器通讯。
+ 通常通过CSS来控制HTML元素的外观。
+ 通常通过Javescript来控制HTML元素。采用Ajax技术异步通信，实现局部刷新等。
这里就不给示例了，总是来说前端Web开发博大精深，新的技术框架层出不穷，当一个前端工程师也不容易。

####Windows桌面应用程序开发Winform&WPF
+ Winform是XP时代的Windows 桌面程序开发技术。
+ 采用C#语言开发UI和逻辑，没有使用标签语言写UI。
+ 采用事件驱动方法。
+ Winform现在基本被淘汰了。
Winform是上一代的主流桌面应用程序开发开发技术，这个我从来没有用过，现在也基本不再使用了。
+ WPF是新一代微软图形界面开发技术。它是随着Windows Vista推出的。.NET Framework 3.0的一部分。它提供了统一的编程模型、语言和框架，真正做到了分离界面设计人员与开发人员的工作；同时它提供了全新的多媒体交互用户图形界面。
+ 采用XAML标签式语言开发UI，可以在Expression Blend可视化设计开发。美工也可以轻易上手。XAML支持DataBind, Data(Item)Template, Style, Storyboard, Rescoure,自定义控件等技术，开发速度快。
+ 支持事件驱动(Code behind)或者数据驱动(MVVM)开发模式
+ 使用GC回收垃圾，XMAL和C#将编译成CLR中间运行语言，效率比较低，占用内存大
WPF的技术理念非常先进，开发过程也非常友好，也可以做出极为绚丽的界面，可是开发出来的应用体积较大，运行效率比较低，占用内存大，所以没有普及开来。(大部分我们常见的桌面应用都是C&C++开发)但是因为开发效率高，所以很多企业内部经常使用该技术。

####Windows 10上的通用应用Universal WIndows APP(UWP)
+ Universal Windows App（UWP）也就是通用Window App 是微软最新的图形应用开发技术，它是基于WPF技术演进而来的。
+ UWP继承了所有WPF的优点，还可以使用C++和HTML&Javascript来开发，和WPF编译成中间代码不同，UWP直接将代码编译成机器码直接运行，极大的提高了效率。一次开发编译，可以同时在Windows 10,Windows 10 Mobile, XBOX，物联网IoT设备等其他Windows平台上运行
+ 采用和iOS APP一样的沙盒机制，一样也有电话本，传感器，地图，推送等API
+ 采用响应式布局，可以适配任何分辨率等。
+ 大量使用异步API，保证界面响应为最高级别。
我开发UWP并不多，但是我接触WPF的时间够长，所以UWP上手毫无压力。相比WPF运行在.NET运行时里，UWP是可以编译成Native Code运行，所以UWP运行效率更高，UI更为流畅。它是目前微软最为主推的开以技术。
####Android
+ 略，我不会开发Android
####iOS
+ iOS应用是基于Cocoa框架上的，早期的Cocoa是用来开发Mac 应用的，后来加入了Cocoa touch层API用于iOS。
+ 采用XIB或者Storyboard可视化搭建UI，也可以使用手写纯代码来开发UI。
+ 采用Objective C 或者 Swift语言开发逻辑。
+ 在Iphone5 加入多种分辨率后，苹果引入了Autolayout自动布局，它是一种基于约束的，描述性的布局系统。
+ 默认严格遵守MVC设计模式，现以也可以使用MVVM开发框架。
+ 采用ARC实现了自动内存管理。
iOS开发技术还有许多要点，这里就省略了，相信看到这篇文章的人都比较熟悉。

##各平台UI开发小结
+ 从上面可以看出，对于UI构建，都是采用类HTML语言。一个HTML标签表示一个View元素。它即可以当其他View的容器，也可以当内容或者数据的容器。可以用独立的Style文件来表示样式，也可以直接放在标签的属性里面。每个标签都可以有Name或者id属性来让js或者其他语言直接操作。
+ iOS其实也和上面的UI开发范式差不多，Storyboard内部其实也是一个XML文件，只不过我们不能直接编辑，只能可视化设计和通过代码操作。

##手写代码和Stortboard的优劣
现在iOS UI最主流的UI开发主要分两种，一是用Stroyboard(Xib也可以用，但是已经被Stroyboard取代)，二是用纯代码手写UI，可以对目前最主流的APP包进行分析，参考[xib 使用调研情况](http://blog.csdn.net/libaineu2004/article/details/45488665)，可见目前这两种开发方式都很主流。总的来说，两者有如下优劣势。
StoryBoard优势
    + 开发界面所见即所得，可以快速通过拖拽构造界面。也可以明确地知道各个ViewController之间的转换关系
    + 代码量少，开发周期短
    + 关键是已经成为新建项目时候的默认配置，代表着苹果以后的方向和重心
遗憾
    + 很难多人协作
    + ViewController的重用和自定义的view的处理
    + 需要很大的显示器
手写代码UI优势
    + 适合大型项目大规模使用，利于版本管理、追踪改动以及代码合并
    + 最好的代码重用性
遗憾
    + 慢，开发周期长，维护代码复杂
    + 自动布局AutoLayout困难

###手写代码和Stortboard选择建议
实际开发过程中，完全不需要全程使用一种开发方式，可以具体情况来选择性的使用 storyboard或者手写代码，下面是建议：
+ 对于复杂的、动态生成的界面，建议使用手工编写界面。
+ 对于需要统一风格的按钮或UI控件，建议使用手工用代码来构造。方便之后的修改和复用。
+ 对于需要有继承或组合关系的 UIView 类或 UIViewController 类，建议用代码手工编写界面。
+ 对于那些简单的、静态的、非核心功能界面，可以考虑使用 xib 或 storyboard 来完成。

##ViewChaos解决了什么问题
上面笼统地讲了这么多关于UI开发的情况，下面回到正题。ViewChaos是怎么解决部分用纯代码开发iOS UI的不便的。目前我在用代码写uI中存在以下问题

+ 效率低，速度慢，手写代码生成UI比拖控件要慢很多。
+ 不能所见即所得，写好后需要编译-> 运行-> 进入当前页面 才能看到效果，而经常需要反复调试才能过到所要的效果,极为浪费时间。
+ 机器里面的UI控件定位到自己写的代码不够方便，如果页面复杂的话非常难找
+ 在Storyboard里使用Autolayout是大势所趋，但手写代码实现Autolayout非常麻烦。

VIewChaos主要在一定程度上解决了第二点和第三点问题，第四个问题无解，不过可以实现可视化查看各View的约束
ViewChaos有以下特点

+ 集成方便，不用写一行代码，把文件挺进你的项目就行了，而且只有在Debug模式有效，Release模式将自动禁用。
+ 给View添加了Name属性，这样就能知道哪个View是由哪些代码生成的，解决第三个问题。
+ 添加了摇一摇功能，可以选择放大镜模式，可以放大页面的元素，还可以显示每个点的颜色。
+ 摇一摇还可以选择边框模式，现在实时显示所有UI空间的边框，并且可以截图，透明模式可以显示所有UI空间的透明度。
+ 可以获取View的基本信息，以及它的所有的父View和子View，同时还可以选择。
+ 可视化显示Autolayout。
+ 可以实时追踪View的状态。
+ 监测内存泄露。
+ 可以实时修改View的Frame, Font,border,tintColor,background,等属性，这个一定程度上解决了第二个问题。
+ 可以生成代码，这个用处不大，但是也是可以参考的。

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
