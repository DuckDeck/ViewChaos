# ViewChaos
A iOS view diagnose tool
ViewChaos is a powerful iOS UI development tool, It can help you locatie the view, find the superView and subView. check the constrains, and trace the view which you want to observer. and the most magically thing is that it can change the view's frame. backgroung&title color, resize the font. change the border color,width and cornerradius. at last. it can generate the code,  you can just copy the ajusted view's code. and parse to the Xcode.  it's very powerful. and every iOS developer should use this tool!

Key Features
No code.
Debug mode. realease version this tool will not work
check view's frame, subViews, superViews,
can see the view's constrains
trace the view
change the view

Requirements 

Xcode 8.0 iOS 7.1

Installation
pod 'ViewChaos' or copy the three files(ViewChaos.swift,ViewChaosInfo.swift,ViewNeat.swift) to your project
Target->build setting-> search swift compile ->add -DDEBUG (it only work in debug mode)
Make sure you are not using the main stroyboard as the start up interface, you must use code to add viewcontroller. and call the makekeyvsible funtion
after the three steps, it's done.





