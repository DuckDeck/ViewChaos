//
//  ViewController.swift
//  ViewChaosDemo
//
//  Created by Tyrant on 11/5/15.
//  Copyright © 2015 Qfq. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var btn:UIButton?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "ViewChaos"
        view.backgroundColor = UIColor.whiteColor()
        btn = UIButton(frame: CGRect(x: 10, y: 100, width: 100, height: 30))
        btn?.backgroundColor = UIColor.redColor()
        btn?.setTitle("Next", forState: UIControlState.Normal)
        btn?.name = "btn"
        btn?.addTarget(self, action: "click:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(btn!)
    }

    
    func click(sender:UIButton)
    {
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let next = story.instantiateViewControllerWithIdentifier("next")
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

